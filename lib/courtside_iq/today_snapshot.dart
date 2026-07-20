// Today header snapshot — Phase 4.10
//
// The per-player figures behind the Today header: the Growth IQ score, its
// movement, and the supporting stat chip.
//
// Pure Dart on purpose. Every number here is derived arithmetic with edge cases
// that matter (division by zero, no games yet, a score that cannot be computed)
// and none of it needs a widget or a network call to be wrong. See CLAUDE.md.

/// Which direction a Growth IQ score has moved.
enum TodayTrend { rising, steady, dipping }

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

  /// Null when there is no delta to describe.
  ///
  /// Zero is deliberately [TodayTrend.steady] rather than null: "no change" is
  /// information a parent wants, and is different from "we cannot tell yet".
  TodayTrend? get trend {
    final d = growthIqDelta;
    if (d == null) return null;
    if (d > 0) return TodayTrend.rising;
    if (d < 0) return TodayTrend.dipping;
    return TodayTrend.steady;
  }

  /// Parent-facing word under the score.
  ///
  /// "Dipping", never "Declining" or "Falling". Every rating level has to feel
  /// survivable - this is a child's development, shown to their parent, and a
  /// bad week should not read as a verdict.
  String? get trendLabel => switch (trend) {
        TodayTrend.rising => 'Rising',
        TodayTrend.steady => 'Steady',
        TodayTrend.dipping => 'Dipping',
        null => null,
      };

  /// Signed, e.g. "+4.2" or "-1.4". Null when there is no delta.
  String? get deltaLabel {
    final d = growthIqDelta;
    if (d == null) return null;
    return d > 0 ? '+$d' : '$d';
  }

  /// True when the header should show the locked state instead of a score.
  bool get isLocked => growthIq == null;
}

/// Whether the header shows paging dots.
///
/// One player is not a carousel. A single dot invites a swipe that does
/// nothing, which reads as a broken control rather than a complete one.
bool showsPlayerPaging(int playerCount) => playerCount > 1;
