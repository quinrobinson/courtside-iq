// Stat events through the offline queue — G1.10
//
// The queue is the ONLY copy of a game between saving and syncing, so the
// tests here are about the two ways a timeline could vanish without anyone
// noticing: dropped on a retry, or dropped when an older payload is decoded.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/game_sync/game_columns.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/pending_game.dart';

Map<String, dynamic> _event(int seq, String type, {String status = 'confirmed'}) => {
      'id': 'e$seq',
      'game_id': 'g1',
      'player_id': 'p1',
      'event_type': type,
      'sequence_no': seq,
      'recorded_at': '2026-09-15T19:00:0${seq}Z',
      'elapsed_ms': seq * 1000,
      'source': 'parent_tap',
      'status': status,
    };

PendingGame _game({List<Map<String, dynamic>>? events}) => PendingGame(
      gameId: 'g1',
      statsId: 's1',
      gameRow: {'id': 'g1', 'player_id': 'p1'},
      statsRow: {'id': 's1', 'game_id': 'g1'},
      eventRows: events ??
          [_event(1, 'two_made'), _event(2, 'def_reb'), _event(3, 'two_made', status: 'voided')],
      queuedAt: DateTime.utc(2026, 9, 15),
    );

void main() {
  group('a retry must not drop the timeline', () {
    test('copyWith carries every event row', () {
      // copyWith runs on EVERY retry to bump attempts. Anything it forgets is
      // silently gone the first time an upload fails, which is exactly when
      // the data matters most.
      final retried = _game().copyWith(attempts: 1, lastError: 'offline');
      expect(retried.eventRows.length, 3);
      expect(retried.eventRows.map((e) => e['sequence_no']), [1, 2, 3]);
      expect(retried.attempts, 1);
    });

    test('survives repeated retries unchanged', () {
      var g = _game();
      for (var i = 1; i <= 5; i++) {
        g = g.copyWith(attempts: i, lastError: 'still offline');
      }
      expect(g.eventRows.length, 3);
      expect(g.attempts, 5);
    });
  });

  group('the outbox is a cross-version format', () {
    test('round trips through json', () {
      final back = PendingGame.fromJson(_game().toJson());
      expect(back.eventRows.length, 3);
      expect(back.eventRows.first['event_type'], 'two_made');
      expect(back.eventRows.last['status'], 'voided');
    });

    test('a payload from before events existed decodes to an empty list', () {
      // A game queued in a gym may be flushed by a build that shipped weeks
      // later. Older payloads have no eventRows key at all, and that must not
      // throw - a PendingGame that cannot be decoded is a lost game.
      final old = {
        'gameId': 'g1',
        'statsId': 's1',
        'gameRow': {'id': 'g1'},
        'statsRow': {'id': 's1'},
        'queuedAt': '2026-08-01T00:00:00Z',
        'attempts': 0,
      };
      final back = PendingGame.fromJson(old);
      expect(back.eventRows, isEmpty);
      expect(back.gameId, 'g1');
    });

    test('a malformed eventRows value degrades to empty, never throws', () {
      for (final bad in ['not a list', 42, {'a': 1}]) {
        final j = _game().toJson()..['eventRows'] = bad;
        expect(PendingGame.fromJson(j).eventRows, isEmpty, reason: '$bad');
      }
    });

    test('one corrupt entry in the list does not take the others down', () {
      final j = _game().toJson()
        ..['eventRows'] = [_event(1, 'two_made'), 'garbage', _event(2, 'steal')];
      expect(PendingGame.fromJson(j).eventRows.length, 2);
    });

    test('a whole queue decodes even with a bad entry beside a good one', () {
      final raw = PendingGame.encodeList([_game(), _game()]);
      final list = PendingGame.decodeList(raw);
      expect(list.length, 2);
      expect(list.every((g) => g.eventRows.length == 3), isTrue);
    });
  });

  group('empty is valid, never a failure', () {
    test('a game with no events is still a complete game', () {
      final g = _game(events: const []);
      expect(g.eventRows, isEmpty);
      expect(PendingGame.fromJson(g.toJson()).eventRows, isEmpty);
      expect(g.copyWith(attempts: 2).eventRows, isEmpty);
    });
  });

  group('conforming against the column list', () {
    test('every key the save path writes is a real stat_events column', () {
      // The same guard that caught started_at and ended_at missing from
      // kGameColumns. A key the table does not have is rejected by PostgREST
      // and then fails on every retry until the queue gives up.
      for (final row in _game().eventRows) {
        final conformed = conformToColumns(row, kStatEventColumns);
        expect(conformed.dropped, isEmpty,
            reason: 'unknown column(s): ${conformed.dropped.join(', ')}');
      }
    });

    test('sheds a key this schema no longer has', () {
      final stale = {..._event(1, 'two_made'), 'quarter': 2};
      final conformed = conformToColumns(stale, kStatEventColumns);
      expect(conformed.dropped, {'quarter'});
      expect(conformed.row.containsKey('quarter'), isFalse);
      expect(conformed.row['event_type'], 'two_made');
    });

    test('the column list matches the migration', () {
      // Transcribed from 20260915000000_stat_events.sql. If a migration adds
      // a column and this is not updated in the same commit, the save path
      // silently stops sending it.
      expect(kStatEventColumns, {
        'id', 'game_id', 'player_id', 'event_type', 'sequence_no',
        'recorded_at', 'elapsed_ms', 'source', 'status', 'confidence',
        'attributes', 'clip_ref', 'merged_into',
      });
    });
  });
}
