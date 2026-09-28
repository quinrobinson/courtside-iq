// CiLogoMark — the Courtside IQ mark, Dot-burst C (Release 2.1, 2026-09-28).
//
// Two rings of dots forming a C that opens right; along each ring the dots
// grow and fade in from the bottom tip to the top tip. The shape lives in
// `lib/courtside_iq/brand/dot_c_mark_geometry.dart` - this widget only paints
// it, so the in-app mark and the app icon cannot drift apart.
//
// PAINTED AGAIN, NOT AN SVG. The previous mark was two tinted SVG halves
// because its rounded cuts were a shape to take from Figma verbatim. This mark
// is 26 circles with an opacity each: exact as constants, and a painter keeps
// the per-dot fade that a single srcIn tint cannot express per colour. It also
// cannot fail to load, which was the tinted SVG's silent failure mode.
//
// Which colour goes where (Quin, 2026-09-28):
// - [CiLogoTone.primary], the default, uses the ground's `mark` token: LIME on
//   ink, where the brand always aims to sit, and INK on light (mono on white).
// - [CiLogoTone.mono] uses the ground's text colour: white on ink, ink on
//   light. For one-colour / greyscale moments on a dark ground.
// The fade stays at EVERY size, top bars included (Quin chose it over a solid
// small-size cut that would avoid the spinner read).
//
// Screens that render above any CiSurface (Splash) must wrap themselves in
// one; there is deliberately no colour override here.
//
// Figma: LogoMark 1066:364, Tone = Primary | Mono on black | Mono on white.

import 'package:flutter/widgets.dart';

import '../../brand/dot_c_mark_geometry.dart';
import '../tokens/ci_colors.dart';

enum CiLogoTone {
  /// Lime on ink, ink on light. Everywhere by default.
  primary,

  /// The ground's text colour. One-colour moments only.
  mono,
}

class CiLogoMark extends StatelessWidget {
  const CiLogoMark({super.key, this.size = 44, this.tone = CiLogoTone.primary});

  /// The mark's box. The dots fill it edge to edge (Figma LogoMark bounds).
  final double size;

  final CiLogoTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = CiColors.of(context);
    final color = switch (tone) {
      CiLogoTone.primary => colors.mark,
      CiLogoTone.mono => colors.text,
    };
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: DotCMarkPainter(color)),
    );
  }
}

/// Paints [kMarkDots] fitted to the canvas by their tight bounds.
class DotCMarkPainter extends CustomPainter {
  const DotCMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final b = markBounds();
    final scale = size.shortestSide / b.side;
    final paint = Paint()..isAntiAlias = true;
    for (final d in kMarkDots) {
      paint.color = color.withValues(alpha: color.a * d.opacity);
      canvas.drawCircle(
        Offset((d.x - b.left) * scale, (d.y - b.top) * scale),
        d.r * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DotCMarkPainter old) => old.color != color;
}
