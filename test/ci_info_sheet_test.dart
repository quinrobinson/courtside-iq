import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_info_sheet.dart';
import 'package:courtside_i_q/features/players/info_copy.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  testWidgets('shows the title, the body, and a dismiss', (tester) async {
    await tester.pumpWidget(_host(const CiInfoSheet(
      title: 'About Growth IQ',
      body: 'A short explanation.',
    )));

    expect(find.text('About Growth IQ'), findsOneWidget);
    expect(find.text('A short explanation.'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('the CTA is lime, because it ends an explanation',
      (tester) async {
    await tester.pumpWidget(_host(const CiInfoSheet(
      title: 'T',
      body: 'B',
    )));

    final button = tester.widget<CiButton>(find.byType(CiButton));
    expect(button.style, CiButtonStyle.lime);
  });

  testWidgets('sizes to its content rather than pinning a height',
      (tester) async {
    // The two frames differ by 56pt and that difference is entirely the
    // paragraph. A fixed height would clip the longer one.
    Future<double> heightFor(String body) async {
      await tester.pumpWidget(_host(
          Align(alignment: Alignment.bottomCenter, child: CiInfoSheet(
        title: 'T',
        body: body,
      ))));
      return tester.getSize(find.byType(CiInfoSheet)).height;
    }

    final short = await heightFor('One line.');
    final long = await heightFor(InfoCopy.growthIqBody);
    expect(long, greaterThan(short));
  });

  group('copy', () {
    test('carries no em dashes', () {
      // House rule for every user-facing string.
      for (final s in [
        InfoCopy.developmentStoryTitle,
        InfoCopy.developmentStoryBody,
        InfoCopy.growthIqTitle,
        InfoCopy.growthIqBody,
      ]) {
        expect(s, isNot(contains('—')), reason: s);
      }
    });

    test('Growth IQ copy refuses the leaderboard reading', () {
      // Growth IQ is age-normalized, which makes it LOOK like a percentile.
      // The denial is the most important sentence in the sheet.
      expect(InfoCopy.growthIqBody, contains('never a ranking against other'));
    });
  });
}
