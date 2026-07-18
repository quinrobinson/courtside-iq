-- Reconcile two migrations that were applied to TEST but never committed.
--
-- Test's migration history contains two entries with no counterpart in this
-- directory, from an apply/revert/re-apply cycle during Phase 1:
--
--   20260420013854  revert_player_profile_view_age_band
--   20260420015110  add_birth_date_to_player_profile_view   (second apply)
--
-- VERIFIED 2026-07-18: after that cycle, player_profile_view is byte-identical
-- in test and prod (md5 of pg_get_viewdef matches: d3bc89f5cf68623c5c09187723e9e9cc).
-- All four public views now hash identically across both environments.
--
-- The net effect of revert + re-apply was therefore ZERO relative to the
-- committed 20260419000002_add_birth_date_to_player_profile_view. There is
-- nothing to replay, so this migration is intentionally a no-op: it exists to
-- close the gap in the written record, not to change any schema.
--
-- Left as documentation because a future reader comparing
-- `supabase migration list` against this directory would otherwise find two
-- unexplained entries and have to re-derive this from scratch.

do $$
begin
  -- Guard rather than assume: fail loudly if the view ever drifts from the
  -- shape this reconciliation was verified against.
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'player_profile_view'
      and column_name  = 'age_band'
  ) then
    raise exception
      'player_profile_view is missing age_band; expected it from 20260419000002. Investigate before proceeding.';
  end if;
end $$;
