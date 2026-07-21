import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/player_averages.dart';

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

void main() {
  test('no games returns zeros and no deltas', () {
    final a = buildPlayerAverages(const []);
    expect(a.games, 0);
    expect(a.points.value, 0);
    expect(a.points.hasDelta, isFalse);
    expect(a.hasShooting, isFalse);
  });

  test('rebounds are offensive plus defensive', () {
    final a = buildPlayerAverages([_g(offReb: 3, defReb: 5)]);
    expect(a.rebounds.value, 8);
  });

  test('a short history shows averages but no deltas', () {
    // Five games: the recent window swallows all of them, leaving nothing to
    // compare against. A delta here would be measuring a window against
    // itself.
    final a = buildPlayerAverages(List.generate(5, (_) => _g(points: 10)));
    expect(a.games, 5);
    expect(a.points.value, 10);
    expect(a.points.hasDelta, isFalse);
  });

  test('deltas compare the recent window with what came before it', () {
    // Newest first: five 20-point games, then five 10-point games.
    final a = buildPlayerAverages([
      ...List.generate(5, (_) => _g(points: 20)),
      ...List.generate(5, (_) => _g(points: 10)),
    ]);
    expect(a.points.value, 15);
    // Recent 20 vs prior 10. Comparing against the lifetime 15 would report
    // +5 and understate a doubling.
    expect(a.points.delta, 10);
  });

  test('a prior window under the minimum yields no delta', () {
    // Seven games: five recent, two prior. Two games is not a baseline.
    final a = buildPlayerAverages([
      ...List.generate(5, (_) => _g(points: 20)),
      ...List.generate(2, (_) => _g(points: 10)),
    ]);
    expect(a.points.hasDelta, isFalse);
  });

  test('shooting percentages weight by attempts, not by game', () {
    // 1/1 then 1/9. Per-game averaging would call this 55%; the real rate is
    // 2 of 10.
    final a = buildPlayerAverages([
      _g(fgMade: 1, fgAttempt: 1),
      _g(fgMade: 1, fgAttempt: 9),
    ]);
    expect(a.fieldGoal!.value, 20);
  });

  test('a shot never attempted is absent, never zero', () {
    final a = buildPlayerAverages([_g(fgMade: 4, fgAttempt: 10)]);
    expect(a.fieldGoal, isNotNull);
    // "0%" would read as a player who tried and missed every three.
    expect(a.threePoint, isNull);
    expect(a.freeThrow, isNull);
    expect(a.hasShooting, isTrue);
  });

  test('a window with no attempts leaves the lifetime figure alone', () {
    // Enough games to compare, but the free throws all sit in the prior
    // window, so there is no recent rate to subtract.
    final a = buildPlayerAverages([
      ...List.generate(5, (_) => _g(points: 8)),
      ...List.generate(5, (_) => _g(points: 8, ftMade: 3, ftAttempt: 4)),
    ]);
    expect(a.freeThrow!.value, 75);
    expect(a.freeThrow!.hasDelta, isFalse);
  });

  test('turnovers carry a delta like any other stat; tone is the UI\'s job',
      () {
    final a = buildPlayerAverages([
      ...List.generate(5, (_) => _g(turnover: 1)),
      ...List.generate(5, (_) => _g(turnover: 3)),
    ]);
    // Fewer turnovers, so the raw delta is negative. buildPlayerAverages does
    // not judge that; AveragesView passes higherIsBetter: false.
    expect(a.turnovers.delta, -2);
  });
}
