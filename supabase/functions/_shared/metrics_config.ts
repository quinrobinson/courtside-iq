// Age bands mirror the SQL get_age_band function.
// Null birth date falls back to "11U-13U" (middle band).
export type AgeBand = "8U-10U" | "11U-13U" | "14U-18U";

export interface PpsaThresholds {
  solidMin: number;
  goodMin: number;
  eliteMin: number;
}

// PPSA — points per shot attempt, age-band-aware
export const PPSA_THRESHOLDS: Record<AgeBand, PpsaThresholds> = {
  "8U-10U":  { solidMin: 0.55, goodMin: 0.80, eliteMin: 1.05 },
  "11U-13U": { solidMin: 0.65, goodMin: 0.90, eliteMin: 1.15 },
  "14U-18U": { solidMin: 0.75, goodMin: 1.00, eliteMin: 1.25 },
};

export const PPSA_MIN_ATTEMPTS = 5;

// AST/TOV — assist-to-turnover ratio
export const AST_TOV_MIN_ASSISTS = 3;
export const AST_TOV_ELITE_MIN_ASSISTS = 4;
export const AST_TOV_GOOD_MIN = 2.0;
export const AST_TOV_ELITE_MIN = 4.0;

// Effort + Disruption score
export const DISRUPT_WEIGHT_OREB = 2.0;
export const DISRUPT_WEIGHT_STEALS = 1.5;
export const DISRUPT_WEIGHT_BLOCKS = 1.0;
export const DISRUPT_WEIGHT_DREB = 0.5;

export const DISRUPT_ACTIVE_MIN = 3;
export const DISRUPT_SOLID_MAX = 5;
export const DISRUPT_GOOD_MIN = 6;
export const DISRUPT_GOOD_MAX = 12;
export const DISRUPT_ELITE_MIN = 13;
