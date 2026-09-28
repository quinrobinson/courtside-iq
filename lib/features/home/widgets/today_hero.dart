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

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_page_dots.dart';
import '/courtside_iq/design/components/dot_gauge.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/growth_iq.dart';
import '/courtside_iq/today_snapshot.dart';
import 'today_skeleton.dart';

class TodayHero extends StatefulWidget {
  const TodayHero({
    super.key,
    required this.snapshots,
    this.loading = false,
    this.userName,
    this.userPhotoUrl,
    this.onProfile,
    this.onPlayerTap,
    this.onAboutGrowthIq,
  });

  /// While true, the content region is a grey skeleton. The brand bar stays
  /// real - the logo and profile do not depend on the pending data.
  final bool loading;

  /// Already filtered and ordered by [headerSnapshots]. Empty renders the
  /// reduced form.
  final List<TodaySnapshot> snapshots;

  final String? userName;
  final String? userPhotoUrl;

  final VoidCallback? onProfile;

  /// Tapping the Growth IQ block opens that player.
  final ValueChanged<TodaySnapshot>? onPlayerTap;

  /// Tapping the GAUGE ITSELF explains the score instead of navigating.
  ///
  /// The entry point the frame specifies: "Today or Player Profile, tap the
  /// Growth IQ gauge". A number a parent cannot interrogate is a number they
  /// have to take on faith, and this one is about their child.
  final VoidCallback? onAboutGrowthIq;

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

    // DECLARES the ground rather than only painting it. CiBadge, CiAvatar and
    // CiIconButton all resolve their colours from context, so without this
    // they read the ambient LIGHT palette and render ink-on-ink - which is
    // exactly what put black text inside the ghost tag on a dark hero.
    // Painting c.bg by hand is not the same as being on that ground.
    return CiSurface.ink(
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
                  onProfile: widget.onProfile,
                ),
                if (widget.loading)
                  const TodayHeroSkeleton()
                else if (!hasContent)
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
                        onGaugeTap: widget.onAboutGrowthIq,
                      ),
                    ),
                  ),
                  // Figma: the 20 gap plus the dots row's own 4 top padding.
                  const SizedBox(height: CiSpace.s6),
                  CiPageDots(
                    count: widget.snapshots.length,
                    index: _index,
                    activeColor: c.text,
                    // White at 30%, as the frame has it. Not textFaint: on
                    // the glow the faint grey disappears.
                    inactiveColor: c.text.withValues(alpha: 0.3),
                  ),
                  // The hero's 28 bottom padding in the frame.
                  const SizedBox(height: 28),
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

/// The account button, top-right of the hero. Measured from 65:8: a 40 rounded
/// square (radius 6), a translucent white fill (white at 8% - the "lighter
/// grey" on ink), a 1px white border, white content.
///
/// With a name it shows one or two initials. With NONE - the common case,
/// since the name lives in public.users and may be unset - it shows a settings
/// glyph, because the button taps into the account. This REPLACES the initials
/// fallback's "?", which read as a broken avatar on a white box.
class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.name, this.onTap});

  final String? name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const c = CiColors.onInk;
    final trimmed = (name ?? '').trim();
    final initials = trimmed.isEmpty ? null : CiAvatar.initialsOf(trimmed);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: 'Account',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.text.withValues(alpha: 0.08),
            borderRadius: CiRadius.chipR,
            // White at 16%, per 65:8 - a faint edge, NOT the solid white I had.
            border: Border.all(color: c.text.withValues(alpha: 0.16)),
          ),
          child: Center(
            child: initials == null
                ? Icon(Icons.settings_outlined, size: 20, color: c.text)
                : Text(
                    initials,
                    style: CiType.rowLabel.copyWith(
                      color: c.text,
                      fontWeight: CiWeight.extraBold,
                      height: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Positions as fractions of the frame, so the wash sits the same way on
    // any device rather than drifting on a wider screen. Values are Figma's
    // glow-a (88:209) and glow-b (88:210) on the 390x296 Today hero, exactly:
    // centre, radius and every stop, rebuilt 2026-09-28 from Quin's edit.
    void glow(
      Offset centre,
      double radius,
      List<double> alphas,
      List<double> stops,
    ) {
      final rect = Rect.fromCircle(center: centre, radius: radius);
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [for (final a in alphas) color.withValues(alpha: a)],
            stops: stops,
          ).createShader(rect),
      );
    }

    // glow-a: up and left, behind the brand row. Centre (60, 60), r 310.
    glow(
      Offset(size.width * 60 / 390, size.height * 60 / 296),
      size.width * 310 / 390,
      const [0.15, 0.09, 0.04, 0.01, 0, 0],
      const [0, 0.30, 0.55, 0.74, 0.88, 1],
    );
    // glow-b: down and right, behind the gauge. Centre (400, 330), r 260.
    glow(
      Offset(size.width * 400 / 390, size.height * 330 / 296),
      size.width * 260 / 390,
      const [0.08, 0.04, 0.01, 0, 0],
      const [0, 0.40, 0.66, 0.86, 1],
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.color != color;
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({this.userName, this.userPhotoUrl, this.onProfile});

  final String? userName;
  final String? userPhotoUrl;
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
            CiLogoMark(size: 20, color: c.text, tone: CiLogoTone.classic),
            const SizedBox(width: CiSpace.s2),
            Text(
              'Courtside IQ',
              style: CiType.rowLabel.copyWith(
                color: c.text,
                fontWeight: CiWeight.semiBold,
              ),
            ),
            const Spacer(),
            // No notifications bell: the app has no alerts feature, so it was a
            // control that did nothing. Removed rather than left inert.
            _AccountAvatar(name: userName, onTap: onProfile),
          ],
        ),
      ),
    );
  }
}

/// Growth IQ runs 40..99, never 0..100. Feeding the raw score to a 0..1 gauge
class _GrowthBlock extends StatelessWidget {
  const _GrowthBlock({required this.snapshot, this.onTap, this.onGaugeTap});

  final TodaySnapshot snapshot;
  final VoidCallback? onTap;
  final VoidCallback? onGaugeTap;

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
            // The gauge is its own tap target, nested inside the block's. It
            // wins the gesture arena, so tapping the ring explains the score
            // while tapping anywhere else still opens the player.
            DotGaugeTapTarget(
              onTap: onGaugeTap,
              child: DotGauge(
                size: 120,
                // The gauge takes 0..1. Growth IQ runs 40..99, so a raw /100
                // would leave the ring looking barely started at a genuinely
                // good score. Map the real range onto the full sweep.
                value: growthIqGaugeValue(snapshot.growthIq!),
                // The score with its trend word under it, as the frame has it
                // (Quin, 2026-09-28: build Today as designed). The delta sits
                // to the right as plain text.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.growthIq}',
                      style: CiType.statSm.copyWith(color: c.text),
                    ),
                    if (snapshot.trend != null) ...[
                      const SizedBox(height: 1.5),
                      Text(
                        growthTrendWord(snapshot.trend!),
                        style: CiType.micro.copyWith(color: c.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // 18, the frame's gap. Off the scale on purpose; the Development
            // view's gauge uses the same 18.
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMES THE PLAYER on every page. With two players in the
                  // carousel, "Growth IQ" alone leaves the second one
                  // unattributed - the headline usually mentions a name, but
                  // it is AI-written and cannot be relied on to.
                  Text(
                    "${snapshot.firstName}'s Growth IQ",
                    style: CiType.rowLabel.copyWith(
                      color: c.textMuted,
                      fontWeight: CiWeight.semiBold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                        // Ghost, not filled: a grey pill beside the score
                        // competes with it. Measured from the frame - no
                        // fill, 1px border.
                        CiBadge(label: ppg, tone: CiBadgeTone.ghost),
                        const SizedBox(width: CiSpace.s3),
                      ],
                      // PLAIN TEXT, as the frame has it (Quin, 2026-09-28). It
                      // was a chip for consistency with other deltas; the
                      // frame wins now, and the trend word moved into the
                      // gauge. The COLOUR RULE is unchanged from the chip:
                      // only Rising earns lime, a dip stays neutral (see
                      // CiBadge.growthTrend for why).
                      if (snapshot.trend != null && delta != null)
                        _GrowthDelta(trend: snapshot.trend!, delta: delta),
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

/// "▲ +4" beside the PPG tag. Lime only when Rising; neutral otherwise.
class _GrowthDelta extends StatelessWidget {
  const _GrowthDelta({required this.trend, required this.delta});

  final GrowthTrend trend;
  final int delta;

  @override
  Widget build(BuildContext context) {
    const c = CiColors.onInk;
    final arrow = delta > 0
        ? '▲ '
        : delta < 0
        ? '▼ '
        : '';
    final number = delta > 0 ? '+$delta' : '$delta';
    return Text(
      '$arrow$number',
      style: CiType.rowLabel.copyWith(
        color: trend == GrowthTrend.rising ? c.accentGood : c.textMuted,
        fontWeight: CiWeight.bold,
      ),
    );
  }
}
