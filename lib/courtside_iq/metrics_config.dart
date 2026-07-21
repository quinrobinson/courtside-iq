// Age bands mirror the SQL get_age_band function.
// Null birth date falls back to u13 (middle band).
enum AgeBand { u10, u13, u18 }

/// Parses a band from the view, or NULL when there is no band to parse.
///
/// This returned the MIDDLE BAND for null until 2026-07-21, mirroring
/// get_age_band's own fallback. Both are gone. Age normalisation is the whole
/// premise of these thresholds, so scoring a player of unknown age against
/// 11U-13U cutoffs produced a number that looked age-fair and was not - an
/// 8-year-old and a 17-year-old were both measured against middle-school
/// play. A rating we cannot stand behind is not shown at all.
AgeBand? ageBandFromString(String? band) {
  switch (band?.trim()) {
    case '8U-10U':
      return AgeBand.u10;
    case '11U-13U':
      return AgeBand.u13;
    case '14U-18U':
      return AgeBand.u18;
    default:
      return null;
  }
}

// PPSA — points per shot attempt, age-band-aware
class PpsaThresholds {
  final double solidMin;
  final double goodMin;
  final double eliteMin;
  const PpsaThresholds({
    required this.solidMin,
    required this.goodMin,
    required this.eliteMin,
  });
}

const Map<AgeBand, PpsaThresholds> kPpsaThresholds = {
  AgeBand.u10: PpsaThresholds(solidMin: 0.55, goodMin: 0.80, eliteMin: 1.05),
  AgeBand.u13: PpsaThresholds(solidMin: 0.65, goodMin: 0.90, eliteMin: 1.15),
  AgeBand.u18: PpsaThresholds(solidMin: 0.75, goodMin: 1.00, eliteMin: 1.25),
};

const int kPpsaMinAttempts = 5;

// AST/TOV — assist-to-turnover ratio
const int kAstTovMinAssists = 3;
const int kAstTovEliteMinAssists = 4;
const double kAstTovGoodMin = 2.0;
const double kAstTovEliteMin = 4.0;

// Effort + Disruption score
const double kDisruptWeightOreb = 2.0;
const double kDisruptWeightSteals = 1.5;
const double kDisruptWeightBlocks = 1.0;
const double kDisruptWeightDreb = 0.5;

const int kDisruptActiveMin = 3;
const int kDisruptSolidMax = 5;
const int kDisruptGoodMin = 6;
const int kDisruptGoodMax = 12;
const int kDisruptEliteMin = 13;

// ---------------------------------------------------------------------------
// Growth IQ (Phase 4.1)
//
// One number for how a player is developing:
//   growthIq = 70% age-normalized ability + 30% improvement
// displayed on a 40-99 scale.
//
// Ability = equal thirds of Scoring Efficiency (PPSA), Playmaking (AST/TOV),
// and Disruption. Improvement = movement in that composite over the last 5
// games vs the prior window, and is what supplies the Building / Steady /
// Rising qualifier and the delta.
//
// It is NEVER a rank or percentile against other players. Age normalization
// is invisible plumbing, not a leaderboard.
// ---------------------------------------------------------------------------

const double kGrowthIqAbilityWeight = 0.70;
const double kGrowthIqImprovementWeight = 0.30;

// Equal thirds. Multiple honest paths up: a weak scorer can still earn a
// strong number through playmaking or defense.
const double kGrowthIqScoringWeight = 1 / 3;
const double kGrowthIqPlaymakingWeight = 1 / 3;
const double kGrowthIqDisruptionWeight = 1 / 3;

// Display scale. The 40 floor exists so no parent opens the app to a number
// that reads like a failing grade. Ordering stays truthful (better play always
// scores higher) - it is a scale choice, not a distortion. Same reasoning as
// FICO starting at 300 rather than 0.
const int kGrowthIqDisplayMin = 40;
const int kGrowthIqDisplayMax = 99;

// Locked until the player has this many games. Below it, show the designed
// locked state - never a provisional number.
const int kGrowthIqMinGames = 5;

// Rolling window used for both the ability composite and the improvement
// comparison (last N vs the N before that).
const int kGrowthIqWindowGames = 5;

// Qualifier cutoffs, in normalized composite points (0-1 scale) of movement
// between the current and prior window.
const double kGrowthIqRisingMin = 0.03;
const double kGrowthIqDippingMax = -0.03;

// --- Normalization anchors ---------------------------------------------------
//
// Each metric family is mapped to 0-1 by piecewise-linear interpolation across
// its EXISTING approved tier thresholds:
//   0.0 at zero, kGrowthIqSolidAnchor at solidMin, kGrowthIqGoodAnchor at
//   goodMin, 1.0 at eliteMin, clamped above.
// This reuses cutoffs already signed off rather than inventing a curve.

const double kGrowthIqSolidAnchor = 1 / 3;
const double kGrowthIqGoodAnchor = 2 / 3;

// KNOWN LIMITATION (accepted 2026-07-18):
// Only PPSA has age-banded thresholds (see kPpsaThresholds). AST/TOV and
// Disruption use flat cutoffs, so those two components are currently
// band-invariant - they are NOT age-normalized.
//
// This is deliberate. Inventing per-band cutoffs for playmaking and disruption
// would mean fabricating youth benchmarks with no data behind them, which would
// then silently drive every Growth IQ number in the app. Scoring efficiency is
// also where age matters most, so PPSA-only normalization captures the bulk of
// the real effect.
//
// FIX LATER: derive per-band AST/TOV and Disruption cutoffs from observed
// distributions once there is enough real data to do it honestly.
const bool kGrowthIqAgeNormalizesPlaymaking = false;
const bool kGrowthIqAgeNormalizesDisruption = false;
