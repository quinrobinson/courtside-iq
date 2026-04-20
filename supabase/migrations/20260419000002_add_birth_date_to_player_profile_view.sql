-- Phase 1.3: Expose birth_date and computed age_band on player_profile_view
-- so the profile page can render the age-band badge in the header without a
-- second fetch against the players table.
--
-- Columns are appended at the end because Postgres CREATE OR REPLACE VIEW
-- cannot reorder or rename existing columns.

CREATE OR REPLACE VIEW public.player_profile_view AS
SELECT
  u.id AS user_id,
  p.id AS player_id,
  p.first_name AS player_first_name,
  p.last_name AS player_last_name,
  p.player_position,
  p.team_name,
  p.player_profile_pic,
  COALESCE(sum(pgs.points), 0::bigint) AS total_points,
  COALESCE(sum(pgs.fg_made), 0::bigint) AS total_fg_made,
  COALESCE(sum(pgs.fg_attempt), 0::bigint) AS total_fg_attempt,
  COALESCE(sum(pgs.two_made), 0::bigint) AS total_two_made,
  COALESCE(sum(pgs.two_attempt), 0::bigint) AS total_two_attempt,
  COALESCE(sum(pgs.three_made), 0::bigint) AS total_three_made,
  COALESCE(sum(pgs.three_attempt), 0::bigint) AS total_three_attempt,
  COALESCE(sum(pgs.ft_made), 0::bigint) AS total_ft_made,
  COALESCE(sum(pgs.ft_attempt), 0::bigint) AS total_ft_attempt,
  COALESCE(sum(pgs.off_reb), 0::bigint) AS total_off_reb,
  COALESCE(sum(pgs.def_reb), 0::bigint) AS total_def_reb,
  COALESCE(sum(pgs.assist), 0::bigint) AS total_assist,
  COALESCE(sum(pgs.steal), 0::bigint) AS total_steal,
  COALESCE(sum(pgs.turnover), 0::bigint) AS total_turnover,
  COALESCE(sum(pgs.block), 0::bigint) AS total_block,
  COALESCE(sum(pgs.off_foul), 0::bigint) AS total_off_foul,
  COALESCE(sum(pgs.def_foul), 0::bigint) AS total_def_foul,
  count(DISTINCT pgs.game_id) AS total_games,
  p.birth_date,
  get_age_band(p.birth_date) AS age_band
FROM users u
  JOIN players p ON u.id = p.user_id
  LEFT JOIN player_game_stats pgs ON p.id = pgs.player_id
GROUP BY u.id, p.id, p.first_name, p.last_name, p.player_position,
         p.team_name, p.player_profile_pic, p.birth_date;
