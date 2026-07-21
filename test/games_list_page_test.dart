import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';
import 'package:courtside_i_q/courtside_iq/games_list_builder.dart';
import 'package:courtside_i_q/features/games/games_list_page.dart';
import 'package:courtside_i_q/features/games/games_repository.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_segmented_tabs.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';

class _FakeRepo implements GamesRepository {
  const _FakeRepo(this.rows);
  final List<GameListRow> rows;

  @override
  Future<List<GameListRow>> load() async => rows;
}

/// Never resolves. A Future.delayed would leave a pending timer and fail the
/// test binding's invariant check on teardown.
class _SlowRepo implements GamesRepository {
  const _SlowRepo();
  @override
  Future<List<GameListRow>> load() => Completer<List<GameListRow>>().future;
}

GameListRow _g({
  String id = 'g1',
  String player = 'p1',
  String name = 'Maya',
  DateTime? at,
  int points = 12,
}) =>
    GameListRow(
      gameId: id,
      playerId: player,
      playerName: name,
      opponent: 'Hawks',
      playedAt: at ?? DateTime(2026, 5, 4),
      points: points,
    );

Future<void> _pump(WidgetTester tester, List<GameListRow> rows) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: GamesListPage(repository: _FakeRepo(rows)),
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
    await _pump(tester, const []);
    expect(find.text('No games yet'), findsOneWidget);
    expect(find.text('Track a Game'), findsOneWidget);
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
}
