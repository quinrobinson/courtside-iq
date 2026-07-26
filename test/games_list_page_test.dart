import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';
import 'package:courtside_i_q/courtside_iq/games_list_builder.dart';
import 'package:courtside_i_q/features/games/games_list_page.dart';
import 'package:courtside_i_q/features/games/games_repository.dart';
import 'package:courtside_i_q/features/games/games_revision.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_segmented_tabs.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';

class _FakeRepo implements GamesRepository {
  const _FakeRepo(this.rows, {this.roster});
  final List<GameListRow> rows;
  final List<GameRosterEntry>? roster;

  @override
  Future<GamesData> load() async => GamesData(
        // Defaults to the players who appear in the games, so existing tests
        // read the same. Pass `roster` to include one with none.
        roster: roster ??
            {for (final r in rows) r.playerId: r.playerName}
                .entries
                .map((e) =>
                    GameRosterEntry(playerId: e.key, firstName: e.value))
                .toList(),
        games: rows,
      );
}

/// Never resolves. A Future.delayed would leave a pending timer and fail the
/// test binding's invariant check on teardown.
class _SlowRepo implements GamesRepository {
  const _SlowRepo();
  @override
  Future<GamesData> load() => Completer<GamesData>().future;
}

/// Counts how many times the list refetches, for the gamesRevision guard.
class _CountingRepo implements GamesRepository {
  _CountingRepo(this.rows);
  final List<GameListRow> rows;
  int loads = 0;

  @override
  Future<GamesData> load() async {
    loads++;
    return GamesData(
      roster: {for (final r in rows) r.playerId: r.playerName}
          .entries
          .map((e) => GameRosterEntry(playerId: e.key, firstName: e.value))
          .toList(),
      games: rows,
    );
  }
}

GameListRow _g({
  String id = 'g1',
  String player = 'p1',
  String name = 'Maya',
  DateTime? at,
  int points = 12,
  bool live = false,
}) =>
    GameListRow(
      gameId: id,
      playerId: player,
      playerName: name,
      opponent: 'Hawks',
      playedAt: at ?? DateTime(2026, 5, 4),
      points: points,
      isLive: live,
    );

Future<void> _pump(
  WidgetTester tester,
  List<GameListRow> rows, {
  List<GameRosterEntry>? roster,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: GamesListPage(repository: _FakeRepo(rows, roster: roster)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists every game, newest first', (tester) async {
    // The v1 list ordered ascending and opened on the oldest game ever
    // logged. The repository orders descending; this asserts the screen keeps
    // that order rather than re-sorting.
    await _pump(tester, [
      _g(id: 'a', at: DateTime(2026, 5, 4), points: 30),
      _g(id: 'b', at: DateTime(2026, 4, 28), points: 10),
    ]);

    final rows = tester.widgetList<GameFeedRow>(find.byType(GameFeedRow));
    expect(rows.map((r) => r.entry.gameId), ['a', 'b']);
  });

  testWidgets('hides the player chips when there is only one player',
      (tester) async {
    // Every chip would show the same list. Scoped to CiChip because "Maya"
    // also appears as the player name on every row.
    await _pump(tester, [_g(id: 'a'), _g(id: 'b', at: DateTime(2026, 5, 2))]);
    expect(find.byType(CiChip).evaluate().isEmpty, isFalse,
        reason: 'the DATE chips still show');
    expect(find.widgetWithText(CiChip, 'Maya'), findsNothing);
    expect(find.widgetWithText(CiChip, 'All'), findsNothing,
        reason: 'the player row is absent entirely, All included');
  });

  testWidgets('offers player chips once there are two', (tester) async {
    await _pump(tester, [
      _g(id: 'a', player: 'p1', name: 'Maya'),
      _g(id: 'b', player: 'p2', name: 'Jordan'),
    ]);
    expect(find.widgetWithText(CiChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(CiChip, 'Maya'), findsOneWidget);
    expect(find.widgetWithText(CiChip, 'Jordan'), findsOneWidget);
  });

  testWidgets('filtering by player narrows the list AND the dates',
      (tester) async {
    // A date chip that yields nothing is a dead control the parent cannot
    // explain, so the dates are built from the already-filtered rows.
    await _pump(tester, [
      _g(id: 'a', player: 'p1', name: 'Maya', at: DateTime(2026, 5, 4)),
      _g(id: 'b', player: 'p2', name: 'Jordan', at: DateTime(2026, 4, 28)),
    ]);
    expect(find.text('Apr 28'), findsOneWidget);

    await tester.tap(find.widgetWithText(CiChip, 'Maya'));
    await tester.pumpAndSettle();

    expect(tester.widgetList<GameFeedRow>(find.byType(GameFeedRow)).length, 1);
    expect(find.text('Apr 28'), findsNothing,
        reason: 'Jordan\'s date must not survive filtering to Maya');
  });

  testWidgets('an empty result says the games are still there',
      (tester) async {
    // Telling a parent with twenty games to log their first would read as
    // data loss.
    await _pump(tester, [
      _g(id: 'a', player: 'p1', name: 'Maya', at: DateTime(2026, 5, 4)),
      _g(id: 'b', player: 'p2', name: 'Jordan', at: DateTime(2026, 5, 4)),
    ]);

    await tester.tap(find.text('May 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CiChip, 'Maya'));
    await tester.pumpAndSettle();
    expect(find.byType(GameFeedRow), findsOneWidget);
  });

  testWidgets('no games at all invites, rather than blaming a filter',
      (tester) async {
    // Copy and button measured from 206:1025, not invented. The button is the
    // same lime "Start a game" as the player-filter state - an earlier version
    // had it on an ink "Track a Game", which was reasoned rather than read.
    await _pump(tester, const []);
    expect(find.text('No games yet'), findsOneWidget);
    expect(
        find.text('Track your first game to see how your player performed and '
            'what it means for their growth.'),
        findsOneWidget);
    expect(find.text('Start a game'), findsOneWidget);
    expect(find.text('Track a Game'), findsNothing);
    expect(find.text('No games match these filters'), findsNothing);
  });

  testWidgets('the header is ink, matching the Players list', (tester) async {
    // Games and Players are the same kind of screen. Two list headers that
    // differ read as a mistake rather than a distinction.
    await _pump(tester, [_g()]);
    final title = tester.widget<Text>(find.text('Games'));
    expect(title.style!.color, CiColors.onInk.text);
  });

  testWidgets('the last row is closed by a rule', (tester) async {
    // Without it the list stops mid-air against the nav bar, which reads as
    // content cut off rather than a list that ended.
    await _pump(tester, [
      _g(id: 'a', at: DateTime(2026, 5, 4)),
      _g(id: 'b', at: DateTime(2026, 5, 2)),
    ]);

    final rows = tester.widgetList<GameFeedRow>(find.byType(GameFeedRow));
    final rules = tester.widgetList<CiHairline>(find.byType(CiHairline));
    // One under the filters, one between the two rows, one under the last.
    expect(rows.length, 2);
    expect(rules.length, greaterThanOrEqualTo(3));
  });

  testWidgets('the header survives loading', (tester) async {
    // The screen's identity does not depend on the games arriving.
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: GamesListPage(repository: const _SlowRepo()),
    ));
    await tester.pump();
    expect(find.text('Games'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a player with NO games still gets a chip', (tester) async {
    // Reported on device: two players, one chip. Chips were built from the
    // games, so a player who had not played was invisible in their own
    // filter - and frame 683:2755 was unreachable.
    await _pump(
      tester,
      [_g(id: 'a', player: 'p1', name: 'Maya')],
      roster: const [
        GameRosterEntry(playerId: 'p1', firstName: 'Maya'),
        GameRosterEntry(playerId: 'p2', firstName: 'Jordan'),
      ],
    );

    expect(find.widgetWithText(CiChip, 'Maya'), findsOneWidget);
    expect(find.widgetWithText(CiChip, 'Jordan'), findsOneWidget);
  });

  testWidgets('selecting a player with no games names them', (tester) async {
    await _pump(
      tester,
      [_g(id: 'a', player: 'p1', name: 'Maya')],
      roster: const [
        GameRosterEntry(playerId: 'p1', firstName: 'Maya'),
        GameRosterEntry(playerId: 'p2', firstName: 'Jordan'),
      ],
    );

    await tester.tap(find.widgetWithText(CiChip, 'Jordan'));
    await tester.pumpAndSettle();

    expect(find.text('No games for Jordan yet'), findsOneWidget);
    expect(
        find.text('Track a game with Jordan to see how they performed and '
            'what it means for their growth.'),
        findsOneWidget);
    expect(find.text('Start a game'), findsOneWidget);
    // Not the generic filter copy - this is an answer, not a dead end.
    expect(find.text('No games match these filters'), findsNothing);
  });

  testWidgets('the date row disappears for a player with no games',
      (tester) async {
    await _pump(
      tester,
      [_g(id: 'a', player: 'p1', name: 'Maya', at: DateTime(2026, 5, 4))],
      roster: const [
        GameRosterEntry(playerId: 'p1', firstName: 'Maya'),
        GameRosterEntry(playerId: 'p2', firstName: 'Jordan'),
      ],
    );

    await tester.tap(find.widgetWithText(CiChip, 'Jordan'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CiChip, 'May 4'), findsNothing);
    expect(find.widgetWithText(CiChip, 'All dates'), findsNothing);
  });

  testWidgets('a live game wears the LIVE pill, and only that one',
      (tester) async {
    await _pump(tester, [
      _g(id: 'a', at: DateTime(2026, 5, 4), live: true),
      _g(id: 'b', at: DateTime(2026, 5, 2)),
    ]);

    // One pill, on one row. There is at most one live game at a time.
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.bySemanticsLabel('Live'), findsOneWidget);
  });

  testWidgets('no pill when nothing is live', (tester) async {
    await _pump(tester, [_g(id: 'a'), _g(id: 'b', at: DateTime(2026, 5, 2))]);
    expect(find.text('LIVE'), findsNothing);
  });

  testWidgets('refetches when a game is saved or synced (gamesRevision)',
      (tester) async {
    // The shell keeps this tab alive, so without this the parent saves a game,
    // lands on Games, and it is not there - the list is the one from before it
    // existed.
    final repo = _CountingRepo([_g(id: 'a')]);
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: GamesListPage(repository: repo),
    ));
    await tester.pumpAndSettle();
    final before = repo.loads;

    notifyGamesChanged();
    await tester.pumpAndSettle();

    expect(repo.loads, greaterThan(before),
        reason: 'a game change must trigger a refetch');
  });
}
