-- Remove the advisory-lock helpers.
--
-- They were added to stop duplicate player-insight generations, but are unsafe
-- in this architecture: Edge Functions reach Postgres through PostgREST on
-- pooled connections, so a session-level advisory lock can be acquired on one
-- connection and "released" on another, leaking the lock. A leaked lock would
-- make every later request for that player wait ~7s before generating anyway.
--
-- Replaced by a claim-row approach in generate-player-insight, which uses the
-- existing unique constraint on (player_id, generated_at_game_id) and needs no
-- connection affinity.

drop function if exists public.try_insight_lock(text);
drop function if exists public.release_insight_lock(text);
