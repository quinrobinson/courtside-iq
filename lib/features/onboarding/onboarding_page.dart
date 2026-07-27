// Onboarding — Phase 4.9
//
// Measured from Screens / Onboarding (Slide 1 · Promise) 248:950,
// (Slide 2 · Insights) 250:955 and (Slide 3 · Growth) 250:1287:
//
//   ground     #0F0F0F, ink
//   top        logo mark centred, "Skip" right
//   mockup     app-screen preview, fading out at its lower edge
//   title      h1, centred
//   body       Regular 16, muted, centred
//   indicator  active is a wide pill, inactive are dots
//   CTA        lime pill, full width
//   footer     "Already have an account? Sign in", Sign in in lime
//
// THREE SLIDES, NOT FOUR. v1 ran a four-page PageView; the 2.0 file has three.
// Not a port - a deliberate change in the design.
//
// The mockups are exported images. They depict a FICTIONAL player with
// fabricated stats and are static marketing artwork, not functioning UI, which
// is why they are not rebuilt from live components. They will drift as the
// real screens evolve: re-export from Figma when the underlying frames change.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_ambient_glow.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_page_dots.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;
}

const kOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    image: 'assets/images/onboarding/slide-1.png',
    title: 'More than a stat tracker',
    body:
        'Courtside IQ turns every game into a clear picture of how your player is developing.',
  ),
  OnboardingSlide(
    image: 'assets/images/onboarding/slide-2.png',
    title: 'Insights, not box scores',
    body:
        'Warm, plain-language coaching after every game, focused on how your player is growing.',
  ),
  OnboardingSlide(
    image: 'assets/images/onboarding/slide-3.png',
    title: 'Follow their growth',
    body:
        'Watch development unfold across the season, one game and one story at a time.',
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Skip and Get Started land in the same place. Onboarding is not a gate:
  /// a parent who already knows what the app does should not have to page
  /// through three slides to reach sign-in.
  void _continue() {
    context.pushNamed(
      UserAuthWidget.routeName,
    );
  }

  void _signIn() {
    context.pushNamed(
      UserAuthEmailWidget.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          return Scaffold(
            backgroundColor: c.bg,
            // The signature lime wash sits BEHIND everything, so onboarding does
            // not open on flat black. ONLY the top wash: the bottom one tinted
            // the zone where the capture fades into the dark, muddying the
            // blend, so it was dropped on device review. (The paywall keeps
            // both.)
            body: Stack(
              children: [
                const Positioned.fill(
                  child: CiAmbientGlow(
                    washes: [
                      CiGlowWash(cx: 0.10, cy: 0.22, radius: 0.82, alpha: 0.16),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _TopBar(onSkip: _continue),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: kOnboardingSlides.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (context, i) =>
                              _Slide(slide: kOnboardingSlides[i]),
                        ),
                      ),
                      // The indicator sat flush against the body copy. Spacing comes
                      // off the scale, not from nudging until it looks right.
                      const SizedBox(height: CiSpace.s6),
                      CiPageDots(
                        count: kOnboardingSlides.length,
                        index: _index,
                      ),
                      Padding(
                        // Top gap is s7 (32), matching the Figma frames' dots →
                        // CTA measure; it read 8pt tight at s6.
                        padding: const EdgeInsets.fromLTRB(
                          CiSpace.screen,
                          CiSpace.s7,
                          CiSpace.screen,
                          CiSpace.s4,
                        ),
                        child: CiButton(
                          label: 'Get Started',
                          style: CiButtonStyle.lime,
                          expand: true,
                          onPressed: _continue,
                        ),
                      ),
                      _SignInFooter(onTap: _signIn),
                      const SizedBox(height: CiSpace.s4),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CiSpace.screen,
        CiSpace.s3,
        CiSpace.s4,
        0,
      ),
      child: Row(
        children: [
          // Balances the Skip button so the mark sits truly centred.
          const SizedBox(width: 56),
          // CiSpace.s7, not a hand-picked 34: sizes come off the scale too.
          const Expanded(
            child: Center(child: CiLogoMark(size: CiSpace.s7)),
          ),
          GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Semantics(
              button: true,
              child: Padding(
                // Padded to a real touch target; the label alone is too short.
                padding: const EdgeInsets.symmetric(
                  vertical: CiSpace.s3,
                  horizontal: CiSpace.s3,
                ),
                child: Text(
                  'Skip',
                  style: CiType.body.copyWith(color: c.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      children: [
        // Sits the mockup below the top bar rather than tight against it.
        const SizedBox(height: CiSpace.s6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CiSpace.s5),
            // CLIP THE CAPTURE TO THE CARD'S CORNERS. The export bakes an
            // opaque ink background (alpha 255 everywhere) around the card,
            // which now carries its designed 6px outside border (#0F0F0F at
            // 60%), so the 320x430 mockup exports at 332x442 (996x1326 at 3x).
            // Left unclipped, those ink corners cover the glow and read as
            // black squares against the lit margins. Constrain to the
            // capture's own aspect so the box matches it exactly, then clip
            // the TOP corners at the border's outer radius so the ink comes
            // off and the glow shows around the card.
            child: Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(
                aspectRatio: 996 / 1326,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The border's outer arc is (26 + 6) * 3 = 96 on a
                    // 996-wide image, but clipping exactly there leaves a
                    // 1-2px ink fringe (the anti-aliased clip edge samples the
                    // ink just outside). 102 clips a hair INTO the border
                    // corner - near-ink over ink, so invisible - taking the
                    // fringe with it.
                    final radius = constraints.maxWidth * 102 / 996;
                    return ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Image.asset(
                            slide.image,
                            // fill (not cover): the box matches the capture
                            // aspect exactly, so fill maps 1:1 with no crop and
                            // the clip lands precisely on the card corners.
                            fit: BoxFit.fill,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                          // THE FADE, matching the Figma ScreenMockup/fade: an
                          // INK gradient painted OVER the capture, not a
                          // transparency mask, so it blends into the dark
                          // ground rather than letting the glow bleed through
                          // the lower edge. Clear until ~0.56, half at ~0.78,
                          // full ink at the base.
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      c.bg.withValues(alpha: 0),
                                      c.bg.withValues(alpha: 0),
                                      c.bg.withValues(alpha: 0.5),
                                      c.bg,
                                    ],
                                    stops: const [0, 0.558, 0.777, 1],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: CiSpace.s6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
          child: Column(
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: CiType.h1.copyWith(color: c.text),
              ),
              const SizedBox(height: CiSpace.s3),
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: CiType.body.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignInFooter extends StatelessWidget {
  const _SignInFooter({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      // container + excludeSemantics so this is ONE node a screen reader can
      // land on. "Sign in" is a TextSpan inside a rich string, not a widget of
      // its own, so without this the tappable target has no button semantics
      // and the label merges with the child text instead of replacing it.
      //
      // The label matches what is on screen, rather than describing it: a
      // screen reader user and a sighted user should hear and see the same
      // words.
      container: true,
      excludeSemantics: true,
      label: 'Already have an account? Sign in',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CiSpace.s3),
          child: Text.rich(
            TextSpan(
              style: CiType.bodySm.copyWith(color: c.textMuted),
              children: [
                const TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign in',
                  style: CiType.bodySm.copyWith(
                    color: c.accentGood,
                    fontWeight: CiWeight.semiBold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
