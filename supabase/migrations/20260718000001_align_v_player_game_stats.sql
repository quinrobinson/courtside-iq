-- Align v_player_game_stats between environments.
--
-- Test drifted during the Phase 0/1 jsonb work: its view exposed the raw jsonb
-- as `game_insights` and dropped `game_insights_json` entirely. Prod exposes the
-- insight twice - the extracted text under the legacy name (so the shipped v1
-- app keeps working) and the full object as game_insights_json.
--
-- Symptom of the drift: the v1.4.0 Games tab threw "column does not exist" when
-- run against test. Prod was never affected; this migration is a no-op there.

drop view if exists public.v_player_game_stats;

create view public.v_player_game_stats as
select
  p.id  as player_id,
  p.first_name,
  p.last_name,
  p.player_profile_pic,
  u.id  as user_id,
  g.id  as game_id,
  g.created_at,
  g.opponent_team,
  g.player_team_name,
  g.event_name,
  g.event_type,
  s.points,
  s.fg_made,
  s.fg_attempt,
  s.two_made,
  s.two_attempt,
  s.three_made,
  s.three_attempt,
  s.ft_made,
  s.ft_attempt,
  s.off_reb,
  s.def_reb,
  s.assist,
  s.steal,
  s.turnover,
  s.block,
  s.off_foul,
  s.def_foul,
  s.game_insights ->> 'text' as game_insights,
  s.game_insights            as game_insights_json
from player_game_stats s
  join players p on p.id = s.player_id
  join games   g on g.id = s.game_id
  left join users u on u.id = p.user_id;
