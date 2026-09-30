import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_logo_mark.dart';
import 'package:courtside_i_q/features/home/widgets/today_promo_banner.dart';

Widget _host(Widget child) =>
    MaterialApp(theme: CiTheme.base(), home: Scaffold(body: child));

void main() {
  testWidgets('the compact strip drops the mark and names what is still visible',
      (tester) async {
    await tester.pumpWidget(_host(const TodayPromoBanner(
      purpose: TodayPromoPurpose.lapse,
      compact: true,
    )));

    expect(find.text('Your Premium has ended'), findsOneWidget);
    expect(find.text('High-level stats only. Renew to unlock the rest.'),
        findsOneWidget);
    // The profile hero is already 258 tall. The mark is what the strip gives
    // up to fit underneath it.
    expect(find.byType(CiLogoMark), findsNothing);
  });

  testWidgets('the full card leads with a premium mark, not the brand logo',
      (tester) async {
    await tester.pumpWidget(_host(const TodayPromoBanner(
      purpose: TodayPromoPurpose.lapse,
    )));

    // A premium glyph (diamond), not the Courtside IQ logo: the banner is
    // about the subscription. See today_promo_banner.
    expect(find.byIcon(Icons.diamond_outlined), findsOneWidget);
    expect(find.byType(CiLogoMark), findsNothing);
    expect(find.text('Renew to keep trends, insights, and the full story.'),
        findsOneWidget);
  });

  testWidgets('upgrade and lapse never share a headline', (tester) async {
    await tester.pumpWidget(_host(const TodayPromoBanner(
      purpose: TodayPromoPurpose.upgrade,
      compact: true,
    )));

    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('High-level stats only. Upgrade to unlock the rest.'),
        findsOneWidget);
  });
}
