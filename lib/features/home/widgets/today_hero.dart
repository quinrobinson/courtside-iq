// Today hero — Phase 4.10a
//
// Measured from Screens / Today 65:8 and Today - Empty (No Players) 204:764:
//
//   ground    ink, with two soft lime glows behind everything
//   brand     LogoMark 20 + "Courtside IQ" SemiBold 15, bell + avatar right
//   content   DotGauge 120 beside a column: "Growth IQ" SemiBold 13 muted,
//             the hero line Light 22, then the stat chips
//   dots      active pill 18x6, inactive 6x6
//   height    296 with content, 150 without
//
// TWO FORMS, BOTH FROM APPROVED FRAMES. The full hero carries the Growth IQ
// block; the reduced one is the brand bar alone, which is exactly what the
// Empty frame shows. So a user whose players have no games yet gets the
// reduced hero rather than an invented placeholder or an empty gap.
//
// THE HEADER IS ABOUT GROWTH, AND GROWTH NEEDS GAMES. Which players appear
// here is decided by headerSnapshots() in lib/courtside_iq/today_snapshot.dart,
// not here: a player without a computable Growth IQ is absent rather than
// shown with a zero, because a zero would be a claim about the child.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_page_dots.dart';
import '/courtside_iq/design/components/dot_gauge.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/today_snapshot.dart';

class TodayHero extends StatefulWidget {
  const TodayHero({
    super.key,
    required this.snapshots,
    this.userName,
    this.userPhotoUrl,
    this.onNotifications,
    this.onProfile,
    this.onPlayerTap,
  });

  /// Already filtered and ordered by [headerSnapshots]. Empty renders the
  /// reduced form.
  final List<TodaySnapshot> snapshots;

  final String? userName;
  final String? userPhotoUrl;

  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  /// Tapping the Growth IQ block opens that player.
  final ValueChanged<TodaySnapshot>? onPlayerTap;

  @override
  State<TodayHero> createState() => _TodayHeroState();
}

class _TodayHeroState extends State<TodayHero> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TodayHero old) {
    super.didUpdateWidget(old);
    // A player dropping out of the header - deleted, or a refresh that
    // recomputed scores - must not strand the page index past the end.
    if (_index >= widget.snapshots.length && widget.snapshots.isNotEmpty) {
      _index = widget.snapshots.length - 1;
      _controller.jumpToPage(_index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const c = CiColors.onInk;
    final hasContent = widget.snapshots.isNotEmpty;

    return ColoredBox(
      color: c.bg,
      child: Stack(
        children: [
          // Two soft lime washes, matching glow-a and glow-b in the frame.
          // Painted rather than exported: they scale with the device and take
          // the accent colour rather than baking it into pixels.
          const Positioned.fill(child: _HeroGlow()),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: CiSpace.s5),
                _BrandRow(
                  userName: widget.userName,
                  userPhotoUrl: widget.userPhotoUrl,
                  onNotifications: widget.onNotifications,
                  onProfile: widget.onProfile,
                ),
                if (!hasContent)
                  const SizedBox(height: CiSpace.s9)
                else ...[
                  const SizedBox(height: CiSpace.s5),
                  SizedBox(
                    height: 120,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.snapshots.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => _GrowthBlock(
                        snapshot: widget.snapshots[i],
                        onTap: widget.onPlayerTap == null
                            ? null
                            : () => widget.onPlayerTap!(widget.snapshots[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: CiSpace.s5),
                  CiPageDots(
                    count: widget.snapshots.length,
                    index: _index,
                    activeColor: c.text,
                    // Not textFaint: on the glow the faint grey disappears.
                    inactiveColor: c.textMuted,
                  ),
                  const SizedBox(height: CiSpace.s7),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The lime wash behind the hero.
class _HeroGlow extends StatelessWidget {
  const _HeroGlow();

  @override
  Widget build(BuildContext context) {
    const accent = CiColors.onInk;
    return CustomPaint(painter: _GlowPainter(accent.accentGood));
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Positions as fractions of the frame, so the wash sits the same way on
    // any device rather than drifting on a wider screen.
    void glow(Offset centre, double radius, double alpha) {
      final rect = Rect.fromCircle(center: centre, radius: radius);
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: alpha * 0.3),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(rect),
      );
    }

    // glow-a: up and left, behind the brand row.
    glow(Offset(size.width * 0.0, size.height * 0.2), size.width * 0.80, 0.16);
    // glow-b: down and right, behind the gauge.
    glow(Offset(size.width * 0.87, size.height * 1.1), size.width * 0.67, 0.10);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.color != color;
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({
    this.userName,
    this.userPhotoUrl,
    this.onNotifications,
    this.onProfile,
  });

  final String? userName;
  final String? userPhotoUrl;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    const c = CiColors.onInk;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.s5),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            CiLogoMark(size: 20, color: c.text),
            const SizedBox(width: CiSpace.s2),
            Text('Courtside IQ',
                style: CiType.rowLabel.copyWith(
                    color: c.text, fontWeight: CiWeight.semiBold)),
            const Spacer(),
            CiIconButton(
              icon: Icons.notifications_none,
              onDark: true,
              semanticLabel: 'Notifications',
              onPressed: onNotifications,
            ),
            const SizedBox(width: CiSpace.s3),
            CiAvatar(
              name: userName ?? '',
              imageUrl: userPhotoUrl,
              onTap: onProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Growth IQ runs 40..99, never 0..100. Feeding the raw score to a 0..1 gauge
/// would draw a nearly empty ring for a score of 45, which is a real result
/// and should not look like a failure.
double _gaugeValue(int score) {
  const min = 40.0;
  const max = 99.0;
  return ((score - min) / (max - min)).clamp(0.0, 1.0);
}

class _GrowthBlock extends StatelessWidget {
  const _GrowthBlock({required this.snapshot, this.onTap});

  final TodaySnapshot snapshot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const c = CiColors.onInk;
    final ppg = snapshot.pointsPerGameLabel;
    final delta = snapshot.growthIqDelta;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CiSpace.s5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DotGauge(
              size: 120,
              // The gauge takes 0..1. Growth IQ runs 40..99, so a raw /100
              // would leave the ring looking barely started at a genuinely
              // good score. Map the real range onto the full sweep.
              value: _gaugeValue(snapshot.growthIq!),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.growthIq}',
                      style: CiType.h2.copyWith(
                          color: c.text, fontWeight: CiWeight.light)),
                  if (snapshot.trendLabel != null)
                    Text(snapshot.trendLabel!,
                        style: CiType.caption.copyWith(color: c.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: CiSpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Growth IQ',
                      style: CiType.rowLabel.copyWith(
                          color: c.textMuted, fontWeight: CiWeight.semiBold)),
                  const SizedBox(height: CiSpace.s2),
                  Expanded(
                    child: Text(
                      // Falls back to the player's name rather than an empty
                      // gap: the AI headline can be absent, but the block
                      // still has to say who it is about.
                      snapshot.headline ?? snapshot.displayName,
                      style: CiType.heroLine.copyWith(color: c.text),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (ppg != null) ...[
                        CiBadge(label: ppg, tone: CiBadgeTone.neutral),
                        const SizedBox(width: CiSpace.s2),
                      ],
                      if (delta != null)
                        CiBadge.delta(value: delta.toDouble()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
