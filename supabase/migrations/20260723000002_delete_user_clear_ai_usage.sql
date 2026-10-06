-- Self-service account deletion, fixed — Phase 4.15d
--
-- delete_current_user (20260723000001) failed on test with:
--
--   ERROR: insert or update on table "ai_usage" violates foreign key
--   constraint "ai_usage_game_id_fkey"
--
-- ai_usage references games, players AND users, all ON DELETE SET NULL, so
-- the intent was for a deleted account's usage rows to SURVIVE with every
-- reference nulled - kept as anonymous cost telemetry.
--
-- That intent is what broke it. During the account cascade, games and players
-- are deleted, and each SET NULL on ai_usage re-validates the WHOLE row. By
-- the time the player_id SET NULL runs, the game the row also pointed at has
-- already been deleted earlier in the same cascade, so the row fails its own
-- game_id check. A row touched by SET NULL down two branches of one cascade
-- cannot always be re-validated mid-flight.
--
-- Since the account is being deleted outright, those rows do not need to
-- survive. Deleting this user's ai_usage FIRST removes them before the
-- cascade can trip on them. Verified in a rolled-back transaction on test:
-- clear ai_usage, then delete the user, cascades with no error.
--
-- The SET NULL rules are LEFT ALONE. They are still correct for a normal
-- single-game or single-player delete, where keeping the spend record is the
-- point. This only changes what a full ACCOUNT deletion does.

create or replace function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  uid uuid := auth.uid();
  em text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  -- Keep the note, drop the personal half (approved 2026-07-23).
  select email into em from auth.users where id = uid;
  if em is not null then
    update public.feedback set email = null where email = em;
  end if;

  -- Clear this account's usage rows BEFORE the cascade, by every path that
  -- ties one to the account. Leaving them is what caused the game_id
  -- re-validation failure above.
  delete from public.ai_usage
  where user_id = uid
     or player_id in (select id from public.players where user_id = uid)
     or game_id in (select g.id from public.games g
                    join public.players p on p.id = g.player_id
                    where p.user_id = uid);

  -- One delete. Players, games, stats, insights, snapshots, teams and the
  -- subscription follow by cascade, as do auth.sessions and auth.identities.
  delete from auth.users where id = uid;
end;
$$;

revoke all on function public.delete_current_user() from public, anon;
grant execute on function public.delete_current_user() to authenticated;
