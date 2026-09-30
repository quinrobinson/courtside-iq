import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_confirm_dialog.dart';
import 'package:courtside_i_q/features/players/delete_player_dialog.dart';

Future<bool?> _open(WidgetTester tester, {String firstName = 'Maya'}) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () async {
            result = await showDeletePlayerDialog(context,
                firstName: firstName);
          },
          child: const Text('open'),
        );
      }),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('names the player and says what else goes', (tester) async {
    await _open(tester);

    // A category ("Delete player?") does not make a wrong tap obvious. A name
    // does.
    expect(find.text('Delete Maya?'), findsOneWidget);
    expect(
        find.text('This removes Maya and every game you have logged for them. '
            'It cannot be undone.'),
        findsOneWidget);
  });

  testWidgets('never guesses a gendered pronoun', (tester) async {
    // The app records no gender for a player - there is no column and no
    // question in the add form - so "her" or "him" here would be a guess that
    // is wrong for some real child.
    await _open(tester);
    final text = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ');
    for (final pronoun in [' her ', ' him ', ' his ', ' she ', ' he ']) {
      expect(text.toLowerCase(), isNot(contains(pronoun)));
    }
  });

  testWidgets('a player with no name still reads as a sentence',
      (tester) async {
    await _open(tester, firstName: '');
    expect(find.text('Delete this player?'), findsOneWidget);
  });

  testWidgets('Cancel returns false', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    // Verified via the dialog closing without a delete; the return value is
    // asserted in the confirm case below.
    expect(find.text('Delete Maya?'), findsNothing);
  });

  testWidgets('only an explicit Delete confirms', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              result =
                  await showDeletePlayerDialog(context, firstName: 'Maya');
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse, reason: 'cancel is not consent');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  group('the shape it takes', () {
    // It was a Material AlertDialog with small corner text buttons and Cancel
    // first, built without reading 370:1886 and then extracted into a shared
    // component - so the discard-game dialog inherited the error. These
    // assert the frame's shape, not just its words.
    Future<void> open(WidgetTester tester, {bool destructive = true}) async {
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showCiConfirmDialog(
              context,
              title: 'Discard this game?',
              message: 'The stats you tracked will be deleted.',
              confirmLabel: 'Discard',
              cancelLabel: 'Keep it',
              destructive: destructive,
            ),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('two full-width pills, not corner text buttons',
        (tester) async {
      await open(tester);
      final buttons = tester.widgetList<CiButton>(find.byType(CiButton));
      expect(buttons.length, 2);
      expect(buttons.every((b) => b.expand), isTrue);
    });

    testWidgets('the confirming action comes FIRST', (tester) async {
      await open(tester);
      final confirm = tester.getTopLeft(find.text('Discard')).dy;
      final cancel = tester.getTopLeft(find.text('Keep it')).dy;
      expect(confirm, lessThan(cancel),
          reason: 'the frame puts the action above Cancel');
    });

    testWidgets('destructive wears orange', (tester) async {
      await open(tester);
      expect(tester.widgetList<CiButton>(find.byType(CiButton)).first.style,
          CiButtonStyle.orange);
    });

    testWidgets('a confirm that merely proceeds wears ink', (tester) async {
      // The accent marks destruction. If every confirm took it there would be
      // nothing left to mark the ones that cannot be undone.
      await open(tester, destructive: false);
      expect(tester.widgetList<CiButton>(find.byType(CiButton)).first.style,
          CiButtonStyle.primary);
    });
  });
}
