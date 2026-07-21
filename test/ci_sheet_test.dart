import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_sheet.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_metrics.dart';
import 'package:courtside_i_q/features/players/present_picker.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  group('CiSheet', () {
    testWidgets('renders the shell and the caller\'s middle', (tester) async {
      await tester.pumpWidget(_host(const CiSheet(
        title: 'Position',
        cta: 'Save',
        child: Text('MIDDLE'),
      )));

      expect(find.text('Position'), findsOneWidget);
      expect(find.text('MIDDLE'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('no cta means no button, not a dead one', (tester) async {
      await tester.pumpWidget(_host(const CiSheet(
        title: 'T',
        child: Text('MIDDLE'),
      )));
      expect(find.byType(CiButton), findsNothing);
    });

    testWidgets('has SQUARE top corners', (tester) async {
      // Four frames, none with a radius. The system HAS a sheet radius, which
      // is how the first info sheet got one applied on reflex.
      await tester.pumpWidget(_host(const CiSheet(
        title: 'T',
        child: SizedBox(),
      )));

      final rounded = tester
          .widgetList<Container>(find.descendant(
              of: find.byType(CiSheet), matching: find.byType(Container)))
          .where((x) =>
              (x.decoration as BoxDecoration?)?.borderRadius ==
              CiRadius.sheetTopR);
      expect(rounded, isEmpty);
    });
  });

  group('CiOptionSheet', () {
    testWidgets('Save is disabled until something is chosen', (tester) async {
      // A Save that commits nothing is a button that lies about what it does.
      await tester.pumpWidget(_host(CiOptionSheet<String>(
        title: 'Position',
        options: const ['Guard', 'Forward', 'Center'],
        labelOf: (s) => s,
      )));

      expect(tester.widget<CiButton>(find.byType(CiButton)).onPressed, isNull);

      await tester.tap(find.text('Forward'));
      await tester.pump();
      expect(
          tester.widget<CiButton>(find.byType(CiButton)).onPressed, isNotNull);
    });

    testWidgets('a tap selects but does NOT commit', (tester) async {
      // The v1 sheet popped on tap. This one holds the choice, so a mis-tap
      // on a 56pt row is recoverable.
      String? result;
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await showCiSheet<String>(
                  context,
                  useRootNavigator: false,
                  child: CiOptionSheet<String>(
                    title: 'Position',
                    options: const ['Guard', 'Forward'],
                    labelOf: (s) => s,
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
      await tester.tap(find.text('Guard'));
      await tester.pumpAndSettle();
      // Still open.
      expect(find.byType(CiOptionSheet<String>), findsOneWidget);
      expect(result, isNull);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, 'Guard');
    });

    testWidgets('the current value arrives already checked', (tester) async {
      await tester.pumpWidget(_host(CiOptionSheet<String>(
        title: 'Position',
        options: const ['Guard', 'Forward'],
        labelOf: (s) => s,
        current: 'Forward',
      )));

      expect(find.byIcon(Icons.check), findsOneWidget);
      final row = tester.widget<CiSheetOptionRow>(
        find.ancestor(
            of: find.text('Forward'), matching: find.byType(CiSheetOptionRow)),
      );
      expect(row.selected, isTrue);
    });
  });

  group('presentCiPicker', () {
    testWidgets('an empty list says so instead of opening a sliver',
        (tester) async {
      // A zero-height sheet is indistinguishable from "the picker did not
      // open", which is exactly how a failed options load presents.
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () => presentCiPicker<String>(
                context,
                title: 'Position',
                options: const [],
                labelOf: (s) => s,
              ),
              child: const Text('open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(CiOptionSheet<String>), findsNothing);
      expect(find.text('Could not load options. Check your connection.'),
          findsOneWidget);
    });
  });
}
