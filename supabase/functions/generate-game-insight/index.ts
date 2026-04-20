// Edge Function: generate-game-insight
// Input:  { game_id: string }
// Output: { insight: jsonb, cached: boolean } | { error: string }

import { createClient } from "npm:@supabase/supabase-js@2";
import {
  ppsa,
  ppsaTier,
  astTovRatio,
  astTovTier,
  disruptScore,
  disruptTier,
  getAgeBand,
} from "../_shared/metrics.ts";
import { PPSA_MIN_ATTEMPTS } from "../_shared/metrics_config.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const MODEL = "claude-haiku-4-5-20251001";
const PROMPT_VERSION = "v1";

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

const systemPrompt = `You are a youth basketball development specialist writing a short insight for a parent about their child's game. Your voice is warm, encouraging, and grounded. You help parents see how numbers connect to their player's growth.

Guidelines:
- 2 to 3 sentences
- Use the player's first name naturally
- Reference specific tier language (Solid, Good, Elite) only when provided
- Never list raw stats; always connect them to development
- Never use em dashes ("—"). Use commas, periods, or parentheses instead. This is strict.
- Close with one small, encouraging observation or thing to watch for next time
- highlight_metric MUST be one of "ppsa", "ast_tov", "disrupt", "effort" whenever any tier (Solid/Good/Elite) is provided for that metric. Only return null if no tier data is given.
- Output valid JSON only`;

function buildUserPrompt(args: {
  firstName: string;
  ageBand: string;
  position: string | null;
  points: number;
  ppsaValue: number;
  ppsaTierLabel: string | null;
  astTovValue: number | null;
  assists: number;
  astTovTierLabel: string | null;
  disrupt: number;
  disruptTierLabel: string | null;
}): string {
  const astTovLine = args.astTovValue === null
    ? `Playmaking (AST/TOV): not yet rated (need at least 3 assists)`
    : `Playmaking (AST/TOV): ${args.astTovValue.toFixed(2)} with ${args.assists} assists — ${args.astTovTierLabel ?? "not yet rated"}`;

  return `Generate a game insight for ${args.firstName}'s recent game.

Age band: ${args.ageBand}
Position: ${args.position ?? "unknown"}

Game stats:
- Points: ${args.points}
- Scoring efficiency (PPSA): ${args.ppsaValue.toFixed(2)} — ${args.ppsaTierLabel ?? "not yet rated"} for ${args.ageBand}
- ${astTovLine}
- Effort + Disruption: ${args.disrupt} — ${args.disruptTierLabel ?? "not yet rated"}

Return JSON with this exact shape:
{
  "text": "The insight, 2 to 3 sentences",
  "highlight_metric": "ppsa" | "ast_tov" | "disrupt" | "effort" | null,
  "tier_context": "Solid" | "Good" | "Elite" | null
}`;
}

const TIER_RANK: Record<string, number> = { Elite: 3, Good: 2, Solid: 1 };

function pickHighlightMetric(tiers: {
  ppsa: string | null;
  disrupt: string | null;
  ast_tov: string | null;
}): string | null {
  // Priority order defines the tie-break; scoring leads because it's the
  // most visible dimension for parents.
  const ordered: Array<[string, string | null]> = [
    ["ppsa", tiers.ppsa],
    ["disrupt", tiers.disrupt],
    ["ast_tov", tiers.ast_tov],
  ];
  let best: { key: string; rank: number } | null = null;
  for (const [key, label] of ordered) {
    const rank = label ? (TIER_RANK[label] ?? 0) : 0;
    if (rank > 0 && (best === null || rank > best.rank)) {
      best = { key, rank };
    }
  }
  return best?.key ?? null;
}

async function callClaude(userPrompt: string): Promise<{
  text: string;
  highlight_metric: string | null;
  tier_context: string | null;
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
      max_tokens: 400,
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

  // Claude occasionally wraps JSON in ```json ... ``` fences — strip before parse.
  const cleaned = textBlock
    .trim()
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
  const parsed = JSON.parse(cleaned);
  // Em dashes slip past the prompt rule often enough that we strip
  // them defensively. Replace with ", " so sentence flow survives.
  const text = String(parsed.text ?? "").replace(/\s*—\s*/g, ", ");
  return {
    text,
    highlight_metric: parsed.highlight_metric ?? null,
    tier_context: parsed.tier_context ?? null,
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

  let gameId: string;
  try {
    const body = await req.json();
    gameId = body.game_id;
    if (!gameId || typeof gameId !== "string") {
      return json({ error: "invalid_input" }, 400);
    }
  } catch {
    return json({ error: "invalid_input" }, 400);
  }

  // Fetch stats + player together (RLS scopes to current user)
  const { data: stats, error: statsErr } = await supabase
    .from("player_game_stats")
    .select(`
      id, game_id, player_id, points,
      fg_attempt, ft_attempt, assist, turnover,
      steal, block, off_reb, def_reb,
      game_insights,
      players:player_id ( id, first_name, birth_date, player_position )
    `)
    .eq("game_id", gameId)
    .maybeSingle();

  if (statsErr) return json({ error: "db_error", detail: statsErr.message }, 500);
  if (!stats) return json({ error: "not_found" }, 404);

  // Cached path
  if (stats.game_insights && stats.game_insights.text) {
    return json({ insight: stats.game_insights, cached: true });
  }

  const player = Array.isArray(stats.players) ? stats.players[0] : stats.players;
  const firstName = player?.first_name ?? "your player";
  const birthDate: string | null = player?.birth_date ?? null;
  const position: string | null = player?.player_position ?? null;

  const ageBand = getAgeBand(birthDate);
  const fallbackBand = birthDate === null;

  const shotAttempts = (stats.fg_attempt ?? 0) + (stats.ft_attempt ?? 0);
  const nowIso = new Date().toISOString();

  // Below-threshold path — skip Claude
  if (shotAttempts < PPSA_MIN_ATTEMPTS) {
    const insight = {
      version: 1,
      model: null,
      text: null,
      highlight_metric: null,
      tier_context: null,
      prompt_version: PROMPT_VERSION,
      generated_at: nowIso,
      age_band: ageBand,
      fallback_band: fallbackBand,
      below_threshold: true,
    };
    await supabase
      .from("player_game_stats")
      .update({ game_insights: insight })
      .eq("id", stats.id);
    return json({ insight, cached: false });
  }

  const ppsaValue = ppsa(stats.fg_attempt ?? 0, stats.ft_attempt ?? 0, stats.points ?? 0);
  const ppsaTierLabel = ppsaTier(ppsaValue, ageBand);
  const astTovValue = astTovRatio(stats.assist ?? 0, stats.turnover ?? 0);
  const astTovTierLabel = astTovTier(stats.assist ?? 0, stats.turnover ?? 0);
  const disrupt = disruptScore(
    stats.steal ?? 0,
    stats.block ?? 0,
    stats.off_reb ?? 0,
    stats.def_reb ?? 0,
  );
  const disruptTierLabel = disruptTier(disrupt);

  const userPrompt = buildUserPrompt({
    firstName,
    ageBand,
    position,
    points: stats.points ?? 0,
    ppsaValue,
    ppsaTierLabel,
    astTovValue,
    assists: stats.assist ?? 0,
    astTovTierLabel,
    disrupt,
    disruptTierLabel,
  });

  let claudeResp;
  try {
    claudeResp = await callClaude(userPrompt);
  } catch (e) {
    console.error("claude_error", e);
    return json({ error: "insight_unavailable" }, 502);
  }

  // Deterministic fallback: if Claude omits highlight_metric, pick the
  // metric with the strongest tier so the game-row tag never silently
  // disappears. Ties break ppsa > disrupt > ast_tov (scoring-first).
  const highlightMetric = claudeResp.highlight_metric ?? pickHighlightMetric({
    ppsa: ppsaTierLabel,
    disrupt: disruptTierLabel,
    ast_tov: astTovTierLabel,
  });

  const insight = {
    version: 1,
    model: MODEL,
    text: claudeResp.text,
    highlight_metric: highlightMetric,
    tier_context: claudeResp.tier_context,
    prompt_version: PROMPT_VERSION,
    generated_at: nowIso,
    age_band: ageBand,
    fallback_band: fallbackBand,
    below_threshold: false,
  };

  const { error: updateErr } = await supabase
    .from("player_game_stats")
    .update({ game_insights: insight })
    .eq("id", stats.id);

  if (updateErr) return json({ error: "db_error", detail: updateErr.message }, 500);

  return json({ insight, cached: false });
});
