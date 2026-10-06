import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/game_sync/game_sync_queue.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/game_upload_steps.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/pending_game.dart';

PendingGame makeGame({bool withEvents = true}) => PendingGame(
      gameId: 'g1',
      statsId: 's1',
      gameRow: {'id': 'g1', 'opponent_team': 'Suns'},
      statsRow: {'id': 's1', 'game_id': 'g1', 'points': 3},
      eventRows: withEvents
          ? [
              {
                'id': 'e1',
                'game_id': 'g1',
                'player_id': 'p1',
                'event_type': 'three_made',
                'sequence_no': 1,
              },
            ]
          : const [],
      queuedAt: DateTime(2026, 9, 27),
    );

/// Records every write, and fails any table named in [failOn].
class FakeDb {
  FakeDb({this.failOn = const {}});

  final Set<String> failOn;
  final writes = <String>[];
  final insights = <String>[];

  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    if (failOn.contains(table)) throw Exception('$table: network');
    writes.add(table);
  }

  Future<void> insight(String gameId) async => insights.add(gameId);
}

Future<void> run(PendingGame game, FakeDb db,
        {InsightRequester? requestInsight}) =>
    runGameUpload(game,
        upsert: db.upsert, requestInsight: requestInsight ?? db.insight);

void main() {
  group('order (G1.14)', () {
    test('events land before stats, so the stats insert carries derived totals',
        () async {
      final db = FakeDb();
      await run(makeGame(), db);

      expect(db.writes, ['games', 'stat_events', 'player_game_stats']);
      expect(db.insights, ['g1']);
    });

    test('a game with no events skips that step and keeps its totals',
        () async {
      final db = FakeDb();
      await run(makeGame(withEvents: false), db);

      expect(db.writes, ['games', 'player_game_stats']);
      expect(db.insights, ['g1']);
    });
  });

  group('failures', () {
    test('a failed events upload FAILS the upload - no stats, no insight',
        () async {
      // Before G1.14 this was logged and swallowed. Events are the totals now,
      // so a game saved without them would keep numbers nothing can check.
      final db = FakeDb(failOn: {'stat_events'});

      await expectLater(run(makeGame(), db), throwsException);
      expect(db.writes, ['games']);
      expect(db.insights, isEmpty);
    });

    test('a failed insight never fails the upload', () async {
      final db = FakeDb();
      await run(makeGame(), db,
          requestInsight: (_) async => throw Exception('function down'));

      expect(db.writes, ['games', 'stat_events', 'player_game_stats']);
    });
  });

  group('through the queue', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('an events failure keeps the game queued, then the retry lands it all',
        () async {
      var eventsDown = true;
      final writes = <String>[];
      final q = GameSyncQueue(
        uploader: (g) => runGameUpload(
          g,
          upsert: (table, rows) async {
            if (table == 'stat_events' && eventsDown) {
              throw Exception('offline');
            }
            writes.add(table);
          },
          requestInsight: (_) async {},
        ),
      );

      expect(await q.enqueueAndTry(makeGame()), isFalse);
      expect(await q.pending(), 1);

      eventsDown = false;
      await q.flush();

      expect(await q.pending(), 0);
      // The retry re-sends the game row too. Every write is an upsert by
      // client id, so that is harmless - and it is why the retry is safe.
      expect(writes, ['games', 'games', 'stat_events', 'player_game_stats']);
    });
  });
}
