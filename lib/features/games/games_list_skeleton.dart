// Games list loading skeleton — Phase 4.27
//
// Measured from Games - Loading (Skeleton) 682:2785: two chip rows under the
// ink header, a full-bleed rule, then four placeholder game rows each carrying
// an avatar disc, a title bar over a subtitle bar, and five stat columns.
//
// THE CHIP ROWS ARE 32 TALL, NOT THE FRAME'S 14. The frame draws the player
// row as thin bars and the date row as full chips, but both are `CiChipBar` in
// the built screen and CiChipBar is h32 (ci_field.dart:263). Reserving 14 for
// something that arrives at 32 would jump the whole list down by 18pt the
// moment data lands, which is the one thing a skeleton must not do. The frame
// is right about WHICH rows exist and how wide their chips run; the component
// is right about how tall they are.
//
// The bar widths ARE the frame's: narrow for the player row (All / Maya /
// Jordan) and wider for the dates (All dates / May 4 / ...), which is what
// those two filters really look like. The date row runs off the right edge on
// purpose - it scrolls in the real screen, so a placeholder that stopped
// neatly inside the margin would misdescribe it.
//
// Four rows, matching the frame, and the same 124 height game_feed_row.dart
// documents for the real row.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_skeleton.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';

/// Height of a built GameFeedRow (game_feed_row.dart:5).
const double _kGameRowHeight = 124;

class GamesListSkeleton extends StatelessWidget {
  const GamesListSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Same rhythm the real screen uses: s3 above the chips, s3 between
        // the two rows, s3 before the rule.
        const SizedBox(height: CiSpace.s3),
        const _ChipRowSkeleton(widths: [30, 44, 52]),
        const SizedBox(height: CiSpace.s3),
        const _ChipRowSkeleton(widths: [76, 66, 66, 71, 71]),
        const SizedBox(height: CiSpace.s3),
        const CiHairline(),
        for (var i = 0; i < rows; i++) ...[
          const _RowSkeleton(),
          const CiHairline(),
        ],
      ],
    );
  }
}

class _ChipRowSkeleton extends StatelessWidget {
  const _ChipRowSkeleton({required this.widths});

  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      // Clipped rather than wrapped: the date row genuinely overflows and
      // scrolls, and a wrapped placeholder would be taller than the thing it
      // stands in for.
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
        children: [
          for (final w in widths) ...[
            CiBone.pill(width: w, height: 32),
            const SizedBox(width: CiSpace.s2),
          ],
        ],
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _kGameRowHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CiBone.circle(38),
                SizedBox(width: CiSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CiBone(width: 100, height: 14),
                      SizedBox(height: 8),
                      CiBone(width: 140, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: CiSpace.s4),
            // spaceBetween, matching GameFeedRow: equal slots leave a visible
            // gap on the right because each column hugs its own narrow number.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatSkeleton(),
                _StatSkeleton(),
                _StatSkeleton(),
                _StatSkeleton(),
                _StatSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One stat column: the value block over its label, centred as the real one is.
class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CiBone(width: 32, height: 20),
        SizedBox(height: 8),
        CiBone(width: 22, height: 9),
      ],
    );
  }
}
