-- PRIVACY FIX - drop two legacy Buildship database webhooks.
-- Found 2026-09-27. Applied to TEST, then PROD (approved), same day.
--
-- public.player_game_stats carried two AFTER INSERT FOR EACH ROW triggers,
-- created in the dashboard (never in a migration), that called
-- supabase_functions.http_request with a POST to Buildship:
--
--   https://nni3ua.buildship.run/executeWorkflow/60xkBoVuYH5tZ2grYTAa/f8fd67be-...
--   https://nni3ua.buildship.run/executeWorkflow/NZlXQJ3jFQdNbAMWyaE0/e8a29e5e-...
--
-- For a POST, http_request builds the body as
--   { record: NEW, old_record: OLD, type, table, schema }
-- so every game a parent saved sent the child's full stat row, twice, to a
-- third-party service that was retired in roadmap Phase 1 (1.10 / 1.12) when
-- generate-game-insight replaced it. Nothing reads the response; nothing in
-- the app, the Edge Functions, or the migrations references these workflows.
--
-- Measured before the fix: 349 firings per trigger on prod, 279 on test,
-- since 2026-01-09. The responses still retained (pg_net keeps only hours)
-- were all "SSL connect error", so nothing was delivered recently. Whether
-- earlier payloads were accepted cannot be told from the database - assume
-- they were. The endpoint going dark is not a fix: if the subdomain ever
-- answers again, delivery resumes silently.
--
-- RULE: no database webhook may point at a service we do not own and run.
-- Check with:
--   select tgrelid::regclass, tgname from pg_trigger
--   where tgfoid = 'supabase_functions.http_request'::regproc;
--
-- supabase_functions.http_request itself is Supabase-owned and left alone.
-- supabase_functions.hooks holds only trigger names and request ids (no row
-- data) and is left alone too.

drop trigger if exists "60xkBoVuYH5tZ2grYTAa/f8fd67be-62dc-4e89-b208-c666b94a0913"
  on public.player_game_stats;

drop trigger if exists "NZlXQJ3jFQdNbAMWyaE0/e8a29e5e-bc7d-427e-88fb-1ab17d049547"
  on public.player_game_stats;
