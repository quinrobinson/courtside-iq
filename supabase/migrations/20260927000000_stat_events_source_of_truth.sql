-- G1.14 — stat_events become the source of truth; player_game_stats becomes a
-- cache the database maintains.
--
-- WHY NOT "THE VIEW BECOMES THE READ PATH". Almost every game ever logged has
-- no events (every game before G1.10, and every game from an app version that
-- does not write them). Reading stats from v_stat_event_rollup would blank
-- them. So the 17 columns stay, keep their meaning, and every reader (both
-- views, the trend-snapshot trigger, both insight functions, the app) keeps
-- working unchanged. What changes is who is allowed to decide their values.
--
-- THE RULE: for a (game, player) that has ANY stat_events row, the 17 fields
-- in player_game_stats are whatever v_stat_event_rollup says, full stop. The
-- client's totals are overwritten on every write. For a (game, player) with no
-- events, nothing here fires and the client's totals stand, which is exactly
-- how every existing game and every older app version keeps working.
--
-- Events must never become a second source of truth running alongside the
-- first (event-model-spec). After this migration they are the only one for any
-- game that has them, and drift is impossible rather than merely detected.
--
-- THE DERIVATION IS NOT RE-IMPLEMENTED HERE. v_stat_event_rollup holds the one
-- definition (confirmed, unmerged rows; fg = twos + threes; points derived).
-- Everything below reads it, so there is still exactly one place the rule
-- lives.
--
-- G1.12 closed 2026-09-27 on TEST: five games, 65 rows, zero mismatches.


-- 1. Every write to a stats row that has events gets the derived totals.
--
-- BEFORE INSERT OR UPDATE, so it covers the first upload, an upsert retry that
-- would otherwise put the client's totals back, and any direct write.
--
-- "Has events" means any row at all, not any CONFIRMED row. A game whose every
-- tap was taken back has events and has zero totals; the rollup view returns
-- no row for it, hence the coalesces.
create or replace function public.pgs_derive_from_events()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  r public.v_stat_event_rollup%rowtype;
begin
  if not exists (
    select 1 from public.stat_events e
     where e.game_id = new.game_id
       and e.player_id = new.player_id
  ) then
    return new;
  end if;

  select * into r
    from public.v_stat_event_rollup v
   where v.game_id = new.game_id
     and v.player_id = new.player_id;

  new.points        := coalesce(r.points, 0);
  new.fg_made       := coalesce(r.fg_made, 0);
  new.fg_attempt    := coalesce(r.fg_attempt, 0);
  new.two_made      := coalesce(r.two_made, 0);
  new.two_attempt   := coalesce(r.two_attempt, 0);
  new.three_made    := coalesce(r.three_made, 0);
  new.three_attempt := coalesce(r.three_attempt, 0);
  new.ft_made       := coalesce(r.ft_made, 0);
  new.ft_attempt    := coalesce(r.ft_attempt, 0);
  new.off_reb       := coalesce(r.off_reb, 0);
  new.def_reb       := coalesce(r.def_reb, 0);
  new.assist        := coalesce(r.assist, 0);
  new.steal         := coalesce(r.steal, 0);
  new.block         := coalesce(r.block, 0);
  new.turnover      := coalesce(r.turnover, 0);
  new.off_foul      := coalesce(r.off_foul, 0);
  new.def_foul      := coalesce(r.def_foul, 0);
  return new;
end;
$$;

drop trigger if exists pgs_derive_from_events_trg on public.player_game_stats;
create trigger pgs_derive_from_events_trg
  before insert or update on public.player_game_stats
  for each row execute function public.pgs_derive_from_events();


-- 2. When events change, re-derive the stats rows they belong to.
--
-- The client uploads events BEFORE the stats row, so on a normal save this
-- touches nothing and trigger 1 does the work on insert. It matters when
-- events land or change after the stats row exists: a retry, a correction, and
-- later a video-derived event being confirmed or merged.
--
-- The update is a deliberate no-op assignment. It exists to route the row
-- through trigger 1, which is the only code that knows the derivation.
--
-- STATEMENT-LEVEL with transition tables, so a 32-play upload re-derives each
-- stats row once, not 32 times. Postgres allows transition tables on
-- single-event triggers only, hence three triggers sharing one function.
create or replace function public.stat_events_rederive_stats()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update public.player_game_stats s set points = s.points
      from (select distinct game_id, player_id from new_rows) t
     where s.game_id = t.game_id and s.player_id = t.player_id;
  elsif tg_op = 'UPDATE' then
    update public.player_game_stats s set points = s.points
      from (select game_id, player_id from new_rows
            union
            select game_id, player_id from old_rows) t
     where s.game_id = t.game_id and s.player_id = t.player_id;
  else
    update public.player_game_stats s set points = s.points
      from (select distinct game_id, player_id from old_rows) t
     where s.game_id = t.game_id and s.player_id = t.player_id;
  end if;
  return null;
end;
$$;

drop trigger if exists stat_events_rederive_ins on public.stat_events;
drop trigger if exists stat_events_rederive_upd on public.stat_events;
drop trigger if exists stat_events_rederive_del on public.stat_events;

create trigger stat_events_rederive_ins
  after insert on public.stat_events
  referencing new table as new_rows
  for each statement execute function public.stat_events_rederive_stats();

create trigger stat_events_rederive_upd
  after update on public.stat_events
  referencing old table as old_rows new table as new_rows
  for each statement execute function public.stat_events_rederive_stats();

create trigger stat_events_rederive_del
  after delete on public.stat_events
  referencing old table as old_rows
  for each statement execute function public.stat_events_rederive_stats();


-- 3. When a game's totals actually change after insert, refresh its snapshot.
--
-- player_game_stats_snapshot_trg computes the rolling snapshot on INSERT only,
-- and compute_trend_snapshot inserts ON CONFLICT DO NOTHING - so a total
-- corrected later would leave a snapshot built from the old numbers forever.
--
-- Only when a stat field really changed: the no-op updates from trigger 2 on a
-- normal save change nothing and must not churn snapshots.
--
-- SECURITY DEFINER because the parent's role cannot delete snapshot rows; the
-- function returns `trigger`, so it cannot be called through the API.
--
-- KNOWN LIMIT: trend_direction_ppsa compares against the latest snapshot by
-- created_at. Recomputing the NEWEST game's snapshot (the only realistic case:
-- a retry or a correction moments after the save) gives the right direction.
-- Recomputing an older game's would compare against a later one. Accepted:
-- rare, and direction is a coarse label that the next game overwrites.
create or replace function public.pgs_refresh_snapshot_on_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (old.points, old.fg_made, old.fg_attempt, old.two_made, old.two_attempt,
      old.three_made, old.three_attempt, old.ft_made, old.ft_attempt,
      old.off_reb, old.def_reb, old.assist, old.steal, old.block,
      old.turnover, old.off_foul, old.def_foul)
     is not distinct from
     (new.points, new.fg_made, new.fg_attempt, new.two_made, new.two_attempt,
      new.three_made, new.three_attempt, new.ft_made, new.ft_attempt,
      new.off_reb, new.def_reb, new.assist, new.steal, new.block,
      new.turnover, new.off_foul, new.def_foul)
  then
    return null;
  end if;

  delete from public.player_trend_snapshots
   where player_id = new.player_id
     and as_of_game_id = new.game_id;
  perform public.compute_trend_snapshot(new.player_id, new.game_id);
  return null;
end;
$$;

revoke all on function public.pgs_refresh_snapshot_on_change() from public, anon, authenticated;

drop trigger if exists pgs_refresh_snapshot_trg on public.player_game_stats;
create trigger pgs_refresh_snapshot_trg
  after update on public.player_game_stats
  for each row execute function public.pgs_refresh_snapshot_on_change();


-- 4. Bring existing rows under the rule. On TEST at G1.12 close every game
-- with events already reconciled, so this changes nothing; it is here so the
-- rule holds for every row from the moment this lands, on any database.
update public.player_game_stats s set points = s.points
 where exists (select 1 from public.stat_events e
                where e.game_id = s.game_id and e.player_id = s.player_id);


comment on view public.v_stat_event_rollup is
  'The 17 player_game_stats fields derived from stat_events. Confirmed, unmerged rows only. '
  'SOURCE OF TRUTH since G1.14: for any (game, player) with events, triggers copy these '
  'values into player_game_stats on every write.';

comment on view public.v_stat_event_reconciliation is
  'Should be empty-mismatched by construction since G1.14. A non-empty row now means a '
  'trigger was dropped or bypassed, not that a tap and a total disagreed.';
