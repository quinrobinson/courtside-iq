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
      expect(lanes.map((l) => l.label), ['Points', 'Rebounds']);
    });

    test('all four appear when all four have plays', () {
      final lanes = buildTimelineLanes(_confirmed([
        LiveStat.twoMade, LiveStat.defReb, LiveStat.assists, LiveStat.steals,
      ]));
      expect(lanes.map((l) => l.label),
          ['Points', 'Rebounds', 'Playmaking', 'Defense']);
    });
  });

  group('corrections never reach the screen', () {
    test('a voided play is absent from its lane', () {
      final lanes = buildTimelineLanes(_events([
        (LiveStat.twoMade, StatEventStatus.confirmed),
        (LiveStat.twoMade, StatEventStatus.voided),
        (LiveStat.twoMade, StatEventStatus.confirmed),
      ]));
      expect(_lane(lanes, 'Points').plays.length, 2);
      expect(_lane(lanes, 'Points').value, '4', reason: 'two makes, not three');
    });

    test('positions renumber over confirmed plays, leaving no gap', () {
      // sequence_no keeps its gap in the database; the display index does not.
      // A parent is shown the corrected game.
      final lanes = buildTimelineLanes(_events([
        (LiveStat.twoMade, StatEventStatus.confirmed), // seq 1 -> pos 1
        (LiveStat.defReb, StatEventStatus.voided), // seq 2 -> absent
        (LiveStat.assists, StatEventStatus.confirmed), // seq 3 -> pos 2
      ]));
      expect(_lane(lanes, 'Points').plays.single.position, 1);
      expect(_lane(lanes, 'Playmaking').plays.single.position, 2,
          reason: 'not 3 - the voided play left no slot behind');
    });

    test('events out of order are sorted before positions are assigned', () {
      final shuffled = [
        StatEvent(sequenceNo: 3, stat: LiveStat.steals, recordedAt: DateTime.utc(2026)),
        StatEvent(sequenceNo: 1, stat: LiveStat.twoMade, recordedAt: DateTime.utc(2026)),
        StatEvent(sequenceNo: 2, stat: LiveStat.defReb, recordedAt: DateTime.utc(2026)),
      ];
      final lanes = buildTimelineLanes(shuffled);
      expect(_lane(lanes, 'Points').plays.single.position, 1);
      expect(_lane(lanes, 'Rebounds').plays.single.position, 2);
      expect(_lane(lanes, 'Defense').plays.single.position, 3);
    });
  });

  group('fill carries the meaning', () {
    test('made shots are filled, missed are hollow', () {
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.twoMade, LiveStat.threeMissed, LiveStat.ftMade]));
      expect(_lane(lanes, 'Points').plays.map((p) => p.filled), [true, false, true]);
    });

    test('defensive rebounds are filled, offensive are hollow', () {
      final lanes = buildTimelineLanes(_confirmed([LiveStat.defReb, LiveStat.offReb]));
      expect(_lane(lanes, 'Rebounds').plays.map((p) => p.filled), [true, false]);
    });

    test('assists are filled, turnovers are hollow', () {
      final lanes = buildTimelineLanes(_confirmed([LiveStat.assists, LiveStat.turnovers]));
      expect(_lane(lanes, 'Playmaking').plays.map((p) => p.filled), [true, false]);
      expect(_lane(lanes, 'Playmaking').value, '1·1');
    });

    test('only free throws are marked as such', () {
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.twoMade, LiveStat.ftMade, LiveStat.ftMissed]));
      expect(_lane(lanes, 'Points').plays.map((p) => p.freeThrow),
          [false, true, true]);
    });
  });

  group('figures', () {
    test('points are derived from the shooting events', () {
      final lanes = buildTimelineLanes(_confirmed([
        LiveStat.twoMade, LiveStat.twoMade, LiveStat.threeMade, LiveStat.ftMade,
      ]));
      expect(_lane(lanes, 'Points').value, '8');
    });

    test('defense combines steals and blocks', () {
      final lanes = buildTimelineLanes(
          _confirmed([LiveStat.steals, LiveStat.steals, LiveStat.blocks]));
      expect(_lane(lanes, 'Defense').value, '3');
    });
  });

  group('marks scale with the play count', () {
    test('a dense game shrinks its marks rather than overlapping them', () {
      // 244 / 35 is 6.97, so a fixed 13 would overlap its neighbour by half.
      final size = timelineMarkSize(35);
      expect(size, lessThan(13));
      expect(size, greaterThanOrEqualTo(7));
    });

    test('a sparse game does not balloon', () {
      expect(timelineMarkSize(3), 13);
      expect(timelineMarkSize(1), 13);
    });

    test('a typical game lands between the bounds', () {
      final size = timelineMarkSize(19);
      expect(size, closeTo(11.84, 0.01));
    });

    test('never returns a size that would collapse or overflow', () {
      for (var plays = 1; plays <= 200; plays++) {
        final s = timelineMarkSize(plays);
        expect(s, inInclusiveRange(7, 13), reason: 'at $plays plays');
      }
    });
  });

  group('the widget', () {
    Future<void> pump(WidgetTester tester, List<StatEvent> events, {String? moment}) =>
        tester.pumpWidget(MaterialApp(
          theme: CiTheme.base(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: GameTimeline(events: events, moment: moment),
            ),
          ),
        ));

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

    testWidgets('labels the axis Start and End', (tester) async {
      await pump(tester, _confirmed([LiveStat.twoMade, LiveStat.defReb]));
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('End'), findsOneWidget);
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

    testWidgets('renders only the lanes that have plays', (tester) async {
      await pump(tester, _confirmed([LiveStat.twoMade, LiveStat.defReb]));
      expect(find.text('POINTS'), findsOneWidget);
      expect(find.text('REBOUNDS'), findsOneWidget);
      expect(find.text('PLAYMAKING'), findsNothing);
      expect(find.text('DEFENSE'), findsNothing);
    });
  });
}
