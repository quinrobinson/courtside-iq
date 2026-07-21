import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_gauge.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_badge.dart';
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

  testWidgets('a decline is NOT dressed in the positive accent',
      (tester) async {
    // "Building -13" on a lime chip read as a contradiction: the gentle word
    // dressed as a win. Lime is reserved for Rising.
    await _pump(tester,
        _entry(growthIq: 61, delta: -13, trend: GrowthTrend.building));
    expect(find.text('Building -13'), findsOneWidget);

    final badge = tester.widget<CiBadge>(find.byType(CiBadge));
    expect(badge.tone, isNot(CiBadgeTone.good),
        reason: 'a drop must not use the positive accent');
    // And NOT an alarm tone either: this is a child's development shown to
    // their parent, so "not climbing" must not read as "something is wrong".
    expect(badge.tone, isNot(CiBadgeTone.energy));
  });

  testWidgets('a rise keeps the lime chip', (tester) async {
    await _pump(tester,
        _entry(growthIq: 82, delta: 5, trend: GrowthTrend.rising));
    expect(tester.widget<CiBadge>(find.byType(CiBadge)).tone,
        CiBadgeTone.good);
  });

  testWidgets('a row with a chip is the SAME height as one without',
      (tester) async {
    // Jada carried a "Building -13" chip and Jordan did not, so her row sat
    // ~28pt taller and the list rhythm looked broken. The chip slot is
    // reserved whether or not it is filled.
    await _pump(tester,
        _entry(growthIq: 70, delta: -13, trend: GrowthTrend.building));
    final withChip = tester.getSize(find.byType(PlayerListRow)).height;

    await _pump(tester, _entry(growthIq: 87, delta: null, trend: null));
    final withoutChip = tester.getSize(find.byType(PlayerListRow)).height;

    expect(withChip, withoutChip,
        reason: 'rows must not change height with the chip');
  });

  testWidgets('the gauge still reserves its slot with no trend to show',
      (tester) async {
    await _pump(tester, _entry(growthIq: 87, delta: null, trend: null));
    expect(find.byType(DotGauge), findsOneWidget);
    expect(find.textContaining('Rising'), findsNothing);
    expect(find.textContaining('Building'), findsNothing);
  });

  testWidgets('the trend chip is the same height as Today\'s Growth IQ chips',
      (tester) async {
    // Both screens show the same kind of chip. Using CiBadge rather than a
    // bespoke container is what guarantees they cannot drift apart.
    await _pump(tester,
        _entry(growthIq: 82, delta: 5, trend: GrowthTrend.rising));
    expect(tester.getSize(find.byType(CiBadge)).height, 24);
  });
}
