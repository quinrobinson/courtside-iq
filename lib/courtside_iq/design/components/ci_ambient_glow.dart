// The signature ambient lime wash — Phase 4.19b
//
// A soft, static accent glow painted BEHIND dark surfaces so they do not sit on
// flat black. Same recipe as the Today hero (today_hero.dart): two radial
// washes of the accent, positioned as fractions of the painted area so they sit
// the same way on any device. Kept low - depth behind the content, never neon -
// and non-interactive.
//
// This was inlined on the Today hero, then copied into onboarding; the paywall
// made it a third use, so it lives here now. Callers wrap it in a Positioned.fill
// (or a Stack) behind their content.
//
// The Figma frames carry a 40px layer blur over eased alpha stops; this
// three-stop shader approximates that softness without the blur - the trade the
// Today glow already makes, so every surface reads the same in-app.

import 'package:flutter/material.dart';

import '/courtside_iq/design/tokens/ci_colors.dart';

/// One radial wash. Position and size are fractions of the painted area:
/// [cx]/[cy] of width/height for the centre, [radius] of width.
class CiGlowWash {
  const CiGlowWash({
    required this.cx,
    required this.cy,
    required this.radius,
    required this.alpha,
  });

  final double cx;
  final double cy;
  final double radius;
  final double alpha;
}

class CiAmbientGlow extends StatelessWidget {
  const CiAmbientGlow({super.key, this.color, this.washes = kCiAmbientWashes});

  /// Defaults to the surface's [CiColors.accentGood] (lime).
  final Color? color;

  /// The washes to paint. Defaults to the standard two-wash layout.
  final List<CiGlowWash> washes;

  /// The standard layout, matching the approved frames: one wash up-left behind
  /// the top content, a fainter one down-right behind the CTA.
  static const List<CiGlowWash> kCiAmbientWashes = [
    CiGlowWash(cx: 0.10, cy: 0.22, radius: 0.82, alpha: 0.16),
    CiGlowWash(cx: 0.92, cy: 0.85, radius: 0.72, alpha: 0.10),
  ];

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? CiColors.of(context).accentGood;
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AmbientGlowPainter(resolved, washes),
      ),
    );
  }
}

class _AmbientGlowPainter extends CustomPainter {
  const _AmbientGlowPainter(this.color, this.washes);

  final Color color;
  final List<CiGlowWash> washes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final w in washes) {
      final centre = Offset(size.width * w.cx, size.height * w.cy);
      final radius = size.width * w.radius;
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: w.alpha),
              color.withValues(alpha: w.alpha * 0.3),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientGlowPainter old) =>
      old.color != color || old.washes != washes;
}
