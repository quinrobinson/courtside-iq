-- G1.11 — derive the aggregates from events, and a view that compares the two.
--
-- player_game_stats STAYS AUTHORITATIVE. Nothing reads these views as a source
-- of truth yet. They exist so the G1.12 parallel run can ask one question on
-- real games: does the sum of the taps equal the total we stored? Only when
-- that holds across a meaningful sample does the read path move (G1.14) and
-- the aggregate columns get deprecated.
--
-- Events must never become a second source of truth running alongside the
-- first. Either the parallel run closes or this table is a liability.
--
-- ROLLUPS COUNT CONFIRMED, UNMERGED ROWS ONLY.
--   voided    a correction - the parent took the tap back
--   suggested video-derived and not yet confirmed by a human
--   dismissed video-derived and rejected
--   merged    a video row absorbed into the parent tap it matched
-- Each is excluded for a different reason, and all four exclusions are the
-- same `where` clause. Anything that aggregates stat_events anywhere else in
-- this codebase must use the same filter or it will disagree with this view.
--
-- SECURITY INVOKER ON BOTH VIEWS, NOT OPTIONAL. A Postgres view runs as its
-- OWNER unless marked otherwise, which bypasses RLS on the underlying tables
-- completely. On 2026-07-29 player_profile_view and v_player_game_stats were
-- found without it on prod: anyone holding the anon key could read 255 player
-- rows across 165 families. Adding policies to a view does NOT fix that; only
-- this does.

create or replace view public.v_stat_event_rollup
with (security_invoker = on) as
select
  e.game_id,
  e.player_id,

  -- Shooting. Attempts are made plus missed, never stored separately, because
  -- a stored attempt count can disagree with the shots that produced it.
  count(*) filter (where e.event_type = 'two_made')::int          as two_made,
  count(*) filter (where e.event_type in ('two_made', 'two_missed'))::int
                                                                  as two_attempt,
  count(*) filter (where e.event_type = 'three_made')::int        as three_made,
  count(*) filter (where e.event_type in ('three_made', 'three_missed'))::int
                                                                  as three_attempt,
  count(*) filter (where e.event_type = 'ft_made')::int           as ft_made,
  count(*) filter (where e.event_type in ('ft_made', 'ft_missed'))::int
                                                                  as ft_attempt,

  -- FIELD GOALS ARE TWOS AND THREES. Free throws are not field goals - the
  -- convention every box score uses, and getting it wrong would quietly change
  -- every shooting percentage in the app.
  count(*) filter (where e.event_type in ('two_made', 'three_made'))::int
                                                                  as fg_made,
  count(*) filter (where e.event_type in
                   ('two_made', 'two_missed', 'three_made', 'three_missed'))::int
                                                                  as fg_attempt,

  -- Points are DERIVED here exactly as live_game.dart derives them on device.
  -- Two implementations of one rule, which is precisely what the parallel run
  -- is checking.
  (count(*) filter (where e.event_type = 'two_made') * 2
   + count(*) filter (where e.event_type = 'three_made') * 3
   + count(*) filter (where e.event_type = 'ft_made'))::int       as points,

  count(*) filter (where e.event_type = 'off_reb')::int           as off_reb,
  count(*) filter (where e.event_type = 'def_reb')::int           as def_reb,
  count(*) filter (where e.event_type = 'assist')::int            as assist,
  count(*) filter (where e.event_type = 'steal')::int             as steal,
  count(*) filter (where e.event_type = 'block')::int             as block,
  count(*) filter (where e.event_type = 'turnover')::int          as turnover,

  -- Always zero in practice: the tracker has no foul control. Present so the
  -- view does not need changing if one ships.
  count(*) filter (where e.event_type = 'off_foul')::int          as off_foul,
  count(*) filter (where e.event_type = 'def_foul')::int          as def_foul,

  -- What the timeline header calls "N plays". Confirmed only, so a corrected
  -- tap does not inflate it.
  count(*)::int                                                   as plays,
  max(e.sequence_no)::int                                         as last_sequence_no
from public.stat_events e
where e.status = 'confirmed'
  and e.merged_into is null
group by e.game_id, e.player_id;

comment on view public.v_stat_event_rollup is
  'The 17 player_game_stats fields derived from stat_events. Confirmed, unmerged rows only. '
  'NOT the read path yet - player_game_stats stays authoritative until the G1.12 parallel run closes.';

-- The parallel run, as a query.
--
-- One row per game that HAS events, with the stored and derived values side by
-- side and an array naming every field that disagrees. Inner join on purpose:
-- a game with no events is a game logged before this shipped, not a mismatch.
create or replace view public.v_stat_event_reconciliation
with (security_invoker = on) as
select
  s.game_id,
  s.player_id,
  r.plays,

  array_remove(array[
    case when coalesce(s.points,        0) <> r.points        then 'points'        end,
    case when coalesce(s.fg_made,       0) <> r.fg_made       then 'fg_made'       end,
    case when coalesce(s.fg_attempt,    0) <> r.fg_attempt    then 'fg_attempt'    end,
    case when coalesce(s.two_made,      0) <> r.two_made      then 'two_made'      end,
    case when coalesce(s.two_attempt,   0) <> r.two_attempt   then 'two_attempt'   end,
    case when coalesce(s.three_made,    0) <> r.three_made    then 'three_made'    end,
    case when coalesce(s.three_attempt, 0) <> r.three_attempt then 'three_attempt' end,
    case when coalesce(s.ft_made,       0) <> r.ft_made       then 'ft_made'       end,
    case when coalesce(s.ft_attempt,    0) <> r.ft_attempt    then 'ft_attempt'    end,
    case when coalesce(s.off_reb,       0) <> r.off_reb       then 'off_reb'       end,
    case when coalesce(s.def_reb,       0) <> r.def_reb       then 'def_reb'       end,
    case when coalesce(s.assist,        0) <> r.assist        then 'assist'        end,
    case when coalesce(s.steal,         0) <> r.steal         then 'steal'         end,
    case when coalesce(s.block,         0) <> r.block         then 'block'         end,
    case when coalesce(s.turnover,      0) <> r.turnover      then 'turnover'      end,
    case when coalesce(s.off_foul,      0) <> r.off_foul      then 'off_foul'      end,
    case when coalesce(s.def_foul,      0) <> r.def_foul      then 'def_foul'      end
  ], null) as mismatched,

  -- Stored beside derived for the fields most likely to drift, so a
  -- disagreement can be read without a second query.
  coalesce(s.points, 0) as stored_points,  r.points  as derived_points,
  coalesce(s.fg_made, 0) as stored_fg_made, r.fg_made as derived_fg_made,
  coalesce(s.fg_attempt, 0) as stored_fg_attempt, r.fg_attempt as derived_fg_attempt
from public.player_game_stats s
join public.v_stat_event_rollup r
  on r.game_id = s.game_id
 and r.player_id = s.player_id;

comment on view public.v_stat_event_reconciliation is
  'G1.12 parallel run. One row per game that has events; `mismatched` is empty when '
  'the derived totals equal the stored ones. Games without events are excluded, not failed.';

revoke all on public.v_stat_event_rollup from anon;
revoke all on public.v_stat_event_reconciliation from anon;
grant select on public.v_stat_event_rollup to authenticated;
grant select on public.v_stat_event_reconciliation to authenticated;
