-- G1.6 — stat_events: one row per observed play.
--
-- Spec: docs/event-model-spec.md. Plan: docs/video-and-events-plan.md.
--
-- WHY THIS EXISTS. player_game_stats holds TOTALS - 22 points, 7 rebounds -
-- and totals cannot say what order anything happened in. The approved game
-- timeline (Figma page "Gate 1 — Game Timeline (WIP)") shows plays in sequence,
-- so it needs the individual taps. This is where they go.
--
-- NAMING. `game_events` ALREADY EXISTS and means TOURNAMENTS - it is the
-- event_name / event_type record behind games.event_name. It has no game
-- reference and no stat column. This table is `stat_events`. In this codebase
-- *event* means tournament and *stat event* means a single observed play.
--
-- ADDITIVE ONLY. Nothing reads this table yet. player_game_stats stays
-- authoritative until the parallel run in G1.12 proves the derived view
-- agrees with it. Events must never become a second source of truth running
-- alongside the first.

create table if not exists public.stat_events (
  id            uuid primary key default gen_random_uuid(),

  game_id       uuid not null references public.games(id)   on delete cascade,
  player_id     uuid not null references public.players(id) on delete cascade,

  -- The 14 stat-bearing types, matching player_game_stats field names exactly.
  --
  -- off_foul and def_foul are included even though the tracker has no foul
  -- control today, so they are always absent in practice. They are LOGGED
  -- SEPARATELY and aggregated into a single foul total for display. Including
  -- them now costs nothing and avoids a migration if a foul control ships.
  --
  -- Video-only types with no stat equivalent (drive, catch, closeout) are NOT
  -- permitted yet. The spec allows them eventually, but they are speculative
  -- names and Gate 4 is gated on a feasibility spike that may fail outright.
  -- Adding them later is a one-line migration.
  event_type    text not null check (event_type in (
                  'two_made',   'two_missed',
                  'three_made', 'three_missed',
                  'ft_made',    'ft_missed',
                  'off_reb',    'def_reb',
                  'assist',     'steal',    'block',  'turnover',
                  'off_foul',   'def_foul'
                )),

  -- Monotonic within a game, and the ONLY trustworthy ordering. There is no
  -- game clock and there will not be one.
  --
  -- VOIDED ROWS KEEP THEIR sequence_no, so gaps here are normal and expected.
  -- The UI renumbers over confirmed rows only, which means the number a parent
  -- sees is a DISPLAY INDEX and is not this column. Never pass one where the
  -- other is expected.
  sequence_no   integer not null check (sequence_no > 0),

  -- Wall clock. What video syncs against, since a clip has a wall-clock start
  -- and no notion of game time.
  --
  -- A parent taps AFTER the possession ends, sometimes at the next dead ball,
  -- so this is accurate to roughly ten seconds. No screen should ever display
  -- a precise time for a tapped event.
  recorded_at   timestamptz not null default now(),

  -- Offset from games.started_at, stored for convenience. Session time, NOT
  -- game time: it includes halftime, timeouts and bench time. Coarse buckets
  -- only, never a displayed time.
  elapsed_ms    integer,

  source        text not null default 'parent_tap'
                  check (source in ('parent_tap', 'video_derived')),

  status        text not null default 'confirmed'
                  check (status in ('confirmed', 'suggested', 'dismissed', 'voided')),

  -- Null for parent_tap; 0..1 for video_derived. No confidence, however high,
  -- ever auto-promotes a suggestion to confirmed. That rule protects the
  -- ratings and should not be relaxed for convenience later.
  confidence    numeric check (confidence is null or (confidence >= 0 and confidence <= 1)),

  -- Open by design. Nothing in here affects a rating; it exists to make the
  -- development narrative specific. Parent taps will usually leave it empty.
  attributes    jsonb not null default '{}'::jsonb,

  -- { clip_id, start_offset_ms, end_offset_ms }
  clip_ref      jsonb,

  -- Set on a video row that has been absorbed into a matching parent tap. The
  -- tap remains the single countable event.
  merged_into   uuid references public.stat_events(id) on delete set null,

  created_at    timestamptz not null default now(),

  -- One play per slot per game. Voids keep their slot rather than freeing it.
  constraint stat_events_game_sequence_unique unique (game_id, sequence_no)
);

-- Cross-game player queries are the PRIMARY read, not the exception: the
-- player is the unit, not the game. Game-scoped rollups still matter for
-- reconciliation against player_game_stats, so both are indexed from the start.
create index if not exists stat_events_game_player_idx
  on public.stat_events (game_id, player_id);
create index if not exists stat_events_game_sequence_idx
  on public.stat_events (game_id, sequence_no);
create index if not exists stat_events_player_type_time_idx
  on public.stat_events (player_id, event_type, recorded_at);
create index if not exists stat_events_attributes_idx
  on public.stat_events using gin (attributes);

-- Every aggregate reads confirmed, unmerged rows only. Partial index so the
-- rollup view does not scan voids and suggestions.
create index if not exists stat_events_confirmed_idx
  on public.stat_events (game_id, event_type)
  where status = 'confirmed' and merged_into is null;

alter table public.stat_events enable row level security;

-- Ownership goes through games.user_id, mirroring player_game_stats exactly.
-- Note games.user_id is TEXT while players.user_id is UUID; this table is
-- game-scoped, so it follows the games side and casts.
--
-- FOUR SEPARATE POLICIES, NONE OF THEM `USING (true)`. A blanket policy is not
-- additive in PostgreSQL - permissive policies union with OR, so a `true`
-- policy becomes the ceiling and silently voids the strict one beside it. That
-- is exactly what leaked game_events on 2026-07-29.
create policy stat_events_select_own on public.stat_events
  for select using (
    exists (select 1 from public.games g
            where g.id = stat_events.game_id
              and g.user_id = (select auth.uid())::text)
  );

create policy stat_events_insert_own on public.stat_events
  for insert with check (
    exists (select 1 from public.games g
            where g.id = stat_events.game_id
              and g.user_id = (select auth.uid())::text)
  );

create policy stat_events_update_own on public.stat_events
  for update using (
    exists (select 1 from public.games g
            where g.id = stat_events.game_id
              and g.user_id = (select auth.uid())::text)
  );

create policy stat_events_delete_own on public.stat_events
  for delete using (
    exists (select 1 from public.games g
            where g.id = stat_events.game_id
              and g.user_id = (select auth.uid())::text)
  );

-- Defence in depth. RLS already blocks anon because no policy admits it, but
-- the anon key ships inside every copy of the app, so the grant goes too.
revoke all on public.stat_events from anon;
grant select, insert, update, delete on public.stat_events to authenticated;

comment on table public.stat_events is
  'One row per observed play. NOT game_events, which is the tournament record. '
  'Aggregates in player_game_stats stay authoritative until the G1.12 parallel run closes.';
comment on column public.stat_events.sequence_no is
  'Monotonic within a game. Voided rows keep their slot, so gaps are expected. '
  'The number shown to a parent is a display index over confirmed rows, not this.';
comment on column public.stat_events.elapsed_ms is
  'Session time from games.started_at, not game time. Includes halftime and bench time. '
  'Coarse buckets only; never display it as a time.';
