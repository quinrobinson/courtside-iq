// Today promo banner — Phase 4.10b
//
// Measured from Premium - Upgrade Banner (327:1450) and Lapse / Downgrade
// (333:1717). Both are the SAME black card, differing only in copy and CTA
// colour, so this is one component with a purpose enum - the same shape as
// CheckEmailPage.
//
//   card     black (surfaceDeep), 98 tall, full bleed, sits between hero
//            and feed
//   emblem   white logo mark (dot burst dropped 2026-07-20, read as busy)
//   copy     title ExtraBold 16 white, subtitle Medium 13 muted
//   CTA      pill: lime "See plans" (upgrade) / orange "Renew" (lapse)
//
// DISPLAY AND ROUTING ONLY. The CTA opens the existing paywall. Nothing here
// reads or writes entitlement - which purpose to show is decided by the
// caller from a client-side RevenueCat read.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

enum TodayPromoPurpose {
  /// Never subscribed. Invites them in: "Unlock Premium", lime.
  upgrade,

  /// Was premium, now expired. Asks them back: "Your Premium has ended",
  /// orange - attention, not alarm, and never framed as a failure.
  lapse,
}

class TodayPromoBanner extends StatelessWidget {
  const TodayPromoBanner({
    super.key,
    required this.purpose,
    this.onTap,
    this.compact = false,
  });

  final TodayPromoPurpose purpose;
  final VoidCallback? onTap;

  /// The 60-tall strip from Player Profile — Locked (663:2584): no logo mark,
  /// tighter padding, and copy that names what is still visible.
  ///
  /// A variant rather than a second component. The profile hero is already
  /// 258 tall, so the full 98-tall card would push the tabs most of the way
  /// down the screen - which is why the frame designed a strip for this spot
  /// and not why it is a different banner.
  final bool compact;

  bool get _isUpgrade => purpose == TodayPromoPurpose.upgrade;

  String get _title =>
      _isUpgrade ? 'Unlock Premium' : 'Your Premium has ended';

  String get _subtitle {
    if (compact) {
      return _isUpgrade
          ? 'High-level stats only. Upgrade to unlock the rest.'
          : 'High-level stats only. Renew to unlock the rest.';
    }
    return _isUpgrade
        ? 'Trends, insights, and the full development story.'
        : 'Renew to keep trends, insights, and the full story.';
  }

  String get _cta => _isUpgrade ? 'See plans' : 'Renew';

  @override
  Widget build(BuildContext context) {
    // Ink ground: the card is black, so its text and mark resolve the ink
    // palette rather than the light feed's around it.
    return CiSurface.ink(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return ColoredBox(
          // surfaceDeep (#000000), a shade below the ink background so the
          // card reads as a distinct block, not part of the hero.
          color: c.surfaceDeep,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              CiSpace.screen,
              compact ? CiSpace.s3 : CiSpace.s5,
              compact ? CiSpace.s4 : CiSpace.screen,
              compact ? CiSpace.s3 : CiSpace.s5,
            ),
            child: Row(
              children: [
                // A premium mark, not the brand logo. The banner is about
                // the subscription, so the leading glyph should say premium
                // rather than say Courtside IQ - which every other surface
                // already does. Outline, to sit with the nav icons.
                //
                // Alternatives, one word each: Icons.workspace_premium (a
                // filled award badge) or Icons.star_outline.
                if (!compact) ...[
                  Icon(Icons.diamond_outlined, size: 28, color: c.text),
                  const SizedBox(width: CiSpace.s4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_title,
                          style: CiType.rowTitle.copyWith(
                              color: c.text,
                              fontWeight: compact
                                  ? CiWeight.semiBold
                                  : CiWeight.extraBold)),
                      const SizedBox(height: 2),
                      Text(_subtitle,
                          style: CiType.bodyXs.copyWith(color: c.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: CiSpace.s3),
                CiButton(
                  label: _cta,
                  // Lime invites, orange asks back. onAccent keeps the label
                  // ink on both, per the locked rule.
                  style: _isUpgrade
                      ? CiButtonStyle.lime
                      : CiButtonStyle.orange,
                  size: CiButtonSize.sm,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
