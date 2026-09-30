import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_sheet.dart';
import 'package:courtside_i_q/features/nav/create_sheet.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  testWidgets('offers both actions once a player exists', (tester) async {
    await tester.pumpWidget(_host(const CreateSheet(hasPlayers: true)));

    expect(find.text('Create'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
    expect(find.text('Track a game for a player'), findsOneWidget);
    expect(find.text('New player'), findsOneWidget);
    expect(find.text('Add a player to track (up to 3)'), findsOneWidget);
  });

  testWidgets('hides New game when there are no players', (tester) async {
    // A game is logged FOR a player. With none, the row has nothing it could
    // do, and hiding it leaves a first-time parent one obvious action.
    await tester.pumpWidget(_host(const CreateSheet(hasPlayers: false)));

    expect(find.text('New game'), findsNothing);
    expect(find.text('New player'), findsOneWidget);
  });

  testWidgets('New player stays tappable regardless of the cap',
      (tester) async {
    // Deliberately NOT disabled at the cap. The gate behind it explains why -
    // a disabled row leaves the parent unable to find out, and a hidden one
    // looks like the app lost a feature.
    await tester.pumpWidget(_host(const CreateSheet(hasPlayers: true)));

    final row = tester.widget<CiSheetActionRow>(
      find.ancestor(
          of: find.text('New player'),
          matching: find.byType(CiSheetActionRow)),
    );
    expect(row.onTap, isNotNull);
  });

  testWidgets('has no CTA button - the rows ARE the actions', (tester) async {
    await tester.pumpWidget(_host(const CreateSheet(hasPlayers: true)));
    expect(find.text('Save'), findsNothing);
    expect(find.text('Got it'), findsNothing);
  });

  testWidgets('each row returns its own choice', (tester) async {
    CreateChoice? choice;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              choice = await showCiSheet<CreateChoice>(
                context,
                useRootNavigator: false,
                child: const CreateSheet(hasPlayers: true),
              );
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New player'));
    await tester.pumpAndSettle();
    expect(choice, CreateChoice.newPlayer);
  });
}
