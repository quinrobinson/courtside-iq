// Sheet grab handles — one per sheet
//
// The theme set showDragHandle: true AND the components drew their own, so
// every sheet rendered TWO bars: Material's floated above the white panel,
// because these sheets are shown over a transparent background. Reported on
// the Create sheet, but it affected all of them.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_sheet.dart';
import 'package:courtside_i_q/features/premium/premium_gate_sheet.dart';

void main() {
  test('the theme does NOT draw its own drag handle', () {
    // The component owns the handle. If this is ever flipped back on, every
    // sheet in the app grows a second bar.
    expect(CiTheme.base().bottomSheetTheme.showDragHandle, isFalse);
  });

  testWidgets('a sheet shows exactly one handle', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showPremiumGateSheet(context),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(CiSheetHandle), findsOneWidget);
  });
}
