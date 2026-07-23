// Auth Landing — Phase 4.9
//
// Measured from Screens / Auth Landing 251:965:
//
//   ground   #0F0F0F, ink
//   back     40x40 IconButton, radius 6, #2E2E2E border, top 52
//   burst    DotBurst centred, 44x44 logo mark at its centre
//   title    "Get started" ExtraBold 34, 104% leading, centred, top 320
//   sub      Regular 16, muted, centred, 330 wide
//   OAuth    white pill h48 x2, 19px icon, 10px gap, tops 456 / 520
//   divider  two 150px hairlines with a faint "or", top 600
//   email    lime pill h48, INK label, top 624
//   legal    Regular 13, faint, centred, 300 wide, top 790
//
// BEHAVIOUR CARRIED OVER FROM THE V1 SCREEN. Each of these is invisible in the
// design and would have been silently dropped by building from the frame alone:
//
//   - Apple is HIDDEN ON ANDROID. v1 renders an empty Container there. An
//     Apple button on Android is a dead end.
//   - OAuth navigates with goNamedAuth, which REPLACES the stack, so back does
//     not return to this screen once signed in. Email uses pushNamed, which
//     keeps it, so back from the email form returns here. That difference is
//     deliberate.
//   - prepareAuthEvent() runs before every OAuth call. Without it the router
//     refreshes mid-flow and the navigation below never happens - the exact
//     bug that made the email sign-in button look dead.
//   - The legal text is really tappable, with real destinations.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Apple's standard EULA, which is what v1 links "Terms of Service" to.
const kTermsUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const kPrivacyUrl = 'https://www.courtsideiq.app/policy';

class AuthLandingPage extends StatefulWidget {
  const AuthLandingPage({super.key, this.isAndroidOverride});

  /// Test seam only. Null means ask the real platform.
  final bool? isAndroidOverride;

  @override
  State<AuthLandingPage> createState() => _AuthLandingPageState();
}

class _AuthLandingPageState extends State<AuthLandingPage> {
  bool _busy = false;

  bool get _isAndroid =>
      widget.isAndroidOverride ?? Theme.of(context).platform == TargetPlatform.android;

  Future<void> _oauth(Future<dynamic> Function() signIn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // Suppresses the router refresh the auth-state change would otherwise
      // fire mid-flow, which would interrupt the navigation below.
      GoRouter.of(context).prepareAuthEvent();
      final user = await signIn();
      if (user == null || !mounted) return;

      // goNamedAuth REPLACES the stack: once signed in, back must not return
      // to this screen. The email button below deliberately pushes instead.
      context.goNamedAuth(
        HomeWidget.routeName,
        context.mounted,
        extra: <String, dynamic>{
          '__transition_info__': const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 400),
          ),
        },
      );
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  void _openEmailAuth() {
    // pushNamed, not goNamed: back from the email form should land here.
    context.pushNamed(
      UserAuthEmailWidget.routeName,
      extra: <String, dynamic>{
        '__transition_info__': const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 400),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: CiSpace.s3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CiIconButton(
                        icon: Icons.chevron_left,
                        onDark: true,
                        semanticLabel: 'Back',
                        onPressed: () => context.pushNamed(
                          OnBoardWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 400),
                            ),
                          },
                        ),
                      ),
                    ),
                    const Center(
                      // 220 to match the frame's burst. The mark is 50 rather
                      // than the frame's 44: at 44 it read as lost inside the
                      // burst on device, at 54 it was heavy. Tuned on device
                      // 2026-07-19, deliberate deviation from the frame.
                      child: DotBurst(
                        size: 220,
                        markSize: 50,
                        child: CiLogoMark(size: 50),
                      ),
                    ),
                    const SizedBox(height: CiSpace.s6),
                    Text('Get started',
                        textAlign: TextAlign.center,
                        style: CiType.h1.copyWith(color: c.text)),
                    const SizedBox(height: CiSpace.s3),
                    Text(
                      "Track your player's development, game by game.",
                      textAlign: TextAlign.center,
                      style: CiType.body.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: CiSpace.s8),

                    // Apple is absent on Android, not disabled. v1 renders an
                    // empty Container here.
                    if (!_isAndroid) ...[
                      CiButton(
                        label: 'Continue with Apple',
                        icon: Icons.apple,
                        expand: true,
                        onPressed: _busy
                            ? null
                            : () => _oauth(
                                () => authManager.signInWithApple(context)),
                      ),
                      const SizedBox(height: CiSpace.s4),
                    ],
                    CiButton(
                      label: 'Continue with Google',
                      // Monochrome. The frame shows the multi-colour Google
                      // mark, which would need a bundled asset; v1 had the
                      // same limitation. Sized to the 19px in the design.
                      leading: FaIcon(FontAwesomeIcons.google,
                          size: 19, color: CiColors.onInk.textInvert),
                      expand: true,
                      onPressed: _busy
                          ? null
                          : () => _oauth(
                              () => authManager.signInWithGoogle(context)),
                    ),
                    const SizedBox(height: CiSpace.s6),
                    const _OrDivider(),
                    const SizedBox(height: CiSpace.s6),
                    CiButton(
                      label: 'Continue with Email',
                      style: CiButtonStyle.lime,
                      expand: true,
                      onPressed: _busy ? null : _openEmailAuth,
                    ),
                    const SizedBox(height: CiSpace.s10),
                    const _LegalText(),
                    const SizedBox(height: CiSpace.s8),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Row(
      children: [
        Expanded(child: Container(height: CiSpace.hairline, color: c.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.s4),
          child: Text('or', style: CiType.bodySm.copyWith(color: c.textFaint)),
        ),
        Expanded(child: Container(height: CiSpace.hairline, color: c.border)),
      ],
    );
  }
}

/// Both destinations are real and match v1. These are the links an app store
/// review looks for, so they must stay tappable.
class _LegalText extends StatefulWidget {
  const _LegalText();

  @override
  State<_LegalText> createState() => _LegalTextState();
}

class _LegalTextState extends State<_LegalText> {
  final _terms = TapGestureRecognizer();
  final _privacy = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _terms.onTap = () => launchURL(kTermsUrl);
    _privacy.onTap = () => launchURL(kPrivacyUrl);
  }

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final base = CiType.bodyXs.copyWith(color: c.textFaint);
    final link = base.copyWith(
      color: c.textMuted,
      decoration: TextDecoration.underline,
      decorationColor: c.textMuted,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
              text: 'Terms of Service', style: link, recognizer: _terms),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: link, recognizer: _privacy),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
