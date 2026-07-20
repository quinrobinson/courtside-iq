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
    this.size = _referenceSize,
    double? innerRadius,
    double? ringGap,
    double? dotSpacing,
    this.glowOpacity = 0.16,
    this.color,
    this.child,
  })  : _innerRadius = innerRadius,
        _ringGap = ringGap,
        _dotSpacing = dotSpacing;

  /// The size everything was originally measured at: the Splash frame.
  ///
  /// GEOMETRY SCALES WITH [size]. These were absolute constants at first,
  /// which meant the burst was only correct at 390 - rendering it at 220 kept
  /// the 390-sized ring gaps inside a burst two thirds as wide, and the rings
  /// visibly drifted apart. Anything derived from this reference reproduces
  /// the original numbers exactly at 390, so existing call sites are unchanged.
  static const double _referenceSize = 390;

  /// Overall square extent of the burst.
  final double size;

  final double? _innerRadius;
  final double? _ringGap;
  final double? _dotSpacing;

  /// How much to scale the reference geometry by.
  double get _scale => size / _referenceSize;

  /// Radius of the first ring. Clears whatever sits in the middle.
  double get innerRadius => _innerRadius ?? 62 * _scale;

  /// Distance between consecutive rings.
  double get ringGap => _ringGap ?? 34 * _scale;

  /// Target arc distance between dots. Dot COUNT is derived from this and the
  /// ring radius, so outer rings get more dots and spacing stays even.
  double get dotSpacing => _dotSpacing ?? 22 * _scale;

  /// The ring-to-ring gap for a given overall size.
  ///
  /// A caller that centres a child of known size can set
  /// `innerRadius: childRadius + DotBurst.ringGapFor(size)` so the first ring
  /// sits one gap out from the child - the SAME gap the rings have between
  /// each other. Without it the first ring hugs the child and the spacing
  /// reads as uneven.
  static double ringGapFor(double size) => 34 * (size / _referenceSize);

  /// Peak alpha of the radial haze behind the dots, at the centre.
  ///
  /// The frame carries a 220x220 ellipse on the burst's own centre, behind
  /// every dot - Figma's codegen drops it because it exports no gradient
  /// fills, which is why the first build looked flat. Kept low on purpose: it
  /// should read as depth behind the dots, never as neon. Set 0 to disable.
  final double glowOpacity;

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
          // Dot radius scales too, or a smaller burst gets reference-sized
          // dots and reads as coarse.
          dotScale: _scale,
          glowOpacity: glowOpacity,
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
    required this.dotScale,
    required this.glowOpacity,
    required this.color,
  });

  final List<_BurstRing> rings;
  final double innerRadius;
  final double ringGap;
  final double dotSpacing;
  final double dotScale;
  final double glowOpacity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);

    // Haze first, so every dot sits on top of it.
    if (glowOpacity > 0) {
      final radius = size.width / 2;
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: glowOpacity),
              color.withValues(alpha: glowOpacity * 0.35),
              color.withValues(alpha: 0),
            ],
            // Weighted toward the centre so the falloff is gradual rather
            // than a visible disc edge.
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }

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
          ring.dotSize * dotScale / 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotBurstPainter old) =>
      old.color != color ||
      old.dotScale != dotScale ||
      old.glowOpacity != glowOpacity ||
      old.innerRadius != innerRadius ||
      old.ringGap != ringGap ||
      old.dotSpacing != dotSpacing;
}
