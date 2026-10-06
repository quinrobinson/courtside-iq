// Today header snapshot — Phase 4.10
//
// The per-player figures behind the Today header: the Growth IQ score, its
// movement, and the supporting stat chip.
//
// Pure Dart on purpose. Every number here is derived arithmetic with edge cases
// that matter (division by zero, no games yet, a score that cannot be computed)
// and none of it needs a widget or a network call to be wrong. See CLAUDE.md.

import 'growth_iq.dart';

class TodaySnapshot {
  const TodaySnapshot({
    required this.playerId,
    required this.firstName,
    this.lastName,
    this.profilePic,
    required this.totalGames,
    required this.totalPoints,
    this.growthIq,
    this.growthIqDelta,
    this.trend,
    this.headline,
  });

  final String playerId;
  final String firstName;
  final String? lastName;
  final String? profilePic;

  final int totalGames;
  final int totalPoints;

  /// Null when there are too few games to compute one. The header shows the
  /// locked treatment rather than a zero: a zero is a claim about the player,
  /// and "not enough games yet" is not.
  final int? growthIq;

  /// Movement since the previous snapshot. Null when there is no prior score
  /// to compare against, which is NOT the same as no movement.
  final int? growthIqDelta;

  /// Growth IQ's own classification. Null when there is no prior window.
  ///
  /// Note this can be [GrowthTrend.steady] alongside a non-zero delta: the
  /// classifier has a dead band, so a one-point wobble is steadiness, not a
  /// dip. That is the point of carrying it rather than re-deriving it here.
  final GrowthTrend? trend;

  /// The AI headline. Null before enough games, or if generation failed.
  final String? headline;

  String get displayName =>
      lastName == null || lastName!.isEmpty ? firstName : '$firstName $lastName';

  /// Points per game. Null when no games have been logged - dividing by zero
  /// would render "NaN PPG", and "0.0 PPG" would state a performance that
  /// never happened.
  double? get pointsPerGame {
    if (totalGames <= 0) return null;
    return totalPoints / totalGames;
  }

  /// One decimal place, e.g. "18.5 PPG". Null when there is nothing to show.
  String? get pointsPerGameLabel {
    final ppg = pointsPerGame;
    if (ppg == null) return null;
    return '${ppg.toStringAsFixed(1)} PPG';
  }

  /// Parent-facing word under the score.
  ///
  /// Comes from [trend], which is Growth IQ's own classification carried
  /// through the builder. It used to be derived here from the SIGN of the
  /// delta, and that was wrong twice over: the same player read "Dipping" here
  /// and "Building -13" on their profile, and a one-point wobble was called a
  /// dip because a sign has no dead band.
  String? get trendLabel => switch (trend) {
        GrowthTrend.rising => 'Rising',
        GrowthTrend.steady => 'Steady',
        GrowthTrend.dipping => 'Dipping',
        null => null,
      };

  /// Signed, e.g. "+4.2" or "-1.4". Null when there is no delta.
  String? get deltaLabel {
    final d = growthIqDelta;
    if (d == null) return null;
    return d > 0 ? '+$d' : '$d';
  }

  /// Whether this player belongs in the Today header at all.
  ///
  /// The header is about growth, and growth needs games. A player with no
  /// computable Growth IQ is NOT shown there with a zero or a placeholder -
  /// they are absent from it, while remaining everywhere else in the app.
  /// Decided 2026-07-20.
  bool get qualifiesForHeader => growthIq != null;
}

/// The players the Today header pages through, in order.
///
/// Filters to those with a Growth IQ, then puts the strongest movement first
/// so a parent opening the app lands on something meaningful rather than on
/// whichever player happens to sort first alphabetically.
///
/// **Can return an empty list**, and callers must handle that: a user whose
/// players have no games yet has nothing to show in the header. There is no
/// approved design for that state - see the roadmap under 4.10.
List<TodaySnapshot> headerSnapshots(List<TodaySnapshot> all) {
  final qualifying = all.where((s) => s.qualifiesForHeader).toList();
  qualifying.sort((a, b) {
    // Most games first: more games means a more trustworthy score.
    final byGames = b.totalGames.compareTo(a.totalGames);
    if (byGames != 0) return byGames;
    return a.firstName.compareTo(b.firstName);
  });
  return qualifying;
}

/// Whether the header shows paging dots.
///
/// One player is not a carousel. A single dot invites a swipe that does
/// nothing, which reads as a broken control rather than a complete one.
bool showsPlayerPaging(int playerCount) => playerCount > 1;
