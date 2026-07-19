// DotBurst — Phase 4.8
//
// The brand motif: concentric rings of lime dots radiating outward, fading and
// shrinking as they go. Used behind the logo on Splash, and as an ambient
// signature elsewhere.
//
// Generated rather than drawn. Each ring has a fixed dot size and opacity, and
// its dot count follows from its circumference so spacing stays even as the
// radius grows. That means one painter serves any size, animates, and needs no
// asset.
//
// The six size/opacity tiers below were measured off the Splash frame and are
// exact. The RING RADII were not reliably measurable (the dots sit in nested
// groups whose transforms did not accumulate), so they are expressed as an
// even progression tuned against the Figma frame by eye. If the burst ever
// looks wrong beside the design, the radii are the thing to adjust - the
// sizes and opacities are correct.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/ci_colors.dart';

@immutable
class _BurstRing {
  const _BurstRing(this.dotSize, this.opacity);
  final double dotSize;
  final double opacity;
}

class DotBurst extends StatelessWidget {
  const DotBurst({
    super.key,
    this.size = 390,
    this.innerRadius = 62,
    this.ringGap = 34,
    this.dotSpacing = 22,
    this.color,
    this.child,
  });

  /// Overall square extent of the burst.
  final double size;

  /// Radius of the first ring. Sized to clear whatever sits in the middle
  /// (on Splash, the 100px logo mark).
  final double innerRadius;

  /// Distance between consecutive rings.
  final double ringGap;

  /// Target arc distance between dots. Dot COUNT is derived from this and the
  /// ring radius, so outer rings get more dots and spacing stays even.
  final double dotSpacing;

  /// Defaults to the lime accent.
  final Color? color;

  /// Content centred inside the burst, typically the logo mark.
  final Widget? child;

  /// Measured from Splash. Outermost first is how they read visually, but the
  /// painter walks inner -> outer, so this is ordered to match: ring 0 is the
  /// innermost and brightest.
  static const _rings = <_BurstRing>[
    _BurstRing(6.38, 0.95),
    _BurstRing(5.90, 0.74),
    _BurstRing(5.43, 0.54),
    _BurstRing(4.95, 0.36),
    _BurstRing(4.47, 0.20),
    _BurstRing(3.99, 0.10),
  ];

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DotBurstPainter(
          rings: _rings,
          innerRadius: innerRadius,
          ringGap: ringGap,
          dotSpacing: dotSpacing,
          color: color ?? c.accentGood,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _DotBurstPainter extends CustomPainter {
  _DotBurstPainter({
    required this.rings,
    required this.innerRadius,
    required this.ringGap,
    required this.dotSpacing,
    required this.color,
  });

  final List<_BurstRing> rings;
  final double innerRadius;
  final double ringGap;
  final double dotSpacing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);

    for (var r = 0; r < rings.length; r++) {
      final ring = rings[r];
      final radius = innerRadius + ringGap * r;

      // Even arc spacing: more dots the further out we go.
      final count = math.max(6, (2 * math.pi * radius / dotSpacing).round());

      // Offset alternate rings by half a step so dots do not line up into
      // visible spokes radiating from the centre.
      final phase = (r.isOdd ? math.pi / count : 0);

      final paint = Paint()
        ..color = color.withValues(alpha: ring.opacity)
        ..isAntiAlias = true;

      for (var i = 0; i < count; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * i / count) + phase;
        canvas.drawCircle(
          Offset(
            centre.dx + radius * math.cos(angle),
            centre.dy + radius * math.sin(angle),
          ),
          ring.dotSize / 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotBurstPainter old) =>
      old.color != color ||
      old.innerRadius != innerRadius ||
      old.ringGap != ringGap ||
      old.dotSpacing != dotSpacing;
}
