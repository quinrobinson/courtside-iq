// CiLogoMark — Phase 4.9
//
// The Courtside IQ mark: a disc cut by one full-height vertical channel and a
// horizontal channel across the right side, leaving three fields - a tall left
// form and two stacked right quadrants.
//
// PAINTED, NOT AN ASSET. `assets/images/logo-mark.png` is solid black, and on
// ink ground it vanishes into the background - which is exactly what happened
// on the Auth Landing screen. Tinting a bitmap would work, but the mark also
// has to sit on light ground elsewhere and scale up for Splash, so it takes a
// colour and a size instead. Same reasoning as DotGauge and DotBurst.
//
// Proportions taken from the 175x174 asset and expressed as fractions, so the
// mark is identical at 44 and at 240.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';

class CiLogoMark extends StatelessWidget {
  const CiLogoMark({super.key, this.size = 44, this.color});

  final double size;

  /// Defaults to the current ground's text colour: white on ink, ink on light.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? CiColors.of(context).text;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoMarkPainter(c)),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  const _LogoMarkPainter(this.color);

  final Color color;

  /// Channel width as a fraction of the mark. Scales with the mark so the
  /// cuts stay visible at 44 and stay proportionate at 240.
  static const _channel = 0.055;

  /// The vertical channel sits just left of centre, which is what gives the
  /// mark its asymmetry.
  static const _channelX = 0.47;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final disc = Path()..addOval(Offset.zero & size);

    final half = _channel * w / 2;
    final cuts = Path()
      // Full-height vertical channel.
      ..addRect(Rect.fromLTRB(_channelX * w - half, 0, _channelX * w + half, h))
      // Horizontal channel, right side only, splitting it into two quadrants.
      ..addRect(Rect.fromLTRB(_channelX * w, h / 2 - half, w, h / 2 + half));

    canvas.drawPath(
      Path.combine(PathOperation.difference, disc, cuts),
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_LogoMarkPainter old) => old.color != color;
}
