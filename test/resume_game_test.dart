// Resuming a game the app lost — Phase 4.13
//
// The snapshot has survived a force-quit since the tracker was built. What it
// did not have was a door back: read() existed and nothing called it, so a
// parent who lost the app lost the game as surely as if nothing had been
// saved. These tests are about that door.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';
import 'package:courtside_i_q/courtside_iq/games_list_builder.dart';
import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/features/games/games_list_page.dart';
import 'package:courtside_i_q/features/games/games_repository.dart';
import 'package:courtside_i_q/features/games/live_game_store.dart';

class _FakeRepo implements GamesRepository {
  const _FakeRepo(this.rows);
  final List<GameListRow> rows;

  @override
  Future<GamesData> load() async => GamesData(
        roster: {for (final r in rows) r.playerId: r.playerName}
            .entries
            .map((e) => GameRosterEntry(playerId: e.key, firstName: e.value))
            .toList(),
        games: rows,
      );
}

GameListRow _finished({String id = 'g1', String player = 'p1'}) => GameListRow(
      gameId: id,
      playerId: player,
      playerName: player == 'p1' ? 'Maya' : 'Jordan',
      opponent: 'Hawks',
      playedAt: DateTime(2026, 5, 4),
      points: 12,
    );

LiveGameSnapshot _snapshot({String playerId = 'p1', String name = 'Maya'}) =>
    LiveGameSnapshot(
      playerId: playerId,
      playerName: name,
      opponent: 'Northside Hawks',
      stats: const LiveGameStats(twoMade: 6, offReb: 5, assists: 3, steals: 1),
      startedAt: DateTime(2026, 5, 4, 18),
    );

Future<void> _pump(WidgetTester tester, List<GameListRow> rows) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: GamesListPage(repository: _FakeRepo(rows)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('an unfinished game leads the list', (tester) async {
    await const LiveGameStore().save(_snapshot());
    await _pump(tester, [_finished()]);

    expect(find.text('LIVE'), findsOneWidget);
    // No date. The game has not finished, so there is no day to name, and
    // showing one would date it to whenever tracking began rather than when
    // it ends.
    expect(find.text('vs Northside Hawks'), findsOneWidget);
  });

  testWidgets('no snapshot, no live row', (tester) async {
    await _pump(tester, [_finished()]);
    expect(find.text('LIVE'), findsNothing);
  });

  testWidgets('it survives when there are no finished games at all',
      (tester) async {
    // The reason this matters: the empty state would otherwise claim there
    // are no games while one is being tracked.
    await const LiveGameStore().save(_snapshot());
    await _pump(tester, []);

    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('it obeys the player filter', (tester) async {
    await const LiveGameStore().save(_snapshot(playerId: 'p1'));
    await _pump(tester, [_finished(player: 'p1'), _finished(id: 'g2', player: 'p2')]);

    expect(find.text('LIVE'), findsOneWidget);

    // Scoped to the chip bar: the names also appear as row titles, and
    // tapping a row would open a game instead of filtering.
    Finder chip(String label) => find.descendant(
        of: find.byType(CiChipBar), matching: find.text(label));

    // Filter to the OTHER player: a row that ignored the filter would read as
    // a bug.
    await tester.tap(chip('Jordan'));
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsNothing);

    await tester.tap(chip('Maya'));
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('tapping it offers resume or discard, with the score',
      (tester) async {
    await const LiveGameStore().save(_snapshot());
    await _pump(tester, [_finished()]);

    await tester.tap(find.text('LIVE'));
    await tester.pumpAndSettle();

    expect(find.text('Game in progress'), findsOneWidget);
    expect(find.text('Resume game'), findsOneWidget);
    expect(find.text('Discard game'), findsOneWidget);
    // 6 twos. The score is what tells a parent this is the game they think
    // it is.
    expect(find.text('12'), findsWidgets);
  });

  testWidgets('dismissing changes nothing', (tester) async {
    // Neither answer is safe to assume on a stray tap: one hijacks the
    // parent into the tracker, the other deletes a tracked game.
    await const LiveGameStore().save(_snapshot());
    await _pump(tester, [_finished()]);

    await tester.tap(find.text('LIVE'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Game in progress'))).pop();
    await tester.pumpAndSettle();

    expect(await const LiveGameStore().read(), isNotNull);
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('discard clears the snapshot and the row', (tester) async {
    await const LiveGameStore().save(_snapshot());
    await _pump(tester, [_finished()]);

    await tester.tap(find.text('LIVE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard game'));
    await tester.pumpAndSettle();

    expect(await const LiveGameStore().read(), isNull,
        reason: 'a discarded game must not come back on the next launch');
    expect(find.text('LIVE'), findsNothing);
  });

  test('the stored snapshot round-trips its stats and start time', () async {
    // What resume replays. Losing startedAt would date a game tracked last
    // night to whenever the parent reopened the app.
    const store = LiveGameStore();
    await store.save(_snapshot());
    final back = await store.read();

    expect(back!.stats.points, 12);
    expect(back.stats.offReb, 5);
    expect(back.stats.assists, 3);
    expect(back.playerName, 'Maya');
    expect(back.startedAt, DateTime(2026, 5, 4, 18));
  });
}
