// The nav icons are Figma SVG exports (4.19b). A missing or unregistered
// asset is a blank tap target, so this checks the four files line up with
// their pubspec entry and decode.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_nav_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  testWidgets('honours its size under TIGHT parent constraints',
      (tester) async {
    // The bug: a fixed-size Container with no alignment hands its child tight
    // constraints, and a bare SvgPicture fills them - so size:22 rendered at
    // the container's size and the icon overflowed the nav tab and the empty
    // circle. Center + SizedBox inside the glyph is what holds the size.
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: Container(
          // No alignment: this is what makes the constraints tight, the same
          // as the nav tab and the empty-state circle.
          width: 80,
          height: 80,
          color: const Color(0xFFEEEEEE),
          child: const CiNavIconGlyph(
              icon: CiNavIcon.players, color: Color(0xFF0F0F0F), size: 22),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final box = tester.getSize(find.byType(SvgPicture));
    expect(box.width, 22, reason: 'the icon must stay 22, not fill the 80 box');
    expect(box.height, 22);
  });
}
