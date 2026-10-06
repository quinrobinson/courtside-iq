// The Supabase half of the offline game queue — Phase 4.5.
//
// Kept separate from GameSyncQueue so the queue logic stays pure Dart and
// testable without a network. This file is the only place that knows the
// database exists.

import 'package:uuid/uuid.dart';

import '/backend/supabase/supabase.dart';
import '/custom_code/actions/generate_game_insight.dart';
import 'game_sync_queue.dart';
import 'game_upload_steps.dart';
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
  List<Map<String, dynamic>> eventRows = const [],
}) {
  final gameId = _uuid.v4();
  final statsId = _uuid.v4();

  return PendingGame(
    gameId: gameId,
    statsId: statsId,
    gameRow: {...gameRow, 'id': gameId},
    statsRow: {...statsRow, 'id': statsId, 'game_id': gameId},
    // Client-generated ids here too, for the same reason the other two rows
    // have them: the upsert is by primary key, so the same PendingGame can be
    // sent five times and still produce exactly one row per event.
    eventRows: [
      for (final e in eventRows) {...e, 'id': _uuid.v4(), 'game_id': gameId},
    ],
    queuedAt: DateTime.now(),
  );
}

/// Uploads a queued game through Supabase.
///
/// The order and the failure rules live in [runGameUpload]
/// (game_upload_steps.dart), where they are tested without a network. This
/// only supplies the two things that need the database.
Future<void> uploadPendingGame(PendingGame game) {
  final client = SupaFlow.client;
  return runGameUpload(
    game,
    upsert: (table, rows) =>
        client.from(table).upsert(rows, onConflict: 'id'),
    requestInsight: generateGameInsight,
    // RLS refusals arrive as 42501. On the games upsert that is the free-game
    // policy (3.8). An expired session would also be 42501; the queue holds the
    // game either way (nothing is lost), and the held sheet only shows when
    // the client agrees the parent is free and at the allowance.
    isLimitRefusal: (e) => e is PostgrestException && e.code == '42501',
  );
}

/// App-wide queue. Single instance so the connectivity listener and any UI
/// observing pendingCount agree with each other.
final gameSyncQueue = GameSyncQueue(uploader: uploadPendingGame);
