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
// sweeping shimmel on a screen a parent opens many times a day is more
// distracting than reassuring.

import 'package:flutter/material.dart';

import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';

/// A rounded grey block standing in for text or a shape.
class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.circle = false});

  final double width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Reads on either ground: the placeholder colour is the sunk surface,
        // so the caller wraps each region in the right one.
        color: c.surfaceSunk,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(6),
      ),
    );
  }
}

/// The grey stand-in for the Growth IQ block, on ink ground.
class TodayHeroSkeleton extends StatelessWidget {
  const TodayHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s7, CiSpace.screen, CiSpace.s7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Bone(width: 120, height: 120, circle: true),
          SizedBox(width: CiSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 90, height: 14),
                SizedBox(height: CiSpace.s3),
                _Bone(width: double.infinity, height: 20),
                SizedBox(height: CiSpace.s2),
                _Bone(width: 160, height: 20),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              _Bone(width: 38, height: 38, circle: true),
              SizedBox(width: CiSpace.s3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 120, height: 15),
                  SizedBox(height: CiSpace.s2),
                  _Bone(width: 180, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: CiSpace.s4),
          _Bone(width: double.infinity, height: 28),
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
