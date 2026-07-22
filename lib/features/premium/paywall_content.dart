// Paywall carousel content — Phase 4.16
//
// The three slides from 234:910 / 237:1354 / 237:889. Only the top block
// swipes - an example card, a category label, a headline and a line of body.
// The pricing, the button and the footer sit still beneath them.
//
// Pure data, so the copy is one place and can be checked. Each slide names a
// different reason to pay: the story, the trend, the single-game read.

import 'package:flutter/widgets.dart';

/// Which example a slide shows in its card, so the screen can render the right
/// mock without the content file importing widgets it does not need.
enum PaywallSlideArt { story, trend, insight }

class PaywallSlide {
  const PaywallSlide({
    required this.art,
    required this.label,
    required this.headline,
    required this.body,
  });

  final PaywallSlideArt art;

  /// The lime eyebrow above the headline: "WHAT'S WORKING", etc.
  final String label;
  final String headline;
  final String body;
}

const List<PaywallSlide> kPaywallSlides = [
  PaywallSlide(
    art: PaywallSlideArt.story,
    label: "WHAT'S WORKING",
    headline: 'Know what every game means',
    body: 'A clear read on what your player is doing well, after every few '
        'games.',
  ),
  PaywallSlide(
    art: PaywallSlideArt.trend,
    label: 'SCORING EFFICIENCY',
    headline: 'Watch growth take shape',
    body: 'See how the numbers move across a season, not just game to game.',
  ),
  PaywallSlide(
    art: PaywallSlideArt.insight,
    label: 'GAME INSIGHT · ELITE',
    headline: 'Every game, decoded',
    body: 'Every game turned into what clicked and what to work on next.',
  ),
];

/// Shown only when RevenueCat cannot return a live, localised price. The real
/// price always wins - these match the frame so a fallback still reads right
/// to a US parent, and are never used to CHARGE anyone (the store owns that).
const String kFallbackMonthlyPrice = r'$5.99';
const String kFallbackWeeklyPrice = r'$1.99';

/// The fine print under the button. Kept as a function because it names the
/// monthly price, which can be the live one.
String paywallLegalLine(String monthlyPrice) =>
    '7-day free trial, then $monthlyPrice/mo. Cancel anytime.';

/// Whichever plan should be selected when the paywall opens.
///
/// Monthly, always: it is the better value across a season and the only one
/// that carries the trial, so it is the frame's default and the honest one to
/// lead with.
const bool kPaywallDefaultsToMonthly = true;

@immutable
class PaywallCopy {
  const PaywallCopy._();

  static const monthlyTitle = 'Monthly';
  static const monthlySub = '7-day free trial';
  static const monthlyPer = 'per month';
  static const bestValue = 'Best value';

  static const weeklyTitle = 'Weekly';
  static const weeklySub = 'Billed weekly';
  static const weeklyPer = 'per week';

  static const cta = 'Start free trial';

  /// The CTA when the selected plan has no trial. "Start free trial" on the
  /// weekly plan would promise a trial it does not include.
  static const ctaNoTrial = 'Subscribe';

  static const restore = 'Restore';
  static const terms = 'Terms';
  static const privacy = 'Privacy';
}
