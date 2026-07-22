// CiScoringMix — where the points came from (145:610)
//
// A single stacked bar: ink for twos, lime for threes, grey for free throws,
// each labelled with the points it contributed, and a dot legend beneath.
//
// IT IS POINTS, NOT MAKES. Two threes and three twos are the same number of
// made shots and a different game, and points are what the bar's widths have
// to be proportional to or the picture lies.
//
// THE ONE PLACE LIME MEANS "THREE-POINTER" rather than "good". It works here
// because the legend names it and the segments sit side by side, so the colour
// is being used to tell three things apart, not to praise one of them.
//
// A segment worth zero never reaches this widget - see buildGameDetail. An
// invisible sliver with a legend entry explaining it is worse than an absence.

import 'package:flutter/material.dart';

import '../../game_detail_builder.dart';
import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

class CiScoringMix extends StatelessWidget {
  const CiScoringMix({super.key, required this.segments});

  final List<ScoringSegment> segments;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    if (segments.isEmpty) return const SizedBox.shrink();

    Color fill(String label) => switch (label) {
          '3PT' => c.accentGood,
          'FT' => c.surfaceSunk,
          _ => c.surfaceDeep,
        };
    Color ink(String label) => label == '2PT' ? c.textInvert : c.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: CiRadius.chipR,
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                for (final s in segments)
                  Expanded(
                    // Flex by POINTS, so a segment's width is the share of the
                    // score it actually produced.
                    flex: s.points,
                    child: Container(
                      color: fill(s.label),
                      alignment: Alignment.center,
                      child: Text(
                        '${s.points}',
                        style: CiType.bodySm.copyWith(
                            color: ink(s.label),
                            fontWeight: CiWeight.semiBold),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: CiSpace.s3),
        Row(
          children: [
            for (final s in segments) ...[
              _LegendDot(color: fill(s.label), label: s.label),
              const SizedBox(width: CiSpace.s4),
            ],
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: CiType.caption.copyWith(color: c.textMuted)),
      ],
    );
  }
}
