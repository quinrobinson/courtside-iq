// Full Breakdown — Phase 4.11c
//
// Every stat the app records, grouped into the four families Growth IQ is
// built from, over a chosen window of games.
//
// Measured from Full Breakdown (435:1922): four sections - Scoring,
// Rebounding, Playmaking, Defense - each a grid of centred tiles carrying a
// value, a label, and a supporting count.
//
// Pure Dart. The rate metrics (PPSA, AST/TOV, disruption) come from
// game_metrics.dart rather than being recomputed here, because that file is
// the mirror of the TypeScript the AI insights use. A breakdown that computed
// its own efficiency would let a parent read one number here and a different
// one in their player's story.

import 'game_metrics.dart';
import 'player_averages.dart';

/// Which games the breakdown covers.
enum BreakdownWindow { last5, last10, season }

extension BreakdownWindowLabel on BreakdownWindow {
  String get label => switch (this) {
        BreakdownWindow.last5 => 'Last 5',
        BreakdownWindow.last10 => 'Last 10',
        BreakdownWindow.season => 'Season',
      };

  /// Null means "everything".
  int? get gameCount => switch (this) {
        BreakdownWindow.last5 => 5,
        BreakdownWindow.last10 => 10,
        BreakdownWindow.season => null,
      };
}

class BreakdownTile {
  /// Pre-formatted, or null when there is nothing honest to show. The UI draws
  /// a dash: an empty tile in a seamed grid looks broken, and a zero would be
  /// a claim the data does not support.
  final String? value;

  final String label;

  /// The count behind the value - "222 total", "78 of 166", "efficiency".
  final String sub;

  const BreakdownTile({
    required this.value,
    required this.label,
    required this.sub,
  });
}

class BreakdownSection {
  final String title;
  final List<BreakdownTile> tiles;

  const BreakdownSection({required this.title, required this.tiles});
}

/// Builds the four sections for [window] from games ordered NEWEST FIRST.
List<BreakdownSection> buildBreakdown(
  List<AveragesGameRow> allGames,
  BreakdownWindow window,
) {
  final n = window.gameCount;
  final games =
      n == null ? allGames : allGames.take(n).toList(growable: false);
  final count = games.length;

  int sum(int Function(AveragesGameRow) f) =>
      games.fold<int>(0, (a, r) => a + f(r));

  /// Per-game average, or null when there are no games to average.
  String? avg(int total) =>
      count == 0 ? null : (total / count).toStringAsFixed(1);

  /// A shooting percentage, or null when the shot was never attempted.
  String? pct(int made, int attempted) =>
      attempted == 0 ? null : '${(made / attempted * 100).round()}%';

  final points = sum((r) => r.points);
  final fgMade = sum((r) => r.fgMade);
  final fgAtt = sum((r) => r.fgAttempt);
  final tpMade = sum((r) => r.threeMade);
  final tpAtt = sum((r) => r.threeAttempt);
  final ftMade = sum((r) => r.ftMade);
  final ftAtt = sum((r) => r.ftAttempt);
  final oreb = sum((r) => r.offReb);
  final dreb = sum((r) => r.defReb);
  final assists = sum((r) => r.assist);
  final turnovers = sum((r) => r.turnover);
  final steals = sum((r) => r.steal);
  final blocks = sum((r) => r.block);

  // Points per shot attempt, over the window as a whole. Uses the shared
  // formula, whose denominator is fga + 0.44 * fta - the true-shooting free
  // throw factor, NOT total attempts.
  final ppsaValue = ppsa(
    fgAttempted: fgAtt,
    ftAttempted: ftAtt,
    points: points,
  );
  final ppsaQualified =
      ppsaQualifies(fgAttempted: fgAtt, ftAttempted: ftAtt);

  // Assist-to-turnover over the window. Null below the assist minimum, where
  // the ratio would swing wildly on a single play.
  final astTov = astTovRatio(assists: assists, turnovers: turnovers);

  // Disruption is a PER-GAME score, so it is averaged rather than summed -
  // a season total would grow with games played and mean nothing.
  final disruption = count == 0
      ? null
      : games
              .map((r) => disruptScore(
                    steals: r.steal,
                    blocks: r.block,
                    oreb: r.offReb,
                    dreb: r.defReb,
                  ))
              .fold<int>(0, (a, b) => a + b) /
          count;

  return [
    BreakdownSection(title: 'Scoring', tiles: [
      BreakdownTile(
        value: avg(points),
        label: 'Points',
        sub: '$points total',
      ),
      BreakdownTile(
        value: pct(fgMade, fgAtt),
        label: 'Field goal',
        sub: '$fgMade of $fgAtt',
      ),
      BreakdownTile(
        value: pct(tpMade, tpAtt),
        label: '3-point',
        sub: '$tpMade of $tpAtt',
      ),
      BreakdownTile(
        value: pct(ftMade, ftAtt),
        label: 'Free throw',
        sub: '$ftMade of $ftAtt',
      ),
      BreakdownTile(
        // Below the attempt minimum a single lucky basket reads as elite
        // efficiency, so the tile shows nothing rather than a flattering lie.
        value: ppsaQualified ? ppsaValue.toStringAsFixed(2) : null,
        label: 'Pts / shot',
        sub: 'efficiency',
      ),
    ]),
    BreakdownSection(title: 'Rebounding', tiles: [
      BreakdownTile(
        value: avg(oreb + dreb),
        label: 'Rebounds',
        sub: '${oreb + dreb} total',
      ),
      BreakdownTile(
        value: avg(oreb),
        label: 'Offensive',
        sub: '$oreb total',
      ),
      BreakdownTile(
        value: avg(dreb),
        label: 'Defensive',
        sub: '$dreb total',
      ),
    ]),
    BreakdownSection(title: 'Playmaking', tiles: [
      BreakdownTile(
        value: avg(assists),
        label: 'Assists',
        sub: '$assists total',
      ),
      BreakdownTile(
        value: avg(turnovers),
        label: 'Turnovers',
        sub: '$turnovers total',
      ),
      BreakdownTile(
        value: astTov?.toStringAsFixed(1),
        label: 'Ast / TO',
        sub: 'ratio',
      ),
    ]),
    BreakdownSection(title: 'Defense', tiles: [
      BreakdownTile(
        value: avg(steals),
        label: 'Steals',
        sub: '$steals total',
      ),
      BreakdownTile(
        value: avg(blocks),
        label: 'Blocks',
        sub: '$blocks total',
      ),
      BreakdownTile(
        value: disruption?.toStringAsFixed(1),
        label: 'Disruption',
        sub: 'score',
      ),
    ]),
  ];
}

/// Windows a player has enough games to fill.
///
/// A player with three games gets "Season" only. Offering "Last 10" to them
/// would show the same numbers under three different labels, which reads as a
/// broken control rather than a complete one - the same rule as the header's
/// paging dots.
List<BreakdownWindow> availableWindows(int gameCount) => [
      if (gameCount > 5) BreakdownWindow.last5,
      if (gameCount > 10) BreakdownWindow.last10,
      BreakdownWindow.season,
    ];
