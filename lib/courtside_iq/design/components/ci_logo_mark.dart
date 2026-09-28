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
//
// TWO HALVES, TWO COLOURS (Release 2.1, 2026-09-28). The app icon went lime +
// white, and the in-app mark followed it. One tinted SVG can only be one
// colour, so the mark is split into `logo-mark-left.svg` and
// `logo-mark-right.svg` - the shipped paths, verbatim, on the same 173x173
// canvas, identical to the app icon's layers - and each half is tinted on its
// own. Figma: LogoMark component set 1066:364, Tone = Classic | Ink | Light.
//
// Which tone goes where (Quin, 2026-09-28):
// - [CiLogoTone.accent], the default: right half lime on EVERY ground. That is
//   Figma's Ink (white + lime) and Light (ink + lime) - the left half follows
//   the ground's text colour, so one tone covers both.
// - [CiLogoTone.classic]: right half at 50% of the left. Kept ONLY for the
//   small brand mark in a top bar - the home screen's "Courtside IQ" callout
//   and marks playing the same role (paywall and onboarding top bars).
//
// Lime on white is low contrast. Quin accepted that for now and chose it over
// a deeper lime; revisit it as its own piece of work, not here.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/ci_colors.dart';

/// The two halves. Both must exist, or that half vanishes silently -
/// ci_logo_mark_test.dart reads and parses each one.
const kLogoMarkLeftAsset = 'assets/images/logo-mark-left.svg';
const kLogoMarkRightAsset = 'assets/images/logo-mark-right.svg';

enum CiLogoTone {
  /// Right half in lime. Everywhere except top-bar brand marks.
  accent,

  /// Right half at 50% of the left. Top-bar brand marks only.
  classic,
}

class CiLogoMark extends StatelessWidget {
  const CiLogoMark({
    super.key,
    this.size = 44,
    this.color,
    this.tone = CiLogoTone.accent,
  });

  final double size;

  /// The LEFT half. Defaults to the current ground's text colour: white on
  /// ink, ink on light.
  final Color? color;

  final CiLogoTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = CiColors.of(context);
    final left = color ?? colors.text;
    final right = switch (tone) {
      CiLogoTone.accent => colors.accentGood,
      CiLogoTone.classic => left.withValues(alpha: 0.5),
    };
    // A SizedBox at the ROOT, exactly as the painted version had, so the
    // widget keeps its intrinsic size - DotBurst spaces its first ring off
    // markSize, and call sites measure this box. Both halves share the full
    // canvas, so stacking them re-assembles the mark with nothing to align.
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            kLogoMarkLeftAsset,
            colorFilter: ColorFilter.mode(left, BlendMode.srcIn),
          ),
          SvgPicture.asset(
            kLogoMarkRightAsset,
            colorFilter: ColorFilter.mode(right, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
