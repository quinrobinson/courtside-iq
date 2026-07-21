import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_badge.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_page_dots.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_gauge.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/growth_iq.dart';
import 'package:courtside_i_q/courtside_iq/today_snapshot.dart';
import 'package:courtside_i_q/features/home/widgets/today_hero.dart';

TodaySnapshot _snap({
  String first = 'Maya',
  int? growthIq = 82,
  int? delta = 4,
  GrowthTrend? trend = GrowthTrend.rising,
  int games = 10,
  int points = 185,
  String? headline,
}) =>
    TodaySnapshot(
      playerId: first,
      firstName: first,
      lastName: 'Chen',
      totalGames: games,
      totalPoints: points,
      growthIq: growthIq,
      growthIqDelta: delta,
      trend: trend,
      headline: headline,
    );

Future<void> _pump(WidgetTester tester, List<TodaySnapshot> snaps) =>
    tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(body: TodayHero(snapshots: snaps, userName: 'Quin R')),
    ));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reduced form', () {
    testWidgets('no qualifying players shows the brand bar and nothing else',
        (tester) async {
      // Matches Today - Empty (No Players): the hero without the Growth IQ
      // block. Every user spends their first days here, before enough games
      // exist to compute a score, so it is not an edge case.
      await _pump(tester, const []);
      expect(find.text('Courtside IQ'), findsOneWidget);
      expect(find.byType(DotGauge), findsNothing);
      expect(find.byType(CiPageDots), findsNothing);
    });

    testWidgets('is shorter than the full hero', (tester) async {
      await _pump(tester, const []);
      final reduced = tester.getSize(find.byType(TodayHero)).height;

      await _pump(tester, [_snap()]);
      final full = tester.getSize(find.byType(TodayHero)).height;

      expect(reduced, lessThan(full));
    });
  });

  group('full form', () {
    testWidgets('names the player on every page of the carousel',
        (tester) async {
      // With two players, "Growth IQ" alone leaves the second unattributed.
      // The headline usually mentions a name but is AI-written, so it cannot
      // be relied on to.
      await _pump(tester, [
        _snap(first: 'Maya', growthIq: 82),
        _snap(first: 'Jordan', growthIq: 71),
      ]);
      expect(find.text("Maya's Growth IQ"), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text("Jordan's Growth IQ"), findsOneWidget);
    });

    testWidgets('the PPG tag is ghost, not a filled chip', (tester) async {
      // A filled grey pill beside the score competes with it.
      await _pump(tester, [_snap(games: 10, points: 185)]);
      // Two badges now: the PPG tag and the delta chip.
      final ppgTag = tester
          .widgetList<CiBadge>(find.byType(CiBadge))
          .firstWhere((b) => b.label.contains('PPG'));
      expect(ppgTag.tone, CiBadgeTone.ghost);
    });

    testWidgets('components inside the hero resolve INK, not the page ground',
        (tester) async {
      // The hero paints ink but sits inside a light page. Painting a colour
      // is not the same as declaring a ground: without CiSurface.ink, every
      // component that resolves its own palette from context - CiBadge,
      // CiAvatar, CiIconButton - reads LIGHT and renders ink-on-ink. That is
      // what put black text inside the ghost tag on a dark hero.
      await _pump(tester, [_snap(games: 10, points: 185)]);

      final ctx = tester.element(find.byType(CiBadge).first);
      expect(CiColors.of(ctx).text, CiColors.onInk.text);
      expect(CiColors.of(ctx).text, isNot(CiColors.onLight.text));
    });

    testWidgets('the delta is a chip, coloured by classification',
        (tester) async {
      // Chosen over the frame's plain lime text, for consistency with every
      // other delta in the app.
      await _pump(tester, [_snap(delta: 4, trend: GrowthTrend.rising)]);
      final badges = tester.widgetList<CiBadge>(find.byType(CiBadge)).toList();
      final delta = badges.firstWhere((b) => b.label.contains('4'));
      expect(delta.tone, CiBadgeTone.good);
      expect(delta.label, '+4');
    });

    testWidgets('a drop is neutral here, exactly as on the Players list',
        (tester) async {
      // This chip used CiBadge.delta and came out ORANGE, while the Players
      // list painted the same player's same drop neutral. One rule now, in
      // CiBadge.growthTrend.
      await _pump(tester, [_snap(delta: -3, trend: GrowthTrend.dipping)]);
      final badges = tester.widgetList<CiBadge>(find.byType(CiBadge)).toList();
      final delta = badges.firstWhere((b) => b.label.contains('3'));
      expect(delta.tone, CiBadgeTone.neutral);
    });

    testWidgets('the chip does not repeat the word inside the gauge',
        (tester) async {
      await _pump(tester, [_snap(delta: -3, trend: GrowthTrend.dipping)]);
      // "Dipping" appears once - in the gauge, not also in the chip.
      expect(find.text('Dipping'), findsOneWidget);
    });

    testWidgets('shows the gauge, score and trend word', (tester) async {
      await _pump(tester, [_snap(growthIq: 82, delta: 4)]);
      expect(find.byType(DotGauge), findsOneWidget);
      expect(find.text('82'), findsOneWidget);
      expect(find.text('Rising'), findsOneWidget);
    });

    testWidgets('falls back to the name when there is no headline',
        (tester) async {
      // The AI headline can be absent, but the block still has to say who it
      // is about rather than leaving a gap.
      await _pump(tester, [_snap(headline: null)]);
      expect(find.text('Maya Chen'), findsOneWidget);
    });

    testWidgets('prefers the headline when there is one', (tester) async {
      await _pump(tester, [_snap(headline: 'Maya is on a 3-game upswing')]);
      expect(find.text('Maya is on a 3-game upswing'), findsOneWidget);
      expect(find.text('Maya Chen'), findsNothing);
    });

    testWidgets('shows the points average as a chip', (tester) async {
      await _pump(tester, [_snap(games: 10, points: 185)]);
      expect(find.text('18.5 PPG'), findsOneWidget);
    });

    testWidgets('omits the average when no games have been played',
        (tester) async {
      // "0.0 PPG" would state a performance that never happened.
      await _pump(tester, [_snap(games: 0, points: 0)]);
      expect(find.textContaining('PPG'), findsNothing);
    });
  });

  group('paging', () {
    testWidgets('one player shows no dots', (tester) async {
      await _pump(tester, [_snap()]);
      expect(find.byType(CiPageDots), findsOneWidget);
      // The component renders nothing below two pages.
      expect(tester.getSize(find.byType(CiPageDots)).height, 0);
    });

    testWidgets('two players page, and the dots track', (tester) async {
      await _pump(tester, [
        _snap(first: 'Maya', growthIq: 82),
        _snap(first: 'Jordan', growthIq: 71),
      ]);
      expect(find.text('82'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('71'), findsOneWidget);
      expect(find.bySemanticsLabel('Page 2 of 2'), findsOneWidget);
    });
  });

  group('gauge range', () {
    testWidgets('a low but real score does not read as an empty ring',
        (tester) async {
      // Growth IQ runs 40..99, never 0..100. Feeding the raw score to a 0..1
      // gauge would draw a nearly empty ring for 45, which is a real result.
      await _pump(tester, [_snap(growthIq: 45)]);
      final gauge = tester.widget<DotGauge>(find.byType(DotGauge));
      expect(gauge.value, greaterThan(0.0));

      await _pump(tester, [_snap(growthIq: 99)]);
      final top = tester.widget<DotGauge>(find.byType(DotGauge));
      expect(top.value, 1.0);
    });

    testWidgets('stays within bounds for an out-of-range score',
        (tester) async {
      await _pump(tester, [_snap(growthIq: 120)]);
      expect(tester.widget<DotGauge>(find.byType(DotGauge)).value, 1.0);
      await _pump(tester, [_snap(growthIq: 10)]);
      expect(tester.widget<DotGauge>(find.byType(DotGauge)).value, 0.0);
    });
  });
}
