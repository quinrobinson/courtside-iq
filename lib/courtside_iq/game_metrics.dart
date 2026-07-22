// Per-game metrics — Phase 4.10a
//
// A DART MIRROR OF supabase/functions/_shared/metrics.ts. Growth IQ is computed
// client-side, but the same numbers are computed server-side for AI insights,
// and the two must agree. A parent who reads "scoring efficiency: Elite" in an
// insight and sees a Growth IQ built on a different PPSA has been shown two
// contradictory things about their child.
//
// **If metrics.ts changes, change this too.** The thresholds already live in
// metrics_config.dart and its TypeScript twin; these are the formulas that use
// them.
//
// Three details here are not obvious and were taken from the TypeScript rather
// than derived, because deriving them is exactly how the two drift apart:
//
//   1. PPSA's denominator is fga + 0.44 * fta, the true-shooting free-throw
//      factor. NOT total attempts.
//   2. disruptScore is ROUNDED to an integer.
//   3. AST/TOV with zero turnovers is the assist count, not infinity.

import 'metrics_config.dart';

/// Points per shot attempt.
///
/// Returns 0 when nothing was attempted, matching the TypeScript. Callers
/// decide whether a game qualifies at all - see [ppsaQualifies].
double ppsa({
  required int fgAttempted,
  required int ftAttempted,
  required int points,
}) {
  if (fgAttempted == 0 && ftAttempted == 0) return 0;
  // 0.44 is the standard free-throw weighting: not every trip to the line is
  // a full possession.
  final denominator = fgAttempted + (0.44 * ftAttempted);
  if (denominator == 0) return 0;
  return points / denominator;
}

/// Total shot attempts for the minimum-attempts gate.
int shotAttempts({required int fgAttempted, required int ftAttempted}) =>
    fgAttempted + ftAttempted;

/// Whether a game had enough attempts for PPSA to mean anything.
///
/// Below this, a single lucky basket would read as elite efficiency.
bool ppsaQualifies({required int fgAttempted, required int ftAttempted}) =>
    shotAttempts(fgAttempted: fgAttempted, ftAttempted: ftAttempted) >=
    kPpsaMinAttempts;

/// Effort + disruption, weighted and ROUNDED to an integer.
int disruptScore({
  required int steals,
  required int blocks,
  required int oreb,
  required int dreb,
}) =>
    ((oreb * kDisruptWeightOreb) +
            (steals * kDisruptWeightSteals) +
            (blocks * kDisruptWeightBlocks) +
            (dreb * kDisruptWeightDreb))
        .round();

/// Whether the disruption score is high enough to count.
bool disruptQualifies(int score) => score >= kDisruptActiveMin;

/// Assist-to-turnover ratio, or null below the assist minimum.
///
/// Zero turnovers yields the ASSIST COUNT rather than infinity: a clean game
/// should read as strong, not as an unbounded number that breaks every
/// comparison downstream.
double? astTovRatio({required int assists, required int turnovers}) {
  if (assists < kAstTovMinAssists) return null;
  if (turnovers == 0) return assists.toDouble();
  return assists / turnovers;
}

// --- Tiers -------------------------------------------------------------------
//
// PORTED FROM metrics.ts IN 4.14, where they had lived alone since Phase 1.
// The server had them because it writes `tier_context` into the insight; the
// client never needed them, because v1 only ever displayed that one stored
// tier.
//
// Game Detail changed that. Its Development section rates all THREE metrics,
// and the jsonb carries exactly one - the highlighted metric's. So the other
// two have to be computed here.
//
// THE INSIGHT CARD USES THESE TOO, not `tier_context`. Otherwise the card can
// read "SCORING EFFICIENCY · ELITE" above a row that says Good, which is the
// same failure as the two trend classifiers that made one player read
// "Dipping" on Today and "Building" on their profile. One classifier.
//
// NULL MEANS NO RATING, never a zero rating. A game below the data threshold
// says nothing rather than something wrong.

/// Solid, Good or Elite. The hierarchy STARTS at Solid - it is the entry
/// level, not a weak score - and every level is meant to feel acceptable.
enum GameTier { solid, good, elite }

extension GameTierLabel on GameTier {
  String get label => switch (this) {
        GameTier.solid => 'Solid',
        GameTier.good => 'Good',
        GameTier.elite => 'Elite',
      };
}

/// Scoring efficiency. Null without an age band: these cutoffs are
/// age-relative, so without an age there is nothing to be relative to.
GameTier? ppsaTier(double ppsaValue, AgeBand? ageBand) {
  if (ageBand == null) return null;
  final t = kPpsaThresholds[ageBand]!;
  if (ppsaValue >= t.eliteMin) return GameTier.elite;
  if (ppsaValue >= t.goodMin) return GameTier.good;
  if (ppsaValue >= t.solidMin) return GameTier.solid;
  return null;
}

/// Effort and disruption, from the weighted score.
GameTier? disruptTier(int score) {
  if (score < kDisruptActiveMin) return null;
  if (score >= kDisruptEliteMin) return GameTier.elite;
  if (score >= kDisruptGoodMin && score <= kDisruptGoodMax) return GameTier.good;
  if (score <= kDisruptSolidMax) return GameTier.solid;
  return null;
}

/// Playmaking. Elite needs BOTH a high ratio and enough assists to earn it -
/// 4 assists to 1 turnover is elite, 4-to-1 off two assists is a small sample.
GameTier? astTovTier({required int assists, required int turnovers}) {
  if (assists < kAstTovMinAssists) return null;
  final ratio = turnovers == 0 ? assists.toDouble() : assists / turnovers;
  if (ratio >= kAstTovEliteMin && assists >= kAstTovEliteMinAssists) {
    return GameTier.elite;
  }
  if (ratio >= kAstTovGoodMin) return GameTier.good;
  return GameTier.solid;
}
