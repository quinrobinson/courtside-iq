// The Supabase half of the offline game queue — Phase 4.5.
//
// Kept separate from GameSyncQueue so the queue logic stays pure Dart and
// testable without a network. This file is the only place that knows the
// database exists.

import 'package:uuid/uuid.dart';

import '/backend/supabase/supabase.dart';
import '/custom_code/actions/generate_game_insight.dart';
import 'game_sync_queue.dart';
import 'pending_game.dart';

const _uuid = Uuid();

/// Build a PendingGame with client-generated ids.
///
/// Generating both ids HERE, before any network call, is what makes retrying
/// safe. The upload upserts by primary key, so the same payload can be sent
/// repeatedly and still produce exactly one game and one stats row. Let the
/// server generate them and a retry after a timeout that actually succeeded
/// silently creates a duplicate game - worse than the failure it retried.
PendingGame buildPendingGame({
  required Map<String, dynamic> gameRow,
  required Map<String, dynamic> statsRow,
}) {
  final gameId = _uuid.v4();
  final statsId = _uuid.v4();

  return PendingGame(
    gameId: gameId,
    statsId: statsId,
    gameRow: {...gameRow, 'id': gameId},
    statsRow: {...statsRow, 'id': statsId, 'game_id': gameId},
    queuedAt: DateTime.now(),
  );
}

/// Upserts the game and its stats, then asks for the insight.
///
/// Order matters: the game must exist before the stats row, which references
/// it by foreign key.
///
/// THE INSIGHT IS REQUESTED HERE, and that is the fix for a defect carried
/// since 4.5. Generation needs a server row, so it was skipped while offline -
/// and the later flush uploaded the rows without ever asking, leaving a game
/// permanently without the insight the save screen PROMISED ("Save to unlock
/// Maya's game insight"). Asking from the uploader covers both paths, because
/// both an immediate save and a flush days later come through here.
///
/// Failure to generate NEVER fails the upload. The game is saved either way,
/// and generateGameInsight already swallows its own errors; the try/catch is
/// belt and braces so a future change there cannot start losing games.
Future<void> uploadPendingGame(PendingGame game) async {
  final client = SupaFlow.client;

  await client.from('games').upsert(game.gameRow, onConflict: 'id');
  await client
      .from('player_game_stats')
      .upsert(game.statsRow, onConflict: 'id');

  try {
    await generateGameInsight(game.gameId);
  } catch (_) {
    // The rows are up. An insight can be regenerated; a lost game cannot.
  }
}

/// App-wide queue. Single instance so the connectivity listener and any UI
/// observing pendingCount agree with each other.
final gameSyncQueue = GameSyncQueue(uploader: uploadPendingGame);
