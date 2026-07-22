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

/// Shared card shell: fixed height, rounded, its own ground.
class _Card extends StatelessWidget {
  const _Card({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 132, trimmed from the frame's 155: the headline and body below it can
      // each run two lines, and at 155 the block overflowed its slot on a
      // 390pt screen.
      height: 132,
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
    final c = CiColors.of(context);
    return _Card(
      color: c.accentGoodWash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 15, color: c.text),
              const SizedBox(width: 6),
              Text("What's Working",
                  style: CiType.caption.copyWith(
                      color: c.text, fontWeight: CiWeight.semiBold)),
            ],
          ),
          const SizedBox(height: CiSpace.s3),
          Text(
            "Maya's scoring efficiency keeps climbing. She's finishing "
            'strong inside and picking smarter shots every game.',
            style: CiType.bodySm.copyWith(color: c.text, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return _Card(
      color: c.surfaceInvert,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('0.95',
                  style: CiType.h2.copyWith(
                      color: c.textInvert, fontWeight: CiWeight.bold)),
              const SizedBox(width: CiSpace.s2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accentGood,
                  borderRadius: CiRadius.chipR,
                ),
                child: Text('Rising +0.12',
                    style: CiType.caption.copyWith(
                        color: c.onAccent, fontWeight: CiWeight.semiBold)),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 44,
            child: CustomPaint(
              painter: _SparklinePainter(c.accentGood, c.borderStrong),
              size: const Size(double.infinity, 44),
            ),
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
    final c = CiColors.of(context);
    return _Card(
      color: c.accentGoodWash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: c.text),
              const SizedBox(width: 6),
              Text('Courtside IQ',
                  style: CiType.caption.copyWith(
                      color: c.text, fontWeight: CiWeight.semiBold)),
              const Spacer(),
              Text('SCORING EFFICIENCY · ELITE',
                  style: CiType.micro.copyWith(
                      color: c.textMuted, fontWeight: CiWeight.semiBold)),
            ],
          ),
          const SizedBox(height: CiSpace.s3),
          Text(
            "Maya's most efficient game of the season. She turned 14 shots "
            'into 22 points and kept attacking the rim.',
            style: CiType.bodySm.copyWith(color: c.text, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A rising line with dots. Deterministic - a marketing sparkline, not data.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.line, this.dot);

  final Color line;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    const points = [0.7, 0.55, 0.62, 0.4, 0.25];
    final step = size.width / (points.length - 1);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = step * i;
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        Offset(step * i, size.height * points[i]),
        2.5,
        Paint()..color = i == points.length - 1 ? line : dot,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => false;
}
