import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
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
}
