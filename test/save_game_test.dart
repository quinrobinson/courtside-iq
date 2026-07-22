import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/game_sync/game_columns.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/game_sync_queue.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/pending_game.dart';
import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/features/games/live_game_store.dart';
import 'package:courtside_i_q/features/games/save_game.dart';

LiveGameSnapshot _snap(LiveGameStats stats) => LiveGameSnapshot(
      playerId: 'p1',
      playerName: 'Maya',
      opponent: 'Northside Hawks',
      team: 'Verde City Vipers',
      event: 'Spring Classic',
      stats: stats,
      startedAt: DateTime.utc(2026, 5, 4, 18),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a save that reaches the server reports synced', () async {
    final sent = <PendingGame>[];
    final saver = GameSaver(
      queue: GameSyncQueue(uploader: (g) async => sent.add(g)),
    );

    final outcome = await saver.save(_snap(const LiveGameStats(twoMade: 5)));

    expect(outcome, SaveOutcome.synced);
    expect(sent.length, 1);
  });

  test('no signal is QUEUED, not failed', () async {
    // A queued game is a saved game. Reporting failure here would tell a
    // parent their game was lost when it is durably on disk.
    final saver = GameSaver(
      queue: GameSyncQueue(uploader: (_) async => throw StateError('offline')),
    );

    final outcome = await saver.save(_snap(const LiveGameStats(twoMade: 5)));
    expect(outcome, SaveOutcome.queued);
  });

  test('never throws, whatever the network does', () async {
    final saver = GameSaver(
      queue: GameSyncQueue(uploader: (_) async => throw StateError('boom')),
    );
    await expectLater(
        saver.save(_snap(const LiveGameStats())), completes);
  });

  group('the rows it builds', () {
    Future<PendingGame> rowsFor(LiveGameStats stats) async {
      final sent = <PendingGame>[];
      await GameSaver(queue: GameSyncQueue(uploader: (g) async => sent.add(g)))
          .save(_snap(stats));
      return sent.single;
    }

    test('carries the setup a parent chose', () async {
      final g = await rowsFor(const LiveGameStats());
      expect(g.gameRow['player_id'], 'p1');
      expect(g.gameRow['opponent_team'], 'Northside Hawks');
      expect(g.gameRow['player_team_name'], 'Verde City Vipers');
      expect(g.gameRow['event_name'], 'Spring Classic');
    });

    test('marks the game finished', () async {
      // Left true, the games list would show a LIVE pill on it forever.
      final g = await rowsFor(const LiveGameStats());
      expect(g.gameRow['game_live'], isFalse);
    });

    test('derives attempts rather than storing only makes', () async {
      final g = await rowsFor(const LiveGameStats(
        twoMade: 4,
        twoMissed: 3,
        threeMade: 2,
        threeMissed: 5,
        ftMade: 1,
        ftMissed: 1,
      ));

      expect(g.statsRow['two_attempt'], 7);
      expect(g.statsRow['three_attempt'], 7);
      expect(g.statsRow['ft_attempt'], 2);
      // Field goals are twos AND threes, which is what every percentage on
      // the profile is computed from.
      expect(g.statsRow['fg_made'], 6);
      expect(g.statsRow['fg_attempt'], 14);
      expect(g.statsRow['points'], 4 * 2 + 2 * 3 + 1);
    });

    test('keeps the two rebound kinds apart', () async {
      // The profile splits them, so collapsing here would lose the split
      // permanently.
      final g = await rowsFor(const LiveGameStats(offReb: 2, defReb: 5));
      expect(g.statsRow['off_reb'], 2);
      expect(g.statsRow['def_reb'], 5);
    });

    test('ids are client-generated and shared by both rows', () async {
      // What makes a retry safe: the same payload upserts to the same rows.
      final g = await rowsFor(const LiveGameStats());
      expect(g.gameRow['id'], g.gameId);
      expect(g.statsRow['game_id'], g.gameId);
      expect(g.gameId, isNotEmpty);
    });

    // The column lists live in lib/courtside_iq/game_sync/game_columns.dart,
    // shared with the uploader that filters against them. Asserting on a
    // copy here would let the two drift, which is the whole failure mode
    // these tests exist to catch.
    test('every games key is a real games column', () async {
      final g = await rowsFor(const LiveGameStats(twoMade: 3));
      expect(g.gameRow.keys.toSet().difference(kGameColumns), isEmpty,
          reason: 'sending a column games does not have rejects the row');
    });

    test('every stats key is a real player_game_stats column', () async {
      final g = await rowsFor(const LiveGameStats(twoMade: 3));
      expect(g.statsRow.keys.toSet().difference(kStatsColumns), isEmpty,
          reason: 'this is the exact check that user_id would have failed');
    });
  });

  group('a payload built by an older build', () {
    // THE OUTBOX IS A CROSS-VERSION FORMAT. These rows are serialized to disk
    // and may not be uploaded until a later build runs the flush, so the
    // uploader has to cope with keys the current schema does not have.
    //
    // This is the exact shape of a real defect: the user_id fix to the save
    // path could not reach the game already queued with user_id baked in, so
    // it failed on every retry.
    test('sheds a column the table no longer has', () {
      final r = conformToColumns(
        {'id': 's1', 'game_id': 'g1', 'points': 12, 'user_id': 'u1'},
        kStatsColumns,
      );
      expect(r.dropped, {'user_id'});
      expect(r.row.containsKey('user_id'), isFalse);
      expect(r.row['points'], 12, reason: 'the real data must survive');
    });

    test('leaves a clean row completely alone', () {
      const row = {'id': 's1', 'game_id': 'g1', 'points': 12};
      final r = conformToColumns(row, kStatsColumns);
      expect(r.dropped, isEmpty);
      expect(identical(r.row, row), isTrue);
    });
  });
}
