import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/players/widgets/player_gates.dart';

// Roadmap 3.8: the free-games sheets (Figma 1182:5313, 1182:5370).
Widget _launcher(Future<bool> Function(BuildContext) open,
        void Function(bool) onResult) =>
    MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => onResult(await open(context)),
            child: const Text('open'),
          ),
        ),
      ),
    );

void main() {
  testWidgets('game limit gate: approved copy, See plans returns true',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_launcher(
      (c) => showGameLimitGate(c, playerFirstName: 'Maya'),
      (r) => result = r,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text("You've used your 3 free games"), findsOneWidget);
    expect(
        find.text("Maya's games and insights stay right where they are. "
            'Go Premium to keep tracking.'),
        findsOneWidget);
    expect(find.text('Unlimited games every season'), findsOneWidget);
    expect(find.text('Track up to 3 players'), findsOneWidget);
    expect(find.text("Growth IQ and Maya's story keep building"),
        findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);

    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('game limit gate without a name falls back cleanly',
      (tester) async {
    await tester.pumpWidget(
        _launcher((c) => showGameLimitGate(c), (_) {}));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
        find.text('Your games and insights stay right where they are. '
            'Go Premium to keep tracking.'),
        findsOneWidget);
  });

  testWidgets('offline held: names the opponent, never says "Not now"',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_launcher(
      (c) => showOfflineGameHeldGate(c,
          opponent: 'Eagles', playerFirstName: 'Maya'),
      (r) => result = r,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Your game is safe on this phone'), findsOneWidget);
    expect(
        find.text('You tracked a game vs Eagles offline after your 3 free '
            "games. Go Premium to add it to Maya's games."),
        findsOneWidget);
    // Dismissing must not read as deleting the game.
    expect(find.text('Not now'), findsNothing);
    await tester.tap(find.text('Keep it on this phone'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('offline held: falls back when there is no opponent',
      (tester) async {
    await tester.pumpWidget(
        _launcher((c) => showOfflineGameHeldGate(c, opponent: ' '), (_) {}));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
        find.text('You tracked a game offline after your 3 free games. '
            'Go Premium to add it to your games.'),
        findsOneWidget);
  });
}
