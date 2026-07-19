import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/game_sync/game_sync_queue.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/pending_game.dart';

PendingGame makeGame(String id, {DateTime? at}) => PendingGame(
      gameId: id,
      statsId: 'stats-$id',
      gameRow: {'id': id, 'opponent_team': 'Suns'},
      statsRow: {'id': 'stats-$id', 'game_id': id, 'points': 14},
      queuedAt: at ?? DateTime.now(),
    );

void main() {
  setUp(() {
    // Fresh storage per test so queues do not leak between them.
    SharedPreferences.setMockInitialValues({});
  });

  group('successful upload', () {
    test('uploads immediately and leaves nothing queued', () async {
      final sent = <String>[];
      final q = GameSyncQueue(uploader: (g) async => sent.add(g.gameId));

      final ok = await q.enqueueAndTry(makeGame('g1'));

      expect(ok, isTrue);
      expect(sent, ['g1']);
      expect(await q.pending(), 0);
    });
  });

  group('offline', () {
    test('a failed upload is queued, not lost', () async {
      final q = GameSyncQueue(uploader: (g) async => throw Exception('offline'));

      final ok = await q.enqueueAndTry(makeGame('g1'));

      // False means "queued for later", NOT "lost". This distinction is the
      // whole point: the parent must be told the game is saved.
      expect(ok, isFalse);
      expect(await q.pending(), 1);
    });

    test('queued game uploads on a later flush', () async {
      var online = false;
      final sent = <String>[];
      final q = GameSyncQueue(uploader: (g) async {
        if (!online) throw Exception('offline');
        sent.add(g.gameId);
      });

      await q.enqueueAndTry(makeGame('g1'));
      expect(await q.pending(), 1);

      online = true;
      final result = await q.flush();

      expect(result.uploaded, 1);
      expect(result.remaining, 0);
      expect(sent, ['g1']);
    });

    test('survives a restart: a new queue sees the persisted game', () async {
      final q1 = GameSyncQueue(uploader: (g) async => throw Exception('offline'));
      await q1.enqueueAndTry(makeGame('g1'));

      // Simulates the app being killed and reopened.
      final q2 = GameSyncQueue(uploader: (g) async {});
      expect(await q2.pending(), 1);

      await q2.flush();
      expect(await q2.pending(), 0);
    });
  });

  group('idempotency', () {
    test('double-tapping save does not queue the game twice', () async {
      final q = GameSyncQueue(uploader: (g) async => throw Exception('offline'));
      final game = makeGame('g1');

      await q.enqueueAndTry(game);
      await q.enqueueAndTry(game);

      expect(await q.pending(), 1);
    });

    test('a retry re-sends the SAME ids, so upsert cannot duplicate', () async {
      final seenGameIds = <String>[];
      var failNext = true;
      final q = GameSyncQueue(uploader: (g) async {
        seenGameIds.add(g.gameId);
        if (failNext) {
          failNext = false;
          throw Exception('timeout');
        }
      });

      await q.enqueueAndTry(makeGame('g1'));
      await q.flush();

      // Same id both times: the server upserts one row, not two.
      expect(seenGameIds, ['g1', 'g1']);
      expect(await q.pending(), 0);
    });
  });

  group('ordering and backoff', () {
    test('flushes oldest first', () async {
      final sent = <String>[];
      final failing =
          GameSyncQueue(uploader: (g) async => throw Exception('offline'));

      final old = DateTime.now().subtract(const Duration(hours: 3));
      await failing.enqueueAndTry(makeGame('newer'));
      await failing.enqueueAndTry(makeGame('older', at: old));

      final q = GameSyncQueue(uploader: (g) async => sent.add(g.gameId));
      await q.flush();

      expect(sent.first, 'older');
    });

    test('stops after maxAttempts and reports the game as stuck', () async {
      var calls = 0;
      final q = GameSyncQueue(uploader: (g) async {
        calls++;
        throw Exception('offline');
      });

      await q.enqueueAndTry(makeGame('g1'));
      for (var i = 0; i < GameSyncQueue.maxAttempts + 3; i++) {
        await q.flush();
      }

      expect(calls, lessThanOrEqualTo(GameSyncQueue.maxAttempts));
      expect((await q.stuck()).length, 1);
      // Critically: still queued. Giving up must never mean discarding.
      expect(await q.pending(), 1);
    });

    test('retryStuck resets attempts and re-sends', () async {
      var online = false;
      final q = GameSyncQueue(uploader: (g) async {
        if (!online) throw Exception('offline');
      });

      await q.enqueueAndTry(makeGame('g1'));
      for (var i = 0; i < GameSyncQueue.maxAttempts + 1; i++) {
        await q.flush();
      }
      expect((await q.stuck()).length, 1);

      online = true;
      await q.retryStuck();

      expect(await q.pending(), 0);
    });
  });

  group('corrupt storage', () {
    test('a bad entry does not take the whole queue down', () async {
      final good = makeGame('g1').toJson();
      SharedPreferences.setMockInitialValues({
        'ciq_pending_games_v1': '[{"garbage":true}, ${_json(good)}]',
      });

      final q = GameSyncQueue(uploader: (g) async {});
      // The valid game survives; the corrupt one is skipped rather than
      // throwing away a real game alongside it.
      expect(await q.pending(), 1);
    });

    test('unparseable storage yields an empty queue, not a crash', () async {
      SharedPreferences.setMockInitialValues({
        'ciq_pending_games_v1': 'not json at all',
      });
      final q = GameSyncQueue(uploader: (g) async {});
      expect(await q.pending(), 0);
    });
  });
}

String _json(Map<String, dynamic> m) => PendingGame.encodeList([
      PendingGame.fromJson(m),
    ]).replaceAll(RegExp(r'^\[|\]$'), '');
