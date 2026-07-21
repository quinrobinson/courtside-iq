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

// ---------------------------------------------------------------------------
// Growth IQ (Phase 4.1)
//
// MIRROR OF lib/courtside_iq/metrics_config.dart — keep in sync.
//
//   growthIq = 70% age-normalized ability + 30% improvement, on a 40-99 scale.
//
// Ability = equal thirds of Scoring Efficiency (PPSA), Playmaking (AST/TOV),
// and Disruption. Improvement = movement over the last 5 games vs the prior
// window, and supplies the Building / Steady / Rising qualifier and delta.
//
// NEVER a rank or percentile. Age normalization is invisible plumbing.
// ---------------------------------------------------------------------------

export const GROWTH_IQ_ABILITY_WEIGHT = 0.70;
export const GROWTH_IQ_IMPROVEMENT_WEIGHT = 0.30;

// Equal thirds: multiple honest paths up.
export const GROWTH_IQ_SCORING_WEIGHT = 1 / 3;
export const GROWTH_IQ_PLAYMAKING_WEIGHT = 1 / 3;
export const GROWTH_IQ_DISRUPTION_WEIGHT = 1 / 3;

// 40 floor so no parent opens the app to a failing-grade number. Ordering
// stays truthful; it is a scale choice, not a distortion.
export const GROWTH_IQ_DISPLAY_MIN = 40;
export const GROWTH_IQ_DISPLAY_MAX = 99;

export const GROWTH_IQ_MIN_GAMES = 5;
export const GROWTH_IQ_WINDOW_GAMES = 5;

export const GROWTH_IQ_RISING_MIN = 0.03;
export const GROWTH_IQ_DIPPING_MAX = -0.03;

// Piecewise-linear normalization anchors across existing approved tiers.
export const GROWTH_IQ_SOLID_ANCHOR = 1 / 3;
export const GROWTH_IQ_GOOD_ANCHOR = 2 / 3;

// KNOWN LIMITATION (accepted 2026-07-18): only PPSA has age-banded thresholds.
// AST/TOV and Disruption are band-invariant. Inventing per-band cutoffs for
// those would fabricate youth benchmarks with no data behind them. Revisit
// once real distributions exist.
export const GROWTH_IQ_AGE_NORMALIZES_PLAYMAKING = false;
export const GROWTH_IQ_AGE_NORMALIZES_DISRUPTION = false;
