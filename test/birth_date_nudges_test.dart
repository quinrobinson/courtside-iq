import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/players/birth_date_nudges.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

Future<bool?> _openPrompt(WidgetTester tester) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () async => result = await showBirthDatePrompt(context),
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
  group('prompt', () {
    testWidgets('says what a birth date buys', (tester) async {
      await _openPrompt(tester);
      expect(find.text('Add a birth date'), findsOneWidget);
      expect(
          find.text("Adding a birth date calibrates ratings to your player's "
              'age band.'),
          findsOneWidget);
    });

    testWidgets('declining says "Not now", never "Cancel"', (tester) async {
      // Cancel implies abandoning something the parent started. This was the
      // app's idea, and declining it is not a failure.
      await _openPrompt(tester);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('only the accept button returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () async =>
                  result = await showBirthDatePrompt(context),
              child: const Text('open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add birth date'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('caveat', () {
    testWidgets('names the player', (tester) async {
      // "these ratings" alone leaves a parent with two players guessing which
      // one is uncalibrated.
      await tester.pumpWidget(_host(
        BirthDateCaveat(firstName: 'Maya', onAdd: () {}),
      ));
      expect(
          find.text("Add a birth date to calibrate these ratings for Maya's "
              'age.'),
          findsOneWidget);
    });

    testWidgets('still reads as a sentence with no name', (tester) async {
      await tester.pumpWidget(_host(
        BirthDateCaveat(firstName: '', onAdd: () {}),
      ));
      expect(
          find.text("Add a birth date to calibrate these ratings for your "
              "player's age."),
          findsOneWidget);
    });

    testWidgets('the action reports', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        BirthDateCaveat(firstName: 'Maya', onAdd: () => taps++),
      ));
      await tester.tap(find.text('Add'));
      expect(taps, 1);
    });
  });
}
