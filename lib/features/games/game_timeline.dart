// Game timeline — G1.13
//
// Measured from LANES · TYPICAL (986:247) on the Gate 1 page:
//
//   lane    74 tall, 24 side padding, 16 top/bottom, 1pt hairline between
//   label   82 wide column, name Medium 9 +7% tracked, value Light 21 with a
//           Medium 10 unit beside it
//   track   244 x 22, a dotted rule at gray300 1.8 with ROUND caps and a
//           [0.01, 3.6] dash, marks centred on it at y 11
//   mark    circle, filled = made / defensive / assist, hollow = the other
//   trip    free throws ENCLOSED by a white-filled capsule, one per trip to
//           the line, 3.5 padding, 1.4 stroke
//   ends    "Start" and "End", never play numbers
//   moment  2pt gray150 bar, 9 gap, Regular 12
//
// EVERY STAT SHARES ONE AXIS. That is the whole point of the direction and
// the reason it replaced the ribbon: three independent ribbons cannot show
// that a turnover landed just before a scoring run, and one shared sequence
// can. Position is ORDER, never time - there is no game clock.
//
// A LANE WITH NOTHING TO SHOW DOES NOT RENDER, and a game with no events
// drops the section entirely. Across 397 prod games only 36% carry all four
// lanes, so a two-lane game is the normal case rather than a degraded one.
//
// MARKS SCALE WITH THE PLAY COUNT. At 35 plays the spacing is under 7pt and a
// fixed 13pt mark would overlap its neighbour by half. The Figma frame is
// drawn at a fixed 13 because it shows 19 plays; this is the general rule.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/live_game.dart';
import '/courtside_iq/stat_event.dart';

/// One play on the timeline: where it sits, and whether it is the filled kind.
@immutable
class TimelinePlay {
  const TimelinePlay({
    required this.position,
    required this.filled,
    this.freeThrow = false,
  });

  /// 1-based index over CONFIRMED plays in the game. A display index, not
  /// `stat_events.sequence_no` - voided plays keep their sequence number and
  /// are not shown, so the two diverge the moment a parent corrects anything.
  final int position;

  /// Made shot, defensive rebound, assist, steal. The hollow alternative is
  /// missed, offensive, turnover.
  final bool filled;

  final bool freeThrow;
}

/// One row: a stat, its figure, and where its plays fell.
@immutable
class TimelineLane {
  const TimelineLane({
    required this.label,
    required this.value,
    required this.unit,
    required this.plays,
  });

  final String label;
  final String value;
  final String unit;
  final List<TimelinePlay> plays;

  bool get isEmpty => plays.isEmpty;
}

/// Builds the four lanes from a game's confirmed events.
///
/// Returns an empty list when there is nothing to show, which is the signal to
/// drop the whole section rather than render an empty state.
List<TimelineLane> buildTimelineLanes(List<StatEvent> events) {
  final confirmed = events.where((e) => e.isConfirmed).toList()
    ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  if (confirmed.isEmpty) return const [];

  // The display index: 1..n over confirmed plays, contiguous. Voided plays are
  // absent and leave no gap, because a parent is shown the corrected game.
  final position = <int, int>{};
  for (var i = 0; i < confirmed.length; i++) {
    position[confirmed[i].sequenceNo] = i + 1;
  }

  const shots = {
    LiveStat.twoMade, LiveStat.twoMissed,
    LiveStat.threeMade, LiveStat.threeMissed,
    LiveStat.ftMade, LiveStat.ftMissed,
  };
  const made = {LiveStat.twoMade, LiveStat.threeMade, LiveStat.ftMade};
  const freeThrows = {LiveStat.ftMade, LiveStat.ftMissed};

  List<TimelinePlay> pick(
    bool Function(LiveStat) belongs,
    bool Function(LiveStat) isFilled,
  ) =>
      [
        for (final e in confirmed)
          if (belongs(e.stat))
            TimelinePlay(
              position: position[e.sequenceNo]!,
              filled: isFilled(e.stat),
              freeThrow: freeThrows.contains(e.stat),
            ),
      ];

  int n(LiveStat s) => confirmed.where((e) => e.stat == s).length;

  final points = n(LiveStat.twoMade) * 2 + n(LiveStat.threeMade) * 3 + n(LiveStat.ftMade);
  final assists = n(LiveStat.assists);
  final turnovers = n(LiveStat.turnovers);
  final defence = n(LiveStat.steals) + n(LiveStat.blocks);

  final lanes = <TimelineLane>[
    TimelineLane(
      label: 'Points', value: '$points', unit: 'PTS',
      plays: pick(shots.contains, made.contains),
    ),
    TimelineLane(
      label: 'Rebounds', value: '${n(LiveStat.offReb) + n(LiveStat.defReb)}', unit: 'REB',
      plays: pick(
        (s) => s == LiveStat.offReb || s == LiveStat.defReb,
        (s) => s == LiveStat.defReb,
      ),
    ),
    // Assists and turnovers share a lane because AST/TOV is already one rated
    // metric - and because separately, a turnovers lane would be absent in 39%
    // of games against 17% for the pair.
    TimelineLane(
      label: 'Playmaking', value: '$assists·$turnovers', unit: 'AST·TO',
      plays: pick(
        (s) => s == LiveStat.assists || s == LiveStat.turnovers,
        (s) => s == LiveStat.assists,
      ),
    ),
    TimelineLane(
      label: 'Defense', value: '$defence', unit: 'STL',
      plays: pick(
        (s) => s == LiveStat.steals || s == LiveStat.blocks,
        (_) => true,
      ),
    ),
  ];

  return [for (final l in lanes) if (!l.isEmpty) l];
}

/// Mark diameter for a given play count.
///
/// At 35 plays the spacing across a 244pt track is under 7pt, so a fixed 13
/// would overlap. Clamped so a 3-play game does not balloon either.
double timelineMarkSize(int plays, {double trackWidth = _kTrack}) {
  if (plays <= 0) return _kMarkMax;
  final spacing = trackWidth / plays;
  return (spacing - 1).clamp(_kMarkMin, _kMarkMax);
}

const double _kTrack = 244;
const double _kLabelCol = 82;
const double _kTrackHeight = 22;
const double _kMarkMax = 13;
const double _kMarkMin = 7;

/// The whole section, header included. Renders nothing when there is no game
/// to show.
class GameTimeline extends StatelessWidget {
  const GameTimeline({super.key, required this.events, this.moment});

  final List<StatEvent> events;

  /// One plain sentence describing the shape of the game. Optional on purpose:
  /// a lane whose sample cannot support a pattern gets no moment, and a
  /// three-play game gets none at all. Describing is allowed; explaining is
  /// not - no confidence, rhythm, or momentum.
  final String? moment;

  @override
  Widget build(BuildContext context) {
    final lanes = buildTimelineLanes(events);
    if (lanes.isEmpty) return const SizedBox.shrink();

    final plays = events.where((e) => e.isConfirmed).length;
    final c = CiColors.of(context);
    final size = timelineMarkSize(plays);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CiSectionHeader(title: 'How the game went', trailing: '$plays plays'),
        for (var i = 0; i < lanes.length; i++)
          _Lane(lane: lanes[i], plays: plays, markSize: size, ruled: i > 0),
        Container(height: CiSpace.hairline, color: c.borderFaint),
        const _Ends(),
        if (moment != null) _Moment(text: moment!),
      ],
    );
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    required this.lane,
    required this.plays,
    required this.markSize,
    required this.ruled,
  });

  final TimelineLane lane;
  final int plays;
  final double markSize;
  final bool ruled;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      decoration: ruled
          ? BoxDecoration(
              border: Border(top: BorderSide(color: c.borderFaint, width: CiSpace.hairline)),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen, vertical: CiSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _kLabelCol,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 9 Medium at +7% tracking, measured from the frame. micro
                // is the nearest token (10 Medium); there is no 9pt eyebrow.
                Text(lane.label.toUpperCase(),
                    style: CiType.micro.copyWith(
                        color: c.textMuted, fontSize: 9, letterSpacing: 0.63)),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lane.value,
                        style: CiType.statSm
                            .copyWith(color: c.text, fontSize: 21, letterSpacing: 0)),
                    const SizedBox(width: 4),
                    Text(lane.unit,
                        style: CiType.micro.copyWith(
                            color: c.textMuted, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: CiSpace.s4),
          Expanded(
            child: _Track(plays: lane.plays, total: plays, markSize: markSize),
          ),
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.plays, required this.total, required this.markSize});

  final List<TimelinePlay> plays;
  final int total;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return SizedBox(
      height: _kTrackHeight,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          double centreOf(int position) => ((position - 0.5) / total) * w;

          // Consecutive free throws are one TRIP to the line, and a trip is
          // drawn as one enclosure rather than two marks. Grouping by adjacent
          // position is what makes a pair read as a pair.
          final trips = <List<TimelinePlay>>[];
          for (final p in plays.where((p) => p.freeThrow)) {
            if (trips.isNotEmpty && trips.last.last.position == p.position - 1) {
              trips.last.add(p);
            } else {
              trips.add([p]);
            }
          }

          const pad = 3.5;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0, right: 0, top: _kTrackHeight / 2 - 1,
                child: CustomPaint(
                  painter: _DottedRule(color: c.border),
                  size: Size(w, 2),
                ),
              ),
              // Enclosures first: white-filled, so they interrupt the dotted
              // rule rather than sitting on top of it. A trip reads as a
              // segment carved out of the timeline.
              for (final t in trips)
                Positioned(
                  left: centreOf(t.first.position) - markSize / 2 - pad,
                  top: _kTrackHeight / 2 - (markSize + pad * 2) / 2,
                  child: Container(
                    width: centreOf(t.last.position) - centreOf(t.first.position) + markSize + pad * 2,
                    height: markSize + pad * 2,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular((markSize + pad * 2) / 2),
                      border: Border.all(color: c.text, width: 1.4),
                    ),
                  ),
                ),
              for (final p in plays)
                Positioned(
                  left: centreOf(p.position) - markSize / 2,
                  top: _kTrackHeight / 2 - markSize / 2,
                  child: Container(
                    width: markSize,
                    height: markSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.filled ? c.text : c.surface,
                      border: p.filled ? null : Border.all(color: c.text, width: 1.4),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The dotted rule. A near-zero dash with a round cap is what draws a DOT; a
/// [1, 2] pattern closes most of its own gaps because the cap extends half the
/// stroke weight past each end.
class _DottedRule extends CustomPainter {
  const _DottedRule({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const period = 3.6;
    const radius = 0.9;
    final fill = Paint()..color = color;
    for (var x = radius; x <= size.width - radius; x += period) {
      canvas.drawCircle(Offset(x, size.height / 2), radius, fill);
    }
  }

  @override
  bool shouldRepaint(_DottedRule old) => old.color != color;
}

class _Ends extends StatelessWidget {
  const _Ends();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // Start and End, never play numbers. Position here means ORDER, and a
    // numbered axis invites reading a precision that does not exist.
    return Padding(
      padding: const EdgeInsets.fromLTRB(CiSpace.screen, 10, CiSpace.screen, 0),
      child: Row(
        children: [
          const SizedBox(width: _kLabelCol + CiSpace.s4),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start', style: CiType.caption.copyWith(color: c.textFaint)),
                Text('End', style: CiType.caption.copyWith(color: c.textFaint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Moment extends StatelessWidget {
  const _Moment({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(CiSpace.screen, 18, CiSpace.screen, 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 2, color: c.hairline),
            const SizedBox(width: 9),
            Expanded(
              child: Text(text,
                  style: CiType.body.copyWith(color: c.text, height: 1.45)),
            ),
          ],
        ),
      ),
    );
  }
}
