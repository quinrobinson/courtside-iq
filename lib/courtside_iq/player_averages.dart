// Player averages — Phase 4.11b
//
// Turns raw per-game rows into the six season averages and three shooting
// percentages the Averages tab shows, plus the delta behind each trend chip.
//
// Pure Dart. No Flutter, no Supabase - the same rule as growth_iq.dart, and
// for the same reason: these are the numbers a parent reads about their child,
// so they must be testable without a network.

/// One logged game, already ordered NEWEST FIRST by the caller.
class AveragesGameRow {
  final int points;
  final int offReb;
  final int defReb;
  final int assist;
  final int steal;
  final int block;
  final int turnover;
  final int fgMade;
  final int fgAttempt;
  final int threeMade;
  final int threeAttempt;
  final int ftMade;
  final int ftAttempt;

  const AveragesGameRow({
    this.points = 0,
    this.offReb = 0,
    this.defReb = 0,
    this.assist = 0,
    this.steal = 0,
    this.block = 0,
    this.turnover = 0,
    this.fgMade = 0,
    this.fgAttempt = 0,
    this.threeMade = 0,
    this.threeAttempt = 0,
    this.ftMade = 0,
    this.ftAttempt = 0,
  });

  int get rebounds => offReb + defReb;
}

/// A single stat: its season average and, when there is enough history, how
/// the recent window compares with what came before.
class AverageStat {
  /// Season average, or the lifetime percentage for a shooting stat.
  final double value;

  /// Recent window minus prior window. NULL when there is no honest
  /// comparison to make - which is most players, most of the time.
  final double? delta;

  const AverageStat(this.value, [this.delta]);

  bool get hasDelta => delta != null;
}

/// Games in the recent window.
const int kAveragesWindow = 5;

/// Minimum games on EACH side of the comparison before a delta is shown.
///
/// Both sides, not just the recent one. A three-game recent window measured
/// against a single earlier game is not a trend, it is that one game.
const int kAveragesMinWindow = 3;

class PlayerAverages {
  final int games;

  final AverageStat points;
  final AverageStat rebounds;
  final AverageStat assists;
  final AverageStat steals;
  final AverageStat blocks;
  final AverageStat turnovers;

  /// Null when the player has never attempted that shot. A player who has not
  /// taken a three shows nothing, never "0%" - which would read as a miss.
  final AverageStat? fieldGoal;
  final AverageStat? threePoint;
  final AverageStat? freeThrow;

  const PlayerAverages({
    required this.games,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.turnovers,
    this.fieldGoal,
    this.threePoint,
    this.freeThrow,
  });

  bool get hasShooting =>
      fieldGoal != null || threePoint != null || freeThrow != null;
}

/// Builds the tab's numbers from the player's games, newest first.
///
/// Deltas compare the last [kAveragesWindow] games against EVERYTHING BEFORE
/// THEM, not against the lifetime figure. Comparing a window to a lifetime
/// that contains it damps every movement toward zero, and the more games a
/// player logs the smaller their improvement appears - exactly backwards for
/// an app about development.
PlayerAverages buildPlayerAverages(List<AveragesGameRow> games) {
  if (games.isEmpty) {
    return const PlayerAverages(
      games: 0,
      points: AverageStat(0),
      rebounds: AverageStat(0),
      assists: AverageStat(0),
      steals: AverageStat(0),
      blocks: AverageStat(0),
      turnovers: AverageStat(0),
    );
  }

  final recent = games.take(kAveragesWindow).toList();
  final prior = games.skip(kAveragesWindow).toList();
  final comparable =
      recent.length >= kAveragesMinWindow && prior.length >= kAveragesMinWindow;

  double avg(List<AveragesGameRow> rows, int Function(AveragesGameRow) f) =>
      rows.isEmpty ? 0 : rows.fold<int>(0, (a, r) => a + f(r)) / rows.length;

  AverageStat stat(int Function(AveragesGameRow) f) {
    final value = avg(games, f);
    if (!comparable) return AverageStat(value);
    return AverageStat(value, avg(recent, f) - avg(prior, f));
  }

  /// Percentage over a window, or null when nothing was attempted.
  double? pct(
    List<AveragesGameRow> rows,
    int Function(AveragesGameRow) made,
    int Function(AveragesGameRow) att,
  ) {
    final a = rows.fold<int>(0, (x, r) => x + att(r));
    if (a == 0) return null;
    final m = rows.fold<int>(0, (x, r) => x + made(r));
    return m / a * 100;
  }

  AverageStat? shot(
    int Function(AveragesGameRow) made,
    int Function(AveragesGameRow) att,
  ) {
    final lifetime = pct(games, made, att);
    if (lifetime == null) return null;
    if (!comparable) return AverageStat(lifetime);
    final r = pct(recent, made, att);
    final p = pct(prior, made, att);
    // A window where the player never took that shot has no percentage, so
    // there is nothing to compare - show the lifetime figure alone.
    if (r == null || p == null) return AverageStat(lifetime);
    return AverageStat(lifetime, r - p);
  }

  return PlayerAverages(
    games: games.length,
    points: stat((r) => r.points),
    rebounds: stat((r) => r.rebounds),
    assists: stat((r) => r.assist),
    steals: stat((r) => r.steal),
    blocks: stat((r) => r.block),
    turnovers: stat((r) => r.turnover),
    fieldGoal: shot((r) => r.fgMade, (r) => r.fgAttempt),
    threePoint: shot((r) => r.threeMade, (r) => r.threeAttempt),
    freeThrow: shot((r) => r.ftMade, (r) => r.ftAttempt),
  );
}
