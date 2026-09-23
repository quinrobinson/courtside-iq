// Game timeline — G1.13
//
// Built from the TABLE frames on the Gate 1 page, approved 2026-09-23:
// TYPICAL (1013:567), DENSE at tip-off (1018:569), DENSE scrolled to final
// (1018:5523). The first build (the lanes, 986:247) went onto a phone and
// showed two problems: every lane said its stat twice (POINTS above, PTS
// beside), and Start/End sat under the tracks where nobody read them.
//
//   table   three edge-to-edge columns: label | timeline | stat. Every row
//           closes on the Development rows' hairline; the timeline column is
//           surface-sunk with the same hairline on its left and right edges
//   label   the hero's abbreviations in the hero's caps style (micro, muted):
//           PTS, REB, AST·TO, STL·BLK. Each number is said once, on the right
//   stat    Light 16, one step below the hero's secondary stats
//   header  one row above the lanes, in the timeline column only: TIP-OFF,
//           an arrow, FINAL
//   track   a dotted rule, marks centred on it. Filled = made / defensive /
//           assist; hollow = the other. Free throws ENCLOSED, one capsule per
//           trip to the line. Hollow marks and capsules take the column's own
//           fill, so they read as hollow rather than as white pills
//   moment  the insight wash (lime-wash + the insight sparkle), because on
//           this screen that already means "Courtside IQ noticed this"
//
// EVERY STAT SHARES ONE AXIS. That is the whole point of the direction: three
// independent ribbons cannot show that a turnover landed just before a scoring
// run, and one shared sequence can. Position is ORDER, never time - there is
// no game clock.
//
// PAST 22 PLAYS THE TIMELINE SCROLLS rather than shrinking its marks. Fitting
// a 35-play game into the column took the marks to 6pt, and at 6pt hollow and
// filled stop reading apart. The rule is a minimum spacing, not a play count:
// at the 390pt design width it lands on 22, and on a narrower phone it
// switches to scrolling a little sooner instead of shrinking below legible.
// (It was 24 until the side columns were balanced at 74pt each; the rule held
// and the count moved.)
// Labels and totals stay pinned; the header and all four lanes scroll as one.
//
// A LANE WITH NOTHING TO SHOW DOES NOT RENDER, and a game with no events
// drops the section entirely. Across 397 prod games only 36% carry all four
// lanes, so a two-lane game is the normal case rather than a degraded one.

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
    required this.plays,
  });

  /// The hero's abbreviation for the stat. It names the row AND serves as the
  /// unit for [value], which is why there is no separate unit any more.
  final String label;
  final String value;
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
      label: 'PTS', value: '$points',
      plays: pick(shots.contains, made.contains),
    ),
    TimelineLane(
      label: 'REB', value: '${n(LiveStat.offReb) + n(LiveStat.defReb)}',
      plays: pick(
        (s) => s == LiveStat.offReb || s == LiveStat.defReb,
        (s) => s == LiveStat.defReb,
      ),
    ),
    // Assists and turnovers share a lane because AST/TOV is already one rated
    // metric - and because separately, a turnovers lane would be absent in 39%
    // of games against 17% for the pair.
    TimelineLane(
      label: 'AST·TO', value: '$assists·$turnovers',
      plays: pick(
        (s) => s == LiveStat.assists || s == LiveStat.turnovers,
        (s) => s == LiveStat.assists,
      ),
    ),
    TimelineLane(
      // STL·BLK, not STL: this lane has always counted blocks too, and the
      // old unit said otherwise.
      label: 'STL·BLK', value: '$defence',
      plays: pick(
        (s) => s == LiveStat.steals || s == LiveStat.blocks,
        (_) => true,
      ),
    ),
  ];

  return [for (final l in lanes) if (!l.isEmpty) l];
}

/// Every free-throw trip in the game, as (first, last) display positions.
///
/// Consecutive free throws are one TRIP to the line, drawn as one enclosure.
/// Only the points lane holds free throws, but the result is used for the
/// WHOLE axis: see [TimelineScale.centreOf].
List<(int, int)> timelineTrips(List<TimelineLane> lanes) {
  final positions = [
    for (final l in lanes)
      for (final p in l.plays)
        if (p.freeThrow) p.position,
  ]..sort();
  final trips = <(int, int)>[];
  for (final pos in positions) {
    if (trips.isNotEmpty && trips.last.$2 == pos - 1) {
      trips[trips.length - 1] = (trips.last.$1, pos);
    } else {
      trips.add((pos, pos));
    }
  }
  return trips;
}

/// How the plays sit on the track at a given width.
@immutable
class TimelineScale {
  const TimelineScale({
    required this.scrolls,
    required this.spacing,
    required this.markSize,
    required this.contentWidth,
    this.trips = const [],
  });

  /// True when the plays are laid out wider than the column and it scrolls.
  final bool scrolls;

  /// Distance between one play's centre and the next, where no free-throw
  /// trip sits between them.
  final double spacing;

  final double markSize;

  /// Width of the drawn track. Equal to the column's track width when the
  /// timeline fits; wider, and scrolled, when it does not.
  final double contentWidth;

  /// Free-throw trips as (first, last) positions, from [timelineTrips].
  final List<(int, int)> trips;

  /// Where play [position] is centred on the track.
  ///
  /// A TRIP GETS ROOM FOR ITS ENCLOSURE. The capsule reaches [kTripClearance]
  /// past its marks on each side, so with plain spacing it ran underneath the
  /// play beside it: a miss followed by two made free throws read as one
  /// joined shape. Each trip adds that clearance before its first play and
  /// after its last, which leaves the gap from the capsule's edge to its
  /// neighbour exactly the gap between any two plain marks.
  ///
  /// The clearance shifts EVERY LANE, not just points. All lanes share one
  /// order, so a rebound that came after the trip has to move with the shot
  /// that came after it or the axis stops meaning anything.
  double centreOf(int position) {
    var gaps = 0;
    for (final (first, last) in trips) {
      if (first <= position) gaps++;
      if (last < position) gaps++;
    }
    return (position - 0.5) * spacing + gaps * kTripClearance;
  }
}

/// Lays [plays] out across a track [trackWidth] wide.
///
/// Fits them to the width while that keeps plays at least [kTimelineMinSpacing]
/// apart, which keeps marks at 9pt or larger. Past that, spacing and marks fix
/// at the typical game's sizing and the track grows wider than the column.
/// Each of [trips] takes its clearance out of the width first.
TimelineScale timelineScale(int plays, double trackWidth,
    {List<(int, int)> trips = const []}) {
  if (plays <= 0) {
    return TimelineScale(
        scrolls: false, spacing: trackWidth, markSize: _kMarkMax, contentWidth: trackWidth);
  }
  final clearance = trips.length * 2 * kTripClearance;
  final fitted = (trackWidth - clearance) / plays;
  if (fitted >= kTimelineMinSpacing) {
    return TimelineScale(
      scrolls: false,
      spacing: fitted,
      markSize: (fitted - 1).clamp(_kMarkFitMin, _kMarkMax),
      contentWidth: trackWidth,
      trips: trips,
    );
  }
  return TimelineScale(
    scrolls: true,
    spacing: _kScrollSpacing,
    markSize: _kScrollMark,
    contentWidth: plays * _kScrollSpacing + clearance,
    trips: trips,
  );
}

/// How far a free-throw enclosure reaches past its marks, on each side.
const double kTripClearance = 3.5;

/// The closest two plays may sit before the timeline scrolls instead.
///
/// At the design width the track is 226pt: 22 plays fit at 10.3 apart, 23
/// would need 9.8, so this is what puts the threshold at 22.
const double kTimelineMinSpacing = 10;

/// Column widths and row heights, measured from the TABLE frames.
///
/// THE SIDE COLUMNS ARE EQUAL ON PURPOSE. The stat column was 55, which left
/// "5·2" 8pt from the timeline's edge hairline while the labels had 12. Both
/// are 74 now, so the table balances and the totals have room.
const double kTimelineLabelCol = 74;
const double kTimelineStatCol = 74;
const double _kTrackPad = 8;
const double _kAxisRow = 34;
const double _kLaneRow = 50;
const double _kTrackHeight = 22;
const double _kMarkMax = 13;
const double _kMarkFitMin = 9;
const double _kScrollSpacing = 12;
const double _kScrollMark = 11;
const double _kFadeWidth = 26;

/// The whole section, header included. Renders nothing when there is no game
/// to show.
class GameTimeline extends StatelessWidget {
  const GameTimeline({super.key, required this.events, this.moment});

  final List<StatEvent> events;

  /// One plain sentence describing the shape of the game. Optional on purpose:
  /// a lane whose sample cannot support a pattern gets no moment, and a
  /// three-play game gets none at all. Describing is allowed; explaining is
  /// not - no confidence, rhythm, or momentum.
  ///
  /// Nothing generates one yet. The widget draws it when it is given one.
  final String? moment;

  @override
  Widget build(BuildContext context) {
    final lanes = buildTimelineLanes(events);
    if (lanes.isEmpty) return const SizedBox.shrink();

    final plays = events.where((e) => e.isConfirmed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CiSectionHeader(title: 'How the game went', trailing: '$plays plays'),
        LayoutBuilder(
          builder: (context, box) {
            final track = box.maxWidth - kTimelineLabelCol - kTimelineStatCol - _kTrackPad * 2;
            final scale = timelineScale(plays, track, trips: timelineTrips(lanes));
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: kTimelineLabelCol,
                  child: _PinnedColumn(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: CiSpace.screen),
                    cells: [for (final l in lanes) _LabelText(l.label)],
                  ),
                ),
                Expanded(
                  child: _TimelineColumn(lanes: lanes, total: plays, scale: scale),
                ),
                SizedBox(
                  width: kTimelineStatCol,
                  child: _PinnedColumn(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: CiSpace.screen),
                    cells: [for (final l in lanes) _StatText(l.value)],
                  ),
                ),
              ],
            );
          },
        ),
        if (moment != null) _Moment(text: moment!),
      ],
    );
  }
}

/// A row cell: fixed height, closed by the hairline every row on this screen
/// closes on. Fixed heights are what keep the three columns level with each
/// other without sharing a parent row.
class _Cell extends StatelessWidget {
  const _Cell({
    required this.height,
    this.alignment = Alignment.centerLeft,
    this.padding = EdgeInsets.zero,
    this.child,
  });

  final double height;
  final Alignment alignment;
  final EdgeInsets padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.hairline, width: CiSpace.hairline)),
      ),
      child: child,
    );
  }
}

/// The label or stat column: an empty header cell, then one cell per lane.
/// Stays put while the timeline beside it scrolls.
class _PinnedColumn extends StatelessWidget {
  const _PinnedColumn({
    required this.alignment,
    required this.padding,
    required this.cells,
  });

  final Alignment alignment;
  final EdgeInsets padding;
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Cell(height: _kAxisRow),
          for (final cell in cells)
            _Cell(
              height: _kLaneRow,
              alignment: alignment,
              padding: padding,
              child: _Shrink(alignment: alignment, child: cell),
            ),
        ],
      );
}

class _LabelText extends StatelessWidget {
  const _LabelText(this.text);

  final String text;

  // The hero's own caps style (_Mini on game_detail_page): micro, muted.
  @override
  Widget build(BuildContext context) => Text(text,
      maxLines: 1, style: CiType.micro.copyWith(color: CiColors.of(context).textMuted));
}

class _StatText extends StatelessWidget {
  const _StatText(this.text);

  final String text;

  // Light 16: one step below the hero's secondary stats, which are Light 18
  // in code and 20 in the frame.
  @override
  Widget build(BuildContext context) => Text(text,
      maxLines: 1,
      style: CiType.unit.copyWith(
          color: CiColors.of(context).text, fontSize: 16, fontWeight: CiWeight.light));
}

/// Keeps a line on one line inside a fixed column.
///
/// The columns are fixed because the frame is, but their contents are not: a
/// three-digit total or a parent running large text sizes widens them.
/// scaleDown leaves the design sizing alone whenever it fits and gives up
/// points only when it cannot.
class _Shrink extends StatelessWidget {
  const _Shrink({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      FittedBox(fit: BoxFit.scaleDown, alignment: alignment, child: child);
}

/// The middle column: header row and tracks, on surface-sunk, between two
/// hairlines. Scrolls when [scale] says so, as ONE unit.
class _TimelineColumn extends StatefulWidget {
  const _TimelineColumn({required this.lanes, required this.total, required this.scale});

  final List<TimelineLane> lanes;
  final int total;
  final TimelineScale scale;

  @override
  State<_TimelineColumn> createState() => _TimelineColumnState();
}

class _TimelineColumnState extends State<_TimelineColumn> {
  // A scrolling timeline always overflows at first (it only scrolls when the
  // plays need more room than the column has), so it opens with the fade on.
  bool _atEnd = false;

  bool _onScroll(ScrollNotification n) {
    final atEnd = n.metrics.extentAfter < 0.5;
    if (atEnd != _atEnd) setState(() => _atEnd = atEnd);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final scale = widget.scale;
    final rowWidth = scale.contentWidth + _kTrackPad * 2;

    // Header and lanes in one Column, so a scroll moves every lane together.
    // Scrolling lanes separately would break the one thing this design is for.
    final content = SizedBox(
      width: scale.scrolls ? rowWidth : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Cell(
            height: _kAxisRow,
            padding: EdgeInsets.symmetric(horizontal: _kTrackPad),
            child: _Axis(),
          ),
          for (final lane in widget.lanes)
            _Cell(
              height: _kLaneRow,
              padding: const EdgeInsets.symmetric(horizontal: _kTrackPad),
              child: _Track(
                plays: lane.plays,
                scale: scale,
                width: scale.contentWidth,
              ),
            ),
        ],
      ),
    );

    return Container(
      color: c.surfaceSunk,
      // Foreground, so the edge hairlines draw over the fade rather than under
      // it. They match the row hairlines exactly: same token, same weight.
      foregroundDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: c.hairline, width: CiSpace.hairline),
          right: BorderSide(color: c.hairline, width: CiSpace.hairline),
        ),
      ),
      child: !scale.scrolls
          ? content
          : Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: content,
                  ),
                ),
                // Says "there is more" until there is not. It never blocks a
                // drag: the gesture belongs to the scroll view underneath.
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: _kFadeWidth,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      key: const ValueKey('timeline-scroll-fade'),
                      opacity: _atEnd ? 0 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            c.surfaceSunk.withValues(alpha: 0),
                            c.surfaceSunk,
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// TIP-OFF, an arrow, FINAL. Words, never play numbers: position here means
/// ORDER, and a numbered axis invites reading a precision that does not exist.
class _Axis extends StatelessWidget {
  const _Axis();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final style = CiType.micro.copyWith(color: c.text);
    return Row(
      children: [
        Text('TIP-OFF', style: style),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Container(height: 1.5, color: c.text)),
              CustomPaint(size: const Size(6, 8), painter: _ArrowHead(color: c.text)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text('FINAL', style: style),
      ],
    );
  }
}

class _ArrowHead extends CustomPainter {
  const _ArrowHead({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowHead old) => old.color != color;
}

class _Track extends StatelessWidget {
  const _Track({required this.plays, required this.scale, required this.width});

  final List<TimelinePlay> plays;
  final TimelineScale scale;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final mark = scale.markSize;
    final centreOf = scale.centreOf;
    const pad = kTripClearance;
    return SizedBox(
      width: width,
      height: _kTrackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0, right: 0, top: _kTrackHeight / 2 - 1,
            // gray300, bound as a primitive in the frame. No semantic token
            // resolves to it on light ground; border is gray150, which is what
            // this drew before and why the rule read as faint.
            child: CustomPaint(
              painter: const _DottedRule(color: CiPalette.gray300),
              size: Size(width, 2),
            ),
          ),
          // Enclosures first, filled with the column's own colour, so they
          // interrupt the dotted rule rather than sitting on top of it. A trip
          // reads as a segment carved out of the timeline.
          //
          // Only this lane's trips: the scale holds every trip in the game,
          // which is right for spacing and wrong for drawing.
          for (final (first, last) in scale.trips)
            if (plays.any((p) => p.position == first && p.freeThrow))
              Positioned(
                left: centreOf(first) - mark / 2 - pad,
                top: _kTrackHeight / 2 - (mark + pad * 2) / 2,
                child: Container(
                  width: centreOf(last) - centreOf(first) + mark + pad * 2,
                  height: mark + pad * 2,
                  decoration: BoxDecoration(
                    color: c.surfaceSunk,
                    borderRadius: BorderRadius.circular((mark + pad * 2) / 2),
                    border: Border.all(color: c.text, width: 1.4),
                  ),
                ),
              ),
          for (final p in plays)
            Positioned(
              left: centreOf(p.position) - mark / 2,
              top: _kTrackHeight / 2 - mark / 2,
              child: Container(
                width: mark,
                height: mark,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.filled ? c.text : c.surfaceSunk,
                  border: p.filled ? null : Border.all(color: c.text, width: 1.4),
                ),
              ),
            ),
        ],
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

/// The summary line, in the insight wash: the same ground and the same
/// sparkle as the insight card, because it is the same kind of statement.
class _Moment extends StatelessWidget {
  const _Moment({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(CiSpace.screen, 18, CiSpace.screen, 20),
      decoration: BoxDecoration(
        color: c.accentGoodWash,
        border: Border(bottom: BorderSide(color: c.hairline, width: CiSpace.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: c.text),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: CiType.bodyXs.copyWith(color: c.text, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
