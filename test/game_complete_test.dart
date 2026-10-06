import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/features/games/game_complete_page.dart';
import 'package:courtside_i_q/features/games/game_paused_dialog.dart';
import 'package:courtside_i_q/features/games/live_game_store.dart';

LiveGameSnapshot _snap({
  LiveGameStats stats = const LiveGameStats(),
  String? opponent = 'Northside Hawks',
}) =>
    LiveGameSnapshot(
      playerId: 'p1',
      playerName: 'Maya',
      opponent: opponent,
      stats: stats,
      startedAt: DateTime(2026, 5, 4),
    );

Future<void> _pumpComplete(
  WidgetTester tester, {
  LiveGameStats stats = const LiveGameStats(),
  String? opponent = 'Northside Hawks',
  VoidCallback? onSave,
  VoidCallback? onDiscard,
  bool saving = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: GameCompletePage(
      snapshot: _snap(stats: stats, opponent: opponent),
      onSave: onSave,
      onDiscard: onDiscard,
      saving: saving,
    ),
  ));
  // pump, not pumpAndSettle: the busy spinner animates forever, so a settle
  // never returns.
  await tester.pump();
}

void main() {
  group('Game complete', () {
    testWidgets('leads with points and shows the supporting line',
        (tester) async {
      await _pumpComplete(tester,
          stats: const LiveGameStats(
              twoMade: 5, threeMade: 4, offReb: 3, defReb: 4, assists: 5));

      expect(find.text('22'), findsOneWidget);
      expect(find.text('POINTS'), findsOneWidget);
      expect(find.text('7'), findsOneWidget, reason: 'rebounds are 3 + 4');
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('names the matchup, and copes without an opponent',
        (tester) async {
      await _pumpComplete(tester);
      expect(find.text('Maya vs Northside Hawks · Mon, May 4'), findsOneWidget);

      await _pumpComplete(tester, opponent: null);
      expect(find.text('Maya · Mon, May 4'), findsOneWidget,
          reason: 'no dangling "vs"');
    });

    testWidgets('a shot never taken has no percentage', (tester) async {
      // "0%" would report a miss that never happened - the same rule the
      // Averages tab follows.
      await _pumpComplete(tester, stats: const LiveGameStats(twoMade: 2));
      expect(find.text('100%'), findsOneWidget, reason: 'field goal 2/2');
      expect(find.text('—'), findsWidgets, reason: 'no threes, no free throws');
      expect(find.text('0%'), findsNothing);
    });

    testWidgets('the teaser promises the insight by name', (tester) async {
      await _pumpComplete(tester);
      // NOT "unlock ... game insight". That promised a per-game insight the
      // data may not support: a quiet game earns none, so the app committed
      // to something it then silently did not do. Changed 2026-07-23.
      expect(find.text("Save to add this game to Maya's development"),
          findsOneWidget);
      expect(find.textContaining('some games earn a closer read'),
          findsOneWidget);
    });

    testWidgets('saving blocks a second tap', (tester) async {
      // A double save would insert the game twice.
      var saves = 0;
      await _pumpComplete(tester, saving: true, onSave: () => saves++);
      final save = tester.widget<CiButton>(find.byType(CiButton));
      expect(save.onPressed, isNull);
      expect(save.busy, isTrue);
    });

    testWidgets('discard is muted, not dressed as danger', (tester) async {
      await _pumpComplete(tester);
      // Below the fold on a test viewport, and a ListView does not build what
      // it cannot show - the same trap as the tracker's counter grid.
      await tester.scrollUntilVisible(
        find.text('Discard Game'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final discard = tester.widget<Text>(find.text('Discard Game'));
      expect(discard.style!.color, CiColors.onLight.textMuted);
      expect(discard.style!.color, isNot(CiColors.onLight.accentEnergy));
    });
  });

  group('Game paused', () {
    Future<PausedChoice?> open(WidgetTester tester) async {
      PausedChoice? choice;
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () async {
                choice = await showGamePausedDialog(context,
                    snapshot: _snap(
                        stats: const LiveGameStats(twoMade: 6, assists: 3)));
              },
              child: const Text('open'),
            );
          }),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return choice;
    }

    testWidgets('answers the question a pause is usually asking',
        (tester) async {
      // A parent pausing is normally checking the tally, so the dialog shows
      // it rather than only asking what to do.
      await open(tester);
      expect(find.text('Game paused'), findsOneWidget);
      expect(find.text('12'), findsOneWidget, reason: 'PTS');
      expect(find.text('3'), findsOneWidget, reason: 'AST');
      expect(find.text('vs Northside Hawks'), findsOneWidget);
    });

    testWidgets('Resume and End both report themselves', (tester) async {
      PausedChoice? choice;
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () async {
                choice = await showGamePausedDialog(context,
                    snapshot: _snap());
              },
              child: const Text('open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(choice, PausedChoice.resume);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End game'));
      await tester.pumpAndSettle();
      expect(choice, PausedChoice.end);
    });

    testWidgets('End game is not dressed as destructive', (tester) async {
      // It leads to the save screen, not to data loss.
      await open(tester);
      final end = tester.widget<CiButton>(
          find.ancestor(of: find.text('End game'), matching: find.byType(CiButton)));
      expect(end.style, CiButtonStyle.secondary);
      expect(end.style, isNot(CiButtonStyle.orange));
    });
  });
}
