import {
  PPSA_SOLID_MIN,
  PPSA_GOOD_MIN,
  PPSA_ELITE_MIN,
  PPSA_MIN_ATTEMPTS,
  AST_TOV_MIN_ASSISTS,
  AST_TOV_GOOD_MIN,
  AST_TOV_ELITE_MIN,
  DISRUPT_WEIGHT_OREB,
  DISRUPT_WEIGHT_STEALS,
  DISRUPT_WEIGHT_BLOCKS,
  DISRUPT_WEIGHT_DREB,
  DISRUPT_ACTIVE_MIN,
  DISRUPT_SOLID_MAX,
  DISRUPT_GOOD_MIN,
  DISRUPT_GOOD_MAX,
  DISRUPT_ELITE_MIN,
} from "./metrics_config.ts";

export function ppsa(fgAttempted: number, ftAttempted: number, points: number): number {
  if (fgAttempted === 0 && ftAttempted === 0) return 0;
  const denominator = fgAttempted + (0.44 * ftAttempted);
  if (denominator === 0) return 0;
  return points / denominator;
}

export function ppsaActive(ppsaValue: number, shotAttempts: number): boolean {
  return shotAttempts >= PPSA_MIN_ATTEMPTS && ppsaValue >= PPSA_SOLID_MIN;
}

export function ppsaTier(ppsaValue: number): "Solid" | "Good" | "Elite" | null {
  if (ppsaValue >= PPSA_ELITE_MIN) return "Elite";
  if (ppsaValue >= PPSA_GOOD_MIN) return "Good";
  if (ppsaValue >= PPSA_SOLID_MIN) return "Solid";
  return null;
}

export function disruptScore(steals: number, blocks: number, oreb: number, dreb: number): number {
  return Math.round(
    (oreb * DISRUPT_WEIGHT_OREB) +
    (steals * DISRUPT_WEIGHT_STEALS) +
    (blocks * DISRUPT_WEIGHT_BLOCKS) +
    (dreb * DISRUPT_WEIGHT_DREB)
  );
}

export function disruptTier(score: number): "Solid" | "Good" | "Elite" | null {
  if (score < DISRUPT_ACTIVE_MIN) return null;
  if (score >= DISRUPT_ELITE_MIN) return "Elite";
  if (score >= DISRUPT_GOOD_MIN && score <= DISRUPT_GOOD_MAX) return "Good";
  if (score <= DISRUPT_SOLID_MAX) return "Solid";
  return null;
}

export function astTovRatio(assists: number, turnovers: number): number | null {
  if (assists < AST_TOV_MIN_ASSISTS) return null;
  if (turnovers === 0) return assists;
  return assists / turnovers;
}

export function astTovTier(assists: number, turnovers: number): "Solid" | "Good" | "Elite" | null {
  if (assists < AST_TOV_MIN_ASSISTS) return null;
  const ratio = turnovers === 0 ? assists : assists / turnovers;
  if (ratio >= AST_TOV_ELITE_MIN) return "Elite";
  if (ratio >= AST_TOV_GOOD_MIN) return "Good";
  return "Solid";
}
