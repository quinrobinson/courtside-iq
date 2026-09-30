-- Phase 4.4b: enforce the free-tier player limit server-side.
--
-- The limit was UI-only: the Add Player button is hidden for a free user who
-- already has one player. That is a suggestion, not a rule - anything talking
-- to the API directly ignored it.
--
-- Audited against prod before writing this (docs/entitlement-audit-findings.md):
-- of 165 users with players, 36 exceed the limit, but only ONE is entitled -
-- and that user passes is_premium(), so the blast radius on paying customers is
-- ZERO. The other 35 keep every player they have.

-- Count a user's players without recursing through the players RLS policy.
-- A policy on public.players that subqueries public.players would re-enter its
-- own predicate; SECURITY DEFINER sidesteps that.
create or replace function public.player_count(uid uuid)
returns int
language sql
stable
security definer
set search_path = public, pg_catalog
as $$
  select count(*)::int from public.players where user_id = uid;
$$;

grant execute on function public.player_count(uuid) to authenticated, service_role;

-- The free allowance. One player, matching what the UI already enforces.
-- There is deliberately NO game limit: none exists in the client, and adding
-- one would be a new product decision rather than an implementation of an
-- existing rule. (The roadmap's "1 player / 3 games" was wrong on games.)
create or replace function public.free_player_limit()
returns int
language sql
immutable
as $$ select 1; $$;

grant execute on function public.free_player_limit() to authenticated, service_role;

-- INSERT ONLY. SELECT, UPDATE and DELETE are untouched, so existing over-limit
-- users keep full access to everything they created. Hiding data a parent
-- already entered would be a far worse outcome than a missed upsell.
drop policy if exists "Users can create own players" on public.players;

create policy "Users can create own players"
  on public.players for insert
  with check (
    (select auth.uid()) = user_id
    and (
      public.is_premium((select auth.uid()))
      or public.player_count((select auth.uid())) < public.free_player_limit()
    )
  );

comment on function public.player_count(uuid) is
  'Player count bypassing RLS, for use inside the players INSERT policy.';
comment on function public.free_player_limit() is
  'Free-tier player allowance. Premium is unlimited via is_premium().';
