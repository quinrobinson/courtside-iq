// Game timeline — G1.13
//
// The rules under test are the ones a parent would notice if they broke: a
// corrected tap must not appear, an empty lane must not render, and the
// position a mark sits at must reflect the game as corrected rather than as
// originally tapped.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/courtside_iq/stat_event.dart';
import 'package:courtside_i_q/features/games/game_timeline.dart';

List<StatEvent> _events(List<(LiveStat, StatEventStatus)> spec) => [
      for (var i = 0; i < spec.length; i++)
        StatEvent(
          sequenceNo: i + 1,
          stat: spec[i].$1,
          recordedAt: DateTime.utc(2026, 9, 22, 19, i),
          status: spec[i].$2,
        ),
    ];

List<StatEvent> _confirmed(List<LiveStat> stats) =>
    _events([for (final s in stats) (s, StatEventStatus.confirmed)]);

TimelineLane _lane(List<TimelineLane> lanes, String label) =>
    lanes.firstWhere((l) => l.label == label);

void main() {
  group('lanes render only when they have something to show', () {
    test('a game with no events produces no lanes at all', () {
      expect(buildTimelineLanes(const []), isEmpty);
    });

    test('a game whose only events are voided produces no lanes', () {
      final lanes = buildTimelineLanes(_events([
        (LiveStat.twoMade, StatEventStatus.voided),
        (LiveStat.defReb, StatEventStatus.voided),
      ]));
      expect(lanes, isEmpty, reason: 'a fully corrected game shows nothing');
    });

    test('a lane with no plays is dropped, not rendered empty', () {
      // No assists, turnovers, steals or blocks. 64% of prod games drop at
      // least one lane, so this is the normal case rather than an edge.
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.twoMade, LiveStat.defReb, LiveStat.twoMissed]));
      expect(lanes.map((l) => l.label), ['PTS', 'REB']);
    });

    test('all four appear when all four have plays', () {
      final lanes = buildTimelineLanes(_confirmed([
        LiveStat.twoMade, LiveStat.defReb, LiveStat.assists, LiveStat.steals,
      ]));
      expect(lanes.map((l) => l.label), ['PTS', 'REB', 'AST·TO', 'STL·BLK']);
    });
  });

  group('corrections never reach the screen', () {
    test('a voided play is absent from its lane', () {
      final lanes = buildTimelineLanes(_events([
        (LiveStat.twoMade, StatEventStatus.confirmed),
        (LiveStat.twoMade, StatEventStatus.voided),
        (LiveStat.twoMade, StatEventStatus.confirmed),
      ]));
      expect(_lane(lanes, 'PTS').plays.length, 2);
      expect(_lane(lanes, 'PTS').value, '4', reason: 'two makes, not three');
    });

    test('positions renumber over confirmed plays, leaving no gap', () {
      // sequence_no keeps its gap in the database; the display index does not.
      // A parent is shown the corrected game.
      final lanes = buildTimelineLanes(_events([
        (LiveStat.twoMade, StatEventStatus.confirmed), // seq 1 -> pos 1
        (LiveStat.defReb, StatEventStatus.voided), // seq 2 -> absent
        (LiveStat.assists, StatEventStatus.confirmed), // seq 3 -> pos 2
      ]));
      expect(_lane(lanes, 'PTS').plays.single.position, 1);
      expect(_lane(lanes, 'AST·TO').plays.single.position, 2,
          reason: 'not 3 - the voided play left no slot behind');
    });

    test('events out of order are sorted before positions are assigned', () {
      final shuffled = [
        StatEvent(sequenceNo: 3, stat: LiveStat.steals, recordedAt: DateTime.utc(2026)),
        StatEvent(sequenceNo: 1, stat: LiveStat.twoMade, recordedAt: DateTime.utc(2026)),
        StatEvent(sequenceNo: 2, stat: LiveStat.defReb, recordedAt: DateTime.utc(2026)),
      ];
      final lanes = buildTimelineLanes(shuffled);
      expect(_lane(lanes, 'PTS').plays.single.position, 1);
      expect(_lane(lanes, 'REB').plays.single.position, 2);
      expect(_lane(lanes, 'STL·BLK').plays.single.position, 3);
    });
  });

  group('fill carries the meaning', () {
    test('made shots are filled, missed are hollow', () {
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.twoMade, LiveStat.threeMissed, LiveStat.ftMade]));
      expect(_lane(lanes, 'PTS').plays.map((p) => p.filled), [true, false, true]);
    });

    test('defensive rebounds are filled, offensive are hollow', () {
      final lanes = buildTimelineLanes(_confirmed([LiveStat.defReb, LiveStat.offReb]));
      expect(_lane(lanes, 'REB').plays.map((p) => p.filled), [true, false]);
    });

    test('assists are filled, turnovers are hollow', () {
      final lanes = buildTimelineLanes(_confirmed([LiveStat.assists, LiveStat.turnovers]));
      expect(_lane(lanes, 'AST·TO').plays.map((p) => p.filled), [true, false]);
      expect(_lane(lanes, 'AST·TO').value, '1·1');
    });

    test('only free throws are marked as such', () {
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.twoMade, LiveStat.ftMade, LiveStat.ftMissed]));
      expect(_lane(lanes, 'PTS').plays.map((p) => p.freeThrow),
          [false, true, true]);
    });
  });

  group('figures', () {
    test('points are derived from the shooting events', () {
      final lanes = buildTimelineLanes(_confirmed([
        LiveStat.twoMade, LiveStat.twoMade, LiveStat.threeMade, LiveStat.ftMade,
      ]));
      expect(_lane(lanes, 'PTS').value, '8');
    });

    test('defense combines steals and blocks', () {
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.steals, LiveStat.steals, LiveStat.blocks]));
      expect(_lane(lanes, 'STL·BLK').value, '3');
    });
  });

  group('fit or scroll', () {
    // The track at the 390pt design width: 390 - 74 - 74 - 2 x 8.
    const design = 226.0;

    test('22 plays fit the column and 23 scroll', () {
      expect(timelineScale(22, design).scrolls, isFalse);
      expect(timelineScale(23, design).scrolls, isTrue);
    });

    test('a fitted game never draws a mark below 9pt or above 13', () {
      // 6pt marks in the dense frame are what failed on review: hollow and
      // filled stop reading apart. Scrolling exists so this floor holds.
      for (var plays = 1; plays <= 22; plays++) {
        final s = timelineScale(plays, design);
        expect(s.markSize, inInclusiveRange(9, 13), reason: 'at $plays plays');
        expect(s.contentWidth, design);
      }
    });

    test('a scrolling game keeps the typical sizing and grows instead', () {
      final s = timelineScale(35, design);
      expect(s.spacing, 12);
      expect(s.markSize, 11);
      expect(s.contentWidth, 35 * 12);
    });

    test('a narrower phone scrolls sooner rather than shrinking', () {
      // 360pt wide: a 215pt track. 21 plays fit at 10.2 apart, 22 would not.
      expect(timelineScale(21, 215).scrolls, isFalse);
      expect(timelineScale(22, 215).scrolls, isTrue);
    });

    test('the side columns are equal', () {
      // Balanced 2026-09-23: a narrow stat column crowded "5·2" against the
      // timeline's edge while the labels had room to spare.
      expect(kTimelineStatCol, kTimelineLabelCol);
    });

    test('the record game scrolls at the same sizing as any other', () {
      final s = timelineScale(181, design);
      expect(s.scrolls, isTrue);
      expect(s.markSize, 11);
    });
  });

  group('the widget', () {
    // The 390pt design width, so the scroll threshold lands where it does on
    // the phone the frames were drawn for.
    Future<void> pump(WidgetTester tester, List<StatEvent> events, {String? moment}) {
      tester.view.physicalSize = const Size(1170, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      return tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: GameTimeline(events: events, moment: moment),
          ),
        ),
      ));
    }

    // The page itself scrolls vertically; only the timeline scrolls sideways.
    final sideways = find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal);

    List<LiveStat> mixed(int plays) => [
          for (var i = 0; i < plays; i++)
            [LiveStat.twoMade, LiveStat.defReb, LiveStat.assists, LiveStat.steals][i % 4],
        ];

    double fade(WidgetTester tester) => tester
        .widget<AnimatedOpacity>(find.byKey(const ValueKey('timeline-scroll-fade')))
        .opacity;

    testWidgets('renders nothing at all for a game with no events',
        (tester) async {
      await pump(tester, const []);
      expect(find.text('How the game went'), findsNothing);
      expect(find.text('Start'), findsNothing);
    });

    testWidgets('counts confirmed plays in the header, not voided ones',
        (tester) async {
      await pump(tester, _events([
        (LiveStat.twoMade, StatEventStatus.confirmed),
        (LiveStat.defReb, StatEventStatus.confirmed),
        (LiveStat.twoMade, StatEventStatus.voided),
      ]));
      expect(find.text('2 plays'), findsOneWidget);
      expect(find.text('3 plays'), findsNothing);
    });

    testWidgets('heads the timeline Tip-off to Final, with no footer', (tester) async {
      await pump(tester, _confirmed([LiveStat.twoMade, LiveStat.defReb]));
      expect(find.text('TIP-OFF'), findsOneWidget);
      expect(find.text('FINAL'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
      expect(find.text('End'), findsNothing);
    });

    testWidgets('each number is said once', (tester) async {
      // The lanes said POINTS above and PTS beside. Now the abbreviation
      // names the row and the figure sits alone on the right.
      await pump(tester, _confirmed([LiveStat.twoMade, LiveStat.twoMade]));
      expect(find.text('PTS'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('POINTS'), findsNothing);
    });

    testWidgets('22 plays fit the column: nothing scrolls sideways', (tester) async {
      await pump(tester, _confirmed(mixed(22)));
      expect(sideways, findsNothing);
    });

    testWidgets('23 plays scroll, and every lane scrolls as one', (tester) async {
      await pump(tester, _confirmed(mixed(23)));
      // ONE sideways scroll view for four lanes and the header. Separate
      // scrolls would let lanes drift apart and break the shared axis.
      expect(sideways, findsOneWidget);
      expect(find.descendant(of: sideways, matching: find.text('TIP-OFF')), findsOneWidget);
      expect(find.descendant(of: sideways, matching: find.text('FINAL')), findsOneWidget);
    });

    testWidgets('labels and totals stay pinned outside the scroll', (tester) async {
      await pump(tester, _confirmed(mixed(30)));
      for (final label in ['PTS', 'REB', 'AST·TO', 'STL·BLK']) {
        expect(find.text(label), findsOneWidget);
        expect(find.descendant(of: sideways, matching: find.text(label)), findsNothing);
      }
    });

    testWidgets('the fade shows until the final play, then goes', (tester) async {
      await pump(tester, _confirmed(mixed(35)));
      expect(fade(tester), 1, reason: 'opens at tip-off with more to the right');

      await tester.drag(sideways, const Offset(-2000, 0));
      await tester.pumpAndSettle();
      expect(fade(tester), 0, reason: 'nothing left to scroll to');

      await tester.drag(sideways, const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(fade(tester), 1, reason: 'back from the end, more again');
    });

    testWidgets('the record 181-play game renders without overflowing', (tester) async {
      await pump(tester, _confirmed(mixed(181)));
      expect(tester.takeException(), isNull);
      expect(sideways, findsOneWidget);
    });

    testWidgets('marks carry no numbers', (tester) async {
      // The ribbon numbered every mark; lanes deliberately do not. A play
      // index is meaningless to a parent and does not fit at 13pt or below.
      //
      // Asserted by holding the LANES constant and varying only the PLAY
      // COUNT: if marks rendered labels, the text count would grow with the
      // plays. Searching for a digit would not work, because the lane values
      // are numbers too, and an exact count would break every time the header
      // or a label changed.
      await pump(tester, _confirmed([LiveStat.twoMade, LiveStat.twoMissed]));
      final fewPlays = find.byType(Text).evaluate().length;

      await pump(tester, _confirmed([
        LiveStat.twoMade, LiveStat.twoMissed, LiveStat.threeMade,
        LiveStat.threeMissed, LiveStat.ftMade, LiveStat.ftMissed,
      ]));
      final manyPlays = find.byType(Text).evaluate().length;

      expect(manyPlays, fewPlays,
          reason: 'three times the plays, same text count: marks are unlabelled');
    });

    testWidgets('shows a moment when given one, and nothing when not',
        (tester) async {
      await pump(tester, _confirmed([LiveStat.twoMade]),
          moment: 'Both turnovers came early.');
      expect(find.text('Both turnovers came early.'), findsOneWidget);

      await pump(tester, _confirmed([LiveStat.twoMade]));
      expect(find.text('Both turnovers came early.'), findsNothing);
    });

    testWidgets('the widest lane fits its fixed label column', (tester) async {
      // AST·TO carries the widest label and value of the four against fixed
      // columns. An earlier build overflowed here by 48pt; an overflow is a
      // caught exception in a test rather than a stripe.
      await pump(tester, _confirmed([
        ...List.filled(12, LiveStat.assists),
        ...List.filled(4, LiveStat.turnovers),
      ]));
      expect(tester.takeException(), isNull);
      expect(find.text('12·4'), findsOneWidget);
    });

    testWidgets('renders only the lanes that have plays', (tester) async {
      await pump(tester, _confirmed([LiveStat.twoMade, LiveStat.defReb]));
      expect(find.text('PTS'), findsOneWidget);
      expect(find.text('REB'), findsOneWidget);
      expect(find.text('AST·TO'), findsNothing);
      expect(find.text('STL·BLK'), findsNothing);
    });
  });
}
