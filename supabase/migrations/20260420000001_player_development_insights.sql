-- Phase 2.1: player_development_insights
-- Player-level narrative cache, keyed by (player_id, latest game at generation time).

create table public.player_development_insights (
  id                      uuid primary key default gen_random_uuid(),
  player_id               uuid not null references public.players(id) on delete cascade,
  user_id                 uuid not null references auth.users(id) on delete cascade,
  generated_at_game_id    uuid not null references public.games(id) on delete cascade,
  games_included_count    int  not null,
  insight_json            jsonb not null,
  model                   text not null,
  prompt_version          text not null,
  created_at              timestamptz not null default now(),
  unique (player_id, generated_at_game_id)
);

create index player_development_insights_player_created_idx
  on public.player_development_insights (player_id, created_at desc);

alter table public.player_development_insights enable row level security;

create policy "Users can read own player insights"
  on public.player_development_insights for select
  using (exists (
    select 1 from public.players p
    where p.id = player_development_insights.player_id
      and p.user_id = (select auth.uid())
  ));

create policy "Users can insert own player insights"
  on public.player_development_insights for insert
  with check (exists (
    select 1 from public.players p
    where p.id = player_development_insights.player_id
      and p.user_id = (select auth.uid())
  ));

create policy "Users can update own player insights"
  on public.player_development_insights for update
  using (exists (
    select 1 from public.players p
    where p.id = player_development_insights.player_id
      and p.user_id = (select auth.uid())
  ))
  with check (exists (
    select 1 from public.players p
    where p.id = player_development_insights.player_id
      and p.user_id = (select auth.uid())
  ));
