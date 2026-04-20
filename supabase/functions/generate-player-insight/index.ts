// Edge Function: generate-player-insight
// Input:  { player_id: string }
// Output: { insight: jsonb, cached: boolean, games_until_unlock: number | null } | { error: string }

import { createClient } from "npm:@supabase/supabase-js@2";
import { getAgeBand } from "../_shared/metrics.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const MODEL = "claude-sonnet-4-6";
const PROMPT_VERSION = "v2";
const MIN_GAMES = 5;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

const systemPrompt = `You are a youth basketball development specialist writing a short development story for a parent about their child's growth across their last 5 games. Your voice is warm, encouraging, and grounded. You connect rolling trends to development, not raw stats.

Guidelines:
- 4 to 6 sentences total in "text"
- Use the player's first name naturally
- Reference trend direction (improving, stable, declining) honestly but gently
- Reference tier language (Solid, Good, Elite) only when relevant
- Never list raw stat lines; always connect patterns to growth
- Never use em dashes ("—"). Use commas, periods, or parentheses instead. This is strict.
- Tier hierarchy is Solid then Good then Elite. Solid is the entry level, not weak.
- Close with one growth edge. It MUST:
  - Name a concrete basketball situation a parent can watch for in a real game (e.g. "when the ball gets swung to the weak-side wing", "after a defensive rebound in transition"), not a stat to improve
  - Tie to the weakest or most volatile rolling metric in the data below, not a random skill
  - Describe a micro-decision or read (what the player does in that moment), not a volume goal ("shoot more threes" is banned)
  - Max 22 words. Encouraging, not prescriptive
  - Must not restate the body's main theme
- Output valid JSON only`;

interface TrendSnapshot {
  rolling_ppsa: number | null;
  rolling_ast_tov_ratio: number | null;
  rolling_assists_per_game: number | null;
  rolling_disrupt_score: number | null;
  rolling_points_per_game: number | null;
  ppsa_games_above_solid: number | null;
  ppsa_games_above_good: number | null;
  ppsa_games_above_elite: number | null;
  trend_direction_ppsa: "improving" | "stable" | "declining" | null;
}

function buildUserPrompt(args: {
  firstName: string;
  ageBand: string;
  position: string | null;
  totalGames: number;
  snapshot: TrendSnapshot;
}): string {
  const s = args.snapshot;
  return `Generate a 5-game development story for ${args.firstName}.

Age band: ${args.ageBand}
Position: ${args.position ?? "unknown"}
Games logged overall: ${args.totalGames}

Rolling 5-game metrics:
- Points per game: ${s.rolling_points_per_game?.toFixed(1) ?? "n/a"}
- Scoring efficiency (PPSA): ${s.rolling_ppsa?.toFixed(2) ?? "n/a"}
- Games above Solid PPSA: ${s.ppsa_games_above_solid ?? 0} of 5
- Games above Good PPSA: ${s.ppsa_games_above_good ?? 0} of 5
- Games above Elite PPSA: ${s.ppsa_games_above_elite ?? 0} of 5
- Playmaking (AST/TOV): ${s.rolling_ast_tov_ratio?.toFixed(2) ?? "n/a"}
- Assists per game: ${s.rolling_assists_per_game?.toFixed(1) ?? "n/a"}
- Effort + Disruption (avg): ${s.rolling_disrupt_score?.toFixed(1) ?? "n/a"}
- PPSA trend vs prior snapshot: ${s.trend_direction_ppsa ?? "stable"}

Return JSON with this exact shape:
{
  "headline": "2 to 6 word title",
  "text": "The development story, 4 to 6 sentences",
  "trend_direction": "improving" | "stable" | "declining",
  "strength_focus": "scoring" | "playmaking" | "disruption" | "consistency",
  "growth_edge": "One concrete in-game moment + the read to watch for. Anchored to the weakest rolling metric. Max 22 words."
}`;
}

async function callClaude(userPrompt: string): Promise<{
  headline: string;
  text: string;
  trend_direction: string | null;
  strength_focus: string | null;
  growth_edge: string | null;
}> {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: 800,
      system: systemPrompt,
      messages: [{ role: "user", content: userPrompt }],
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Claude API ${res.status}: ${errText}`);
  }

  const body = await res.json();
  const textBlock = body.content?.[0]?.text;
  if (!textBlock) throw new Error("Claude returned no text block");

  const cleaned = textBlock
    .trim()
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
  const parsed = JSON.parse(cleaned);
  const stripDash = (v: unknown) => String(v ?? "").replace(/\s*—\s*/g, ", ");
  return {
    headline: stripDash(parsed.headline),
    text: stripDash(parsed.text),
    trend_direction: parsed.trend_direction ?? null,
    strength_focus: parsed.strength_focus ?? null,
    growth_edge: parsed.growth_edge ? stripDash(parsed.growth_edge) : null,
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_auth" }, 401);

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  let playerId: string;
  try {
    const body = await req.json();
    playerId = body.player_id;
    if (!playerId || typeof playerId !== "string") {
      return json({ error: "invalid_input" }, 400);
    }
  } catch {
    return json({ error: "invalid_input" }, 400);
  }

  // Fetch player (RLS scopes to current user)
  const { data: player, error: playerErr } = await supabase
    .from("players")
    .select("id, user_id, first_name, birth_date, player_position")
    .eq("id", playerId)
    .maybeSingle();

  if (playerErr) return json({ error: "db_error", detail: playerErr.message }, 500);
  if (!player) return json({ error: "not_found" }, 404);

  const firstName = player.first_name ?? "your player";
  const ageBand = getAgeBand(player.birth_date);
  const nowIso = new Date().toISOString();

  const { count: totalGames } = await supabase
    .from("player_game_stats")
    .select("id", { count: "exact", head: true })
    .eq("player_id", playerId);

  const gamesLogged = totalGames ?? 0;

  // Below-threshold placeholder
  if (gamesLogged < MIN_GAMES) {
    const placeholder = {
      version: 1,
      model: null,
      headline: null,
      text: null,
      trend_direction: null,
      strength_focus: null,
      growth_edge: null,
      prompt_version: PROMPT_VERSION,
      generated_at: nowIso,
      age_band: ageBand,
      games_included_count: gamesLogged,
      below_threshold: true,
    };
    return json({
      insight: placeholder,
      cached: false,
      games_until_unlock: MIN_GAMES - gamesLogged,
    });
  }

  // Latest snapshot (cache key aligns with the trigger's as_of_game_id).
  const { data: snapshot, error: snapErr } = await supabase
    .from("player_trend_snapshots")
    .select(
      "as_of_game_id, rolling_ppsa, rolling_ast_tov_ratio, rolling_assists_per_game, rolling_disrupt_score, rolling_points_per_game, ppsa_games_above_solid, ppsa_games_above_good, ppsa_games_above_elite, trend_direction_ppsa",
    )
    .eq("player_id", playerId)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (snapErr) return json({ error: "db_error", detail: snapErr.message }, 500);
  if (!snapshot) return json({ error: "snapshot_missing" }, 500);

  const latestGameId = snapshot.as_of_game_id;

  // Cache check
  const { data: cached } = await supabase
    .from("player_development_insights")
    .select("insight_json")
    .eq("player_id", playerId)
    .eq("generated_at_game_id", latestGameId)
    .maybeSingle();

  if (cached?.insight_json) {
    return json({
      insight: cached.insight_json,
      cached: true,
      games_until_unlock: null,
    });
  }

  const userPrompt = buildUserPrompt({
    firstName,
    ageBand,
    position: player.player_position ?? null,
    totalGames: gamesLogged,
    snapshot: snapshot as TrendSnapshot,
  });

  let claudeResp;
  try {
    claudeResp = await callClaude(userPrompt);
  } catch (e) {
    console.error("claude_error", e);
    return json({ error: "insight_unavailable" }, 502);
  }

  const insight = {
    version: 1,
    model: MODEL,
    headline: claudeResp.headline,
    text: claudeResp.text,
    trend_direction: claudeResp.trend_direction ?? (snapshot as TrendSnapshot).trend_direction_ppsa,
    strength_focus: claudeResp.strength_focus,
    growth_edge: claudeResp.growth_edge,
    prompt_version: PROMPT_VERSION,
    generated_at: nowIso,
    age_band: ageBand,
    games_included_count: MIN_GAMES,
    below_threshold: false,
  };

  const { error: upsertErr } = await supabase
    .from("player_development_insights")
    .upsert(
      {
        player_id: playerId,
        user_id: player.user_id,
        generated_at_game_id: latestGameId,
        games_included_count: MIN_GAMES,
        insight_json: insight,
        model: MODEL,
        prompt_version: PROMPT_VERSION,
      },
      { onConflict: "player_id,generated_at_game_id" },
    );

  if (upsertErr) return json({ error: "db_error", detail: upsertErr.message }, 500);

  return json({ insight, cached: false, games_until_unlock: null });
});
