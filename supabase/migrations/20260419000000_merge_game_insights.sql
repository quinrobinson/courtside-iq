-- Phase 0.2 + 0.3: Add game_insights jsonb to player_game_stats,
-- migrate legacy text insights, rebuild v_player_game_stats, drop player_game_insights.

-- 1. Drop view before altering the column type it exposes.
DROP VIEW IF EXISTS v_player_game_stats;

-- 2. Add jsonb column to player_game_stats
ALTER TABLE player_game_stats
  ADD COLUMN IF NOT EXISTS game_insights jsonb;

-- 3. Migrate legacy text insights, wrapping in structured jsonb.
--    DISTINCT ON handles any duplicate (game_id, player_id) rows — keeps most recent.
UPDATE player_game_stats pgs
SET game_insights = jsonb_build_object(
  'version',          1,
  'model',            'legacy',
  'text',             latest.game_insights,
  'highlight_metric', null,
  'tier_context',     null,
  'prompt_version',   'v0',
  'generated_at',     latest.created_at
)
FROM (
  SELECT DISTINCT ON (game_id, player_id)
    game_id,
    player_id,
    game_insights,
    created_at
  FROM player_game_insights
  WHERE game_insights IS NOT NULL
  ORDER BY game_id, player_id, created_at DESC
) latest
WHERE pgs.game_id = latest.game_id
  AND pgs.player_id = latest.player_id;

-- 4. Recreate v_player_game_stats reading game_insights from player_game_stats directly.
CREATE VIEW v_player_game_stats AS
SELECT
  p.id                  AS player_id,
  p.first_name,
  p.last_name,
  p.player_profile_pic,
  u.id                  AS user_id,
  g.id                  AS game_id,
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
  s.game_insights
FROM player_game_stats s
JOIN players p ON p.id = s.player_id
JOIN games g ON g.id = s.game_id
LEFT JOIN users u ON u.id = p.user_id;

-- 5. Drop player_game_insights (FK constraints dropped automatically with the table).
DROP TABLE player_game_insights;
