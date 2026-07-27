// CiField hit target — the whole box focuses, not just the text line.
//
// The TextField inside the 48pt box is only as tall as its text line (isDense
// + zero content padding), centred - so more than half the visible field was
// dead to taps, and on device focusing took a couple of tries. These pin the
// fix: a tap anywhere in the box focuses the field.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

TextField _textField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  testWidgets('a tap in the box corner, off the text line, still focuses',
      (tester) async {
    await tester.pumpWidget(_host(const CiField(label: 'Email address')));

    // The bottom-left corner of the 48pt box: below the centred text line and
    // left of the 16px content inset - dead space before the fix.
    final box = tester.getRect(find.byType(CiField));
    await tester.tapAt(Offset(box.left + 4, box.bottom - 4));
    await tester.pump();

    expect(_textField(tester).focusNode!.hasFocus, isTrue,
        reason: 'the whole visible field is the tap target');
  });

  testWidgets('a dead-zone tap puts the cursor at the END of existing text',
      (tester) async {
    final ctrl = TextEditingController(text: 'alex@example');
    addTearDown(ctrl.dispose);
    await tester
        .pumpWidget(_host(CiField(label: 'Email address', controller: ctrl)));

    final box = tester.getRect(find.byType(CiField));
    await tester.tapAt(Offset(box.left + 4, box.bottom - 4));
    await tester.pump();

    expect(ctrl.selection.isCollapsed, isTrue);
    expect(ctrl.selection.baseOffset, ctrl.text.length,
        reason: 'typing should continue from the end, not the start');
  });

  testWidgets('a tap on the text itself keeps native cursor placement',
      (tester) async {
    final ctrl = TextEditingController(text: 'alex@example');
    addTearDown(ctrl.dispose);
    await tester
        .pumpWidget(_host(CiField(label: 'Email address', controller: ctrl)));

    // Tapping the TextField directly must go to the field, not the wrapper -
    // the wrapper only claims taps the TextField does not.
    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(_textField(tester).focusNode!.hasFocus, isTrue);
  });

  testWidgets('a disabled field does not take focus from a box tap',
      (tester) async {
    await tester.pumpWidget(
        _host(const CiField(label: 'Email address', enabled: false)));

    final box = tester.getRect(find.byType(CiField));
    await tester.tapAt(Offset(box.left + 4, box.bottom - 4));
    await tester.pump();

    expect(_textField(tester).focusNode!.hasFocus, isFalse);
  });
}
