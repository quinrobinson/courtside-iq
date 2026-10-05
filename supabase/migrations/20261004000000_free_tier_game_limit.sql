-- Roadmap 3.8: enforce the free-tier GAME limit server-side (1 player + 3 games).
--
-- 20260719000001 added the player limit and deliberately no game limit, on the
-- reading that the roadmap's "1 player / 3 games" was wrong on games. It was
-- not: the limit was advertised (Play listing) and prod data shows a wall at
-- three games (free accounts with 3 games: 12, with 4 games: 0). Quin confirmed
-- the rule on 2026-10-04.
--
-- Audited against prod before writing this (read-only, 2026-10-04): 159 free
-- accounts, 8 already above 3 games. They keep every game they have; they meet
-- the limit on their next NEW game. All 7 premium accounts pass is_premium(),
-- so paying customers are unaffected.

-- Count a user's games without recursing through the games RLS policy (same
-- reason as player_count: a games policy that subqueries games re-enters itself).
-- games.user_id is TEXT, so compare against the uuid as text.
create or replace function public.game_count(uid uuid)
returns int
language sql
stable
security definer
set search_path = public, pg_catalog
as $$
  select count(*)::int from public.games where user_id = uid::text;
$$;

grant execute on function public.game_count(uuid) to authenticated, service_role;

-- Whether a game id already belongs to the CALLER. Needed because the client
-- saves with upsert (INSERT ... ON CONFLICT DO UPDATE), and Postgres checks the
-- INSERT policy's WITH CHECK against the proposed row even when the statement
-- ends up updating. Without this, a free parent at 3 games could not retry or
-- re-save their own third game. Scoped to the caller's games so it cannot be
-- used to probe other families' ids.
create or replace function public.owns_game(gid uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_catalog
as $$
  select exists (
    select 1 from public.games
    where id = gid and user_id = (select auth.uid())::text
  );
$$;

grant execute on function public.owns_game(uuid) to authenticated, service_role;

-- The free allowance. Mirrors kFreeGameLimit in lib/courtside_iq/player_gating.dart.
create or replace function public.free_game_limit()
returns int
language sql
immutable
as $$ select 3; $$;

grant execute on function public.free_game_limit() to authenticated, service_role;

-- INSERT ONLY. SELECT, UPDATE and DELETE are untouched, so over-limit accounts
-- keep full access to every game they already have.
drop policy if exists "Users can create own games" on public.games;

create policy "Users can create own games"
  on public.games for insert
  with check (
    ((select auth.uid()))::text = user_id
    and (
      public.is_premium((select auth.uid()))
      or public.game_count((select auth.uid())) < public.free_game_limit()
      or public.owns_game(id)
    )
  );

comment on function public.game_count(uuid) is
  'Game count bypassing RLS, for use inside the games INSERT policy.';
comment on function public.owns_game(uuid) is
  'True when the caller already owns this game id; lets an upsert of an existing game pass the INSERT policy.';
comment on function public.free_game_limit() is
  'Free-tier game allowance (3). Premium is unlimited via is_premium().';
