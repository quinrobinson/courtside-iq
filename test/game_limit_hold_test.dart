import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/game_sync/game_sync_queue.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/game_upload_steps.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/pending_game.dart';

// Roadmap 3.8: a 4th game tracked offline that the server refuses at sync is
// HELD on the phone, never dropped, never "stuck", and syncs once premium.

PendingGame _game(String id, {String opponent = 'Eagles'}) => PendingGame(
      gameId: id,
      statsId: 'stats-$id',
      gameRow: {'id': id, 'opponent_team': opponent},
      statsRow: {'id': 'stats-$id', 'game_id': id, 'points': 8},
      queuedAt: DateTime(2026, 10, 4),
    );

class _RlsError implements Exception {
  const _RlsError();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('upload steps', () {
    test('a refused games row becomes GameLimitRefusal, nothing else is sent',
        () async {
      final writes = <String>[];
      final call = runGameUpload(
        _game('g4'),
        upsert: (table, rows) async {
          if (table == 'games') throw const _RlsError();
          writes.add(table);
        },
        requestInsight: (_) async {},
        isLimitRefusal: (e) => e is _RlsError,
      );
      await expectLater(call, throwsA(isA<GameLimitRefusal>()));
      // The stats row and the insight never went up, so the game is whole in
      // the queue rather than half-saved on the server.
      expect(writes, isEmpty);
    });

    test('other errors still surface unchanged', () async {
      final call = runGameUpload(
        _game('g1'),
        upsert: (table, rows) async => throw Exception('network'),
        requestInsight: (_) async {},
        isLimitRefusal: (e) => e is _RlsError,
      );
      await expectLater(call, throwsA(isA<Exception>()));
      await expectLater(call, throwsA(isNot(isA<GameLimitRefusal>())));
    });
  });

  group('queue', () {
    test('a refused game is held, kept, and burns no attempts', () async {
      final q = GameSyncQueue(
          uploader: (g) async => throw const GameLimitRefusal());

      final ok = await q.enqueueAndTry(_game('g4'));

      expect(ok, isFalse);
      expect(await q.pending(), 1);
      final held = await q.heldForLimit();
      expect(held.single.gameId, 'g4');
      expect(held.single.attempts, 0);
      expect(await q.stuck(), isEmpty);
    });

    test('held games are never marked stuck, however many flushes', () async {
      final q = GameSyncQueue(
          uploader: (g) async => throw const GameLimitRefusal());
      await q.enqueueAndTry(_game('g4'));
      for (var i = 0; i < GameSyncQueue.maxAttempts + 3; i++) {
        await q.flush();
      }
      expect(await q.pending(), 1);
      expect(await q.stuck(), isEmpty);
    });

    test('a held game does not block the games behind it', () async {
      final sent = <String>[];
      final q = GameSyncQueue(uploader: (g) async {
        if (g.gameId == 'g4') throw const GameLimitRefusal();
        sent.add(g.gameId);
      });
      // Both queued while offline.
      final offline = GameSyncQueue(
          uploader: (g) async => throw Exception('offline'));
      await offline.enqueueAndTry(_game('g4'));
      await offline.enqueueAndTry(_game('g-resave'));

      await q.flush();

      expect(sent, ['g-resave']);
      expect((await q.heldForLimit()).single.gameId, 'g4');
    });

    test('once premium, the held game syncs on the next flush', () async {
      var premium = false;
      final sent = <String>[];
      final q = GameSyncQueue(uploader: (g) async {
        if (!premium) throw const GameLimitRefusal();
        sent.add(g.gameId);
      });
      await q.enqueueAndTry(_game('g4'));
      expect(await q.heldForLimit(), hasLength(1));

      premium = true;
      final result = await q.flush();

      expect(result.uploaded, 1);
      expect(sent, ['g4']);
      expect(await q.pending(), 0);
    });

    test('held survives an app restart', () async {
      final q1 = GameSyncQueue(
          uploader: (g) async => throw const GameLimitRefusal());
      await q1.enqueueAndTry(_game('g4'));

      final q2 = GameSyncQueue(
          uploader: (g) async => throw const GameLimitRefusal());
      expect((await q2.heldForLimit()).single.gameId, 'g4');
    });
  });

  group('PendingGame', () {
    test('heldForLimit round-trips, and older payloads read as not held', () {
      final held = _game('g4').copyWith(heldForLimit: true);
      expect(PendingGame.fromJson(held.toJson()).heldForLimit, isTrue);

      final legacy = _game('g1').toJson()..remove('heldForLimit');
      expect(PendingGame.fromJson(legacy).heldForLimit, isFalse);
    });

    test('copyWith keeps the flag when bumping attempts', () {
      final held = _game('g4').copyWith(heldForLimit: true);
      expect(held.copyWith(attempts: 2).heldForLimit, isTrue);
    });
  });

  group('games stuck on 2.0, after the update', () {
    // A free parent on 2.0 tracks a 4th game, the server refuses it, and 2.0
    // retries it to stuck. 2.1 must still catch it as held.
    PendingGame stuckGame() => _game('g4')
        .copyWith(attempts: GameSyncQueue.maxAttempts);

    test('the first 2.1 launch retries it and holds it', () async {
      SharedPreferences.setMockInitialValues({
        'ciq_pending_games_v1': PendingGame.encodeList([stuckGame()]),
      });
      final q = GameSyncQueue(
          uploader: (g) async => throw const GameLimitRefusal());

      await q.resetStuckOnce();
      await q.flush();

      final held = await q.heldForLimit();
      expect(held.single.gameId, 'g4');
      expect(await q.stuck(), isEmpty);
    });

    test('runs once per install, so a game stuck later stays stuck',
        () async {
      SharedPreferences.setMockInitialValues({});
      final q = GameSyncQueue(uploader: (g) async => throw Exception('net'));
      await q.resetStuckOnce();

      SharedPreferences.setMockInitialValues({
        'ciq_pending_games_v1': PendingGame.encodeList([stuckGame()]),
        'ciq_stuck_reset_v2_1': true,
      });
      await q.resetStuckOnce();

      expect((await q.stuck()).single.attempts, GameSyncQueue.maxAttempts);
    });
  });
}
