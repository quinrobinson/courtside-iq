// CiOfflineBanner — Phase 4.18
//
// A pure renderer, so the test pins the two things that carry meaning: the
// message, and the orange status dot (the app's attention accent). The
// connectivity wiring that shows/hides it is device-verified, the same as the
// live tracker's offline indicator.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_offline_banner.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

void main() {
  testWidgets('renders the message with an orange status dot', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CiOfflineBanner(
            message: "You're offline. Reconnect to use Courtside IQ."),
      ),
    ));

    expect(find.text("You're offline. Reconnect to use Courtside IQ."),
        findsOneWidget);

    final dot = tester.widgetList<Container>(find.byType(Container)).firstWhere(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).shape == BoxShape.circle,
        );
    expect((dot.decoration as BoxDecoration).color, CiPalette.orange);
  });
}
