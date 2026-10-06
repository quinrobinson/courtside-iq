-- Allow player_development_insights.insight_json to be null.
--
-- generate-player-insight claims a generation by inserting a placeholder row
-- and filling it in when Claude responds, using the unique constraint on
-- (player_id, generated_at_game_id) to make the claim atomic. A NOT NULL
-- insight_json makes that placeholder impossible: the insert fails and the
-- function 500s before ever calling Claude.
--
-- Caught in test by three 500s during verification, after the claim-row change
-- shipped. The constraint was visible in the baseline dump written the same
-- afternoon and the connection was missed.
--
-- A null insight_json now means exactly one thing: "generation in progress, or
-- abandoned". Readers already treat it as a cache miss:
--   - Edge Function readCache(): `data?.insight_json ?? null` -> miss
--   - Client readCached(): `raw is! Map` -> null
--   - Dashboard batch read: `if (raw is! Map) continue`

alter table public.player_development_insights
  alter column insight_json drop not null;

comment on column public.player_development_insights.insight_json is
  'Null means a generation is in flight (or was abandoned). Readers treat null as a cache miss.';
