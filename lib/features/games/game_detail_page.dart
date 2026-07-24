// Game Detail — Phase 4.14
//
// Measured from 145:610:
//
//   header  ink: back, "Game", share; then avatar + "vs Opponent" / date
//   hero    ink: PTS at 44 Light beside REB/AST/STL/BLK/TO
//   shots   ink: three columns divided by vertical rules
//   insight limeWash card (see game_insight_card.dart)
//   dev     light: "Development", one row per rated metric, tier badge right
//   mix     light: "Scoring Mix", the stacked bar and its legend
//   remove  a ghost pill
//
// WHAT IS ABSENT IS DECIDED IN game_detail_builder.dart, not here. This screen
// renders what the view model gives it; the rules about which metrics earn a
// row and when the section disappears live in pure Dart where they are
// testable.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_confirm_dialog.dart';
import '/courtside_iq/design/components/ci_info_sheet.dart';
import '/courtside_iq/design/components/ci_scoring_mix.dart';
import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/game_detail_builder.dart';
import '/courtside_iq/game_metrics.dart';
import 'game_detail_repository.dart';
import 'game_insight_card.dart';

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({
    super.key,
    required this.gameId,
    this.repository = const GameDetailRepository(),
    this.onRemoved,
  });

  final String gameId;
  final GameDetailRepository repository;

  /// Called after the game is deleted, so the caller can leave and reload.
  final VoidCallback? onRemoved;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late final Future<GameDetailRow?> _future = widget.repository.load(
    widget.gameId,
  );

  Future<void> _share(GameDetailView v) async {
    final r = v.row;
    final who = r.playerName.trim().isEmpty ? 'Our player' : r.playerName;
    final vs = (r.opponent ?? '').trim();

    String shot(String label, int made, int attempt) => attempt == 0
        ? ''
        : '$label $made/$attempt (${(made / attempt * 100).round()}%)';

    final lines = <String>[
      '$who${vs.isEmpty ? '' : ' vs $vs'}',
      if (r.playedAt != null) DateFormat('EEE, MMM d').format(r.playedAt!),
      '',
      '${r.points} PTS · ${r.rebounds} REB · ${r.assists} AST · '
          '${r.steals} STL · ${r.blocks} BLK · ${r.turnovers} TO',
      [
        shot('FG', r.fgMade, r.fgAttempt),
        shot('3P', r.threeMade, r.threeAttempt),
        shot('FT', r.ftMade, r.ftAttempt),
      ].where((s) => s.isNotEmpty).join(' · '),
    ];

    if (v.showInsight) {
      lines
        ..add('')
        ..add(
          'Courtside IQ${v.insightLabel == null ? '' : ' — ${v.insightLabel}'}',
        )
        ..add(r.insight!.text!.trim());
    }
    if (v.showDevelopment) {
      lines.add('');
      lines.add('Development');
      for (final d in v.development) {
        lines.add('${d.title} (${d.tier.label}): ${d.detail}');
      }
    }

    // sharePositionOrigin is REQUIRED on iPad: the share popover has nowhere
    // to anchor without it and the sheet never appears - which is the "share
    // does nothing" symptom. It is ignored on iPhone. Derived from this page's
    // box.
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      lines.join('\n').trimRight(),
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  Future<void> _remove() async {
    final confirmed = await showCiConfirmDialog(
      context,
      title: 'Remove this game?',
      // The gentle version of a real product truth. A parent removing games
      // to stay under the free limit is working around the thing that makes
      // the app worth having, and this is the only moment we can say so
      // without nagging - so it explains rather than warns, and it does not
      // block them.
      message:
          'This game and its insight will be deleted. Development '
          'tracking gets better the more games you keep, so their progress '
          'has more to build on.',
      confirmLabel: 'Remove game',
      cancelLabel: 'Keep it',
    );
    if (!confirmed || !mounted) return;

    await widget.repository.remove(widget.gameId);
    if (!mounted) return;
    widget.onRemoved?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          return Scaffold(
            backgroundColor: c.bg,
            body: FutureBuilder<GameDetailRow?>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData &&
                    snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final row = snap.data;
                if (row == null) return _Missing(onBack: _back);

                final v = buildGameDetail(row);
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _Header(view: v, onBack: _back, onShare: () => _share(v)),
                    if (v.showInsight)
                      GameInsightCard(
                        state: InsightState.ready,
                        playerName: row.playerName,
                        text: row.insight?.text,
                        label: v.insightLabel,
                        onAbout: () => showCiInfoSheet(
                          context,
                          title: 'About game insights',
                          body:
                              'After each game you log, we write a short read '
                              'on how your player did. What stood out, where '
                              "they can grow, and how it ties to their "
                              "development. It's pulled from the game's stat "
                              'line and written in plain language, so you get a '
                              "coach's take in seconds.",
                        ),
                      ),
                    // CiSectionHeader DRAWS ITS OWN CLOSING HAIRLINE. Adding
                    // one after it put a double rule under every section
                    // header on this screen.
                    if (v.showDevelopment) ...[
                      const CiSectionHeader(title: 'Development'),
                      for (var i = 0; i < v.development.length; i++) ...[
                        if (i > 0) const CiHairline(),
                        _DevelopmentRow(row: v.development[i]),
                      ],
                      const CiHairline(),
                    ],
                    if (v.scoringMix.isNotEmpty) ...[
                      const CiSectionHeader(title: 'Scoring Mix'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CiSpace.screen,
                          CiSpace.s5,
                          CiSpace.screen,
                          CiSpace.s5,
                        ),
                        child: CiScoringMix(segments: v.scoringMix),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen,
                        CiSpace.s5,
                        CiSpace.screen,
                        CiSpace.s8,
                      ),
                      child: CiButton(
                        label: 'Remove Game',
                        style: CiButtonStyle.secondary,
                        expand: true,
                        onPressed: _remove,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _back() => Navigator.of(context).maybePop();
}

/// The ink block: chrome, matchup, hero stats and the shooting columns.
class _Header extends StatelessWidget {
  const _Header({
    required this.view,
    required this.onBack,
    required this.onShare,
  });

  final GameDetailView view;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          final r = view.row;
          final opponent = (r.opponent ?? '').trim();
          final date = r.playedAt == null
              ? null
              : DateFormat('EEE, MMM d').format(r.playedAt!);

          return SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CiSpace.screen,
                    CiSpace.s3,
                    CiSpace.screen,
                    CiSpace.s4,
                  ),
                  child: Row(
                    children: [
                      _IconTap(
                        semanticLabel: 'Back',
                        onTap: onBack,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: c.text,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Game',
                          textAlign: TextAlign.center,
                          style: CiType.h4.copyWith(
                            color: c.text,
                            fontWeight: CiWeight.semiBold,
                          ),
                        ),
                      ),
                      _IconTap(
                        semanticLabel: 'Share game',
                        onTap: onShare,
                        child: Icon(
                          Icons.ios_share_outlined,
                          size: 18,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CiSpace.screen,
                  ),
                  child: Row(
                    children: [
                      CiAvatar(
                        name: r.playerName,
                        imageUrl: r.playerPhotoUrl,
                        size: 40,
                      ),
                      const SizedBox(width: CiSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              opponent.isEmpty ? r.playerName : 'vs $opponent',
                              style: CiType.bodySm.copyWith(
                                color: c.text,
                                fontWeight: CiWeight.semiBold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (date != null)
                              Text(
                                date,
                                style: CiType.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: CiSpace.s5),
                CiHairline(color: c.hairline),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CiSpace.screen,
                    CiSpace.s4,
                    CiSpace.screen,
                    CiSpace.s4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${r.points}',
                        style: CiType.statXl.copyWith(
                          color: c.text,
                          fontSize: 44,
                        ),
                      ),
                      // PTS close to the number and lifted 8 so it rests on the
                      // box-stat label line (145:610), the big figure descending
                      // below it.
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'PTS',
                          style: CiType.rowLabel.copyWith(color: c.textMuted),
                        ),
                      ),
                      Expanded(
                        // The box stats are RIGHT-ALIGNED and tightly spaced (the
                        // frame runs them ~28 apart against the gutter), NOT
                        // spread full-width - equal Expanded slots left far too
                        // much air. Same 8 lift so their labels share PTS's
                        // baseline. FittedBox scaleDown keeps it from overflowing
                        // when points AND every stat run to two/three digits on a
                        // 360pt screen - the case the equal-slot version guarded.
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (final (i, m) in [
                                  (r.rebounds, 'REB'),
                                  (r.assists, 'AST'),
                                  (r.steals, 'STL'),
                                  (r.blocks, 'BLK'),
                                  (r.turnovers, 'TO'),
                                ].indexed) ...[
                                  if (i > 0) const SizedBox(width: 14),
                                  _Mini(value: m.$1, label: m.$2),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CiHairline(color: c.hairline),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Shot(
                        label: 'Field Goal',
                        made: r.fgMade,
                        attempted: r.fgAttempt,
                      ),
                      VerticalDivider(width: 1, color: c.hairline),
                      _Shot(
                        label: '3-Point',
                        made: r.threeMade,
                        attempted: r.threeAttempt,
                      ),
                      VerticalDivider(width: 1, color: c.hairline),
                      _Shot(
                        label: 'Free Throw',
                        made: r.ftMade,
                        attempted: r.ftAttempt,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Shot extends StatelessWidget {
  const _Shot({
    required this.label,
    required this.made,
    required this.attempted,
  });

  final String label;
  final int made;
  final int attempted;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final pct = shootingPct(made: made, attempted: attempted);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CiSpace.s4,
          vertical: CiSpace.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: CiType.caption.copyWith(color: c.textMuted)),
            const SizedBox(height: CiSpace.s2),
            Text(
              // A shot never taken has no percentage.
              pct == null ? '—' : '${pct.round()}%',
              style: CiType.statSm.copyWith(
                color: pct == null ? c.textFaint : c.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: CiType.unit.copyWith(
            color: c.text,
            fontWeight: CiWeight.light,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: CiType.micro.copyWith(color: c.textMuted)),
      ],
    );
  }
}

class _DevelopmentRow extends StatelessWidget {
  const _DevelopmentRow({required this.row});

  final DevelopmentRow row;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CiSpace.screen,
        CiSpace.s4,
        CiSpace.screen,
        CiSpace.s4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(row.title, style: CiType.rowTitle.copyWith(color: c.text)),
                const SizedBox(height: 2),
                Text(
                  row.detail,
                  style: CiType.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: CiSpace.s3),
          CiBadge(
            label: row.tier.label,
            // Elite is the only tier that takes the accent. Good and Solid
            // are both fine outcomes, and painting all three lime would make
            // the colour mean "rated" rather than "excellent".
            tone: row.tier == GameTier.elite
                ? CiBadgeTone.good
                : CiBadgeTone.neutral,
          ),
        ],
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CiSpace.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This game is no longer here',
              style: CiType.h3.copyWith(color: c.text),
            ),
            const SizedBox(height: CiSpace.s2),
            Text(
              'It may have been removed on another device.',
              textAlign: TextAlign.center,
              style: CiType.bodySm.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: CiSpace.s5),
            CiButton(
              label: 'Back to games',
              style: CiButtonStyle.secondary,
              onPressed: onBack,
            ),
          ],
        ),
      ),
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
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: CiRadius.chipR,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: CiRadius.chipR,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
