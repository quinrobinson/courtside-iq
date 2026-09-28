// Splash — Phase 4.9
//
// Measured from Screens / Splash 191:789: full-bleed ink and the logo mark at
// the centre, 128 on the 390 frame. Since the Dot-burst C (Quin, 2026-09-28)
// there is no DotBurst behind it: the mark is itself a burst, and the two
// competed.
//
// Painted, not an image. It replaces `assets/images/App_Load_d.png`, which was
// a fixed bitmap stretched with BoxFit.cover - so it distorted on any aspect
// ratio it was not drawn for. The mark is geometry, so it fits every screen.
//
// A NATIVE SPLASH RENDERS BEFORE THIS ONE. iOS has LaunchScreen.storyboard and
// Android its own; if their background is not #0F0F0F there is a visible flash
// on every cold start before Flutter boots. Invisible in debug, obvious on a
// real device.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';

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
    // A fraction of the width, so it keeps the frame's proportion on any
    // device: 128 / 390.
    final markSize = MediaQuery.sizeOf(context).width * (128 / 390);

    // CiSurface.ink, not CiColors.of(context): this renders inside the router,
    // above any CiSurface, so it names its ground explicitly - which is also
    // what makes the mark lime. statusBar stays false; the AnnotatedRegion
    // above already owns the status bar.
    return CiSurface.ink(
      child: Center(child: CiLogoMark(size: markSize)),
    );
  }
}
