// The nav icons are Figma SVG exports (4.19b). A missing or unregistered
// asset is a blank tap target, so this checks the four files line up with
// their pubspec entry and decode.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_nav_icon.dart';

void main() {
  testWidgets('every nav icon asset loads', (tester) async {
    for (final icon in CiNavIcon.values) {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: CiNavIconGlyph(icon: icon, color: const Color(0xFF0F0F0F)),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$icon failed to load');
    }
  });
}
