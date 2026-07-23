// Paywall — Phase 4.16
//
// Measured from 234:910 / 237:1354 / 237:889 and the four state frames
// (242:910 loading, 243:920 processing, 243:1386 error, 244:943 already
// premium).
//
// THE TOP SWIPES, THE BOTTOM DOES NOT. Three slides share one pricing block,
// one button and one footer. A parent comparing plans should not have the
// price move out from under them while they read the reasons to pay.
//
// PRICE FROM REVENUECAT, trial claim tied to the plan. The button says "Start
// free trial" only while a trial-bearing plan is selected; on weekly it says
// "Subscribe", because weekly has no trial and promising one would be the
// "Save to unlock" mistake in the one place it costs money.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_page_dots.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'paywall_content.dart';
import 'paywall_repository.dart';
import 'paywall_states.dart';
import 'subscription_management.dart';

class PaywallPage extends StatefulWidget {
  /// A REAL ROUTE. Pushing this as a bare MaterialPageRoute onto GoRouter's
  /// navigator - which is what showPaywall did first - is discarded on the
  /// next router rebuild, exactly as Change Password was. So it pushes by
  /// name, and the three entry points all reached a screen that vanished.
  static const String routeName = 'Paywall';
  static const String routePath = '/paywall';

  const PaywallPage({
    super.key,
    this.repository = const PaywallRepository(),
    this.onClose,
    this.onPurchased,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.onManage = openStoreSubscriptions,
  });

  final PaywallRepository repository;

  /// Dismiss without buying.
  final VoidCallback? onClose;

  /// Bought or already premium - the caller closes and refreshes.
  final VoidCallback? onPurchased;

  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  /// Opens the store's subscription page for an existing subscriber. Injected
  /// so a test can assert it fires without launching anything.
  final Future<void> Function() onManage;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

/// THE PAYWALL'S GUTTER IS 20, not the app's 24.
///
/// Measured from 234:910: the card, the copy, the dots, the plan radios and
/// the button all share x=20 (a 350-wide card on a 390 frame). At 24 the card
/// rendered 342 wide, so it no longer matched its own 350x155 export and got
/// scaled and cropped.
const double _gutter = 20;

/// The plan rows, from the frame's 82-tall blocks. They were ~69 with padding
/// alone, which is what made them feel cramped against the price.
const double _planRowHeight = 82;

enum _Plan { monthly, weekly }

class _PaywallPageState extends State<PaywallPage> {
  final _pages = PageController();
  int _slide = 0;

  PaywallOffer _offer = const PaywallOffer();
  _Plan _selected = _Plan.monthly;

  /// null while the offer loads; then ready. The purchase states are their
  /// own overlay so the whole screen does not flash between them.
  _Phase _phase = _Phase.loading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Already a subscriber? Do not sell to them - show the confirmation the
    // frame draws for exactly this.
    if (await widget.repository.isPremium()) {
      if (mounted) setState(() => _phase = _Phase.alreadyPremium);
      return;
    }
    final offer = await widget.repository.loadOffer();
    if (!mounted) return;
    // No plans loaded is the error state (243:1386, "We couldn't load
    // plans"), not a ready paywall with a dead button. Selling nothing is
    // worse than saying the store is unreachable.
    if (!offer.hasAny) {
      setState(() => _phase = _Phase.error);
      return;
    }
    setState(() {
      _offer = offer;
      // Fall to weekly only if monthly did not come back.
      _selected = offer.monthly != null ? _Plan.monthly : _Plan.weekly;
      _phase = _Phase.ready;
    });
  }

  PaywallPlan? get _selectedPlan =>
      _selected == _Plan.monthly ? _offer.monthly : _offer.weekly;

  String get _monthlyPrice => _offer.monthly?.price ?? kFallbackMonthlyPrice;
  String get _weeklyPrice => _offer.weekly?.price ?? kFallbackWeeklyPrice;

  Future<void> _buy() async {
    final plan = _selectedPlan;
    if (plan == null) return;

    setState(() => _phase = _Phase.processing);
    final outcome = await widget.repository.purchase(plan.packageId);
    if (!mounted) return;

    switch (outcome) {
      case PurchaseOutcome.purchased:
      case PurchaseOutcome.alreadyPremium:
        widget.onPurchased?.call();
      case PurchaseOutcome.cancelled:
        // Back to the paywall, no error. They chose to stop.
        setState(() => _phase = _Phase.ready);
      case PurchaseOutcome.failed:
        setState(() => _phase = _Phase.error);
    }
  }

  Future<void> _restore() async {
    setState(() => _phase = _Phase.processing);
    final outcome = await widget.repository.restore();
    if (!mounted) return;
    if (outcome == PurchaseOutcome.alreadyPremium) {
      widget.onPurchased?.call();
    } else {
      // Nothing to restore reads as a soft failure, not a hard error - most
      // people who tap Restore never bought.
      setState(() => _phase = _Phase.ready);
      _snack('Nothing to restore on this account.');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: switch (_phase) {
            _Phase.loading => const PaywallLoading(),
            _Phase.alreadyPremium => PaywallAlreadyPremium(
                onManage: widget.onManage,
                onDone: widget.onPurchased,
              ),
            _Phase.processing => const PaywallProcessing(),
            _Phase.error => PaywallError(
                onRetry: () => setState(() => _phase = _Phase.ready),
                onClose: widget.onClose,
              ),
            _Phase.ready => _buildPaywall(context, c),
          },
        );
      }),
    );
  }

  Widget _buildPaywall(BuildContext context, CiColors c) {
    return SafeArea(
      child: Column(
        children: [
          // ONE ROW: close at the left gutter, logo centred on the same
          // line. They were stacked, so the logo sat below the X and neither
          // lined up with anything.
          Padding(
            padding: const EdgeInsets.fromLTRB(
                _gutter, CiSpace.s2, _gutter, 0),
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CiLogoMark(size: 26),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _IconTap(
                      semanticLabel: 'Close',
                      onTap: widget.onClose,
                      child: Icon(Icons.close, size: 18, color: c.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // CENTRED IN WHAT IS LEFT, rather than packed under the header
          // with all the slack dumped above the pricing. That gave the card
          // no breathing room from the close/logo row and left a wide gap
          // under the dots; splitting the slack puts air on both sides.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 330,
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: kPaywallSlides.length,
                    onPageChanged: (i) => setState(() => _slide = i),
                    itemBuilder: (context, i) =>
                        _Slide(slide: kPaywallSlides[i]),
                  ),
                ),
                const SizedBox(height: CiSpace.s4),
                // LEFT, under the copy, at the content gutter.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _gutter),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CiPageDots(
                        count: kPaywallSlides.length, index: _slide),
                  ),
                ),
              ],
            ),
          ),
          Container(height: CiSpace.hairline, color: c.hairline),
          _PlanRow(
            title: PaywallCopy.monthlyTitle,
            sub: PaywallCopy.monthlySub,
            price: _monthlyPrice,
            per: PaywallCopy.monthlyPer,
            badge: PaywallCopy.bestValue,
            selected: _selected == _Plan.monthly,
            enabled: _offer.monthly != null,
            onTap: () => setState(() => _selected = _Plan.monthly),
          ),
          Container(height: CiSpace.hairline, color: c.hairline),
          _PlanRow(
            title: PaywallCopy.weeklyTitle,
            sub: PaywallCopy.weeklySub,
            price: _weeklyPrice,
            per: PaywallCopy.weeklyPer,
            selected: _selected == _Plan.weekly,
            enabled: _offer.weekly != null,
            onTap: () => setState(() => _selected = _Plan.weekly),
          ),
          Container(height: CiSpace.hairline, color: c.hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                _gutter, CiSpace.s5, _gutter, CiSpace.s3),
            child: CiButton(
              // Trial claim follows the plan, never the frame's fixed label.
              label: (_selectedPlan?.hasTrial ?? true)
                  ? PaywallCopy.cta
                  : PaywallCopy.ctaNoTrial,
              style: CiButtonStyle.lime,
              expand: true,
              onPressed: _offer.hasAny ? _buy : null,
            ),
          ),
          Text(paywallLegalLine(_monthlyPrice),
              style: CiType.caption.copyWith(color: c.textFaint)),
          const SizedBox(height: CiSpace.s3),
          _Footer(
            onRestore: _restore,
            onTerms: widget.onOpenTerms,
            onPrivacy: widget.onOpenPrivacy,
          ),
          const SizedBox(height: CiSpace.s4),
        ],
      ),
    );
  }
}

enum _Phase { loading, ready, processing, error, alreadyPremium }

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final PaywallSlide slide;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaywallSlideCard(art: slide.art),
          const SizedBox(height: CiSpace.s4),
          Row(
            children: [
              Icon(slide.icon, size: 15, color: c.accentGood),
              const SizedBox(width: 6),
              Text(slide.label,
                  style: CiType.caption.copyWith(
                      color: c.accentGood, fontWeight: CiWeight.semiBold)),
            ],
          ),
          const SizedBox(height: CiSpace.s3),
          Text(slide.headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CiType.h2
                  .copyWith(color: c.text, fontWeight: CiWeight.extraBold)),
          const SizedBox(height: CiSpace.s3),
          Text(slide.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CiType.body.copyWith(color: c.textMuted, height: 1.4)),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.title,
    required this.sub,
    required this.price,
    required this.per,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String sub;
  final String price;
  final String per;
  final String? badge;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: ColoredBox(
        // The SELECTED row carries a lighter ground (the frame's 390x82
        // #1a1a1a block). Without it the radio was the only thing marking
        // the choice.
        color: selected ? c.surfaceSunk : Colors.transparent,
        child: Semantics(
        button: enabled,
        selected: selected,
        label: '$title, $price $per',
        container: true,
        excludeSemantics: true,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            height: _planRowHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Row(
              children: [
                _Radio(selected: selected),
                const SizedBox(width: CiSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CiType.rowTitle.copyWith(
                                    color: c.text,
                                    fontWeight: CiWeight.semiBold)),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: CiSpace.s2),
                            _BestValue(label: badge!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(sub,
                          style:
                              CiType.caption.copyWith(color: c.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(price,
                        style: CiType.h4.copyWith(
                            color: c.text, fontWeight: CiWeight.bold)),
                    const SizedBox(height: 2),
                    Text(per,
                        style:
                            CiType.caption.copyWith(color: c.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? c.accentGood : Colors.transparent,
        border: selected ? null : Border.all(color: c.border, width: 1.5),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: c.bg, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

class _BestValue extends StatelessWidget {
  const _BestValue({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        // Outlined in the text colour, not filled. A dark fill on the dark
        // selected row made it disappear.
        color: Colors.transparent,
        border: Border.all(color: c.text),
        borderRadius: CiRadius.chipR,
      ),
      child: Text(label,
          style: CiType.caption.copyWith(color: c.text)),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({this.onRestore, this.onTerms, this.onPrivacy});

  final VoidCallback? onRestore;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    Widget link(String label, VoidCallback? onTap) => InkWell(
          onTap: onTap,
          child: Text(label,
              style: CiType.caption.copyWith(color: c.textMuted)),
        );
    Widget dot() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('·', style: CiType.caption.copyWith(color: c.textFaint)),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        link(PaywallCopy.restore, onRestore),
        dot(),
        link(PaywallCopy.terms, onTerms),
        dot(),
        link(PaywallCopy.privacy, onPrivacy),
      ],
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.semanticLabel,
    required this.child,
    this.onTap,
  });

  final String semanticLabel;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      // Bordered 40 square (the frame's IconButton, stroke #2e2e2e). A bare
      // glyph read as unstyled next to the logo.
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return InkWell(
          onTap: onTap,
          borderRadius: CiRadius.chipR,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: c.border),
              borderRadius: CiRadius.chipR,
            ),
            child: Center(child: child),
          ),
        );
      }),
    );
  }
}
