// The columns games and player_game_stats actually have.
//
// Transcribed from information_schema on test, 2026-07-21. When a migration
// adds or removes a column, change it HERE in the same commit - this list is
// what the save path builds against, what the uploader filters against, and
// what the tests assert against.
//
// WHY A LIST IN CODE AT ALL. The stats row once carried a user_id that
// player_game_stats does not have. Every unit test passed, because they all
// assert on the map and the map was fine. PostgREST rejected the row on a
// device, the games row had already gone up, and the result was a game with
// no stats and a "will sync when you are back online" message on a phone
// with full signal.

const Set<String> kGameColumns = {
  'id',
  'created_at',
  'opponent_team',
  'game_live',
  'user_id',
  'player_id',
  'player_team_name',
  'event_name',
  'event_type',
  // Added 20260915000001. Distinct from created_at, which is when the ROW was
  // written - for a game queued offline that can be days after it was played.
  'started_at',
  'ended_at',
};

const Set<String> kStatsColumns = {
  'id',
  'game_id',
  'player_id',
  'points',
  'fg_made',
  'fg_attempt',
  'two_made',
  'two_attempt',
  'three_made',
  'three_attempt',
  'ft_made',
  'ft_attempt',
  'off_reb',
  'def_reb',
  'assist',
  'steal',
  'turnover',
  'block',
  'off_foul',
  'def_foul',
  'game_insights',
};

/// The columns public.stat_events actually has.
///
/// Transcribed from 20260915000000_stat_events.sql. Same rule as the two sets
/// above: when a migration changes this table, change it HERE in the same
/// commit. The uploader conforms against this list before sending, so a game
/// queued by an older build cannot fail forever on a key this schema lost.
const Set<String> kStatEventColumns = {
  'id',
  'game_id',
  'player_id',
  'event_type',
  'sequence_no',
  'recorded_at',
  'elapsed_ms',
  'source',
  'status',
  'confidence',
  'attributes',
  'clip_ref',
  'merged_into',
};

/// Drops any key the table does not have, returning what was dropped.
///
/// THE OUTBOX IS A CROSS-VERSION FORMAT. A game queued in a gym holds the
/// BUILT ROWS, not the snapshot, and may not be uploaded until a build
/// shipped weeks later runs the flush. So the uploader cannot assume the
/// payload was written by the current code - and a payload it cannot fix is
/// a payload that fails on every retry until the queue gives up, silently,
/// with the parent's game still on the phone.
///
/// That is not hypothetical: the user_id defect stranded a real game exactly
/// this way, and the fix to the save path could not reach it.
({Map<String, dynamic> row, Set<String> dropped}) conformToColumns(
  Map<String, dynamic> row,
  Set<String> columns,
) {
  final dropped = row.keys.toSet().difference(columns);
  if (dropped.isEmpty) return (row: row, dropped: const <String>{});
  return (
    row: {
      for (final e in row.entries)
        if (columns.contains(e.key)) e.key: e.value,
    },
    dropped: dropped,
  );
}
