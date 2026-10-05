import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/game_sync/pending_game.dart';
import 'package:courtside_i_q/features/games/game_allowance.dart';
import 'package:courtside_i_q/features/games/held_game_gate.dart';

// Roadmap 3.8: the "Your game is safe on this phone" reminder.

PendingGame _held(String opponent) => PendingGame(
      gameId: 'g4',
      statsId: 's4',
      gameRow: {'id': 'g4', 'opponent_team': opponent},
      statsRow: {'id': 's4', 'game_id': 'g4'},
      queuedAt: DateTime(2026, 10, 4),
      heldForLimit: true,
    );

class _Policy implements HeldGamePolicy {
  _Policy({required this.games, required this.a});
  final List<PendingGame> games;
  final GameAllowance a;
  final controller = StreamController<int>.broadcast();
  @override
  Future<List<PendingGame>> held() async => games;
  @override
  Future<GameAllowance> allowance() async => a;
  @override
  Stream<int> get changes => controller.stream;
  @override
  Future<void> syncNow() async {}
}

Future<void> _pump(WidgetTester tester, HeldGamePolicy policy) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: HeldGameGate(policy: policy, child: const Scaffold()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(resetHeldGameGateForTest);

  testWidgets('a free parent at the allowance sees the reminder once',
      (tester) async {
    final policy = _Policy(
      games: [_held('Eagles')],
      a: const GameAllowance(
          isPremium: false, gameCount: 4, playerFirstName: 'Maya'),
    );
    await _pump(tester, policy);

    expect(find.text('Your game is safe on this phone'), findsOneWidget);
    expect(find.textContaining('vs Eagles'), findsOneWidget);

    await tester.tap(find.text('Not now, keep it on this phone'));
    await tester.pumpAndSettle();

    // A reconnect flush changes the queue: no second sheet this launch.
    policy.controller.add(1);
    await tester.pumpAndSettle();
    expect(find.text('Your game is safe on this phone'), findsNothing);
  });

  testWidgets('premium is never told it ran out', (tester) async {
    await _pump(
      tester,
      _Policy(
        games: [_held('Eagles')],
        a: const GameAllowance(isPremium: true, gameCount: 40),
      ),
    );
    expect(find.text('Your game is safe on this phone'), findsNothing);
  });

  testWidgets('nothing held, nothing shown', (tester) async {
    await _pump(
      tester,
      _Policy(
        games: const [],
        a: const GameAllowance(isPremium: false, gameCount: 3),
      ),
    );
    expect(find.text('Your game is safe on this phone'), findsNothing);
  });
}
