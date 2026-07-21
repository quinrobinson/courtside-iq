// DevelopmentView — Phase 4.11b
//
// This widget is testable at all because it takes an insight rather than
// fetching one. Keep it that way: the moment it owns a fetch, these tests
// start hitting Supabase and get deleted for being flaky.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/growth_iq.dart';
import 'package:courtside_i_q/features/player_insight/models/player_insight.dart';
import 'package:courtside_i_q/features/players/widgets/development_view.dart';

PlayerInsight _insight({
  String? whatsWorking = 'She is finishing at the rim.',
  String? needsDevelopment = 'Free throws are streaky.',
  String? growthEdge = 'Watch how she sets her feet.',
  String? text,
  bool belowThreshold = false,
}) =>
    PlayerInsight(
      headline: 'Maya is trending up',
      text: text,
      whatsWorking: whatsWorking,
      needsDevelopment: needsDevelopment,
      growthEdge: growthEdge,
      trendDirection: 'up',
      strengthFocus: '64% FT',
      belowThreshold: belowThreshold,
    );

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  testWidgets('renders the split narrative, not the legacy text field',
      (tester) async {
    await tester.pumpWidget(_host(DevelopmentView(
      firstName: 'Maya',
      insight: _insight(text: 'LEGACY COPY'),
      growthIq: 72,
      trend: GrowthTrend.rising,
      trendLabel: 'Rising +5',
    )));

    expect(find.text("What's Working"), findsOneWidget);
    expect(find.text('Room to Grow'), findsOneWidget);
    expect(find.text('LEGACY COPY'), findsNothing);
  });

  testWidgets('falls back to the legacy text when there is no split narrative',
      (tester) async {
    // A v2 cache row. Showing nothing here would blank the tab for an existing
    // user until the v3 insight regenerates.
    await tester.pumpWidget(_host(DevelopmentView(
      firstName: 'Maya',
      insight: _insight(
        whatsWorking: null,
        needsDevelopment: null,
        text: 'LEGACY COPY',
      ),
    )));

    expect(find.text('LEGACY COPY'), findsOneWidget);
  });

  testWidgets('below threshold shows the countdown, never a story',
      (tester) async {
    await tester.pumpWidget(_host(DevelopmentView(
      firstName: 'Maya',
      insight: _insight(belowThreshold: true),
      gamesLogged: 3,
      gamesUntilUnlock: 2,
    )));

    expect(find.text('3 of 5 games logged'), findsOneWidget);
    expect(find.text("Maya's development story unlocks in 2 games."),
        findsOneWidget);
    expect(find.text('Track a Game'), findsOneWidget);
    // The narrative must not leak through the lock.
    expect(find.text("What's Working"), findsNothing);
  });

  testWidgets('countdown singularises the last game', (tester) async {
    await tester.pumpWidget(_host(DevelopmentView(
      firstName: 'Maya',
      insight: _insight(belowThreshold: true),
      gamesLogged: 4,
      gamesUntilUnlock: 1,
    )));

    expect(find.text("Maya's development story unlocks in 1 game."),
        findsOneWidget);
  });

  testWidgets('trend chip is lime only for Rising', (tester) async {
    // Building covers flat AND declining movement. Painting it on the positive
    // accent would dress a decline as a win - the defect the Players list
    // review caught, and this view repeats the rule.
    for (final (trend, expectRising) in [
      (GrowthTrend.rising, true),
      (GrowthTrend.building, false),
      (GrowthTrend.steady, false),
    ]) {
      await tester.pumpWidget(_host(DevelopmentView(
        firstName: 'Maya',
        insight: _insight(),
        growthIq: 72,
        trend: trend,
        trendLabel: 'Label +2',
      )));
      await tester.pump();

      final chip = tester.widget<Container>(find
          .ancestor(
            of: find.text('Label +2'),
            matching: find.byType(Container),
          )
          .first);
      final decoration = chip.decoration as BoxDecoration;
      expect(decoration.color == CiColors.onLight.accentGood, expectRising,
          reason: '$trend');
    }
  });
}
