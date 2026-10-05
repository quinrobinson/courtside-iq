// Outbox for completed games — Phase 4.5.
//
// A parent finishes tracking in a gym with no signal. Before this, the save
// fired two inserts, both failed, and the game was gone. Now the game is
// written to local storage FIRST, then uploaded. If the upload fails it stays
// queued and flushes when connectivity returns.
//
// Two invariants:
//
//   1. Local write happens before the network attempt, always. The queue is
//      the only copy of that game until Supabase confirms it.
//   2. Uploads are idempotent. Both rows carry client-generated ids and are
//      upserted by primary key, so a retry after a timeout that actually
//      succeeded cannot create a duplicate game.
//
// The upload itself is injected rather than imported, so this file stays free
// of Supabase and is testable without a network.

import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_upload_steps.dart' show GameLimitRefusal;
import 'pending_game.dart';

/// Uploads one game. Returns normally on success, throws on failure.
typedef GameUploader = Future<void> Function(PendingGame game);

/// Result of a flush, for surfacing state in the UI.
class FlushResult {
  final int uploaded;
  final int remaining;
  const FlushResult({required this.uploaded, required this.remaining});
}

class GameSyncQueue {
  GameSyncQueue({
    required GameUploader uploader,
    Connectivity? connectivity,
  })  : _uploader = uploader,
        _connectivity = connectivity ?? Connectivity();

  static const _storageKey = 'ciq_pending_games_v1';

  /// Give up auto-retrying after this many attempts and surface the game as
  /// stuck. Retrying invisibly forever hides a real problem from the parent.
  static const maxAttempts = 8;

  /// Set once [resetStuckOnce] has run on this install.
  static const _stuckResetKey = 'ciq_stuck_reset_v2_1';

  final GameUploader _uploader;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _flushing = false;

  /// Emits whenever the queue changes, so UI can show "1 game waiting to sync".
  final _changes = StreamController<int>.broadcast();
  Stream<int> get pendingCount => _changes.stream;

  // --- persistence -----------------------------------------------------------

  Future<List<PendingGame>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    // List.of gives a growable copy. decodeList can return a const [] for the
    // empty case, and callers here add/remove/sort in place.
    return List<PendingGame>.of(
      PendingGame.decodeList(prefs.getString(_storageKey)),
    );
  }

  Future<void> _write(List<PendingGame> games) async {
    final prefs = await SharedPreferences.getInstance();
    if (games.isEmpty) {
      await prefs.remove(_storageKey);
    } else {
      await prefs.setString(_storageKey, PendingGame.encodeList(games));
    }
    _changes.add(games.length);
  }

  Future<int> pending() async => (await _read()).length;

  /// Games that exhausted their retries and need a nudge or a look. A game
  /// held for the free limit is never "stuck" - it is waiting on purpose.
  Future<List<PendingGame>> stuck() async => (await _read())
      .where((g) => !g.heldForLimit && g.attempts >= maxAttempts)
      .toList();

  /// Games the server refused because the free game allowance is used (3.8).
  /// Kept on the phone indefinitely; they sync once the account is premium.
  Future<List<PendingGame>> heldForLimit() async =>
      (await _read()).where((g) => g.heldForLimit).toList();

  // --- the main path ---------------------------------------------------------

  /// Queue a finished game, then try to upload immediately.
  ///
  /// Returns true if it reached Supabase now, false if it is safely queued for
  /// later. **False is not an error** - the game is durably stored either way,
  /// and the caller should tell the parent it is saved, not that it failed.
  Future<bool> enqueueAndTry(PendingGame game) async {
    final games = await _read();

    // Guard against a double-tap on Save producing two copies.
    if (!games.any((g) => g.gameId == game.gameId)) {
      games.add(game);
      await _write(games);
    }

    try {
      await _uploader(game);
      await _remove(game.gameId);
      return true;
    } on GameLimitRefusal {
      await _markHeld(game.gameId);
      return false;
    } catch (e) {
      await _recordFailure(game.gameId, e.toString());
      dev.log('game queued for later sync: $e', name: 'GameSyncQueue');
      return false;
    }
  }

  /// Attempt every queued game oldest-first. Safe to call repeatedly.
  Future<FlushResult> flush() async {
    if (_flushing) {
      return FlushResult(uploaded: 0, remaining: await pending());
    }
    _flushing = true;
    var uploaded = 0;

    try {
      final games = await _read()
        ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));

      for (final game in games) {
        if (game.attempts >= maxAttempts) continue;
        try {
          await _uploader(game);
          await _remove(game.gameId);
          uploaded++;
        } on GameLimitRefusal {
          // Not a network failure: the next game may sync fine (a premium
          // purchase, or a re-save of a game already on the server), so mark
          // this one held and keep going rather than breaking.
          await _markHeld(game.gameId);
        } catch (e) {
          await _recordFailure(game.gameId, e.toString());
          // Stop on the first failure: if the network is down, hammering the
          // rest just burns attempts on games that would fail identically.
          break;
        }
      }
    } finally {
      _flushing = false;
    }

    return FlushResult(uploaded: uploaded, remaining: await pending());
  }

  /// Flush when connectivity returns, so a parent who leaves the gym does not
  /// have to think about it. Call once at app start.
  ///
  /// Also flushes immediately: a game queued in a previous session must sync
  /// on next launch, not sit waiting for a connectivity *change* that may
  /// never come if the phone is already online.
  void startAutoFlush() {
    unawaited(resetStuckOnce().then((_) => flush()));
    _connSub ??= _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) unawaited(flush());
    });
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    _connSub = null;
    await _changes.close();
  }

  /// Reset attempts so a stuck game retries. For a user-facing "try again".
  Future<void> retryStuck() async {
    final games = await _read();
    await _write([
      for (final g in games)
        g.attempts >= maxAttempts ? g.copyWith(attempts: 0) : g,
    ]);
    await flush();
  }

  /// ONE FRESH ROUND FOR GAMES THAT GOT STUCK BEFORE 2.1 (3.8).
  ///
  /// 2.0 has no free game limit on the client, so once the server limit is
  /// on, a free parent still on 2.0 can track a 4th game the server refuses.
  /// 2.0 keeps it and retries until it is stuck. [flush] skips stuck games,
  /// so after the update that game would never be retried, never recognised
  /// as a limit refusal, and never shown as held: invisible on the phone.
  /// One reset per install lets the 2.1 flush see the refusal and hold it.
  /// Games stuck for any other reason simply get one more round.
  Future<void> resetStuckOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_stuckResetKey) ?? false) return;
    final games = await _read();
    if (games.any((g) => g.attempts >= maxAttempts)) {
      await _write([
        for (final g in games)
          g.attempts >= maxAttempts ? g.copyWith(attempts: 0) : g,
      ]);
    }
    await prefs.setBool(_stuckResetKey, true);
  }

  // --- internals -------------------------------------------------------------

  Future<void> _remove(String gameId) async {
    final games = await _read();
    games.removeWhere((g) => g.gameId == gameId);
    await _write(games);
  }

  Future<void> _markHeld(String gameId) async {
    final games = await _read();
    final i = games.indexWhere((g) => g.gameId == gameId);
    if (i == -1) return;
    // No attempts bump: held is a state, not a failure, and burning attempts
    // would eventually mark a perfectly safe game as stuck.
    games[i] = games[i].copyWith(heldForLimit: true);
    await _write(games);
  }

  Future<void> _recordFailure(String gameId, String error) async {
    final games = await _read();
    final i = games.indexWhere((g) => g.gameId == gameId);
    if (i == -1) return;
    games[i] = games[i].copyWith(
      attempts: games[i].attempts + 1,
      lastError: error.length > 200 ? error.substring(0, 200) : error,
    );
    await _write(games);
  }
}
