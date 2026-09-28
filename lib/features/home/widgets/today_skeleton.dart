// Today loading skeleton — Phase 4.10b
//
// Measured from Today - Loading (Skeleton) 670:2559: the ink hero with a grey
// gauge disc and grey bars where the score and headline go, then grey
// placeholder feed rows on light ground.
//
// A SKELETON, NOT A SPINNER. Today has a fixed, known shape, so showing its
// outline while data loads reads as "your screen, arriving" rather than "the
// app is busy". It also holds the layout still, so nothing jumps when the real
// content lands.
//
// Shapes only, no shimmer animation: the load is a single quick query, and a
// sweeping shimmer on a screen a parent opens many times a day is more
// distracting than reassuring.
//
// The bone itself moved to design/components/ci_skeleton.dart in 4.27, when
// the Players and Games lists needed the same shape. That swapped the fill
// from `surfaceSunk` to `border`, which is nearer what 670:2559 actually
// draws: the hero bones are #3D3D3D in the frame, and #1A1A1A on a #0F0F0F
// ground was very nearly invisible on device.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_skeleton.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';

/// The grey stand-in for the Growth IQ block, on ink ground.
class TodayHeroSkeleton extends StatelessWidget {
  const TodayHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s7, CiSpace.screen, CiSpace.s7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CiBone.circle(120),
          SizedBox(width: CiSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CiBone(width: 90, height: 14),
                SizedBox(height: CiSpace.s3),
                CiBone(width: double.infinity, height: 20),
                SizedBox(height: CiSpace.s2),
                CiBone(width: 160, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One grey feed row.
class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CiBone.circle(38),
              SizedBox(width: CiSpace.s3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CiBone(width: 120, height: 15),
                  SizedBox(height: CiSpace.s2),
                  CiBone(width: 180, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: CiSpace.s4),
          CiBone(width: double.infinity, height: 28),
        ],
      ),
    );
  }
}

/// The feed placeholder: a few grey rows on light ground.
class TodayFeedSkeleton extends StatelessWidget {
  const TodayFeedSkeleton({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++) const _RowSkeleton(),
      ],
    );
  }
}
