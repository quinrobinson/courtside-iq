// Guided First-Run gate — Phase 4.9
//
// The gate's DECISION is what matters and what once went wrong elsewhere (a
// screen that showed to the wrong user, or not at all). The policy is injected
// so these run without Supabase or storage: a fake says show / don't show, and
// the tests assert the gate routes and records accordingly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/onboarding/first_run_gate.dart';

class _FakePolicy implements FirstRunPolicy {
  _FakePolicy(this.show);
  final bool show;
  int seenCalls = 0;

  @override
  Future<bool> shouldShow() async => show;

  @override
  Future<void> markSeen() async => seenCalls++;
}

Future<void> _pump(WidgetTester tester, FirstRunPolicy policy) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: FirstRunGate(policy: policy, child: const Text('TODAY')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a settled user lands on Today, and is marked seen so the gate '
      'never queries again', (tester) async {
    final policy = _FakePolicy(false);
    await _pump(tester, policy);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text("Let's get set up"), findsNothing);
    expect(policy.seenCalls, greaterThan(0));
  });

  testWidgets('a brand-new player-less user gets the welcome, not Today',
      (tester) async {
    final policy = _FakePolicy(true);
    await _pump(tester, policy);
    expect(find.text("Let's get set up"), findsOneWidget);
    expect(find.text('TODAY'), findsNothing);
  });

  testWidgets('finishing the flow marks it seen and lands on Today',
      (tester) async {
    // Skip is a first-class exit; either way the welcome must not reappear.
    final policy = _FakePolicy(true);
    await _pump(tester, policy);
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(policy.seenCalls, greaterThan(0));
    expect(find.text('TODAY'), findsOneWidget);
  });
}
