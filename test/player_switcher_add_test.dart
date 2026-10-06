import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_avatar.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.ink(child: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('the add slot appears only when a caller wants it',
      (tester) async {
    await tester.pumpWidget(_host(CiPlayerSwitcher(
      names: const ['Maya Chen', 'Jada Chen'],
      index: 0,
      onSelected: (_) {},
    )));
    expect(find.bySemanticsLabel('Add player'), findsNothing);

    await tester.pumpWidget(_host(CiPlayerSwitcher(
      names: const ['Maya Chen', 'Jada Chen'],
      index: 0,
      onSelected: (_) {},
      onAdd: () {},
    )));
    expect(find.bySemanticsLabel('Add player'), findsOneWidget);
  });

  testWidgets('tapping the slot reports it', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(_host(CiPlayerSwitcher(
      names: const ['Maya Chen'],
      index: 0,
      onSelected: (_) {},
      onAdd: () => tapped++,
    )));

    await tester.tap(find.bySemanticsLabel('Add player'));
    expect(tapped, 1);
  });

  testWidgets('the slot is drawn, not bordered', (tester) async {
    // A solid ring reads as a player who has not loaded. The dashed ring
    // reads as a space waiting to be filled, and Flutter's Border cannot
    // draw one - hence the painter.
    await tester.pumpWidget(_host(CiPlayerSwitcher(
      names: const ['Maya Chen'],
      index: 0,
      onSelected: (_) {},
      onAdd: () {},
    )));

    final painted = find.descendant(
      of: find.bySemanticsLabel('Add player'),
      matching: find.byType(CustomPaint),
    );
    expect(painted, findsWidgets);
  });
}
