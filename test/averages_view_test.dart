import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_badge.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/player_averages.dart';
import 'package:courtside_i_q/features/players/widgets/averages_view.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

AveragesGameRow _g({int points = 0, int turnover = 0, int ftMade = 0, int ftAttempt = 0}) =>
    AveragesGameRow(
      points: points,
      turnover: turnover,
      ftMade: ftMade,
      ftAttempt: ftAttempt,
    );

void main() {
  testWidgets('no games shows the empty line, not a wall of zeros',
      (tester) async {
    await tester.pumpWidget(_host(AveragesView(
      averages: buildPlayerAverages(const []),
    )));

    expect(find.text('Averages appear once a game is logged.'), findsOneWidget);
    expect(find.text('Season Averages'), findsNothing);
  });

  testWidgets('renders the six season tiles', (tester) async {
    await tester.pumpWidget(_host(AveragesView(
      averages: buildPlayerAverages([_g(points: 12)]),
    )));

    for (final label in [
      'Points',
      'Rebounds',
      'Assists',
      'Steals',
      'Blocks',
      'Turnovers',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('12.0'), findsOneWidget);
  });

  testWidgets('a drop in turnovers reads as an improvement', (tester) async {
    // The trap: fewer turnovers is a NEGATIVE delta and a GOOD outcome. A
    // sign-driven chip would paint this orange and tell a parent their kid
    // got worse.
    await tester.pumpWidget(_host(AveragesView(
      averages: buildPlayerAverages([
        ...List.generate(5, (_) => _g(turnover: 1)),
        ...List.generate(5, (_) => _g(turnover: 3)),
      ]),
    )));

    final chip = tester.widget<CiBadge>(
      find.ancestor(of: find.text('-2.0'), matching: find.byType(CiBadge)),
    );
    expect(chip.tone, CiBadgeTone.good);
  });

  testWidgets('the Shooting section is absent when no shot was attempted',
      (tester) async {
    await tester.pumpWidget(_host(AveragesView(
      averages: buildPlayerAverages([_g(points: 2)]),
    )));

    expect(find.text('Shooting'), findsNothing);
    expect(find.text('Free Throw'), findsNothing);
  });

  testWidgets('shooting percentages are whole numbers', (tester) async {
    await tester.pumpWidget(_host(AveragesView(
      averages: buildPlayerAverages([_g(ftMade: 2, ftAttempt: 3)]),
    )));

    expect(find.text('Free Throw'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
  });

  testWidgets('the calibration note only claims a band the player has',
      (tester) async {
    final a = buildPlayerAverages([_g(points: 5)]);

    await tester.pumpWidget(_host(AveragesView(averages: a)));
    expect(find.textContaining('calibrated'), findsNothing);

    await tester.pumpWidget(_host(AveragesView(averages: a, ageBand: 'U14')));
    expect(find.text('Ratings calibrated for the U14 age band'), findsOneWidget);
  });

  testWidgets('action buttons appear only once they lead somewhere',
      (tester) async {
    final a = buildPlayerAverages([_g(points: 5)]);

    await tester.pumpWidget(_host(AveragesView(averages: a)));
    expect(find.text('Full Breakdown'), findsNothing);
    expect(find.text('View trends'), findsNothing);

    await tester.pumpWidget(_host(AveragesView(
      averages: a,
      onFullBreakdown: () {},
    )));
    expect(find.text('Full Breakdown'), findsOneWidget);
    // Still no destination for trends, so still no button.
    expect(find.text('View trends'), findsNothing);
  });

  testWidgets('grid seams use the hairline token', (tester) async {
    await tester.pumpWidget(_host(AveragesView(
      averages: buildPlayerAverages([_g(points: 5)]),
    )));

    // The seam is the grid container showing through 1px gaps. If this stops
    // being the hairline the whole grid reads as boxes rather than a table.
    final grid = tester.widgetList<Container>(find.byType(Container)).where(
        (c) => c.color == CiColors.onLight.hairline);
    expect(grid, isNotEmpty);
  });

  group('the premium lock (4.17)', () {
    // 663:2426. The averages themselves STAY - the frame leaves every number
    // on screen and locks only the way deeper, which is what the lapse strip
    // above already says: high-level stats only.
    final averages = buildPlayerAverages([_g(points: 20), _g(points: 14)]);

    testWidgets('a subscriber gets the real Breakdown button', (tester) async {
      var opened = false;
      await tester.pumpWidget(_host(AveragesView(
        averages: averages,
        onFullBreakdown: () => opened = true,
      )));

      expect(find.text('Full Breakdown'), findsOneWidget);
      expect(find.text('Breakdown · Locked'), findsNothing);

      await tester.tap(find.text('Full Breakdown'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
    });

    testWidgets('free or lapsed gets the locked chip instead', (tester) async {
      await tester.pumpWidget(_host(AveragesView(
        averages: averages,
        locked: true,
        onFullBreakdown: () {},
        onLockedTap: () {},
      )));

      expect(find.text('Breakdown · Locked'), findsOneWidget);
      expect(find.text('Full Breakdown'), findsNothing);
    });

    testWidgets('the locked chip opens plans, NOT the breakdown',
        (tester) async {
      var breakdown = false;
      var plans = false;
      await tester.pumpWidget(_host(AveragesView(
        averages: averages,
        locked: true,
        onFullBreakdown: () => breakdown = true,
        onLockedTap: () => plans = true,
      )));

      await tester.tap(find.text('Breakdown · Locked'));
      await tester.pumpAndSettle();

      expect(plans, isTrue);
      expect(breakdown, isFalse,
          reason: 'a locked control must not reach what it locks');
    });

    testWidgets('the averages stay visible while locked', (tester) async {
      await tester.pumpWidget(_host(AveragesView(
        averages: averages,
        locked: true,
        onFullBreakdown: () {},
        onLockedTap: () {},
      )));
      // 17.0 PPG across the two games above: the numbers are not the premium
      // part, the deeper arrangement of them is.
      expect(find.text('17.0'), findsOneWidget);
    });

    testWidgets('it is still a button for a screen reader', (tester) async {
      // A control that only LOOKS disabled must still announce what it does,
      // or a parent using VoiceOver just finds a dead chip.
      await tester.pumpWidget(_host(AveragesView(
        averages: averages,
        locked: true,
        onFullBreakdown: () {},
        onLockedTap: () {},
      )));
      expect(find.bySemanticsLabel('Breakdown, locked. Opens plans.'),
          findsOneWidget);
    });
  });
}
