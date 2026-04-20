-- Phase 2.2: player_trend_snapshots
-- Rolling 5-game metrics, one immutable row per game save once player has >=5 games.

create table public.player_trend_snapshots (
  id                         uuid primary key default gen_random_uuid(),
  player_id                  uuid not null references public.players(id) on delete cascade,
  user_id                    uuid not null references auth.users(id) on delete cascade,
  as_of_game_id              uuid not null references public.games(id) on delete cascade,
  games_in_window            int  not null default 5,
  rolling_ppsa               numeric,
  rolling_ast_tov_ratio      numeric,
  rolling_assists_per_game   numeric,
  rolling_disrupt_score      numeric,
  rolling_points_per_game    numeric,
  ppsa_games_above_solid     int,
  ppsa_games_above_good      int,
  ppsa_games_above_elite     int,
  trend_direction_ppsa       text check (trend_direction_ppsa in ('improving','stable','declining')),
  created_at                 timestamptz not null default now(),
  unique (player_id, as_of_game_id)
);

create index player_trend_snapshots_player_created_idx
  on public.player_trend_snapshots (player_id, created_at desc);

alter table public.player_trend_snapshots enable row level security;

create policy "Users can read own trend snapshots"
  on public.player_trend_snapshots for select
  using (exists (
    select 1 from public.players p
    where p.id = player_trend_snapshots.player_id
      and p.user_id = (select auth.uid())
  ));

create policy "Users can insert own trend snapshots"
  on public.player_trend_snapshots for insert
  with check (exists (
    select 1 from public.players p
    where p.id = player_trend_snapshots.player_id
      and p.user_id = (select auth.uid())
  ));
