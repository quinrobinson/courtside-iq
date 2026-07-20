// Splash — Phase 4.9
//
// Measured from Screens / Splash 191:789: full-bleed ink, the dot burst filling
// the width, and a 100px logo mark at the centre.
//
// Painted, not an image. It replaces `assets/images/App_Load_d.png`, which was
// a fixed bitmap stretched with BoxFit.cover - so it distorted on any aspect
// ratio it was not drawn for. The burst is geometry, so it fits every screen.
//
// A NATIVE SPLASH RENDERS BEFORE THIS ONE. iOS has LaunchScreen.storyboard and
// Android its own; if their background is not #0F0F0F there is a visible flash
// on every cold start before Flutter boots. Invisible in debug, obvious on a
// real device.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Ink ground, so the status-bar icons go light. See CiSystemUi.
      value: CiSystemUi.onInk,
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // The mark is a fraction of the burst; the first ring then sits ONE ring
    // gap out from it, so the space around the mark matches the space between
    // rings. Deriving innerRadius from the mark size is what makes the whole
    // thing resize evenly on any device.
    final markSize = width * 0.20;
    final innerRadius = markSize / 2 + DotBurst.ringGapFor(width);

    return ColoredBox(
      // Not CiColors.of(context): this renders inside the router, above any
      // CiSurface, so it names its ground explicitly.
      color: CiColors.onInk.bg,
      child: Center(
        child: DotBurst(
          size: width,
          innerRadius: innerRadius,
          child: CiLogoMark(size: markSize, color: CiColors.onInk.text),
        ),
      ),
    );
  }
}
