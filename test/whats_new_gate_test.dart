// "What's new in 2.0" gate — Phase 4.19c
//
// The gate's job is a one-time decision that must not misfire: show the upgrade
// sheet to an existing user exactly once, and never to anyone else. The policy
// is injected so these run without Supabase or storage - a fake says show /
// don't show, and the tests assert the sheet appears (or not) and is recorded.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/onboarding/whats_new_gate.dart';

class _FakePolicy implements WhatsNew2Policy {
  _FakePolicy(this.show);
  final bool show;
  int seenCalls = 0;

  @override
  Future<bool> shouldShow() async => show;

  @override
  Future<void> markSeen() async => seenCalls++;
}

Future<void> _pump(WidgetTester tester, WhatsNew2Policy policy) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: WhatsNewGate(policy: policy, child: const Text('TODAY')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an existing user sees the sheet, marked seen only AFTER it is '
      'dismissed', (tester) async {
    final policy = _FakePolicy(true);
    await _pump(tester, policy);
    // Today is underneath; the sheet floats over it.
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('The new Courtside IQ'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    // NOT marked while it is still open. Marking before the render finished is
    // what let an interrupted show set the flag with the sheet never seen -
    // and on iOS that flag survives a reinstall, so a real v1 user could miss
    // the reassurance forever.
    expect(policy.seenCalls, 0);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    // Marked now that it was actually dismissed, so it never returns.
    expect(policy.seenCalls, greaterThan(0));
  });

  testWidgets('a user who should not see it gets Today alone, unmarked',
      (tester) async {
    final policy = _FakePolicy(false);
    await _pump(tester, policy);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('The new Courtside IQ'), findsNothing);
    // Never marked: only actually showing it records a view.
    expect(policy.seenCalls, 0);
  });

  testWidgets('"Got it" dismisses the sheet and leaves Today', (tester) async {
    final policy = _FakePolicy(true);
    await _pump(tester, policy);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('The new Courtside IQ'), findsNothing);
    expect(find.text('TODAY'), findsOneWidget);
  });
}
