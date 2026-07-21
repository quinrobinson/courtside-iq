// Growth IQ — Phase 4.1
//
// One number for how a player is developing:
//   70% age-normalized ability + 30% improvement, shown on a 40-99 scale.
//
// Pure Dart. No Flutter, no Supabase, no I/O — so it is trivially testable and
// can be mirrored exactly in TypeScript for the Edge Functions.
//
// All thresholds and weights come from metrics_config.dart. Nothing is
// hardcoded here.

import 'metrics_config.dart';

/// Direction-of-travel qualifier shown beside the number ("Rising +5").
enum GrowthTrend { building, steady, rising }

/// A display score as a 0..1 gauge fill.
///
/// Lives here rather than beside each gauge because the 40-99 floor and
/// ceiling are a Growth IQ decision, not a drawing one. Two screens drawing
/// the same score from two private copies of this mapping is how a gauge ends
/// up disagreeing with the number printed inside it.
double growthIqGaugeValue(int score) =>
    ((score - 40) / (99 - 40)).clamp(0.0, 1.0);

/// Per-game inputs the composite is built from. One instance per logged game,
/// ordered oldest -> newest by the caller.
class GrowthGame {
  final double? ppsa; // null when below kPpsaMinAttempts
  final double? astTov; // null when below kAstTovMinAssists
  final double? disrupt; // null when below kDisruptActiveMin

  const GrowthGame({this.ppsa, this.astTov, this.disrupt});
}

/// Result of a Growth IQ evaluation.
class GrowthIqResult {
  /// Display score, 40-99. Null when locked.
  final int? score;

  /// Movement vs the prior window, already scaled to display points.
  /// Null when there is no prior window to compare against.
  final int? delta;

  final GrowthTrend? trend;

  /// True when the player has fewer than kGrowthIqMinGames games.
  /// The UI shows the designed locked state, never a provisional number.
  final bool locked;

  /// Games counted toward the current window.
  final int gamesUsed;

  const GrowthIqResult({
    this.score,
    this.delta,
    this.trend,
    required this.locked,
    required this.gamesUsed,
  });

  static const GrowthIqResult lockedResult =
      GrowthIqResult(locked: true, gamesUsed: 0);
}

/// Maps a raw metric value onto 0-1 by piecewise-linear interpolation across
/// its approved tier thresholds.
///
/// 0.0 at zero, solid anchor at [solidMin], good anchor at [goodMin],
/// 1.0 at [eliteMin], clamped above. Reuses cutoffs that are already signed
/// off rather than inventing a distribution curve.
double normalizeToTiers(
  double value, {
  required double solidMin,
  required double goodMin,
  required double eliteMin,
}) {
  if (value <= 0) return 0.0;
  if (value >= eliteMin) return 1.0;

  if (value < solidMin) {
    return (value / solidMin) * kGrowthIqSolidAnchor;
  }
  if (value < goodMin) {
    final t = (value - solidMin) / (goodMin - solidMin);
    return kGrowthIqSolidAnchor +
        t * (kGrowthIqGoodAnchor - kGrowthIqSolidAnchor);
  }
  final t = (value - goodMin) / (eliteMin - goodMin);
  return kGrowthIqGoodAnchor + t * (1.0 - kGrowthIqGoodAnchor);
}

/// Scoring efficiency, normalized against the player's age band.
double normalizeScoring(double ppsa, AgeBand band) {
  final t = kPpsaThresholds[band]!;
  return normalizeToTiers(
    ppsa,
    solidMin: t.solidMin,
    goodMin: t.goodMin,
    eliteMin: t.eliteMin,
  );
}

/// Playmaking. Band-invariant — see the KNOWN LIMITATION note in
/// metrics_config.dart. [band] is accepted so the signature does not have to
/// change when per-band cutoffs are eventually derived.
double normalizePlaymaking(double astTov, AgeBand band) {
  // Solid anchor sits midway to Good; Good and Elite are the approved cutoffs.
  return normalizeToTiers(
    astTov,
    solidMin: kAstTovGoodMin / 2,
    goodMin: kAstTovGoodMin,
    eliteMin: kAstTovEliteMin,
  );
}

/// Disruption. Band-invariant — see the KNOWN LIMITATION note.
double normalizeDisruption(double disrupt, AgeBand band) {
  return normalizeToTiers(
    disrupt,
    solidMin: kDisruptActiveMin.toDouble(),
    goodMin: kDisruptGoodMin.toDouble(),
    eliteMin: kDisruptEliteMin.toDouble(),
  );
}

/// Ability composite for a set of games: equal thirds of the three families,
/// averaged across the window.
///
/// A family with no qualifying games in the window is dropped and the
/// remaining families are re-weighted evenly. A player who never records an
/// assist is not punished with a zero for playmaking — they are scored on what
/// they actually did.
double? abilityComposite(List<GrowthGame> games, AgeBand band) {
  if (games.isEmpty) return null;

  final scoring = <double>[];
  final playmaking = <double>[];
  final disruption = <double>[];

  for (final g in games) {
    if (g.ppsa != null) scoring.add(normalizeScoring(g.ppsa!, band));
    if (g.astTov != null) playmaking.add(normalizePlaymaking(g.astTov!, band));
    if (g.disrupt != null) disruption.add(normalizeDisruption(g.disrupt!, band));
  }

  double? mean(List<double> xs) =>
      xs.isEmpty ? null : xs.reduce((a, b) => a + b) / xs.length;

  final present = <double>[
    for (final m in [mean(scoring), mean(playmaking), mean(disruption)])
      if (m != null) m,
  ];

  if (present.isEmpty) return null;
  return present.reduce((a, b) => a + b) / present.length;
}

/// Evaluate Growth IQ for a player.
///
/// [games] must be ordered oldest -> newest and contain every logged game.
/// The current window is the last [kGrowthIqWindowGames]; the prior window is
/// the [kGrowthIqWindowGames] before that, when available.
GrowthIqResult growthIq(List<GrowthGame> games, AgeBand band) {
  if (games.length < kGrowthIqMinGames) {
    return GrowthIqResult.lockedResult;
  }

  const w = kGrowthIqWindowGames;
  final current = games.sublist(games.length - w);
  final ability = abilityComposite(current, band);

  if (ability == null) {
    // Enough games logged, but no qualifying data in any family.
    return GrowthIqResult.lockedResult;
  }

  // Prior window, only when a full one exists. A partial prior window would
  // make improvement noisy and could show a decline that is really just a
  // smaller sample.
  double? priorAbility;
  if (games.length >= w * 2) {
    priorAbility = abilityComposite(
      games.sublist(games.length - w * 2, games.length - w),
      band,
    );
  }

  // Improvement, normalized to 0-1 where 0.5 is "no change". Movement is
  // amplified so realistic game-to-game gains register, then clamped.
  final rawMovement = priorAbility == null ? 0.0 : ability - priorAbility;
  final improvement = priorAbility == null
      ? ability // no baseline yet: fall back to current ability
      : (0.5 + rawMovement * 2.5).clamp(0.0, 1.0);

  final blended = ability * kGrowthIqAbilityWeight +
      improvement * kGrowthIqImprovementWeight;

  const span = kGrowthIqDisplayMax - kGrowthIqDisplayMin;
  final score =
      (kGrowthIqDisplayMin + blended * span).round().clamp(
            kGrowthIqDisplayMin,
            kGrowthIqDisplayMax,
          );

  int? delta;
  GrowthTrend? trend;
  if (priorAbility != null) {
    // Delta is expressed in the same display points as the score, so
    // "Rising +5" means five points on the 40-99 scale.
    final priorBlended = priorAbility * kGrowthIqAbilityWeight +
        0.5 * kGrowthIqImprovementWeight;
    final priorScore =
        (kGrowthIqDisplayMin + priorBlended * span).round().clamp(
              kGrowthIqDisplayMin,
              kGrowthIqDisplayMax,
            );
    delta = score - priorScore;

    if (rawMovement >= kGrowthIqRisingMin) {
      trend = GrowthTrend.rising;
    } else if (rawMovement <= kGrowthIqBuildingMax) {
      trend = GrowthTrend.building;
    } else {
      trend = GrowthTrend.steady;
    }
  }

  return GrowthIqResult(
    score: score,
    delta: delta,
    trend: trend,
    locked: false,
    gamesUsed: current.length,
  );
}
