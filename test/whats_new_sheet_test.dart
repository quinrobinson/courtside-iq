// "What's new in 2.0" sheet — Phase 4.19c
//
// A pure renderer, so the test just asserts the content is all there: the
// reassurance-first header and every one of the four feature rows, plus the one
// button out. If a row goes missing in a refactor, the upgrade story silently
// loses a beat - this catches that.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/onboarding/whats_new_sheet.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: CiWhatsNewSheet())),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the header, all four feature rows, and the CTA',
      (tester) async {
    await _pump(tester);

    expect(find.text('The new Courtside IQ'), findsOneWidget);
    expect(find.text('Fresh look and new ways to track player growth.'),
        findsOneWidget);

    // Reassurance leads, then the three added features.
    expect(find.text("Everything's safe"), findsOneWidget);
    expect(find.text('Growth IQ'), findsOneWidget);
    expect(find.text('Development story'), findsOneWidget);
    expect(find.text('A faster live tracker'), findsOneWidget);

    expect(find.text('Got it'), findsOneWidget);
  });
}
