// Stat events — G1.8 / G1.9
//
// The property under test throughout is the DUAL-WRITE GUARANTEE: after any
// sequence of taps, every total equals the number of confirmed events of that
// type. If that ever stops holding, the rollup view and player_game_stats
// disagree, and the parallel run in G1.12 is the thing that would find out -
// after a season of real games rather than here.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/courtside_iq/stat_event.dart';

TapResult _tap(TapResult r, LiveStat s, int d, {DateTime? at}) =>
    applyTap(r.stats, r.events, s, d, at: at);

TapResult get _empty => (stats: const LiveGameStats(), events: <StatEvent>[]);

void main() {
  group('recording a tap', () {
    test('appends one confirmed event and moves the total', () {
      final r = _tap(_empty, LiveStat.twoMade, 1);
      expect(r.stats.twoMade, 1);
      expect(r.events.length, 1);
      expect(r.events.single.stat, LiveStat.twoMade);
      expect(r.events.single.isConfirmed, isTrue);
      expect(r.events.single.sequenceNo, 1);
    });

    test('numbers events from one, in tap order', () {
      var r = _empty;
      for (final s in [LiveStat.twoMade, LiveStat.defReb, LiveStat.assists]) {
        r = _tap(r, s, 1);
      }
      expect(r.events.map((e) => e.sequenceNo), [1, 2, 3]);
      expect(r.events.map((e) => e.stat),
          [LiveStat.twoMade, LiveStat.defReb, LiveStat.assists]);
    });
  });

  group('a decrement is a correction, not an event', () {
    test('voids the most recent confirmed event of that type', () {
      var r = _empty;
      r = _tap(r, LiveStat.twoMade, 1);
      r = _tap(r, LiveStat.twoMade, 1);
      r = _tap(r, LiveStat.twoMade, -1);

      expect(r.stats.twoMade, 1);
      expect(r.events.length, 2, reason: 'nothing is removed');
      expect(r.events[0].isConfirmed, isTrue);
      expect(r.events[1].isConfirmed, isFalse, reason: 'the LAST one is voided');
    });

    test('never writes a negative row', () {
      var r = _empty;
      r = _tap(r, LiveStat.steals, 1);
      r = _tap(r, LiveStat.steals, -1);
      expect(r.events.every((e) => e.sequenceNo > 0), isTrue);
      expect(countConfirmed(r.events, LiveStat.steals), 0);
    });

    test('voided events keep their slot, so gaps in the sequence are normal',
        () {
      var r = _empty;
      r = _tap(r, LiveStat.twoMade, 1); // 1
      r = _tap(r, LiveStat.defReb, 1); // 2
      r = _tap(r, LiveStat.twoMade, 1); // 3
      r = _tap(r, LiveStat.twoMade, -1); // voids 3
      r = _tap(r, LiveStat.assists, 1); // 4, not 3

      expect(r.events.map((e) => e.sequenceNo), [1, 2, 3, 4]);
      expect(r.events.last.sequenceNo, 4,
          reason: 'a void does not free its number for reuse');
      final confirmed = r.events.where((e) => e.isConfirmed).toList();
      expect(confirmed.map((e) => e.sequenceNo), [1, 2, 4]);
    });

    test('minus at zero changes neither the total nor the list', () {
      final r = _tap(_empty, LiveStat.blocks, -1);
      expect(r.stats.blocks, 0);
      expect(r.events, isEmpty);
    });

    test('a second minus voids the next one back, not the same one again', () {
      var r = _empty;
      r = _tap(r, LiveStat.ftMade, 1);
      r = _tap(r, LiveStat.ftMade, 1);
      r = _tap(r, LiveStat.ftMade, -1);
      r = _tap(r, LiveStat.ftMade, -1);
      expect(r.stats.ftMade, 0);
      expect(r.events.where((e) => e.isConfirmed), isEmpty);
      expect(r.events.length, 2);
    });

    test('voids only its own stat', () {
      var r = _empty;
      r = _tap(r, LiveStat.twoMade, 1);
      r = _tap(r, LiveStat.threeMade, 1);
      r = _tap(r, LiveStat.threeMade, -1);
      expect(countConfirmed(r.events, LiveStat.twoMade), 1);
      expect(countConfirmed(r.events, LiveStat.threeMade), 0);
    });
  });

  group('the dual-write guarantee', () {
    test('holds after every tap of a random game', () {
      // Both paths a real parent uses: the Make and Miss buttons, and the
      // minus steppers. Seeded so a failure is reproducible.
      final rnd = Random(20260915);
      var r = _empty;
      for (var i = 0; i < 600; i++) {
        final stat = LiveStat.values[rnd.nextInt(LiveStat.values.length)];
        final delta = rnd.nextInt(4) == 0 ? -1 : 1;
        r = _tap(r, stat, delta);
        expect(eventsMatchTotals(r.stats, r.events), isTrue,
            reason: 'drifted at tap $i on ${stat.name} $delta');
      }
      expect(r.events, isNotEmpty);
    });

    test('derived points agree with the confirmed shooting events', () {
      var r = _empty;
      for (var i = 0; i < 3; i++) {
        r = _tap(r, LiveStat.twoMade, 1);
      }
      for (var i = 0; i < 2; i++) {
        r = _tap(r, LiveStat.threeMade, 1);
      }
      r = _tap(r, LiveStat.ftMade, 1);
      r = _tap(r, LiveStat.twoMade, -1);

      final fromEvents = countConfirmed(r.events, LiveStat.twoMade) * 2 +
          countConfirmed(r.events, LiveStat.threeMade) * 3 +
          countConfirmed(r.events, LiveStat.ftMade);
      expect(r.stats.points, fromEvents);
      expect(r.stats.points, 2 * 2 + 3 * 2 + 1);
    });
  });

  group('event type mapping', () {
    test('covers every LiveStat', () {
      for (final s in LiveStat.values) {
        expect(kStatEventType[s], isNotNull, reason: '${s.name} has no type');
      }
    });

    test('uses the singular column names, not the plural enum names', () {
      // player_game_stats uses assist / steal / block / turnover, and the
      // CHECK constraint on stat_events.event_type matches those. Writing the
      // plural would be rejected on upload and fail every retry.
      expect(kStatEventType[LiveStat.assists], 'assist');
      expect(kStatEventType[LiveStat.steals], 'steal');
      expect(kStatEventType[LiveStat.blocks], 'block');
      expect(kStatEventType[LiveStat.turnovers], 'turnover');
    });

    test('every value is one the database will accept', () {
      const allowed = {
        'two_made', 'two_missed', 'three_made', 'three_missed',
        'ft_made', 'ft_missed', 'off_reb', 'def_reb',
        'assist', 'steal', 'block', 'turnover', 'off_foul', 'def_foul',
      };
      for (final v in kStatEventType.values) {
        expect(allowed, contains(v));
      }
    });
  });

  group('serialization survives a round trip', () {
    test('keeps sequence, stat, time and status', () {
      final e = StatEvent(
        sequenceNo: 7,
        stat: LiveStat.offReb,
        recordedAt: DateTime.utc(2026, 9, 15, 19, 4, 12),
        status: StatEventStatus.voided,
      );
      final back = StatEvent.fromJson(e.toJson())!;
      expect(back.sequenceNo, 7);
      expect(back.stat, LiveStat.offReb);
      expect(back.recordedAt.toUtc(), e.recordedAt);
      expect(back.status, StatEventStatus.voided);
    });

    test('returns null rather than guessing at a payload it cannot read', () {
      // The outbox is a cross-version format: a game queued in a gym may be
      // flushed by a build that shipped weeks later.
      for (final bad in <Map<String, dynamic>>[
        {},
        {'seq': 'one', 'stat': 'two_made', 'at': '2026-09-15T00:00:00Z'},
        {'seq': 1, 'stat': 'not_a_stat', 'at': '2026-09-15T00:00:00Z'},
        {'seq': 1, 'stat': 'twoMade', 'at': 'not a date'},
      ]) {
        expect(StatEvent.fromJson(bad), isNull, reason: '$bad');
      }
    });

    test('an unknown status reads as confirmed rather than dropping the play', () {
      final back = StatEvent.fromJson({
        'seq': 2,
        'stat': 'assists',
        'at': '2026-09-15T00:00:00Z',
        'status': 'suggested',
      })!;
      expect(back.isConfirmed, isTrue);
    });
  });
}
