// Guided First-Run — Phase 4.9
//
// Step 1 (Welcome) is pure UI and covered here. Step 2 (First Player) loads
// positions and inserts through SupaFlow on entry, so it needs a device or an
// injected repository; that arrives with the gate wiring. These tests stay on
// the welcome step so they never touch Supabase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/onboarding/first_run_flow.dart';

Future<void> _pump(WidgetTester tester, {VoidCallback? onFinished}) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(home: FirstRunFlow(onFinished: onFinished)),
  );
  await tester.pump();
}

void main() {
  testWidgets('opens on the welcome step', (tester) async {
    await _pump(tester);
    expect(find.text("Let's get set up"), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  testWidgets('Skip for now ends the flow without adding a player',
      (tester) async {
    // Onboarding is a welcome, not a gate: skipping is a first-class exit.
    var finished = false;
    await _pump(tester, onFinished: () => finished = true);
    await tester.tap(find.text('Skip for now'));
    await tester.pump();
    expect(finished, isTrue);
  });
}
