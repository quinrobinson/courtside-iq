// DotGauge — Phase 4.8
//
// The Growth IQ dial: concentric rings of dots, filled clockwise from 12
// o'clock to show a 0-1 value.
//
// Drawn with a CustomPainter rather than an image or SVG, deliberately:
//   - no new dependency, and no raster to go soft on a high-DPI screen
//   - colors come from tokens, so light/dark and any future palette change
//     are free. Tinting individual dots inside an SVG is awkward.
//   - it animates. Growth IQ moving 71 -> 76 can sweep the fill; a static
//     asset cannot.
//
// Geometry measured from the Figma component (Components / DotGauge, 168x168):
//   outer ring: 30 dots, radius 74, dot 6.0
//   inner ring: 24 dots, radius 56, dot 5.0
// Both start at 12 o'clock and run clockwise. Radii and dot sizes scale with
// the widget size, so the same component serves a 168px hero and a 44px
// inline gauge.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/ci_colors.dart';

/// One ring of the gauge, expressed as fractions of the widget's radius so the
/// whole thing scales cleanly.
@immutable
class DotGaugeRing {
  const DotGaugeRing({
    required this.dotCount,
    required this.radiusFactor,
    required this.dotSizeFactor,
  });

  /// Dots in the full 360 degrees.
  final int dotCount;

  /// Ring radius as a fraction of half the widget's shortest side.
  /// Figma: 74/84 outer, 56/84 inner.
  final double radiusFactor;

  /// Dot diameter as a fraction of half the widget's shortest side.
  /// Figma: 6/84 outer, 5/84 inner.
  final double dotSizeFactor;
}

abstract final class DotGaugeRings {
  /// The measured Figma configuration. Two rings at 168x168.
  static const standard = <DotGaugeRing>[
    DotGaugeRing(dotCount: 30, radiusFactor: 74 / 84, dotSizeFactor: 6 / 84),
    DotGaugeRing(dotCount: 24, radiusFactor: 56 / 84, dotSizeFactor: 5 / 84),
  ];

  /// Single ring, for small inline use where two rings would read as noise.
  static const compact = <DotGaugeRing>[
    DotGaugeRing(dotCount: 30, radiusFactor: 74 / 84, dotSizeFactor: 7 / 84),
  ];
}

class DotGauge extends StatelessWidget {
  const DotGauge({
    super.key,
    required this.value,
    this.size = 168,
    this.rings = DotGaugeRings.standard,
    this.filledColor,
    this.emptyColor,
    this.child,
  });

  /// 0..1. Values outside are clamped rather than throwing - a gauge that
  /// crashes on bad data is worse than one that pins to full.
  final double value;

  final double size;
  final List<DotGaugeRing> rings;

  /// Defaults to the lime accent.
  final Color? filledColor;

  /// Defaults to a neutral that reads as "not yet", never as an error.
  final Color? emptyColor;

  /// Centred content, typically the score itself.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DotGaugePainter(
          value: value.clamp(0.0, 1.0),
          rings: rings,
          filled: filledColor ?? c.accentGood,
          empty: emptyColor ?? CiPalette.gray300,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

/// Animates the fill between values. Use when a score can change on screen.
class AnimatedDotGauge extends StatelessWidget {
  const AnimatedDotGauge({
    super.key,
    required this.value,
    this.size = 168,
    this.rings = DotGaugeRings.standard,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeOutCubic,
    this.child,
  });

  final double value;
  final double size;
  final List<DotGaugeRing> rings;
  final Duration duration;
  final Curve curve;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: curve,
      builder: (context, v, child) =>
          DotGauge(value: v, size: size, rings: rings, child: child),
      child: child,
    );
  }
}

class _DotGaugePainter extends CustomPainter {
  _DotGaugePainter({
    required this.value,
    required this.rings,
    required this.filled,
    required this.empty,
  });

  final double value;
  final List<DotGaugeRing> rings;
  final Color filled;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final unit = math.min(size.width, size.height) / 2;

    final filledPaint = Paint()..color = filled..isAntiAlias = true;
    final emptyPaint = Paint()..color = empty..isAntiAlias = true;

    for (final ring in rings) {
      final radius = unit * ring.radiusFactor;
      final dotRadius = unit * ring.dotSizeFactor / 2;

      // Round rather than floor: at 83.3% of 30 dots, floor gives 24 and the
      // gauge reads a whole dot short of the number beside it.
      final litCount = (value * ring.dotCount).round();

      for (var i = 0; i < ring.dotCount; i++) {
        // Start at 12 o'clock, run clockwise. -pi/2 puts 0 at the top.
        final angle = -math.pi / 2 + (2 * math.pi * i / ring.dotCount);
        final centreOfDot = Offset(
          centre.dx + radius * math.cos(angle),
          centre.dy + radius * math.sin(angle),
        );
        canvas.drawCircle(
          centreOfDot,
          dotRadius,
          i < litCount ? filledPaint : emptyPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGaugePainter old) =>
      old.value != value ||
      old.filled != filled ||
      old.empty != empty ||
      old.rings != rings;
}

/// Makes a [DotGauge] tappable, with the label a screen reader needs.
///
/// The gauge is the entry point to "About Growth IQ" on both Today and the
/// player profile ("tap the Growth IQ gauge", per the frame). Shared rather
/// than wrapped inline at each site so both carry the same semantics: a bare
/// GestureDetector around a painter is an unlabelled tap target, which reads
/// to a screen reader as nothing at all.
///
/// Passing a null [onTap] returns the child untouched, so a gauge with nothing
/// to explain does not advertise itself as a button.
class DotGaugeTapTarget extends StatelessWidget {
  const DotGaugeTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel = 'About Growth IQ',
  });

  final Widget child;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
