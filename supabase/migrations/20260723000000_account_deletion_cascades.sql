-- Account deletion cascades — Phase 4.15d
--
-- THE ROOT OF THE TREE DID NOT REFERENCE auth.users.
--
-- Two tables already did - player_development_insights and
-- player_trend_snapshots, both CASCADE. users, players, games,
-- player_game_stats, subscriptions and ai_usage did not.
--
-- So deleting an auth user removed the login, cleaned up two leaf tables,
-- and left every player, game and stat behind permanently: reachable by no
-- account and owned by nobody. A parent who asked to be forgotten would have
-- had their child's entire game history still sitting on our servers.
--
-- Check with pg_constraint, not information_schema. The first pass here used
-- information_schema joins and reported zero references, missing both of the
-- two that existed.
--
-- The cascade chain inside public was always complete:
--
--   users -> players -> games -> player_game_stats
--                            -> player_development_insights
--                            -> player_trend_snapshots
--                    -> player_teams
--
-- It simply had nothing to trigger it. This makes deletion correct BY
-- CONSTRUCTION rather than by an Edge Function remembering the right order,
-- which is the part that rots.
--
-- WHY THE THREE RULES DIFFER:
--
--   users         CASCADE. It is the root of everything a parent owns.
--   subscriptions CASCADE. A subscription row for an account that no longer
--                 exists is not a record of anything, and is_premium() must
--                 stop answering for a deleted uid.
--   ai_usage      SET NULL. This is cost and telemetry, not personal data
--                 once the link is gone. Its player_id and game_id are
--                 already SET NULL for exactly this reason, and keeping the
--                 spend while dropping the person is the same principle the
--                 feedback table follows.
--
-- BEFORE PROMOTING THIS TO PROD, check for orphans:
--
--   select count(*) from public.users u
--   where not exists (select 1 from auth.users a where a.id = u.id);
--
-- Test had none. Prod has been live for months and may. A failure here is
-- the right outcome if so - it means rows exist that this would otherwise
-- silently make deletable.

-- ai_usage.user_id must be nullable to be SET NULL on delete.
alter table public.ai_usage alter column user_id drop not null;

alter table public.users
  drop constraint if exists users_id_fkey;
alter table public.users
  add constraint users_id_fkey
  foreign key (id) references auth.users (id) on delete cascade;

alter table public.subscriptions
  drop constraint if exists subscriptions_user_id_fkey;
alter table public.subscriptions
  add constraint subscriptions_user_id_fkey
  foreign key (user_id) references auth.users (id) on delete cascade;

alter table public.ai_usage
  drop constraint if exists ai_usage_user_id_fkey;
alter table public.ai_usage
  add constraint ai_usage_user_id_fkey
  foreign key (user_id) references auth.users (id) on delete set null;
