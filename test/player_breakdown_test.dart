import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/player_averages.dart';
import 'package:courtside_i_q/courtside_iq/player_breakdown.dart';

AveragesGameRow _g({
  int points = 0,
  int offReb = 0,
  int defReb = 0,
  int assist = 0,
  int steal = 0,
  int block = 0,
  int turnover = 0,
  int fgMade = 0,
  int fgAttempt = 0,
  int threeMade = 0,
  int threeAttempt = 0,
  int ftMade = 0,
  int ftAttempt = 0,
}) =>
    AveragesGameRow(
      points: points,
      offReb: offReb,
      defReb: defReb,
      assist: assist,
      steal: steal,
      block: block,
      turnover: turnover,
      fgMade: fgMade,
      fgAttempt: fgAttempt,
      threeMade: threeMade,
      threeAttempt: threeAttempt,
      ftMade: ftMade,
      ftAttempt: ftAttempt,
    );

BreakdownTile _tile(List<BreakdownSection> s, String label) =>
    s.expand((x) => x.tiles).firstWhere((t) => t.label == label);

void main() {
  test('the four sections match the Growth IQ families', () {
    final s = buildBreakdown([_g(points: 10)], BreakdownWindow.season);
    expect([for (final x in s) x.title],
        ['Scoring', 'Rebounding', 'Playmaking', 'Defense']);
  });

  test('a window takes the most recent games, newest first', () {
    // Five 20-point games then five 10-point games. Last 5 must see the 20s.
    final games = [
      ...List.generate(5, (_) => _g(points: 20)),
      ...List.generate(5, (_) => _g(points: 10)),
    ];
    expect(_tile(buildBreakdown(games, BreakdownWindow.last5), 'Points').value,
        '20.0');
    expect(_tile(buildBreakdown(games, BreakdownWindow.season), 'Points').value,
        '15.0');
  });

  test('the sub line counts only the window, not the season', () {
    final games = List.generate(10, (_) => _g(points: 10));
    expect(_tile(buildBreakdown(games, BreakdownWindow.last5), 'Points').sub,
        '50 total');
    expect(_tile(buildBreakdown(games, BreakdownWindow.season), 'Points').sub,
        '100 total');
  });

  test('a shot never attempted shows nothing, not 0%', () {
    final s = buildBreakdown([_g(fgMade: 4, fgAttempt: 10)],
        BreakdownWindow.season);
    expect(_tile(s, 'Field goal').value, '40%');
    // "0%" would read as a player who tried and missed every three.
    expect(_tile(s, '3-point').value, isNull);
    expect(_tile(s, '3-point').sub, '0 of 0');
  });

  test('efficiency is withheld below the attempt minimum', () {
    // One attempt, one make. Without the gate this reads as elite.
    final thin = buildBreakdown([_g(points: 2, fgMade: 1, fgAttempt: 1)],
        BreakdownWindow.season);
    expect(_tile(thin, 'Pts / shot').value, isNull);

    final real = buildBreakdown(
        [_g(points: 20, fgMade: 8, fgAttempt: 20, ftMade: 4, ftAttempt: 5)],
        BreakdownWindow.season);
    expect(_tile(real, 'Pts / shot').value, isNotNull);
  });

  test('ast/TO is withheld below the assist minimum', () {
    final thin =
        buildBreakdown([_g(assist: 1, turnover: 1)], BreakdownWindow.season);
    expect(_tile(thin, 'Ast / TO').value, isNull);

    final real =
        buildBreakdown([_g(assist: 6, turnover: 3)], BreakdownWindow.season);
    expect(_tile(real, 'Ast / TO').value, '2.0');
  });

  test('disruption is averaged per game, never summed', () {
    // A season total would climb with games played and mean nothing.
    final one = buildBreakdown([_g(steal: 2, block: 1, offReb: 2, defReb: 2)],
        BreakdownWindow.season);
    final five = buildBreakdown(
        List.generate(5, (_) => _g(steal: 2, block: 1, offReb: 2, defReb: 2)),
        BreakdownWindow.season);
    expect(_tile(five, 'Disruption').value, _tile(one, 'Disruption').value);
  });

  test('rebounds split into offensive and defensive and sum back', () {
    final s = buildBreakdown([_g(offReb: 3, defReb: 5)], BreakdownWindow.season);
    expect(_tile(s, 'Rebounds').value, '8.0');
    expect(_tile(s, 'Offensive').value, '3.0');
    expect(_tile(s, 'Defensive').value, '5.0');
  });

  test('no games yields dashes, not zeros', () {
    final s = buildBreakdown(const [], BreakdownWindow.season);
    for (final t in s.expand((x) => x.tiles)) {
      expect(t.value, isNull, reason: t.label);
    }
  });

  group('availableWindows', () {
    test('a short season offers only Season', () {
      // Offering Last 10 to a player with three games would show identical
      // numbers under three labels, which reads as a broken control.
      expect(availableWindows(3), [BreakdownWindow.season]);
      expect(availableWindows(5), [BreakdownWindow.season]);
    });

    test('windows unlock as games accumulate', () {
      expect(availableWindows(6),
          [BreakdownWindow.last5, BreakdownWindow.season]);
      expect(availableWindows(11), [
        BreakdownWindow.last5,
        BreakdownWindow.last10,
        BreakdownWindow.season,
      ]);
    });
  });
}
