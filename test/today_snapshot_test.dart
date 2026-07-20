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

  group('header membership', () {
    test('a player without a Growth IQ is absent, not shown as zero', () {
      // The header is about growth, and growth needs games. A zero would be a
      // claim about the child.
      expect(_snap(growthIq: null).qualifiesForHeader, isFalse);
      expect(_snap(growthIq: 40).qualifiesForHeader, isTrue);
    });

    test('filters out players with no score', () {
      final list = headerSnapshots([
        _snap(first: 'Maya', growthIq: 82, totalGames: 10),
        _snap(first: 'Jordan', growthIq: null, totalGames: 1),
      ]);
      expect(list.map((s) => s.firstName), ['Maya']);
    });

    test('orders by games, so the most trustworthy score leads', () {
      final list = headerSnapshots([
        _snap(first: 'Jordan', growthIq: 70, totalGames: 6),
        _snap(first: 'Maya', growthIq: 82, totalGames: 12),
      ]);
      expect(list.map((s) => s.firstName), ['Maya', 'Jordan']);
    });

    test('breaks ties by name rather than leaving order to chance', () {
      final list = headerSnapshots([
        _snap(first: 'Zoe', growthIq: 70, totalGames: 6),
        _snap(first: 'Amara', growthIq: 82, totalGames: 6),
      ]);
      expect(list.map((s) => s.firstName), ['Amara', 'Zoe']);
    });

    test('CAN return empty, and callers must handle it', () {
      // A user whose players have no games yet has nothing for the header.
      // There is no approved design for that state.
      expect(headerSnapshots([_snap(growthIq: null)]), isEmpty);
      expect(headerSnapshots(const []), isEmpty);
    });

    test('paging follows the FILTERED count, not the player count', () {
      // Two players where only one qualifies is a single-item header, and a
      // lone dot would invite a swipe that does nothing.
      final list = headerSnapshots([
        _snap(first: 'Maya', growthIq: 82),
        _snap(first: 'Jordan', growthIq: null),
      ]);
      expect(showsPlayerPaging(list.length), isFalse);
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
