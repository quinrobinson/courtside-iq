// Today assembly — Phase 4.10a
//
// Turns per-game rows into the header snapshots, running Growth IQ over each
// player's games. Pure Dart: no Supabase, no widgets, so the arithmetic and
// the ordering can be tested without a network or a device.
//
// The IO lives in lib/features/home/today_repository.dart and does nothing but
// fetch and hand rows here.

import 'game_metrics.dart';
import 'growth_iq.dart';
import 'metrics_config.dart';
import 'today_snapshot.dart';

/// One row of `v_player_game_stats`, reduced to what Today needs.
class TodayGameRow {
  const TodayGameRow({
    required this.playerId,
    required this.gameId,
    required this.createdAt,
    required this.points,
    required this.fgAttempt,
    required this.ftAttempt,
    required this.offReb,
    required this.defReb,
    required this.assist,
    required this.steal,
    required this.turnover,
    required this.block,
  });

  final String playerId;
  final String gameId;
  final DateTime createdAt;

  final int points;
  final int fgAttempt;
  final int ftAttempt;
  final int offReb;
  final int defReb;
  final int assist;
  final int steal;
  final int turnover;
  final int block;
}

/// A player as `player_profile_view` describes them.
class TodayPlayerRow {
  const TodayPlayerRow({
    required this.playerId,
    required this.firstName,
    this.lastName,
    this.profilePic,
    required this.totalGames,
    required this.totalPoints,
    this.ageBand,
    this.headline,
  });

  final String playerId;
  final String firstName;
  final String? lastName;
  final String? profilePic;
  final int totalGames;
  final int totalPoints;

  /// Raw string from the view; only PPSA thresholds are age-banded.
  final String? ageBand;

  /// From the cached development insight, when one exists.
  final String? headline;
}

/// Converts one game into the shape Growth IQ consumes.
///
/// Each metric is null when the game did not clear its minimum. That is a real
/// distinction, not a convenience: a game with two shot attempts should not
/// contribute an efficiency figure at all, rather than contribute a wild one.
GrowthGame toGrowthGame(TodayGameRow r) {
  final qualifies =
      ppsaQualifies(fgAttempted: r.fgAttempt, ftAttempted: r.ftAttempt);
  final disrupt = disruptScore(
    steals: r.steal,
    blocks: r.block,
    oreb: r.offReb,
    dreb: r.defReb,
  );

  return GrowthGame(
    ppsa: qualifies
        ? ppsa(
            fgAttempted: r.fgAttempt,
            ftAttempted: r.ftAttempt,
            points: r.points,
          )
        : null,
    astTov: astTovRatio(assists: r.assist, turnovers: r.turnover),
    disrupt: disruptQualifies(disrupt) ? disrupt.toDouble() : null,
  );
}

/// Builds one snapshot per player, Growth IQ included where computable.
///
/// [games] may hold rows for any number of players in any order; they are
/// grouped and sorted here. Growth IQ requires OLDEST FIRST, since it compares
/// the latest window against the one before it - handing it newest-first would
/// invert every trend, reporting improvement as decline.
List<TodaySnapshot> buildTodaySnapshots({
  required List<TodayPlayerRow> players,
  required List<TodayGameRow> games,
}) {
  final byPlayer = <String, List<TodayGameRow>>{};
  for (final g in games) {
    (byPlayer[g.playerId] ??= <TodayGameRow>[]).add(g);
  }

  return players.map((p) {
    // List.of, not the raw value: a player with no games falls back to a
    // const list, and sorting an unmodifiable list throws - which would have
    // crashed the whole screen for the commonest state there is, a player
    // just added. Copying also avoids mutating the grouped map in place.
    final rows = List<TodayGameRow>.of(
      byPlayer[p.playerId] ?? const <TodayGameRow>[],
    )..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final result = growthIq(
      rows.map(toGrowthGame).toList(),
      ageBandFromString(p.ageBand),
    );

    return TodaySnapshot(
      playerId: p.playerId,
      firstName: p.firstName,
      lastName: p.lastName,
      profilePic: p.profilePic,
      totalGames: p.totalGames,
      totalPoints: p.totalPoints,
      // Locked stays null, so the player is absent from the header rather
      // than shown with a provisional number.
      growthIq: result.locked ? null : result.score,
      growthIqDelta: result.locked ? null : result.delta,
      // CARRIED, not re-derived. The snapshot used to work the word out from
      // the sign of the delta, which is how Today came to say "Dipping" about
      // a player their own profile called "Building".
      trend: result.locked ? null : result.trend,
      headline: p.headline,
    );
  }).toList();
}
