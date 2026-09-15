-- G1.7 — games.started_at / ended_at.
--
-- stat_events.elapsed_ms is an offset from the moment tracking began, so there
-- has to be a moment to offset from. games carries created_at and game_live
-- and nothing else temporal, which the design inventory flagged
-- (docs/design-inventory.md, section 5).
--
-- WHY created_at IS NOT ENOUGH. created_at is when the ROW WAS WRITTEN, which
-- for a game queued offline in a gym is whenever the queue later flushed -
-- possibly days afterwards. started_at is when the parent actually began
-- tracking.
--
-- BOTH NULLABLE, NO DEFAULT, NO BACKFILL. Every one of the 397 existing games
-- predates this column and there is no honest value to give them. Inventing
-- one from created_at would put a start time on games that were logged after
-- the fact, and anything reading elapsed_ms would then trust it. Null means
-- unknown and must keep meaning unknown.
--
-- THIS IS STILL NOT A CLOCK. Pause is a safety lock that stops stray taps
-- while the player is off the floor; it is not a timer, and minutes played are
-- not tracked. The window between these two columns is SESSION time, not game
-- time. It contains halftime, timeouts, bench time, and whatever happened
-- before tracking started.

alter table public.games
  add column if not exists started_at timestamptz,
  add column if not exists ended_at   timestamptz;

comment on column public.games.started_at is
  'When tracking began, not when the row was written. Null on every game logged '
  'before 2026-09-15 and on any game where it was not captured. Null means unknown.';
comment on column public.games.ended_at is
  'When tracking ended. The span to started_at is SESSION time, not game time: it '
  'includes halftime, timeouts and bench time. There is no game clock.';
