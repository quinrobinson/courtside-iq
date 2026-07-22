import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/live_game.dart';

void main() {
  group('points are derived', () {
    test('from the shots that produced them', () {
      const s = LiveGameStats(twoMade: 4, threeMade: 2, ftMade: 3);
      expect(s.points, 4 * 2 + 2 * 3 + 3);
    });

    test('misses never score', () {
      const s = LiveGameStats(twoMissed: 9, threeMissed: 9, ftMissed: 9);
      expect(s.points, 0);
    });

    test('a stored total can never disagree with the shots', () {
      // The whole reason points is a getter. Adding a make moves the score by
      // exactly that shot's value, always.
      var s = const LiveGameStats();
      s = applyStat(s, LiveStat.threeMade, 1);
      expect(s.points, 3);
      s = applyStat(s, LiveStat.threeMade, -1);
      expect(s.points, 0);
    });
  });

  group('box score conventions', () {
    test('field goals are twos AND threes, never free throws', () {
      // Getting this wrong would quietly change every shooting percentage in
      // the app.
      const s = LiveGameStats(
        twoMade: 3,
        twoMissed: 2,
        threeMade: 1,
        threeMissed: 4,
        ftMade: 5,
        ftMissed: 5,
      );
      expect(s.fgMade, 4);
      expect(s.fgAttempted, 10);
      expect(s.ftAttempted, 10);
    });

    test('rebounds are the two kinds added', () {
      const s = LiveGameStats(offReb: 2, defReb: 5);
      expect(s.rebounds, 7);
    });
  });

  group('applyStat', () {
    test('increments and decrements every stat', () {
      for (final stat in LiveStat.values) {
        var s = applyStat(const LiveGameStats(), stat, 1);
        expect(readStat(s, stat), 1, reason: stat.name);
        s = applyStat(s, stat, -1);
        expect(readStat(s, stat), 0, reason: stat.name);
      }
    });

    test('NOTHING goes below zero', () {
      // A parent cannot un-take a shot that was never taken, and a negative
      // count would poison every percentage downstream.
      for (final stat in LiveStat.values) {
        final s = applyStat(const LiveGameStats(), stat, -1);
        expect(readStat(s, stat), 0, reason: stat.name);
      }
    });

    test('touches only the stat it was given', () {
      final s = applyStat(const LiveGameStats(), LiveStat.assists, 1);
      for (final other in LiveStat.values) {
        if (other == LiveStat.assists) continue;
        expect(readStat(s, other), 0, reason: other.name);
      }
    });
  });

  group('isEmpty', () {
    test('a fresh game is empty', () {
      expect(const LiveGameStats().isEmpty, isTrue);
    });

    test('a missed shot is NOT nothing', () {
      // Ending a game after only misses still discards real tracking.
      expect(const LiveGameStats(twoMissed: 1).isEmpty, isFalse);
    });

    test('any counter makes it non-empty', () {
      for (final stat in LiveStat.values) {
        final s = applyStat(const LiveGameStats(), stat, 1);
        expect(s.isEmpty, isFalse, reason: stat.name);
      }
    });
  });

  group('round trip', () {
    test('survives json in both directions', () {
      // This is what write-through persistence stores, so a lost field is a
      // lost stat after a crash mid-game.
      var s = const LiveGameStats();
      for (final stat in LiveStat.values) {
        s = applyStat(s, stat, LiveStat.values.indexOf(stat) + 1);
      }
      final back = LiveGameStats.fromJson(s.toJson());
      for (final stat in LiveStat.values) {
        expect(readStat(back, stat), readStat(s, stat), reason: stat.name);
      }
      expect(back.points, s.points);
    });

    test('a missing or malformed field reads as zero, not a crash', () {
      final s = LiveGameStats.fromJson({'two_made': '4', 'assists': null});
      expect(s.twoMade, 4);
      expect(s.assists, 0);
      expect(s.points, 8);
    });
  });
}
