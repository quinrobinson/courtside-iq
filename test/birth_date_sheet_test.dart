import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_wheel_picker.dart';
import 'package:courtside_i_q/features/players/birth_date_sheet.dart';

final _today = DateTime(2026, 7, 21);

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  testWidgets('asks for month and year, never a day', (tester) async {
    // A birth date is the most personal thing the app collects about a child,
    // and an age band never turns on the day of the month.
    await tester.pumpWidget(_host(BirthDateSheet(today: _today)));

    expect(find.byType(CiWheelPicker<String>), findsOneWidget);
    expect(find.byType(CiWheelPicker<int>), findsOneWidget);
    expect(find.bySemanticsLabel('Birth month'), findsOneWidget);
    expect(find.bySemanticsLabel('Birth year'), findsOneWidget);
  });

  testWidgets('says why it is asking, at the moment of asking',
      (tester) async {
    await tester.pumpWidget(_host(BirthDateSheet(today: _today)));
    expect(
        find.text(
            "We use this to calibrate ratings for your player's age band."),
        findsOneWidget);
  });

  testWidgets('opens on the stored date', (tester) async {
    await tester.pumpWidget(_host(BirthDateSheet(
      today: _today,
      current: DateTime(2012, 3, 1),
    )));

    final month = tester.widget<CiWheelPicker<String>>(
        find.byType(CiWheelPicker<String>));
    expect(month.items[month.index], 'March');

    final year =
        tester.widget<CiWheelPicker<int>>(find.byType(CiWheelPicker<int>));
    expect(year.items[year.index], 2012);
  });

  testWidgets('a stored year outside the range still opens somewhere sensible',
      (tester) async {
    // 1990 is not an eligible year. Throwing or landing on a negative index
    // would take down the sheet for a row that only has bad data.
    await tester.pumpWidget(_host(BirthDateSheet(
      today: _today,
      current: DateTime(1990, 5, 1),
    )));

    final year =
        tester.widget<CiWheelPicker<int>>(find.byType(CiWheelPicker<int>));
    expect(year.index, 0);
  });

  testWidgets('the year range covers the ages the app is for', (tester) async {
    await tester.pumpWidget(_host(BirthDateSheet(today: _today)));

    final year =
        tester.widget<CiWheelPicker<int>>(find.byType(CiWheelPicker<int>));
    // Ages 3 through 20 - wider than the 8-18 product range on purpose, so a
    // parent whose child sits just outside can enter the truth.
    expect(year.items.first, 2023);
    expect(year.items.last, 2006);
  });

  testWidgets('Save returns the chosen month and year with day 1',
      (tester) async {
    DateTime? result;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              result = await showDialog<DateTime>(
                context: context,
                builder: (_) => Dialog(
                  child: BirthDateSheet(
                    today: _today,
                    current: DateTime(2011, 6, 1),
                  ),
                ),
              );
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CiButton));
    await tester.pumpAndSettle();

    expect(result, DateTime(2011, 6, 1));
  });
}
