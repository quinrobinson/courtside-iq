// CiBone — the skeleton placeholder shape. Phase 4.27
//
// One grey block standing in for text, a control, or an avatar while a screen
// loads. Extracted from today_skeleton.dart the moment the Players and Games
// lists needed the same thing: three near-identical private `_Bone` classes
// would have been three chances to drift apart.
//
// COLOUR IS `border`, NOT `surfaceSunk`. The loading frames draw bones at
// #E7E7E7 on white (515:1975, 682:2785) and #3D3D3D on ink (670:2559).
// `border` resolves to #E9E9E9 and #2E2E2E, the nearest values the palette
// actually holds. `surfaceSunk` is what today_skeleton used before this file
// existed and it is too faint on both grounds - on ink especially, where
// #1A1A1A against a #0F0F0F background is very nearly invisible.
//
// RADII ARE TOKENS. The frames draw 3, 4, 6 and 11 depending on the bar. On a
// grey placeholder that spread is imperceptible, and four untokenised radii is
// how a system starts to leak, so rectangles take `chipR` and pills take
// `pillR`.
//
// NO SHIMMER, for the reason today_skeleton already gives: these screens load
// from a single quick query, and a sweep animation on something a parent opens
// many times a day is more distracting than reassuring.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';

class CiBone extends StatelessWidget {
  const CiBone({
    super.key,
    this.width,
    required this.height,
    this.radius,
  })  : _circle = false,
        _size = null;

  /// A round bone: avatars, gauges, and anything else that reads as a disc.
  const CiBone.circle(double size, {super.key})
      : _circle = true,
        _size = size,
        width = null,
        height = 0,
        radius = null;

  /// A fully rounded bar, for standing in over a pill-shaped control such as
  /// a filter chip or a trend badge.
  const CiBone.pill({super.key, this.width, required this.height})
      : _circle = false,
        _size = null,
        radius = CiRadius.pillR;

  /// Null stretches to the available width, so a bone can fill a column
  /// without the caller measuring it.
  final double? width;

  final double height;

  /// Defaults to [CiRadius.chipR].
  final BorderRadius? radius;

  final bool _circle;
  final double? _size;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      width: _circle ? _size : width,
      height: _circle ? _size : height,
      decoration: BoxDecoration(
        color: c.border,
        shape: _circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: _circle ? null : (radius ?? CiRadius.chipR),
      ),
    );
  }
}
