// Development tab — Phase 4.11b
//
// Measured from Player Profile 93:211 (Development) and the Locked variant
// 156:704:
//
//   summary   DotGauge with the Growth IQ, a trend chip, and the headline
//   sections  "What's Working" and "Room to Grow" on limeWash (#F1FFD2)
//   focus     "WATCH NEXT GAME" on an ink block - the one thing to watch for
//   footer    "About this story"
//   locked    progress dots, "unlocks in N games", "Track a Game"
//
// A PURE RENDERER. It receives the insight rather than fetching one: the
// fetch lives on the profile page precisely so returning to this tab cannot
// re-trigger a paid generation. Do not add a fetch here.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/components/dot_gauge.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/growth_iq.dart';
import '/features/player_insight/models/player_insight.dart';

/// Games needed before a development story exists. Mirrors the server.
const int kMinGamesForStory = 5;

class DevelopmentView extends StatelessWidget {
  const DevelopmentView({
    super.key,
    required this.firstName,
    required this.insight,
    this.growthIq,
    this.growthIqDelta,
    this.trend,
    this.gamesLogged,
    this.gamesUntilUnlock,
    this.onTrackGame,
    this.onAbout,
  });

  final String firstName;

  /// Null while loading. Below-threshold is carried ON the insight, so a
  /// present insight can still mean "not enough games yet".
  final PlayerInsight? insight;

  final int? growthIq;
  final int? growthIqDelta;
  final GrowthTrend? trend;
  final int? gamesLogged;

  /// The server's own countdown. Preferred over deriving one from the game
  /// count: the threshold rule lives on the server and this is it answering.
  final int? gamesUntilUnlock;

  final VoidCallback? onTrackGame;
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    final i = insight;
    if (i == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (i.belowThreshold) {
      return _Locked(
        firstName: firstName,
        gamesLogged: gamesLogged ?? 0,
        gamesUntilUnlock: gamesUntilUnlock,
        onTrackGame: onTrackGame,
      );
    }
    return _Story(
      insight: i,
      growthIq: growthIq,
      growthIqDelta: growthIqDelta,
      trend: trend,
      onAbout: onAbout,
    );
  }
}

class _Story extends StatelessWidget {
  const _Story({
    required this.insight,
    required this.growthIq,
    required this.growthIqDelta,
    required this.trend,
    this.onAbout,
  });

  final PlayerInsight insight;
  final int? growthIq;
  final int? growthIqDelta;
  final GrowthTrend? trend;
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          // 24 all round, measured from 94:235.
          padding: const EdgeInsets.all(CiSpace.screen),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (growthIq != null) ...[
                DotGauge(
                  size: 104,
                  value: growthIqGaugeValue(growthIq!),
                  // The score only. See CiBadge.growthTrend: the word and the
                  // delta stay together on the chip rather than being split
                  // across the gauge and the chip.
                  child: Text('$growthIq',
                      style: CiType.statSm.copyWith(color: c.text)),
                ),
                const SizedBox(width: 18),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trend != null) ...[
                      CiBadge.growthTrend(
                          trend: trend!, delta: growthIqDelta),
                      const SizedBox(height: 10),
                    ],
                    Text(insight.headline ?? '',
                        style: CiType.body.copyWith(color: c.text)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // The frame has no rule here, but on device the summary and the
        // section header ran together as one undifferentiated block. Averages
        // does not need this because its header sits directly under the tab
        // bar, which already ends in a rule.
        Container(height: CiSpace.hairline, color: c.hairline),
        const CiSectionHeader(title: 'Development Story'),
        // A v2 cache row has no split narrative, only `text`. Rendering it in
        // one block is what keeps an existing user's story on screen instead
        // of an empty tab while the v3 insight regenerates.
        if (!insight.hasSplitNarrative && _has(insight.text))
          _WashBlock(title: 'The Story', body: insight.text!),
        if (_has(insight.whatsWorking))
          _WashBlock(
            title: "What's Working",
            body: insight.whatsWorking!,
          ),
        if (_has(insight.needsDevelopment))
          _WashBlock(
            title: 'Room to Grow',
            body: insight.needsDevelopment!,
          ),
        if (_has(insight.growthEdge))
          _FocusBlock(
            label: 'WATCH NEXT GAME',
            body: insight.growthEdge!,
            focus: insight.strengthFocus,
          ),
        if (onAbout != null) _AboutRow(onTap: onAbout!),
        const SizedBox(height: CiSpace.s8),
      ],
    );
  }

  static bool _has(String? s) => s != null && s.trim().isNotEmpty;
}

/// A lime-wash block. Used for both the positive and the growth section on
/// purpose: "Room to Grow" is not a warning, and giving it an alarm colour
/// would tell a parent their child is failing at the moment the app is trying
/// to point somewhere useful.
class _WashBlock extends StatelessWidget {
  const _WashBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      width: double.infinity,
      color: c.accentGoodWash,
      // 22 top / 32 bottom, measured from 128:608. The bottom is heavier on
      // purpose: it is what separates one narrative block from the next.
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, 22, CiSpace.screen, CiSpace.s7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 17, color: c.text),
              const SizedBox(width: CiSpace.s2),
              Text(title, style: CiType.buttonSm.copyWith(color: c.text)),
            ],
          ),
          const SizedBox(height: CiSpace.s2),
          Text(body, style: CiType.body.copyWith(color: c.text, height: 1.48)),
        ],
      ),
    );
  }
}

/// The ink "watch next game" block: one concrete thing to look for.
class _FocusBlock extends StatelessWidget {
  const _FocusBlock({required this.label, required this.body, this.focus});

  final String label;
  final String body;
  final String? focus;

  @override
  Widget build(BuildContext context) {
    const c = CiColors.onInk;
    return Container(
      width: double.infinity,
      color: c.bg,
      // 24 all round, measured from 95:304.
      padding: const EdgeInsets.all(CiSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CiType.badge.copyWith(color: c.accentGood)),
          if (focus != null && focus!.trim().isNotEmpty) ...[
            const SizedBox(height: CiSpace.s2),
            Text(focus!, style: CiType.statSm.copyWith(color: c.text)),
          ],
          const SizedBox(height: CiSpace.s2),
          Text(body,
              style: CiType.body.copyWith(color: c.textMuted, height: 1.48)),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: CiSpace.screen, vertical: CiSpace.s5),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: c.textMuted),
            const SizedBox(width: CiSpace.s2),
            Text('About this story',
                style: CiType.bodySm.copyWith(color: c.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Below the game threshold: progress, not a refusal.
///
/// The copy counts DOWN to something arriving rather than reporting a lack.
/// A parent who has logged three games has done nothing wrong.
class _Locked extends StatelessWidget {
  const _Locked({
    required this.firstName,
    required this.gamesLogged,
    required this.gamesUntilUnlock,
    this.onTrackGame,
  });

  final String firstName;
  final int gamesLogged;
  final int? gamesUntilUnlock;
  final VoidCallback? onTrackGame;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final remaining =
        (gamesUntilUnlock ?? (kMinGamesForStory - gamesLogged))
            .clamp(1, kMinGamesForStory);
    final name = firstName.isEmpty ? 'Their' : "$firstName's";

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
      children: [
        const SizedBox(height: CiSpace.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < kMinGamesForStory; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i < gamesLogged ? c.accentGood : c.border,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: CiSpace.s4),
        Text('$gamesLogged of $kMinGamesForStory games logged',
            textAlign: TextAlign.center,
            style: CiType.bodySm.copyWith(color: c.textMuted)),
        const SizedBox(height: CiSpace.s7),
        Text(
          '$name development story unlocks in $remaining '
          '${remaining == 1 ? 'game' : 'games'}.',
          textAlign: TextAlign.center,
          style: CiType.h3.copyWith(color: c.text),
        ),
        const SizedBox(height: CiSpace.s7),
        CiButton(
          label: 'Track a Game',
          style: CiButtonStyle.primary,
          expand: true,
          onPressed: onTrackGame,
        ),
      ],
    );
  }
}
