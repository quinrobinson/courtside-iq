// Send Feedback — Phase 4.15c
//
// The thing worth guarding is what happens to a message that fails to send.
// The feedback table is insert-only, so a parent has no sent-items list to
// check: if the app drops what they wrote, it is gone and they will not know.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/menu/feedback_repository.dart';
import 'package:courtside_i_q/features/menu/send_feedback_page.dart';

class _FakeFeedback implements FeedbackRepository {
  _FakeFeedback({this.succeeds = true});
  final bool succeeds;
  final sent = <({FeedbackCategory category, String message})>[];

  @override
  Future<bool> send({
    required FeedbackCategory category,
    required String message,
  }) async {
    sent.add((category: category, message: message));
    return succeeds;
  }
}

Future<void> _pump(WidgetTester tester, _FakeFeedback repo) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: SendFeedbackPage(repository: repo),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers all four categories, with Idea preselected',
      (tester) async {
    // The frame's default. A form opening with nothing chosen asks a question
    // before the one it actually wants answered.
    final repo = _FakeFeedback();
    await _pump(tester, repo);
    for (final label in const ['Bug', 'Idea', 'Question', 'Other']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.enterText(find.byType(TextField), 'The tracker is great.');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send feedback').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.sent.single.category, FeedbackCategory.idea);
  });

  testWidgets('an empty note cannot be sent', (tester) async {
    final repo = _FakeFeedback();
    await _pump(tester, repo);
    await tester.tap(find.text('Send feedback').last);
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);

    // Whitespace is not a note either.
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send feedback').last);
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
  });

  testWidgets('carries the chosen category', (tester) async {
    final repo = _FakeFeedback();
    await _pump(tester, repo);
    await tester.tap(find.text('Bug'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'The score reset itself.');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send feedback').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.sent.single.category, FeedbackCategory.bug);
    expect(repo.sent.single.message, 'The score reset itself.');
  });

  testWidgets('a send that fails KEEPS the message', (tester) async {
    // There is no sent-items list to recover it from. Clearing the field
    // here would lose something a parent took time to write, and the app
    // would be at fault twice.
    final repo = _FakeFeedback(succeeds: false);
    await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Something I typed.');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send feedback').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Something I typed.'), findsOneWidget);
    expect(find.textContaining("didn't send"), findsOneWidget);
  });

  testWidgets('a successful send confirms in a sheet', (tester) async {
    // Not a snackbar. Feedback goes somewhere a parent cannot check, so a
    // receipt that vanishes in three seconds is a poor one.
    final repo = _FakeFeedback();
    await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Loving it.');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send feedback').last);
    await tester.pumpAndSettle();

    expect(find.text("Thanks, we've got it"), findsOneWidget);
    expect(find.textContaining('reach out by email'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    // The frame's leftover "Position" header and X are not carried over.
    expect(find.text('Position'), findsNothing);
  });
}
