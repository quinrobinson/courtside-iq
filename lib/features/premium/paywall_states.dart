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
  final VoidCallback? onManage;

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
            const CiLogoMark(size: 40),
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
            Text("You have full access to every game's development story.",
                textAlign: TextAlign.center,
                style: CiType.body.copyWith(color: c.textMuted, height: 1.4)),
            const Spacer(),
            CiButton(
              label: 'Manage subscription',
              style: CiButtonStyle.secondary,
              expand: true,
              onPressed: onManage,
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

/// One carousel example card (350x155 in the frame).
class PaywallSlideCard extends StatelessWidget {
  const PaywallSlideCard({super.key, required this.art});

  final PaywallSlideArt art;

  @override
  Widget build(BuildContext context) {
    return switch (art) {
      PaywallSlideArt.story => const _StoryCard(),
      PaywallSlideArt.trend => const _TrendCard(),
      PaywallSlideArt.insight => const _InsightCard(),
    };
  }
}

/// Shared card shell: 155 tall on EVERY slide (the frame's ScreenMockup), so
/// the three cards cannot disagree in height as the carousel swipes.
///
/// TEXT INSIDE A CARD READS FROM THE LIGHT PALETTE, not the page's. The cards
/// sit on white or limeWash while the paywall is ink, so `CiColors.of(context)`
/// here returns WHITE text - which is what made the story and insight copy
/// invisible on device. CiColors.onLight is the ground the card actually has.
class _Card extends StatelessWidget {
  const _Card({required this.color, required this.child});

  final Color color;
  final Widget child;

  static const light = CiColors.onLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: double.infinity,
      padding: const EdgeInsets.all(CiSpace.s4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: CiRadius.sheetR,
      ),
      child: child,
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard();

  @override
  Widget build(BuildContext context) {
    const light = _Card.light;
    return _Card(
      color: light.accentGoodWash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 14, color: light.text),
              const SizedBox(width: 6),
              Text("What's Working",
                  style: CiType.caption.copyWith(
                      color: light.text, fontWeight: CiWeight.semiBold)),
            ],
          ),
          const SizedBox(height: CiSpace.s3),
          Text(
            "Maya's scoring efficiency keeps climbing. She's finishing "
            'strong inside and picking smarter shots every game.',
            style: CiType.bodySm.copyWith(color: light.text, height: 1.45),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  /// The x-axis the frame labels. Static, like the rest of the mock.
  static const _months = ['Apr 26', 'Apr 28', 'May 1', 'May 2', 'May 4'];

  @override
  Widget build(BuildContext context) {
    const light = _Card.light;
    return _Card(
      color: light.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('0.95',
                  style: CiType.statMd.copyWith(
                      color: light.text, fontWeight: CiWeight.light)),
              const SizedBox(width: CiSpace.s3),
              Flexible(
                child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: light.accentGood,
                  borderRadius: CiRadius.chipR,
                ),
                child: Text('Rising +0.12',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CiType.micro.copyWith(
                        color: light.onAccent,
                        fontWeight: CiWeight.semiBold)),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 38,
            child: CustomPaint(
              painter: _TrendPainter(
                line: light.text,
                end: light.accentGood,
              ),
              size: const Size(double.infinity, 38),
            ),
          ),
          const SizedBox(height: 6),
          // Equal shares rather than spaceBetween: five labels at their
          // natural width overflow a 360pt card.
          Row(
            children: [
              for (final m in _months)
                Expanded(
                  child: Text(m,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: CiType.micro.copyWith(color: light.textMuted)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    const light = _Card.light;
    return _Card(
      color: light.accentGoodWash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 13, color: light.text),
              const SizedBox(width: 6),
              Text('Courtside IQ',
                  style: CiType.micro.copyWith(
                      color: light.text, fontWeight: CiWeight.semiBold)),
              const Spacer(),
              // INK, not muted grey. The frame sets this Bold 10 at #0f0f0f -
              // it is a rating, and greying it made it read as a caption.
              Flexible(
                child: Text('SCORING EFFICIENCY · ELITE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: CiType.micro.copyWith(
                        color: light.text, fontWeight: CiWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: CiSpace.s3),
          Text(
            "Maya's most efficient game of the season. She turned 14 shots "
            'into 22 points and kept attacking the rim instead of settling.',
            style: CiType.bodySm.copyWith(color: light.text, height: 1.45),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A DOTTED line of small ink dots, larger ink dots at the readings, and a
/// single lime dot at the end (the frame builds it from ~40 ellipses).
///
/// Dotted, not a solid stroke: the solid lime line it replaced read as a
/// chart with a trend drawn ON it, when the point is the last reading.
class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.line, required this.end});

  final Color line;
  final Color end;

  /// Five readings, dipping then climbing, as the frame draws.
  static const _points = [0.62, 0.78, 0.70, 0.34, 0.12];

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()..color = line;
    final step = size.width / (_points.length - 1);

    Offset at(double t) {
      final i = (t * (_points.length - 1)).clamp(0, _points.length - 1.0001);
      final lo = i.floor();
      final f = i - lo;
      final y = _points[lo] + (_points[lo + 1] - _points[lo]) * f;
      return Offset(size.width * t, size.height * y);
    }

    // The trail: small dots every ~6px along the interpolated path.
    final dots = (size.width / 6).floor();
    for (var i = 0; i <= dots; i++) {
      canvas.drawCircle(at(i / dots), 1.5, ink);
    }
    // The readings themselves, slightly larger.
    for (var i = 0; i < _points.length - 1; i++) {
      canvas.drawCircle(
          Offset(step * i, size.height * _points[i]), 2.0, ink);
    }
    // The latest reading, in lime - the one the card is about.
    canvas.drawCircle(
      Offset(size.width, size.height * _points.last),
      4,
      Paint()..color = end,
    );
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.line != line || old.end != end;
}
