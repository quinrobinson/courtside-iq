// The ORDER of a game upload - G1.14.
//
// Pure Dart, no Supabase import, so the order and the failure rules can be
// tested without a network. supabase_game_uploader.dart supplies the real
// writes; this file decides what happens in what order and which failures
// send the game back to the queue.

import 'dart:developer' as dev;

import 'game_columns.dart';
import 'pending_game.dart';

/// Upserts [rows] into [table], conflicting on `id`.
typedef RowUpserter = Future<void> Function(
    String table, List<Map<String, dynamic>> rows);

/// Asks the server for a game's insight.
typedef InsightRequester = Future<void> Function(String gameId);

/// The server refused the GAME row because the free game allowance is used up
/// (roadmap 3.8: the games INSERT policy). Thrown instead of the raw database
/// error so the queue can HOLD the game rather than count a failure.
class GameLimitRefusal implements Exception {
  const GameLimitRefusal();

  @override
  String toString() => 'GameLimitRefusal: free game allowance used';
}

/// Whether an error from the games upsert is that policy refusing the row.
typedef LimitRefusalTest = bool Function(Object error);

/// games, then stat_events, then player_game_stats, then the insight.
///
/// EVENTS BEFORE STATS, and EVENTS CAN FAIL THE UPLOAD. Since G1.14 the
/// database derives a game's totals from its events: a trigger overwrites the
/// stats row's 17 fields with the rollup whenever that game has events. So:
/// - events land first, and the stats insert already carries derived totals,
///   which the trend-snapshot trigger then reads. Stats first would snapshot
///   the client's totals and need a correction a moment later.
/// - a failed events upload throws. Before G1.14 it was logged and swallowed,
///   because events were a timeline added beside totals that were already
///   saved. Now they ARE the totals; a game saved without them would quietly
///   keep numbers nothing can check. Throwing sends the whole game back to
///   the queue, and every write here is an upsert by client id, so the retry
///   cannot duplicate anything.
///
/// A game with no events (an older build's queued payload, or a game from
/// before events existed) skips that step and keeps its client totals.
///
/// THE INSIGHT IS REQUESTED LAST, from here, so an immediate save and a flush
/// days later both get one (the 4.5 carry-over fix). It must come after the
/// stats row, which is what it reads. Failure to generate NEVER fails the
/// upload: an insight can be regenerated, a lost game cannot.
Future<void> runGameUpload(
  PendingGame game, {
  required RowUpserter upsert,
  required InsightRequester requestInsight,
  LimitRefusalTest? isLimitRefusal,
}) async {
  // Conform BEFORE sending. A queued game holds the rows as they were built,
  // so one written by an older build can carry a key this schema does not
  // have - and a payload that cannot be fixed fails on every retry until the
  // queue gives up. Logged, never silent: a dropped key is either a stale
  // payload healing itself or a column list that has drifted from the
  // database, and the second one needs a person.
  final gameRow = conformToColumns(game.gameRow, kGameColumns);
  final statsRow = conformToColumns(game.statsRow, kStatsColumns);
  for (final (table, dropped) in [
    ('games', gameRow.dropped),
    ('player_game_stats', statsRow.dropped),
  ]) {
    if (dropped.isNotEmpty) {
      dev.log('dropped unknown $table columns: ${dropped.join(', ')}',
          name: 'GameSync');
    }
  }

  // The game first: both other tables reference it by foreign key. A refusal
  // HERE is the free-game limit (3.8); nothing after it has been sent, so the
  // whole game stays intact in the queue.
  try {
    await upsert('games', [gameRow.row]);
  } catch (e) {
    if (isLimitRefusal != null && isLimitRefusal(e)) {
      throw const GameLimitRefusal();
    }
    rethrow;
  }

  if (game.eventRows.isNotEmpty) {
    await upsert('stat_events', [
      for (final e in game.eventRows) conformToColumns(e, kStatEventColumns).row,
    ]);
  }

  await upsert('player_game_stats', [statsRow.row]);

  try {
    await requestInsight(game.gameId);
  } catch (_) {
    // The rows are up. An insight can be regenerated; a lost game cannot.
  }
}
