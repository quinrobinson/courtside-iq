// CiEmptyState — Phase 4.19b
//
// The shared empty-state layout, so Players and Games (and any future list) are
// identical by construction. These pin the two shapes: with a CTA and without
// (the dead-end filter fallback).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_empty_state.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_nav_icon.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(theme: CiTheme.base(), home: Scaffold(body: child)),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the title, body and a CTA when one is given',
      (tester) async {
    await _pump(
      tester,
      const CiEmptyState(
        icon: CiNavIcon.players,
        title: 'No players yet',
        body: 'Add your player to start tracking how they grow.',
        ctaLabel: 'Add player',
      ),
    );
    expect(find.text('No players yet'), findsOneWidget);
    expect(find.text('Add your player to start tracking how they grow.'),
        findsOneWidget);
    expect(find.widgetWithText(CiButton, 'Add player'), findsOneWidget);
  });

  testWidgets('draws NO button for a dead-end empty (no CTA)', (tester) async {
    await _pump(
      tester,
      const CiEmptyState(
        icon: CiNavIcon.games,
        title: 'No games match these filters',
        body: 'Try a different player or date.',
      ),
    );
    expect(find.text('No games match these filters'), findsOneWidget);
    expect(find.byType(CiButton), findsNothing);
  });
}
