// Saving a finished game — Phase 4.13
//
// Turns a LiveGameSnapshot into the two rows the database holds, and hands
// them to the offline queue.
//
// IT ALWAYS GOES THROUGH THE QUEUE, even with full signal. The queue writes
// locally BEFORE attempting the network, so a save that fails mid-flight is
// still a game the parent keeps. Calling Supabase directly when online would
// mean two code paths, and the rarely-exercised one would be the one that
// runs in a gym with no bars.
//
// The insight is requested by the uploader, not here - see
// supabase_game_uploader.dart. That is what makes an offline game get its
// insight when it finally syncs.

import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/game_sync/game_sync_queue.dart';
import '/courtside_iq/game_sync/supabase_game_uploader.dart';
import 'live_game_store.dart';

/// What happened, so the screen can say so.
enum SaveOutcome {
  /// Uploaded and confirmed.
  synced,

  /// Written locally and waiting for signal. NOT a failure - the game is safe.
  queued,
}

class GameSaver {
  const GameSaver({GameSyncQueue? queue}) : _queue = queue;

  final GameSyncQueue? _queue;

  GameSyncQueue get _q => _queue ?? gameSyncQueue;

  /// Saves [snapshot] and returns whether it reached the server.
  ///
  /// Never throws: a save that cannot reach Supabase is queued, and a queued
  /// game is a saved game. The only thing a parent could act on is signal, and
  /// the screen tells them about that.
  Future<SaveOutcome> save(LiveGameSnapshot snapshot) async {
    final s = snapshot.stats;
    final userId = currentUserUid;

    final pending = buildPendingGame(
      gameRow: {
        'user_id': userId,
        'player_id': snapshot.playerId,
        'opponent_team': snapshot.opponent,
        'player_team_name': snapshot.team,
        'event_name': snapshot.event,
        // The game is finished the moment it is saved. Leaving this true
        // would leave a LIVE pill on the games list forever.
        'game_live': false,
        'created_at': snapshot.startedAt.toUtc().toIso8601String(),
      },
      statsRow: {
        'user_id': userId,
        'player_id': snapshot.playerId,
        'points': s.points,
        'two_made': s.twoMade,
        'two_attempt': s.twoMade + s.twoMissed,
        'three_made': s.threeMade,
        'three_attempt': s.threeMade + s.threeMissed,
        'fg_made': s.fgMade,
        'fg_attempt': s.fgAttempted,
        'ft_made': s.ftMade,
        'ft_attempt': s.ftAttempted,
        'off_reb': s.offReb,
        'def_reb': s.defReb,
        'assist': s.assists,
        'steal': s.steals,
        'block': s.blocks,
        'turnover': s.turnovers,
      },
    );

    return await _q.enqueueAndTry(pending)
        ? SaveOutcome.synced
        : SaveOutcome.queued;
  }
}
