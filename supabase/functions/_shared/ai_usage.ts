// Shared Anthropic token telemetry writer.
//
// Writes one row per Claude API call into public.ai_usage so AI cost can be
// measured (per user, per game, per model) instead of estimated.
//
// Design rule: logging must NEVER break insight generation. Every failure path
// here is swallowed and logged to console only. This is observability, and
// observability that can take down the feature it observes is a net negative.

import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
// Service role: ai_usage has RLS enabled with no policies, so only this key can write.
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// ---------------------------------------------------------------------------
// Per-user daily cap (Phase 4.3).
//
// This is a CIRCUIT BREAKER, not a quota. Costs do not run away because a
// family logs a lot of basketball - they run away because a retry loop or a
// client bug hammers the endpoint. So the limit is set well above any
// plausible human usage and exists purely to bound the blast radius.
//
// Sizing: a parent with 3 players logging 2 games each in a day generates
// roughly 12 calls. 60 is 5x that and still caps a runaway loop at about
// $0.40/day/user instead of unbounded.
//
// Revisit once there is a meaningful window of real ai_usage data. Do not
// tighten this toward a quota without evidence - a false positive silently
// denies a paying user their insight.
// ---------------------------------------------------------------------------
export const AI_DAILY_CALL_LIMIT = 60;

/**
 * True when the user is under their daily cap.
 *
 * Fails OPEN: if the check itself errors, the request proceeds. A broken
 * counter must never block a paying customer's insight - the cap is a
 * safety net, not an access control.
 */
export async function withinDailyLimit(userId: string | null): Promise<boolean> {
  if (!userId) return true;

  try {
    if (!SERVICE_ROLE_KEY) return true;

    const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
    });

    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

    // Throttle rejections are logged too, so exclude them - otherwise a user
    // who hits the cap can never fall back under it.
    const { count, error } = await admin
      .from("ai_usage")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", since)
      .or("error_kind.is.null,error_kind.neq.throttled");

    if (error) return true;
    return (count ?? 0) < AI_DAILY_CALL_LIMIT;
  } catch (_) {
    return true;
  }
}

/** Shape of the `usage` object on an Anthropic Messages API response. */
export interface ClaudeUsage {
  input_tokens?: number;
  output_tokens?: number;
  cache_creation_input_tokens?: number;
  cache_read_input_tokens?: number;
}

export interface AiUsageRow {
  function_name: string;
  model: string;
  prompt_version?: string | null;
  usage?: ClaudeUsage | null;
  user_id?: string | null;
  player_id?: string | null;
  game_id?: string | null;
  succeeded?: boolean;
  error_kind?: string | null;
}

export async function logAiUsage(row: AiUsageRow): Promise<void> {
  try {
    if (!SERVICE_ROLE_KEY) {
      console.warn("ai_usage_skipped", "SUPABASE_SERVICE_ROLE_KEY not set");
      return;
    }

    const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
    });

    const u = row.usage ?? {};

    const { error } = await admin.from("ai_usage").insert({
      function_name: row.function_name,
      model: row.model,
      prompt_version: row.prompt_version ?? null,
      input_tokens: u.input_tokens ?? 0,
      output_tokens: u.output_tokens ?? 0,
      cache_creation_input_tokens: u.cache_creation_input_tokens ?? 0,
      cache_read_input_tokens: u.cache_read_input_tokens ?? 0,
      user_id: row.user_id ?? null,
      player_id: row.player_id ?? null,
      game_id: row.game_id ?? null,
      succeeded: row.succeeded ?? true,
      error_kind: row.error_kind ?? null,
    });

    if (error) console.error("ai_usage_insert_failed", error.message);
  } catch (e) {
    // Deliberately swallowed. See design rule above.
    console.error("ai_usage_threw", e instanceof Error ? e.message : String(e));
  }
}
