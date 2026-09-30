// Help Center — Phase 4.15c

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/help_content.dart';
import 'package:courtside_i_q/features/menu/help_center_page.dart';

Future<void> _pump(WidgetTester tester, {VoidCallback? onSendFeedback}) async {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: HelpCenterPage(onSendFeedback: onSendFeedback),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists every question and no answers', (tester) async {
    // Arriving with a question, the list is what you want to see. An answer
    // already open would push most of the questions off screen.
    await _pump(tester);
    for (final t in kHelpTopics) {
      expect(find.text(t.question), findsOneWidget, reason: t.question);
    }
    expect(find.text(kHelpTopics.first.answer), findsNothing);
  });

  testWidgets('tapping a question opens its answer', (tester) async {
    await _pump(tester);
    await tester.tap(find.text(kHelpTopics.first.question));
    await tester.pumpAndSettle();
    expect(find.text(kHelpTopics.first.answer), findsOneWidget);
  });

  testWidgets('tapping it again closes it', (tester) async {
    await _pump(tester);
    await tester.tap(find.text(kHelpTopics.first.question));
    await tester.pumpAndSettle();
    await tester.tap(find.text(kHelpTopics.first.question));
    await tester.pumpAndSettle();
    expect(find.text(kHelpTopics.first.answer), findsNothing);
  });

  testWidgets('only ONE answer is open at a time', (tester) async {
    // Eight of these open at once is a wall of text with no shape, and the
    // frame draws exactly one.
    await _pump(tester);
    await tester.tap(find.text(kHelpTopics[0].question));
    await tester.pumpAndSettle();
    await tester.tap(find.text(kHelpTopics[1].question));
    await tester.pumpAndSettle();

    expect(find.text(kHelpTopics[1].answer), findsOneWidget);
    expect(find.text(kHelpTopics[0].answer), findsNothing);
  });

  testWidgets('the footer opens Send Feedback', (tester) async {
    var tapped = false;
    await _pump(tester, onSendFeedback: () => tapped = true);
    await tester.tap(find.text(kHelpFooterPrompt));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('a screen reader hears the question and its state',
      (tester) async {
    // Without this the inner Text wins and the answer's opening words get
    // read instead of the question.
    await _pump(tester);
    expect(
        find.bySemanticsLabel('${kHelpTopics.first.question}, collapsed'),
        findsOneWidget);

    await tester.tap(find.text(kHelpTopics.first.question));
    await tester.pumpAndSettle();
    expect(
        find.bySemanticsLabel('${kHelpTopics.first.question}, expanded'),
        findsOneWidget);
  });
}
