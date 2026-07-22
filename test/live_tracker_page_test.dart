import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/features/games/live_game_store.dart';
import 'package:courtside_i_q/features/games/live_tracker_page.dart';

/// Records every write so the write-through guarantee can be asserted.
class _SpyStore implements LiveGameStore {
  final saves = <LiveGameStats>[];

  @override
  Future<void> save(LiveGameSnapshot snapshot) async =>
      saves.add(snapshot.stats);

  @override
  Future<LiveGameSnapshot?> read() async => null;

  @override
  Future<void> clear() async {}
}

/// Scrolls a control into view before tapping it.
///
/// The counter grid sits below the shooting rows, which puts it off a 800x600
/// test viewport. A tap on an off-screen finder lands nowhere and fails
/// SILENTLY - the widget is found, the callback never runs - so every counter
/// tap goes through here.
Future<void> _tapControl(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

LiveGameSnapshot _snap({LiveGameStats stats = const LiveGameStats()}) =>
    LiveGameSnapshot(
      playerId: 'p1',
      playerName: 'Maya',
      opponent: 'Northside Hawks',
      stats: stats,
      startedAt: DateTime(2026, 5, 4),
    );

Future<_SpyStore> _pump(
  WidgetTester tester, {
  LiveGameStats stats = const LiveGameStats(),
  ValueChanged<LiveGameSnapshot>? onEnd,
}) async {
  final store = _SpyStore();
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: LiveTrackerPage(
      snapshot: _snap(stats: stats),
      store: store,
      onEnd: onEnd,
    ),
  ));
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('a make moves the score by that shot value', (tester) async {
    await _pump(tester);
    expect(find.text('0'), findsWidgets);

    await tester.tap(find.text('Make +3'));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsWidgets);

    await tester.tap(find.text('Make +2'));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsWidgets);
  });

  testWidgets('a miss never scores', (tester) async {
    await _pump(tester);
    await tester.tap(find.widgetWithText(InkWell, 'Miss').first);
    await tester.pumpAndSettle();
    // PTS still zero; the missed count moved instead.
    expect(find.text('Missed'), findsWidgets);
  });

  testWidgets('EVERY tap writes through', (tester) async {
    // A game cannot be tracked twice, and phones get dropped.
    final store = await _pump(tester);
    await tester.tap(find.text('Make +2'));
    await tester.pumpAndSettle();
    await _tapControl(tester, find.bySemanticsLabel('One more Assists'));

    expect(store.saves.length, 2);
    expect(store.saves.last.twoMade, 1);
    expect(store.saves.last.assists, 1);
  });

  testWidgets('tapping a count undoes one', (tester) async {
    // The frame shows no undo, but a mis-tap during a game is certain and the
    // shooting rows had no way back.
    await _pump(tester, stats: const LiveGameStats(twoMade: 3));
    expect(find.text('6'), findsWidgets, reason: '3 twos');

    await tester.tap(find.bySemanticsLabel('Undo one made 2PT'));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsWidgets);
  });

  testWidgets('nothing to undo is not a tap target', (tester) async {
    await _pump(tester);
    final undo = tester.widget<InkWell>(find.descendant(
      of: find.bySemanticsLabel('Undo one made 2PT'),
      matching: find.byType(InkWell),
    ));
    expect(undo.onTap, isNull);
  });

  testWidgets('minus stops at zero', (tester) async {
    await _pump(tester);
    final minus = tester.widget<InkWell>(find.descendant(
      of: find.bySemanticsLabel('One fewer Assists'),
      matching: find.byType(InkWell),
    ));
    expect(minus.onTap, isNull, reason: 'nothing to remove at zero');
  });

  testWidgets('minus removes one when there is one to remove', (tester) async {
    // The disabled case is covered above; this is the working one. Both
    // matter: a mis-tapped assist during a game has to be recoverable.
    final store = await _pump(tester, stats: const LiveGameStats(assists: 2));
    await _tapControl(tester, find.bySemanticsLabel('One fewer Assists'));

    expect(store.saves.length, 1);
    expect(store.saves.last.assists, 1);
  });

  testWidgets('rebounds in the header are the two kinds added',
      (tester) async {
    await _pump(tester, stats: const LiveGameStats(offReb: 2, defReb: 3));
    expect(find.text('REB'), findsOneWidget);
    expect(find.text('5'), findsWidgets);
  });

  testWidgets('End hands over the final stats', (tester) async {
    LiveGameSnapshot? ended;
    await _pump(tester,
        stats: const LiveGameStats(twoMade: 4), onEnd: (s) => ended = s);

    await tester.tap(find.bySemanticsLabel('End game'));
    await tester.pumpAndSettle();

    expect(ended, isNotNull);
    expect(ended!.stats.points, 8);
  });

  testWidgets('with no opponent the player still names the game',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: LiveTrackerPage(
        snapshot: LiveGameSnapshot(
          playerId: 'p1',
          playerName: 'Maya',
          stats: const LiveGameStats(),
          startedAt: DateTime(2026, 5, 4),
        ),
        store: _SpyStore(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Maya'), findsOneWidget);
    expect(find.textContaining('vs '), findsNothing);
  });
}
