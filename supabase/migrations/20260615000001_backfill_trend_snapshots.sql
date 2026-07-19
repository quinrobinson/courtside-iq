-- Phase 2.2 fix: back-fill trend snapshots for games that predate the
-- player_game_stats snapshot trigger (added in 20260420000003).
--
-- The trigger only fires on INSERT, so games logged before it existed never
-- produced a player_trend_snapshots row. Players with 5+ such games hit
-- "snapshot_missing" (500) in generate-player-insight, surfacing as the
-- "loading error, try again" card on the Development tab.
--
-- This replays every existing game through the same compute_trend_snapshot()
-- function the trigger uses, in chronological order so the prior-snapshot
-- lookup (trend direction) resolves correctly. The function self-guards
-- (< 5 games returns early) and upserts with ON CONFLICT DO NOTHING, so this
-- is idempotent and safe to re-run.

do $$
declare
  r record;
begin
  for r in
    select s.player_id, s.game_id
      from public.player_game_stats s
      join public.games g on g.id = s.game_id
     order by g.created_at asc, s.player_id
  loop
    perform public.compute_trend_snapshot(r.player_id, r.game_id);
  end loop;
end $$;
