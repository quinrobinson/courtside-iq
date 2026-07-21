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

  testWidgets('a decline is neither the positive accent nor an alarm',
      (tester) async {
    // Lime is reserved for Rising. The word was "Building" until 2026-07-21,
    // when "Building -13" was read on device as saying the opposite of the
    // number beside it.
    await _pump(tester,
        _entry(growthIq: 61, delta: -13, trend: GrowthTrend.dipping));
    expect(find.text('Dipping -13'), findsOneWidget);

    final badge = tester.widget<CiBadge>(find.byType(CiBadge));
    expect(badge.tone, isNot(CiBadgeTone.good),
        reason: 'a drop must not use the positive accent');
    // And NOT an alarm tone either. Orange was tried on 2026-07-21 and
    // reverted: this is a child's development shown to their parent, so "not
    // climbing" must not read as "something is wrong". The word does the work.
    expect(badge.tone, isNot(CiBadgeTone.energy));
  });

  testWidgets('a rise keeps the lime chip', (tester) async {
    await _pump(tester,
        _entry(growthIq: 82, delta: 5, trend: GrowthTrend.rising));
    expect(tester.widget<CiBadge>(find.byType(CiBadge)).tone,
        CiBadgeTone.good);
  });

  testWidgets('EVERY row is the same height, whatever the player has',
      (tester) async {
    // Three configurations that all appeared on device at different heights:
    // a full row with a chip, a scored row without one, and a brand-new
    // player with no Growth IQ at all. A player joins the list with no data,
    // so the rhythm cannot depend on how much they have.
    await _pump(tester,
        _entry(growthIq: 70, delta: -13, trend: GrowthTrend.dipping));
    final withChip = tester.getSize(find.byType(PlayerListRow)).height;

    await _pump(tester, _entry(growthIq: 87, delta: null, trend: null));
    final scoredNoChip = tester.getSize(find.byType(PlayerListRow)).height;

    await _pump(tester,
        _entry(growthIq: null, delta: null, trend: null, games: 0, points: 0));
    final brandNew = tester.getSize(find.byType(PlayerListRow)).height;

    expect(scoredNoChip, withChip, reason: 'chip must not change height');
    expect(brandNew, withChip, reason: 'a gaugeless row must not collapse');
  });

  testWidgets('the gauge still reserves its slot with no trend to show',
      (tester) async {
    await _pump(tester, _entry(growthIq: 87, delta: null, trend: null));
    expect(find.byType(DotGauge), findsOneWidget);
    expect(find.textContaining('Rising'), findsNothing);
    expect(find.textContaining('Dipping'), findsNothing);
  });

  testWidgets('the trend chip is the same height as Today\'s Growth IQ chips',
      (tester) async {
    // Both screens show the same kind of chip. Using CiBadge rather than a
    // bespoke container is what guarantees they cannot drift apart.
    await _pump(tester,
        _entry(growthIq: 82, delta: 5, trend: GrowthTrend.rising));
    expect(tester.getSize(find.byType(CiBadge)).height, 24);
  });

  testWidgets('space above the name equals space below the chip',
      (tester) async {
    // The two the device review asked to match. Centring made them differ,
    // because the gauge column is taller than the identity column and centring
    // pushed the name down by half that difference.
    await _pump(tester,
        _entry(growthIq: 70, delta: -13, trend: GrowthTrend.dipping));

    final row = tester.getRect(find.byType(PlayerListRow));
    final name = tester.getRect(find.text('Maya Chen'));
    final chip = tester.getRect(find.byType(CiBadge));

    final above = name.top - row.top;
    final below = row.bottom - chip.bottom;

    expect(below, closeTo(above, 1.0),
        reason: 'above name $above, below chip $below');
  });
}
