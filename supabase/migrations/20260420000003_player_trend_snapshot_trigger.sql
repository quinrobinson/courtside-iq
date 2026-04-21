-- Phase 2.2: snapshot population trigger
-- Computes rolling 5-game snapshot on every player_game_stats insert.
-- KEEP PPSA THRESHOLDS IN SYNC WITH:
--   lib/courtside_iq/metrics_config.dart
--   supabase/functions/_shared/metrics_config.ts

create or replace function public.compute_trend_snapshot(
  p_player_id uuid,
  p_as_of_game_id uuid
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id         uuid;
  v_as_of_created   timestamptz;
  v_games_count     int;
  v_rolling_ppsa    numeric;
  v_rolling_astov   numeric;
  v_rolling_apg     numeric;
  v_rolling_disrupt numeric;
  v_rolling_ppg     numeric;
  v_above_solid     int;
  v_above_good      int;
  v_above_elite     int;
  v_prior_ppsa      numeric;
  v_trend           text;
begin
  select p.user_id into v_user_id from public.players p where p.id = p_player_id;
  if v_user_id is null then return; end if;

  select g.created_at into v_as_of_created from public.games g where g.id = p_as_of_game_id;
  if v_as_of_created is null then return; end if;

  select count(*) into v_games_count
    from public.player_game_stats s
    join public.games g on g.id = s.game_id
   where s.player_id = p_player_id and g.created_at <= v_as_of_created;

  if v_games_count < 5 then return; end if;

  with last5 as (
    select s.*, g.created_at as game_created_at,
           coalesce(extract(year from age(g.created_at, p.birth_date))::int, 12) as age_years
      from public.player_game_stats s
      join public.games g on g.id = s.game_id
      join public.players p on p.id = s.player_id
     where s.player_id = p_player_id
       and g.created_at <= v_as_of_created
     order by g.created_at desc
     limit 5
  ),
  classed as (
    select
      coalesce(points,0) as pts,
      coalesce(fg_attempt,0) + coalesce(ft_attempt,0) as shots,
      case when coalesce(fg_attempt,0) + coalesce(ft_attempt,0) > 0
           then coalesce(points,0)::numeric / (coalesce(fg_attempt,0) + coalesce(ft_attempt,0))
           else null end as ppsa,
      coalesce(assist,0) as ast,
      coalesce(turnover,0) as tov,
      coalesce(steal,0)*1.5 + coalesce(block,0)*1.0
        + coalesce(off_reb,0)*2.0 + coalesce(def_reb,0)*0.5 as disrupt,
      case when age_years <= 10 then 0
           when age_years <= 13 then 1
           else 2 end as band_idx
    from last5
  )
  select
    avg(ppsa) filter (where shots >= 5),
    case when sum(tov) = 0 then null else sum(ast)::numeric / sum(tov) end,
    avg(ast), avg(disrupt), avg(pts),
    count(*) filter (where ppsa is not null and (
      (band_idx=0 and ppsa>=0.55) or (band_idx=1 and ppsa>=0.65) or (band_idx=2 and ppsa>=0.75))),
    count(*) filter (where ppsa is not null and (
      (band_idx=0 and ppsa>=0.80) or (band_idx=1 and ppsa>=0.90) or (band_idx=2 and ppsa>=1.00))),
    count(*) filter (where ppsa is not null and (
      (band_idx=0 and ppsa>=1.05) or (band_idx=1 and ppsa>=1.15) or (band_idx=2 and ppsa>=1.25)))
  into v_rolling_ppsa, v_rolling_astov, v_rolling_apg, v_rolling_disrupt, v_rolling_ppg,
       v_above_solid, v_above_good, v_above_elite
  from classed;

  select rolling_ppsa into v_prior_ppsa
    from public.player_trend_snapshots
   where player_id = p_player_id
   order by created_at desc
   limit 1;

  if v_prior_ppsa is null or v_rolling_ppsa is null then v_trend := 'stable';
  elsif v_rolling_ppsa - v_prior_ppsa >  0.05 then v_trend := 'improving';
  elsif v_rolling_ppsa - v_prior_ppsa < -0.05 then v_trend := 'declining';
  else v_trend := 'stable';
  end if;

  insert into public.player_trend_snapshots (
    player_id, user_id, as_of_game_id, games_in_window,
    rolling_ppsa, rolling_ast_tov_ratio, rolling_assists_per_game,
    rolling_disrupt_score, rolling_points_per_game,
    ppsa_games_above_solid, ppsa_games_above_good, ppsa_games_above_elite,
    trend_direction_ppsa
  ) values (
    p_player_id, v_user_id, p_as_of_game_id, 5,
    v_rolling_ppsa, v_rolling_astov, v_rolling_apg, v_rolling_disrupt, v_rolling_ppg,
    v_above_solid, v_above_good, v_above_elite, v_trend
  )
  on conflict (player_id, as_of_game_id) do nothing;
end;
$$;

create or replace function public.trg_pgs_compute_snapshot()
returns trigger language plpgsql as $$
begin
  perform public.compute_trend_snapshot(new.player_id, new.game_id);
  return new;
end;
$$;

drop trigger if exists player_game_stats_snapshot_trg on public.player_game_stats;
create trigger player_game_stats_snapshot_trg
  after insert on public.player_game_stats
  for each row execute function public.trg_pgs_compute_snapshot();
