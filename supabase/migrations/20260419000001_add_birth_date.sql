-- Phase 1.1: Add birth_date to players and create get_age_band helper function.
-- Only year + month are captured in the app; day is always stored as 01.

-- 1. Add nullable birth_date column to players.
ALTER TABLE players
  ADD COLUMN IF NOT EXISTS birth_date date;

-- 2. Create age band helper function.
--    NULL birth_date returns '11U-13U' (middle band fallback per Phase 1.4).
--    STABLE because result depends on CURRENT_DATE.
CREATE OR REPLACE FUNCTION get_age_band(birth_date date)
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT CASE
    WHEN birth_date IS NULL THEN '11U-13U'
    WHEN date_part('year', age(birth_date)) <= 10 THEN '8U-10U'
    WHEN date_part('year', age(birth_date)) <= 13 THEN '11U-13U'
    ELSE '14U-18U'
  END;
$$;
