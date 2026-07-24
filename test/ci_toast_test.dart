// CiToast — Phase 4.19d
//
// The dot carries the meaning, so the tests pin the dot COLOUR to the type
// (lime = done, orange = problem, white = neutral) and check the optional
// action taps through and dismisses. If a refactor swapped the colours the
// toast would lie about whether something worked - this catches that.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_toast.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

Future<void> _fire(
  WidgetTester tester, {
  required String message,
  CiToastType type = CiToastType.neutral,
  String? actionLabel,
  VoidCallback? onAction,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showCiToast(context, message,
              type: type, actionLabel: actionLabel, onAction: onAction),
          child: const Text('go'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pump(); // let the snackbar animate in
}

Color _dotColor(WidgetTester tester) {
  final dot = tester.widgetList<Container>(find.byType(Container)).firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
      );
  return (dot.decoration as BoxDecoration).color!;
}

void main() {
  testWidgets('success shows the message with the lime dot', (tester) async {
    await _fire(tester, message: 'Changes saved.', type: CiToastType.success);
    expect(find.text('Changes saved.'), findsOneWidget);
    expect(_dotColor(tester), CiPalette.lime);
  });

  testWidgets('error shows the orange dot', (tester) async {
    await _fire(tester,
        message: "Couldn't save. Check your connection.",
        type: CiToastType.error);
    expect(_dotColor(tester), CiPalette.orange);
  });

  testWidgets('neutral shows a white dot', (tester) async {
    await _fire(tester, message: 'Sent. Check your email again.');
    expect(_dotColor(tester), CiPalette.white);
  });

  testWidgets('the action taps through and dismisses the toast',
      (tester) async {
    var taps = 0;
    await _fire(tester,
        message: "Couldn't save. Check your connection.",
        type: CiToastType.error,
        actionLabel: 'Retry',
        onAction: () => taps++);

    // Let the snackbar finish sliding in so the action is hit-testable.
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(taps, 1);
    // Dismissed by the tap, not left lingering.
    expect(find.text("Couldn't save. Check your connection."), findsNothing);
  });
}
