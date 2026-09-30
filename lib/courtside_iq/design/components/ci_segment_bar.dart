// CiSegmentBar — Phase 4.8
//
// The scoring-mix bar: proportional segments showing where a player's points
// came from (2PT / 3PT / FT).
//
// Measured from Components / SegmentBar: h44, 2px gaps between segments,
// widths proportional to value, labels SemiBold 13 centred.
//   2PT  ink fill,     white label
//   3PT  lime fill,    ink label
//   FT   gray300 fill, ink label
//
// The 2px gap is the seam. Segments are not rounded and do not touch.
//
// Note this shows COMPOSITION, not score - it answers "where did the points
// come from", which is a development question. It is not a scoreboard, and
// there is deliberately no team total anywhere in this app.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

@immutable
class CiSegment {
  const CiSegment({
    required this.value,
    required this.color,
    required this.labelColor,
    this.tooltip,
  });

  /// Raw contribution. Widths are computed from the total, so callers pass
  /// points rather than percentages.
  final double value;
  final Color color;
  final Color labelColor;
  final String? tooltip;
}

class CiSegmentBar extends StatelessWidget {
  const CiSegmentBar({
    super.key,
    required this.segments,
    this.height = 44,
    this.showValues = true,
  });

  final List<CiSegment> segments;
  final double height;

  /// Hide labels when the bar is small enough that they would not fit.
  final bool showValues;

  /// The standard scoring mix, in the designed order and colors.
  factory CiSegmentBar.scoringMix({
    Key? key,
    required double twoPoint,
    required double threePoint,
    required double freeThrow,
    required CiColors colors,
    double height = 44,
  }) {
    return CiSegmentBar(
      key: key,
      height: height,
      segments: [
        CiSegment(
          value: twoPoint,
          color: colors.surfaceInvert,
          labelColor: colors.textInvert,
          tooltip: '2PT',
        ),
        CiSegment(
          value: threePoint,
          color: colors.accentGood,
          labelColor: colors.onAccent,
          tooltip: '3PT',
        ),
        CiSegment(
          value: freeThrow,
          color: CiPalette.gray300,
          labelColor: CiPalette.inkDefault,
          tooltip: 'FT',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Segments with no contribution are dropped rather than rendered as
    // slivers. A player who took no threes should show two segments, not a
    // 1px artifact.
    final live = segments.where((s) => s.value > 0).toList();
    if (live.isEmpty) return SizedBox(height: height);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var i = 0; i < live.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              // Rounded so a 1-point segment still gets a usable flex.
              flex: (live[i].value * 100).round().clamp(1, 1 << 20),
              child: Container(
                color: live[i].color,
                alignment: Alignment.center,
                child: showValues
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: CiSpace.s1),
                          child: Text(
                            _fmt(live[i].value),
                            style: CiType.buttonSm
                                .copyWith(color: live[i].labelColor),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}
