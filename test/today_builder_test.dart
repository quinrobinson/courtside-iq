import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/metrics_config.dart';
import 'package:courtside_i_q/courtside_iq/today_builder.dart';

TodayGameRow _game({
  String player = 'p1',
  required int day,
  int points = 20,
  int fga = 12,
  int fta = 4,
  int oreb = 2,
  int dreb = 4,
  int assist = 5,
  int steal = 3,
  int turnover = 2,
  int block = 1,
}) =>
    TodayGameRow(
      playerId: player,
      gameId: 'g$day',
      createdAt: DateTime(2026, 1, day),
      points: points,
      fgAttempt: fga,
      ftAttempt: fta,
      offReb: oreb,
      defReb: dreb,
      assist: assist,
      steal: steal,
      turnover: turnover,
      block: block,
    );

TodayPlayerRow _player({
  String id = 'p1',
  String first = 'Maya',
  int totalGames = 10,
  int totalPoints = 185,
  String? band = '11U-13U',
}) =>
    TodayPlayerRow(
      playerId: id,
      firstName: first,
      totalGames: totalGames,
      totalPoints: totalPoints,
      ageBand: band,
    );

void main() {
  group('toGrowthGame', () {
    test('drops efficiency for a game with too few attempts', () {
      // Two shots is not an efficiency performance. Contributing a wild figure
      // is worse than contributing none.
      final g = toGrowthGame(_game(day: 1, fga: 2, fta: 0, points: 6));
      expect(g.ppsa, isNull);
    });

    test('keeps efficiency once the gate is cleared', () {
      final g = toGrowthGame(_game(day: 1, fga: 10, fta: 4, points: 22));
      expect(g.ppsa, closeTo(22 / (10 + 0.44 * 4), 1e-9));
    });

    test('drops playmaking below the assist minimum', () {
      final g = toGrowthGame(
          _game(day: 1, assist: kAstTovMinAssists - 1, turnover: 0));
      expect(g.astTov, isNull);
    });

    test('drops disruption for a quiet game', () {
      final g = toGrowthGame(
          _game(day: 1, steal: 0, block: 0, oreb: 0, dreb: 1));
      expect(g.disrupt, isNull);
    });
  });

  group('buildTodaySnapshots', () {
    test('orders games oldest first before scoring', () {
      // Growth IQ compares the latest window against the previous one.
      // Newest-first would invert every trend, reporting improvement as
      // decline - the single worst thing this screen could get wrong.
      final ascending = [for (var d = 1; d <= 10; d++) _game(day: d)];
      final descending = ascending.reversed.toList();

      final a = buildTodaySnapshots(
          players: [_player()], games: ascending).single;
      final b = buildTodaySnapshots(
          players: [_player()], games: descending).single;

      expect(a.growthIq, b.growthIq);
      expect(a.growthIqDelta, b.growthIqDelta);
    });

    test('a player with too few games gets no score, not a zero', () {
      final s = buildTodaySnapshots(
        players: [_player(totalGames: 1)],
        games: [_game(day: 1)],
      ).single;
      expect(s.growthIq, isNull);
      expect(s.qualifiesForHeader, isFalse);
    });

    test('a player with no games at all is handled', () {
      final s = buildTodaySnapshots(
        players: [_player(totalGames: 0, totalPoints: 0)],
        games: const [],
      ).single;
      expect(s.growthIq, isNull);
      expect(s.pointsPerGameLabel, isNull);
    });

    test('groups games by player rather than pooling them', () {
      // Pooling would let one player's games unlock another's score.
      final snaps = buildTodaySnapshots(
        players: [_player(id: 'p1'), _player(id: 'p2', first: 'Jordan')],
        games: [
          for (var d = 1; d <= 10; d++) _game(player: 'p1', day: d),
          _game(player: 'p2', day: 11),
        ],
      );
      final jordan = snaps.firstWhere((s) => s.playerId == 'p2');
      expect(jordan.growthIq, isNull, reason: 'one game cannot unlock a score');
    });

    test('carries player identity and totals through', () {
      final s = buildTodaySnapshots(
        players: [_player(totalGames: 10, totalPoints: 185)],
        games: [for (var d = 1; d <= 10; d++) _game(day: d)],
      ).single;
      expect(s.firstName, 'Maya');
      expect(s.pointsPerGameLabel, '18.5 PPG');
    });

    test('a null age band produces NO score, however many games', () {
      // REVERSED 2026-07-21. This used to assert the opposite, on the
      // reasoning that only PPSA is age-banded so a missing band should not
      // lock a player out of the header.
      //
      // The trouble was what "missing band" meant: get_age_band returned
      // '11U-13U' for a null birth date, so the app scored a player of unknown
      // age against middle-school cutoffs and presented it as age-normalised.
      // Age fairness is the entire premise of the number. A rating we cannot
      // stand behind is not shown.
      final s = buildTodaySnapshots(
        players: [_player(band: null)],
        games: [for (var d = 1; d <= 10; d++) _game(day: d)],
      ).single;
      expect(s.growthIq, isNull);
      // And so the player is absent from the header, exactly as one with too
      // few games is.
      expect(s.qualifiesForHeader, isFalse);
    });
  });
}
