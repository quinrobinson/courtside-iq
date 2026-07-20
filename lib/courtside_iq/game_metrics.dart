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
