// Players list loading skeleton — Phase 4.27
//
// Measured from Players - Loading (Skeleton) 515:1975: three placeholder rows
// under the ink header, each carrying an avatar disc, a name bar over a
// subtitle bar, three stat blocks with their labels, and a gauge disc with a
// trend pill beside it.
//
// GEOMETRY COMES FROM THE ROW, NOT THE FRAME, wherever the two disagree. The
// frame draws a 188-tall row with a 96 gauge; the built [PlayerListRow] is
// `kPlayerRowHeight` (208) with a `kPlayerRowGaugeSize` (112) gauge. A skeleton
// exists to hold the layout still - today_skeleton.dart says so in as many
// words - so a placeholder 20pt shorter than the thing it stands in for would
// defeat the whole point and make the list jump as data lands. The frame
// decides WHICH shapes appear and where; the row decides HOW BIG. Those
// constants are imported rather than copied, so the two cannot drift.
//
// Three rows, matching the frame. Enough to read as a list without pretending
// to know how many players the parent actually has.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_skeleton.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import 'player_list_row.dart';

class PlayersListSkeleton extends StatelessWidget {
  const PlayersListSkeleton({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return ListView.builder(
      // Matches the real list: a scroll view under the ink header would
      // otherwise inherit the ambient MediaQuery padding and open a gap.
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows,
      itemBuilder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RowSkeleton(),
          Container(height: CiSpace.hairline, color: c.hairline),
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
      height: kPlayerRowHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CiSpace.screen,
          kPlayerRowPadding,
          CiSpace.screen,
          kPlayerRowPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identity column, centred against the taller gauge exactly as
            // PlayerListRow centres its own.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CiBone.circle(40),
                      SizedBox(width: CiSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CiBone(width: 110, height: 14),
                            SizedBox(height: 10),
                            CiBone(width: 150, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: CiSpace.s5),
                  Row(
                    children: [
                      _AvgSkeleton(),
                      SizedBox(width: CiSpace.s7),
                      _AvgSkeleton(),
                      SizedBox(width: CiSpace.s7),
                      _AvgSkeleton(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: CiSpace.s3),
            Column(
              children: [
                CiBone.circle(kPlayerRowGaugeSize),
                SizedBox(height: CiSpace.s2),
                CiBone.pill(width: 64, height: kPlayerRowChipHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One PPG / RPG / APG column: the value block over its label.
class _AvgSkeleton extends StatelessWidget {
  const _AvgSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CiBone(width: 48, height: 30),
        SizedBox(height: 6),
        CiBone(width: 26, height: 10),
      ],
    );
  }
}
