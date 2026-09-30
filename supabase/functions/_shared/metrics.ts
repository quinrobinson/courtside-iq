import {
  PPSA_THRESHOLDS,
  PPSA_MIN_ATTEMPTS,
  AST_TOV_MIN_ASSISTS,
  AST_TOV_ELITE_MIN_ASSISTS,
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
  AgeBand,
} from "./metrics_config.ts";

export function ppsa(fgAttempted: number, ftAttempted: number, points: number): number {
  if (fgAttempted === 0 && ftAttempted === 0) return 0;
  const denominator = fgAttempted + (0.44 * ftAttempted);
  if (denominator === 0) return 0;
  return points / denominator;
}

// A NULL band yields no tier. These cutoffs are age-relative, so without an
// age there is nothing to be relative to - see getAgeBand.
export function ppsaActive(
  ppsaValue: number,
  shotAttempts: number,
  ageBand: AgeBand | null,
): boolean {
  if (!ageBand) return false;
  return shotAttempts >= PPSA_MIN_ATTEMPTS && ppsaValue >= PPSA_THRESHOLDS[ageBand].solidMin;
}

export function ppsaTier(
  ppsaValue: number,
  ageBand: AgeBand | null,
): "Solid" | "Good" | "Elite" | null {
  if (!ageBand) return null;
  const t = PPSA_THRESHOLDS[ageBand];
  if (ppsaValue >= t.eliteMin) return "Elite";
  if (ppsaValue >= t.goodMin) return "Good";
  if (ppsaValue >= t.solidMin) return "Solid";
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
  if (ratio >= AST_TOV_ELITE_MIN && assists >= AST_TOV_ELITE_MIN_ASSISTS) return "Elite";
  if (ratio >= AST_TOV_GOOD_MIN) return "Good";
  return "Solid";
}

// birthDate should be an ISO date string (YYYY-MM-DD) or null.
//
// NULL returns NULL, mirroring get_age_band after migration
// 20260721000000. It used to return '11U-13U'. That fallback scored a player
// of unknown age against middle-school cutoffs while presenting the result as
// age-normalised, which is the one thing this metric must not do.
//
// CALLERS MUST HANDLE NULL. The client locks Growth IQ outright; these
// functions still produce an insight, but must not claim an age-relative tier
// while doing it - see fallbackBand in generate-game-insight.
export function getAgeBand(birthDate: string | null): AgeBand | null {
  if (!birthDate) return null;
  const birth = new Date(birthDate);
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  if (age <= 10) return "8U-10U";
  if (age <= 13) return "11U-13U";
  return "14U-18U";
}
