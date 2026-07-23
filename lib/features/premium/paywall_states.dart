// Paywall states and slide art — Phase 4.16
//
// Loading (242:910), Processing (243:920), Error (243:1386) and Already
// Premium (244:943), plus the three example cards the carousel swipes.
//
// THE CARDS ARE MARKETING MOCKS, not live data. They illustrate what premium
// looks like, so they are built from static content rather than a real
// player - a paywall shown to a parent with no games still has to show what
// the feature does.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'paywall_content.dart';

class PaywallLoading extends StatelessWidget {
  const PaywallLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CiLogoMark(size: 32),
          const SizedBox(height: CiSpace.s5),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.accentGood),
          ),
        ],
      ),
    );
  }
}

class PaywallProcessing extends StatelessWidget {
  const PaywallProcessing({super.key});

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: c.accentGood),
          ),
          const SizedBox(height: CiSpace.s6),
          Text('Completing your purchase',
              style: CiType.rowTitle
                  .copyWith(color: c.text, fontWeight: CiWeight.semiBold)),
          const SizedBox(height: CiSpace.s2),
          Text('This only takes a moment.',
              style: CiType.bodySm.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}

class PaywallError extends StatelessWidget {
  const PaywallError({
    super.key,
    this.title = "We couldn't load plans",
    this.message = 'Check your connection and try again.',
    this.onRetry,
    this.onClose,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: IconButton(
                icon: Icon(Icons.close, size: 22, color: c.text),
                onPressed: onClose,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(CiSpace.screen),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 28, color: c.accentEnergy),
                  const SizedBox(height: CiSpace.s4),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: CiType.h4.copyWith(
                          color: c.text, fontWeight: CiWeight.bold)),
                  const SizedBox(height: CiSpace.s2),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: CiType.bodySm.copyWith(color: c.textMuted)),
                  const SizedBox(height: CiSpace.s6),
                  CiButton(
                    label: 'Try again',
                    style: CiButtonStyle.lime,
                    onPressed: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaywallAlreadyPremium extends StatelessWidget {
  const PaywallAlreadyPremium({super.key, this.onManage, this.onDone});

  /// Opens the store's subscription management. Apple and Google own
  /// cancellation, so "Manage" cannot happen in-app - it deep-links out.
  final Future<void> Function()? onManage;

  /// Leaves the paywall. A premium parent who landed here by a stale banner
  /// needs a way back that is not the store.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(CiSpace.screen),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.close, size: 22, color: c.text),
                onPressed: onDone,
              ),
            ),
            const Spacer(),
            // THE DOT BURST, which was missing entirely. 244:943 centres a
            // 50pt mark in a 220 burst - the same pairing reset_successful
            // and check_email already use, so this is the app's celebratory
            // mark rather than a one-off.
            const DotBurst(size: 220, child: CiLogoMark(size: 50)),
            const SizedBox(height: CiSpace.s6),
            Text('PREMIUM ACTIVE',
                style: CiType.caption.copyWith(
                    color: c.accentGood, fontWeight: CiWeight.semiBold)),
            const SizedBox(height: CiSpace.s3),
            Text("You're on Premium",
                textAlign: TextAlign.center,
                style: CiType.h1
                    .copyWith(color: c.text, fontWeight: CiWeight.extraBold)),
            const SizedBox(height: CiSpace.s3),
            // 300 WIDE, from the frame. At full width it ran as one long
            // line; the frame's narrower measure is what breaks it over two
            // and gives the block its shape.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                  "You have full access to every game's development story.",
                  textAlign: TextAlign.center,
                  style: CiType.body.copyWith(color: c.textMuted, height: 1.4)),
            ),
            const Spacer(),
            CiButton(
              label: 'Manage subscription',
              style: CiButtonStyle.secondary,
              expand: true,
              onPressed: onManage == null ? null : () => onManage!(),
            ),
            const SizedBox(height: CiSpace.s3),
            TextButton(
              onPressed: onDone,
              child: Text('Done',
                  style: CiType.body.copyWith(color: c.textMuted)),
            ),
            const SizedBox(height: CiSpace.s4),
          ],
        ),
      ),
    );
  }
}

/// One carousel example card, EXPORTED FROM FIGMA (726:3127 / 726:3290 /
/// 726:3424 at 3x).
///
/// These are marketing mockups: they never change with data, are never
/// themed, and nobody interacts with them. Rebuilding them as widgets meant
/// approximating a design that already exists pixel-perfect, and every review
/// found another detail off - the chart's dots, the text colour, the vertical
/// rhythm. An image ends that loop.
///
/// RE-EXPORT IF THE FRAMES CHANGE. That is the cost of this choice, and it is
/// the reason it is only made for art, never for UI a parent reads data from.
class PaywallSlideCard extends StatelessWidget {
  const PaywallSlideCard({super.key, required this.art});

  final PaywallSlideArt art;

  /// The frame's card size. The asset is 3x this.
  static const _w = 350.0;
  static const _h = 155.0;

  String get _asset => switch (art) {
        PaywallSlideArt.story => 'assets/images/paywall/slide_story.png',
        PaywallSlideArt.trend => 'assets/images/paywall/slide_trend.png',
        PaywallSlideArt.insight => 'assets/images/paywall/slide_insight.png',
      };

  /// What a screen reader says instead of describing a picture it cannot
  /// read. Each card IS the argument its slide is making.
  String get _semantics => switch (art) {
        PaywallSlideArt.story =>
          "An example insight: Maya's scoring efficiency keeps climbing.",
        PaywallSlideArt.trend =>
          'An example trend chart showing scoring efficiency rising to 0.95.',
        PaywallSlideArt.insight =>
          'An example game insight rated Elite for scoring efficiency.',
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semantics,
      image: true,
      container: true,
      excludeSemantics: true,
      // NO ClipRRect. The frame clips its own content at radius 18, so the
      // export already carries rounded corners - clipping again at the
      // sheet's 14 cut into them and left the corners uneven.
      //
      // ASPECT RATIO, not a fixed height. At a forced 155 with BoxFit.cover
      // the artwork was scaled up and cropped, which ate the padding under
      // the copy and made it sit low in the card.
      child: AspectRatio(
        aspectRatio: _w / _h,
        child: Image.asset(
          _asset,
          // cacheWidth bounds the decode: the source is 1050 wide and would
          // otherwise sit in memory at full size for a 350pt slot.
          cacheWidth: (_w * 3).round(),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
