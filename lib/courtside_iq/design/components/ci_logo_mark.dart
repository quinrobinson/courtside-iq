// CiLogoMark — the Courtside IQ mark.
//
// A disc cut by a vertical channel and a horizontal channel across the right
// side, leaving three fields: a tall left form and two stacked right quadrants.
//
// AN SVG, NOT A PAINTER (changed 4.19e). It was drawn as a CustomPainter for
// two good reasons - it had to take a colour and scale to any size, because
// `assets/images/logo-mark.png` is solid black and vanishes on ink ground. Both
// still hold, and both are satisfied here: the path is vector, so it scales,
// and srcIn replaces its fill with the caller's colour. Same guarantees, no
// geometry of ours to drift.
//
// What changed is the mark itself. The refreshed mark (Figma Branding page,
// `923:3515`) moved the vertical channel to centre and widened it, and its cut
// terminations are ROUNDED. That rounding is deliberate, including the fact
// that it stops reading as rounded at small sizes - so the shape is taken from
// the design as-is rather than re-derived from constants here, where an
// approximation of the brand mark would quietly drift from the file.
//
// The old painter expressed the geometry as fractions (channel 0.055 wide at
// x 0.47). Those numbers do not describe this mark and are gone, not adjusted.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/ci_colors.dart';

class CiLogoMark extends StatelessWidget {
  const CiLogoMark({super.key, this.size = 44, this.color});

  final double size;

  /// Defaults to the current ground's text colour: white on ink, ink on light.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? CiColors.of(context).text;
    // A SizedBox at the ROOT, exactly as the painted version had, so the
    // widget keeps its intrinsic size - DotBurst spaces its first ring off
    // markSize, and call sites measure this box.
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/images/logo-mark.svg',
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }
}
