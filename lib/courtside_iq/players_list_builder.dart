// Players list assembly — Phase 4.11a
//
// One row per player: identity, season averages, and a Growth IQ. Pure Dart -
// the averages are arithmetic and the Growth IQ reuses the same client-side
// formula the Today header uses, so nothing here needs a network to be tested.
//
// AVERAGES COME FROM LIFETIME TOTALS, Growth IQ from per-game rows. PPG/RPG/APG
// are just totals over games and need no game-by-game data; Growth IQ compares
// rolling windows and does. The two sources are kept distinct on purpose.

import 'game_metrics.dart';
import 'growth_iq.dart';
import 'metrics_config.dart';
import 'today_builder.dart' show TodayGameRow, toGrowthGame;

class PlayerListEntry {
  const PlayerListEntry({
    required this.playerId,
    required this.firstName,
    this.lastName,
    this.profilePic,
    this.position,
    this.ageBand,
    this.hasBirthDate = true,
    required this.totalGames,
    required this.totalPoints,
    required this.totalRebounds,
    required this.totalAssists,
    this.growthIq,
    this.growthIqDelta,
    this.trend,
  });

  final String playerId;
  final String firstName;
  final String? lastName;
  final String? profilePic;

  /// Raw strings from the view, shown as typed. v1 joins them the same way.
  final String? position;
  /// The band a rating was computed against. PRESENT EVEN WHEN ASSUMED - see
  /// [hasBirthDate] before showing it to anyone.
  final String? ageBand;

  /// False when the player has no birth date.
  ///
  /// get_age_band() returns '11U-13U' for a null birth date, so ageBand is
  /// NEVER null and cannot be used to tell "we know" from "we guessed". The
  /// band is still needed for the rating maths; this is what says whether it
  /// is a fact.
  final bool hasBirthDate;

  /// The band, only when it is actually known.
  String? get knownAgeBand => hasBirthDate ? ageBand : null;

  final int totalGames;
  final int totalPoints;
  final int totalRebounds;
  final int totalAssists;

  /// Null when there are too few games. The row then shows no gauge, the same
  /// rule the header uses - a zero would be a claim about the child.
  final int? growthIq;
  final int? growthIqDelta;

  /// Growth IQ's own classification, by movement threshold. INDEPENDENT of the
  /// delta's sign: a low-but-positive mover is "Building", a steady one can
  /// still carry a small +delta. Building / Steady / Rising, never a negative
  /// word - every level stays survivable.
  final GrowthTrend? trend;

  String get displayName =>
      lastName == null || lastName!.isEmpty ? firstName : '$firstName $lastName';

  double? _avg(int total) => totalGames <= 0 ? null : total / totalGames;

  /// One decimal, e.g. "18.5". Null when no games have been played, so the row
  /// shows nothing rather than "0.0" for a season that never happened.
  String? get ppg => _fmt(_avg(totalPoints));
  String? get rpg => _fmt(_avg(totalRebounds));
  String? get apg => _fmt(_avg(totalAssists));

  static String? _fmt(double? v) => v?.toStringAsFixed(1);

  bool get hasGrowthIq => growthIq != null;

  /// "position, ageBand · N games", dropping whichever pieces are missing.
  ///
  /// A player added but not yet detailed has no position or band, and the
  /// subtitle must not read "null, null · 0 games" or leave stray separators.
  String get subtitle {
    final left = <String>[
      if (position != null && position!.trim().isNotEmpty) position!.trim(),
      // knownAgeBand, not ageBand: an assumed band must not read as a fact.
      if (knownAgeBand != null && knownAgeBand!.trim().isNotEmpty)
        knownAgeBand!.trim(),
    ].join(', ');
    final games = '$totalGames ${totalGames == 1 ? 'game' : 'games'}';
    return left.isEmpty ? games : '$left · $games';
  }

}

class PlayerListPlayerRow {
  const PlayerListPlayerRow({
    required this.playerId,
    required this.firstName,
    this.lastName,
    this.profilePic,
    this.position,
    this.ageBand,
    this.hasBirthDate = true,
    required this.totalGames,
    required this.totalPoints,
    required this.totalRebounds,
    required this.totalAssists,
  });

  final String playerId;
  final String firstName;
  final String? lastName;
  final String? profilePic;
  final String? position;
  final String? ageBand;

  /// See [PlayerListEntry.hasBirthDate]. Set from `birth_date != null`, not
  /// from the band, which is never null.
  final bool hasBirthDate;

  final int totalGames;
  final int totalPoints;
  final int totalRebounds;
  final int totalAssists;
}

/// Builds one entry per player, Growth IQ included where computable.
///
/// [games] may hold rows for any number of players in any order. As in the
/// header, they are grouped per player and sorted OLDEST FIRST before Growth
/// IQ, since it compares the latest window against the prior one - newest
/// first would invert every trend.
List<PlayerListEntry> buildPlayerList({
  required List<PlayerListPlayerRow> players,
  required List<TodayGameRow> games,
}) {
  final byPlayer = <String, List<TodayGameRow>>{};
  for (final g in games) {
    (byPlayer[g.playerId] ??= <TodayGameRow>[]).add(g);
  }

  return players.map((p) {
    // List.of, not the raw value: a player with no games falls back to a const
    // list, and sorting an unmodifiable list throws - the same crash that hit
    // the header builder.
    final rows = List<TodayGameRow>.of(
      byPlayer[p.playerId] ?? const <TodayGameRow>[],
    )..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final result = growthIq(
      rows.map(toGrowthGame).toList(),
      ageBandFromString(p.ageBand),
    );

    return PlayerListEntry(
      playerId: p.playerId,
      firstName: p.firstName,
      lastName: p.lastName,
      profilePic: p.profilePic,
      position: p.position,
      ageBand: p.ageBand,
      hasBirthDate: p.hasBirthDate,
      totalGames: p.totalGames,
      totalPoints: p.totalPoints,
      totalRebounds: p.totalRebounds,
      totalAssists: p.totalAssists,
      growthIq: result.locked ? null : result.score,
      growthIqDelta: result.locked ? null : result.delta,
      trend: result.locked ? null : result.trend,
    );
  }).toList();
}
