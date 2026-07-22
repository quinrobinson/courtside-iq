import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // THE COLUMNS THE DATABASE ACTUALLY HAS, transcribed from
    // information_schema on test 2026-07-21.
    //
    // This group exists because of a real defect: the stats row carried a
    // user_id that player_game_stats does not have. Every unit test passed -
    // they all assert on the map, and the map was fine - while PostgREST
    // rejected the row on a device. The games row went up first, so the
    // result was a game with no stats and a save that reported itself queued
    // on a phone with full signal.
    //
    // A map is not a row. Nothing else in the suite checks the key NAMES
    // against the schema, so a typo or an invented column is invisible until
    // a save fails in a gym. Update these lists when a migration changes the
    // tables - a red test here means the two have drifted.
    const gameColumns = {
      'id', 'created_at', 'opponent_team', 'game_live', 'user_id',
      'player_id', 'player_team_name', 'event_name', 'event_type',
    };
    const statsColumns = {
      'id', 'game_id', 'player_id', 'points', 'fg_made', 'fg_attempt',
      'two_made', 'two_attempt', 'three_made', 'three_attempt', 'ft_made',
      'ft_attempt', 'off_reb', 'def_reb', 'assist', 'steal', 'turnover',
      'block', 'off_foul', 'def_foul', 'game_insights',
    };

    test('every games key is a real games column', () async {
      final g = await rowsFor(const LiveGameStats(twoMade: 3));
      expect(g.gameRow.keys.toSet().difference(gameColumns), isEmpty,
          reason: 'sending a column games does not have rejects the row');
    });

    test('every stats key is a real player_game_stats column', () async {
      final g = await rowsFor(const LiveGameStats(twoMade: 3));
      expect(g.statsRow.keys.toSet().difference(statsColumns), isEmpty,
          reason: 'this is the exact check that user_id would have failed');
    });
  });
}
