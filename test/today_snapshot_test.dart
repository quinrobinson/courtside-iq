import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/today_snapshot.dart';

TodaySnapshot _snap({
  int totalGames = 10,
  int totalPoints = 185,
  int? growthIq = 82,
  int? delta,
  String first = 'Maya',
  String? last = 'Chen',
}) =>
    TodaySnapshot(
      playerId: 'p1',
      firstName: first,
      lastName: last,
      totalGames: totalGames,
      totalPoints: totalPoints,
      growthIq: growthIq,
      growthIqDelta: delta,
    );

void main() {
  group('points per game', () {
    test('averages to one decimal', () {
      expect(_snap(totalGames: 10, totalPoints: 185).pointsPerGameLabel,
          '18.5 PPG');
    });

    test('is null with no games, rather than NaN or a false zero', () {
      // Dividing by zero renders "NaN PPG". Showing "0.0 PPG" is worse: it
      // states a performance that never happened.
      final s = _snap(totalGames: 0, totalPoints: 0);
      expect(s.pointsPerGame, isNull);
      expect(s.pointsPerGameLabel, isNull);
    });

    test('handles a real zero-point game without hiding the average', () {
      // Played and scored nothing is a fact worth showing; no games is not.
      expect(_snap(totalGames: 2, totalPoints: 0).pointsPerGameLabel,
          '0.0 PPG');
    });

    test('rounds rather than truncates', () {
      expect(_snap(totalGames: 3, totalPoints: 56).pointsPerGameLabel,
          '18.7 PPG');
    });
  });

  group('trend', () {
    test('a gain rises, a drop dips', () {
      expect(_snap(delta: 4).trend, TodayTrend.rising);
      expect(_snap(delta: -1).trend, TodayTrend.dipping);
    });

    test('zero is steady, NOT unknown', () {
      // "No change" is information a parent wants. It is different from "we
      // cannot tell yet".
      expect(_snap(delta: 0).trend, TodayTrend.steady);
      expect(_snap(delta: 0).trendLabel, 'Steady');
    });

    test('no delta means no trend, not steady', () {
      expect(_snap(delta: null).trend, isNull);
      expect(_snap(delta: null).trendLabel, isNull);
    });

    test('the down label is survivable', () {
      // This is a child's development shown to their parent. A bad stretch
      // must not read as a verdict.
      final label = _snap(delta: -3).trendLabel!;
      expect(label, 'Dipping');
      for (final harsh in ['Declining', 'Falling', 'Poor', 'Bad', 'Worse']) {
        expect(label, isNot(contains(harsh)));
      }
    });

    test('delta labels carry their sign', () {
      expect(_snap(delta: 4).deltaLabel, '+4');
      expect(_snap(delta: -4).deltaLabel, '-4');
      expect(_snap(delta: 0).deltaLabel, '0');
      expect(_snap(delta: null).deltaLabel, isNull);
    });
  });

  group('locked', () {
    test('no score means locked, and no score is shown', () {
      // A zero would be a claim about the player. "Not enough games yet" is
      // not a claim.
      expect(_snap(growthIq: null).isLocked, isTrue);
      expect(_snap(growthIq: 40).isLocked, isFalse);
    });
  });

  group('display name', () {
    test('joins both names, and survives a missing surname', () {
      expect(_snap().displayName, 'Maya Chen');
      expect(_snap(last: null).displayName, 'Maya');
      expect(_snap(last: '').displayName, 'Maya');
    });
  });

  group('player paging', () {
    test('one player is not a carousel', () {
      // A single dot invites a swipe that does nothing, which reads as a
      // broken control rather than a complete one.
      expect(showsPlayerPaging(0), isFalse);
      expect(showsPlayerPaging(1), isFalse);
      expect(showsPlayerPaging(2), isTrue);
      expect(showsPlayerPaging(3), isTrue);
    });
  });
}
