// Game Complete & Save — Phase 4.13
//
// Measured from 291:1334:
//
//   ink block  474 tall: "Game complete" ExtraBold 26, the matchup line,
//              POINTS at Light 72, five stat columns, three shooting columns,
//              all separated by #2e2e2e rules
//   teaser     84 on limeWash: "Save to add this game to <name>'s
//              development"
//   actions    lime "Save Game", then a muted "Discard Game"
//
// A PURE RENDERER: it takes the finished stats and two callbacks. Saving is
// the caller's job, because saving is where the offline queue and the insight
// live and none of that belongs in a screen.
//
// THE TEASER NO LONGER PROMISES AN INSIGHT. It read "Save to unlock Maya's
// game insight", which committed the app to producing one for THIS game - and
// a quiet game earns no insight and no Development section, so the promise
// was made and then silently not kept. The frame's copy, changed 2026-07-23.
//
// What saving reliably does is add to the history, and that is what the new
// copy says. "Some games earn a closer read" keeps the insight honest: it is
// a bonus when there is enough to say, not a debt.
//
// It is also the same argument the Remove Game dialog makes, deliberately -
// the two moments that talk about why games are worth keeping should agree.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_spark.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/live_game.dart';
import 'live_game_store.dart';

class GameCompletePage extends StatelessWidget {
  const GameCompletePage({
    super.key,
    required this.snapshot,
    this.onSave,
    this.onDiscard,
    this.saving = false,
  });

  final LiveGameSnapshot snapshot;
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;

  /// Shows the button busy and blocks a second tap. A double save would
  /// insert the game twice.
  final bool saving;

  LiveGameStats get _s => snapshot.stats;

  /// "Maya vs Northside Hawks · Sat, May 4", dropping the opponent when the
  /// game was started without one.
  String get _matchup {
    final parts = <String>[
      if ((snapshot.opponent ?? '').trim().isNotEmpty)
        '${snapshot.playerName} vs ${snapshot.opponent!.trim()}'
      else
        snapshot.playerName,
      DateFormat('EEE, MMM d').format(snapshot.startedAt),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Summary(matchup: _matchup, stats: _s),
              const CiHairline(),
              _InsightTeaser(playerName: snapshot.playerName),
              const CiHairline(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    CiSpace.screen, CiSpace.s9, CiSpace.screen, CiSpace.s6),
                child: CiButton(
                  label: 'Save Game',
                  style: CiButtonStyle.lime,
                  expand: true,
                  busy: saving,
                  onPressed: saving ? null : onSave,
                ),
              ),
              Center(
                child: Semantics(
                  button: true,
                  child: InkWell(
                    // Blocked while saving: discarding a game mid-insert is a
                    // race with nothing good on the other side.
                    onTap: saving ? null : onDiscard,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: CiSpace.s6, vertical: CiSpace.s3),
                      child: Text(
                        'Discard Game',
                        // Muted, not the energy accent. Discarding is a real
                        // choice a parent may want after a test game, and
                        // painting it as danger next to a lime Save overstates
                        // it. The confirmation carries the weight instead.
                        style: CiType.h4.copyWith(color: c.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: CiSpace.s8),
            ],
          ),
        );
      }),
    );
  }
}

/// The ink block: everything the game was, before it is saved.
class _Summary extends StatelessWidget {
  const _Summary({required this.matchup, required this.stats});

  final String matchup;
  final LiveGameStats stats;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: CiSpace.s6),
              Text('Game complete',
                  textAlign: TextAlign.center,
                  style: CiType.h2
                      .copyWith(color: c.text, fontWeight: CiWeight.extraBold)),
              const SizedBox(height: CiSpace.s2),
              Text(matchup,
                  textAlign: TextAlign.center,
                  style: CiType.bodySm.copyWith(color: c.textMuted)),
              const SizedBox(height: CiSpace.s5),
              const _Rule(),
              const SizedBox(height: CiSpace.s5),
              // The one number a parent looks for first, at 72.
              Text('${stats.points}',
                  textAlign: TextAlign.center,
                  style: CiType.statXl.copyWith(color: c.text)),
              const SizedBox(height: CiSpace.s1),
              Text('POINTS',
                  textAlign: TextAlign.center,
                  style: CiType.label.copyWith(color: c.textMuted)),
              const SizedBox(height: CiSpace.s5),
              const _Rule(),
              const SizedBox(height: CiSpace.s5),
              Row(
                children: [
                  _Stat(value: stats.rebounds, label: 'REB'),
                  _Stat(value: stats.assists, label: 'AST'),
                  _Stat(value: stats.steals, label: 'STL'),
                  _Stat(value: stats.blocks, label: 'BLK'),
                  _Stat(value: stats.turnovers, label: 'TO'),
                ],
              ),
              const SizedBox(height: CiSpace.s5),
              const _Rule(),
              const SizedBox(height: CiSpace.s5),
              Row(
                children: [
                  _Shot(
                    made: stats.fgMade,
                    attempted: stats.fgAttempted,
                    label: 'Field Goal',
                  ),
                  _Shot(
                    made: stats.threeMade,
                    attempted: stats.threeMade + stats.threeMissed,
                    label: '3-Point',
                  ),
                  _Shot(
                    made: stats.ftMade,
                    attempted: stats.ftAttempted,
                    label: 'Free Throw',
                  ),
                ],
              ),
              const SizedBox(height: CiSpace.s7),
            ],
          ),
        );
      }),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(
        height: CiSpace.hairline,
        color: CiColors.of(context).border,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: CiType.h2.copyWith(
              color: c.text, fontWeight: CiWeight.light)),
          const SizedBox(height: 2),
          Text(label, style: CiType.micro.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}

/// A shooting column: percentage, name, and the made/attempted behind it.
class _Shot extends StatelessWidget {
  const _Shot({
    required this.made,
    required this.attempted,
    required this.label,
  });

  final int made;
  final int attempted;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // A shot never taken has no percentage. "0%" would report a miss that
    // never happened - the same rule the Averages tab follows.
    final pct = attempted == 0 ? '—' : '${(made / attempted * 100).round()}%';

    // CENTERED, AND NO EXTRA INSET. 291:1358-1366 divides the content width
    // into three equal columns with centered text, exactly like the five
    // stat columns directly above. Left-aligning these and padding them in
    // pushed every figure off the shared grid, so the two rows read as
    // belonging to different screens.
    return Expanded(
      child: Column(
        children: [
          Text(pct,
              style: CiType.statSm.copyWith(
                  color: attempted == 0 ? c.textFaint : c.text)),
          const SizedBox(height: 2),
          Text(label, style: CiType.bodyXs.copyWith(color: c.textMuted)),
          Text('$made/$attempted',
              style: CiType.caption.copyWith(color: c.textFaint)),
        ],
      ),
    );
  }
}

/// The lime-wash promise that saving produces an insight.
class _InsightTeaser extends StatelessWidget {
  const _InsightTeaser({required this.playerName});

  final String playerName;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final who = playerName.trim().isEmpty ? 'your player' : playerName.trim();
    return Container(
      width: double.infinity,
      color: c.accentGoodWash,
      padding: const EdgeInsets.symmetric(
          horizontal: CiSpace.screen, vertical: 18),
      // The spark leads the line (443:1971, 22pt at the screen gutter, text
      // from 58). Without it the promise is a sentence in a green box; with
      // it, it carries the same mark the finished insight will.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CiSpark(size: 22, color: c.text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Save to add this game to $who's development",
                    style: CiType.h4.copyWith(color: c.text)),
                const SizedBox(height: CiSpace.s1),
                Text('Every game you log builds the picture of how they are '
                    'growing, and some games earn a closer read.',
                    style: CiType.bodySm.copyWith(color: c.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
