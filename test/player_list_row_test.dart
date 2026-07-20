import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_gauge.dart';
import 'package:courtside_i_q/courtside_iq/growth_iq.dart';
import 'package:courtside_i_q/courtside_iq/players_list_builder.dart';
import 'package:courtside_i_q/features/players/widgets/player_list_row.dart';

PlayerListEntry _entry({
  int? growthIq = 82,
  int? delta = 5,
  GrowthTrend? trend = GrowthTrend.rising,
  int games = 12,
  int points = 222,
}) =>
    PlayerListEntry(
      playerId: 'p1',
      firstName: 'Maya',
      lastName: 'Chen',
      position: 'Guard',
      ageBand: '11U-13U',
      totalGames: games,
      totalPoints: points,
      totalRebounds: 74,
      totalAssists: 49,
      growthIq: growthIq,
      growthIqDelta: delta,
      trend: trend,
    );

Future<void> _pump(WidgetTester tester, PlayerListEntry e) =>
    tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(body: PlayerListRow(entry: e)),
    ));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows name, subtitle and averages', (tester) async {
    await _pump(tester, _entry());
    expect(find.text('Maya Chen'), findsOneWidget);
    expect(find.text('Guard, 11U-13U · 12 games'), findsOneWidget);
    expect(find.text('18.5'), findsOneWidget);
    for (final l in ['PPG', 'RPG', 'APG']) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testWidgets('shows the gauge, score and trend chip when there is a Growth IQ',
      (tester) async {
    await _pump(tester, _entry(growthIq: 82, delta: 5, trend: GrowthTrend.rising));
    expect(find.byType(DotGauge), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    expect(find.text('Rising +5'), findsOneWidget);
  });

  testWidgets('hides the gauge entirely when there is no Growth IQ',
      (tester) async {
    // Too few games: identity and averages remain, but no gauge and no zero.
    await _pump(tester, _entry(growthIq: null, delta: null, trend: null));
    expect(find.byType(DotGauge), findsNothing);
    expect(find.text('Maya Chen'), findsOneWidget);
  });

  testWidgets('shows a dash for averages with no games', (tester) async {
    await _pump(tester,
        _entry(games: 0, points: 0, growthIq: null, delta: null, trend: null));
    // "0.0" would state a season that never happened.
    expect(find.text('—'), findsNWidgets(3));
    expect(find.textContaining('0.0'), findsNothing);
  });
}
