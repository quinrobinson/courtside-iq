-- Phase 4.1: ai_usage
-- Per-call Anthropic token telemetry, written by Edge Functions via the service role.
-- Purpose: turn AI cost from an estimate into a measured number (cost per user,
-- per game, per model) so model and throttle decisions are made from evidence.
--
-- This table is NOT user-facing. RLS is enabled with no policies, which means
-- only the service role can read or write it. The client can never see it.

create table public.ai_usage (
  id                          uuid primary key default gen_random_uuid(),

  -- What ran
  function_name               text not null,          -- 'generate-game-insight' | 'generate-player-insight'
  model                       text not null,          -- exact model id as sent to the API
  prompt_version              text,                   -- mirrors PROMPT_VERSION in the function

  -- What it cost (straight from the Anthropic response `usage` object)
  input_tokens                int  not null default 0,
  output_tokens               int  not null default 0,
  cache_creation_input_tokens int  not null default 0,
  cache_read_input_tokens     int  not null default 0,

  -- Who/what it was for. Nulled rather than cascaded on delete so that
  -- deleting a game or player does not erase the cost history for that month.
  user_id                     uuid references auth.users(id) on delete set null,
  player_id                   uuid references public.players(id) on delete set null,
  game_id                     uuid references public.games(id) on delete set null,

  -- Outcome, so failed/retried calls are visible rather than silently absent
  succeeded                   boolean not null default true,
  error_kind                  text,

  created_at                  timestamptz not null default now()
);

-- Cost rollups are almost always "spend over a time window", optionally per user.
create index ai_usage_created_idx
  on public.ai_usage (created_at desc);

create index ai_usage_user_created_idx
  on public.ai_usage (user_id, created_at desc);

create index ai_usage_model_created_idx
  on public.ai_usage (model, created_at desc);

-- Enabled with NO policies: service role only. Deliberate.
alter table public.ai_usage enable row level security;

comment on table public.ai_usage is
  'Anthropic token telemetry per Edge Function call. Service-role only; never exposed to the client.';
