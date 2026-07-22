// Live Stat Tracker — Phase 4.13
//
// Measured from 138:611. INK THROUGHOUT - the whole screen, not just a hero.
//
//   header 222: avatar 40, "vs Opponent" over a LIVE pill, pause + End at the
//          right, a hairline, then PTS 54 Light beside REB/AST/STL/BLK/TO,
//          then another hairline
//   shots  three rows at 222 / 334 / 446: a WHITE "Make +N" 184x60 and a dark
//          "Miss" 92x60, with made/missed counts beneath
//   count  six 167x83 tiles: label, then minus / value / plus
//
// THE MAKE BUTTON IS WHITE AND TWICE THE WIDTH OF MISS. That is the frame's
// judgement about which tap happens under pressure, and it is the right one:
// a parent watching their kid is looking at the court, not the phone.
//
// EVERY TAP WRITES THROUGH to LiveGameStore before anything else. A game
// cannot be tracked twice, and phones get dropped.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/live_game.dart';
import 'live_game_store.dart';

/// The offline banner (654:2199): ink, 54 tall, under the header.
///
/// Says the stats are SAFE, not that something failed. A parent in a gym with
/// no bars has done nothing wrong, and the queue means nothing is at risk -
/// so the sentence leads with where the stats are, not with the problem.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      width: double.infinity,
      height: 54,
      color: c.bg,
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.accentEnergy,
              borderRadius: CiRadius.chipR,
            ),
            child: Text('OFFLINE',
                style: CiType.badge.copyWith(
                    color: c.onAccent, fontWeight: CiWeight.semiBold)),
          ),
          const SizedBox(width: CiSpace.s3),
          Expanded(
            child: Text(
              "You're offline. Stats are saved here and sync when you "
              'reconnect.',
              style: CiType.caption.copyWith(color: c.textMuted),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveTrackerPage extends StatefulWidget {
  const LiveTrackerPage({
    super.key,
    required this.snapshot,
    this.store = const LiveGameStore(),
    this.onEnd,
    this.onPause,
    this.offline = false,
  });

  final LiveGameSnapshot snapshot;
  final LiveGameStore store;

  /// Called with the final stats when the parent ends the game. The Complete
  /// and Save screen is its own piece.
  final ValueChanged<LiveGameSnapshot>? onEnd;

  final ValueChanged<LiveGameSnapshot>? onPause;

  /// Shows the offline banner. Display only - the queue keeps the game safe
  /// whether or not this is true.
  final bool offline;

  @override
  State<LiveTrackerPage> createState() => _LiveTrackerPageState();
}

class _LiveTrackerPageState extends State<LiveTrackerPage> {
  late LiveGameSnapshot _snapshot = widget.snapshot;

  LiveGameStats get _stats => _snapshot.stats;

  void _tap(LiveStat stat, int delta) {
    final next = _snapshot.withStats(applyStat(_stats, stat, delta));
    setState(() => _snapshot = next);
    // Fire and forget deliberately: the UI must not wait on a disk write
    // between taps, and the write cannot fail in a way the parent could act
    // on mid-game.
    widget.store.save(next);
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  snapshot: _snapshot,
                  onEnd: () => widget.onEnd?.call(_snapshot),
                  onPause: () => widget.onPause?.call(_snapshot),
                ),
                if (widget.offline) const OfflineBanner(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: CiSpace.s8),
                    children: [
                      _ShotRow(
                        label: '2PT',
                        makeLabel: 'Make +2',
                        made: _stats.twoMade,
                        missed: _stats.twoMissed,
                        onMake: () => _tap(LiveStat.twoMade, 1),
                        onMiss: () => _tap(LiveStat.twoMissed, 1),
                        onUndoMade: () => _tap(LiveStat.twoMade, -1),
                        onUndoMissed: () => _tap(LiveStat.twoMissed, -1),
                      ),
                      _ShotRow(
                        label: '3PT',
                        makeLabel: 'Make +3',
                        made: _stats.threeMade,
                        missed: _stats.threeMissed,
                        onMake: () => _tap(LiveStat.threeMade, 1),
                        onMiss: () => _tap(LiveStat.threeMissed, 1),
                        onUndoMade: () => _tap(LiveStat.threeMade, -1),
                        onUndoMissed: () => _tap(LiveStat.threeMissed, -1),
                      ),
                      _ShotRow(
                        label: 'FT',
                        makeLabel: 'Make +1',
                        made: _stats.ftMade,
                        missed: _stats.ftMissed,
                        onMake: () => _tap(LiveStat.ftMade, 1),
                        onMiss: () => _tap(LiveStat.ftMissed, 1),
                        onUndoMade: () => _tap(LiveStat.ftMade, -1),
                        onUndoMissed: () => _tap(LiveStat.ftMissed, -1),
                      ),
                      const SizedBox(height: CiSpace.s3),
                      _CounterGrid(stats: _stats, onTap: _tap),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.snapshot,
    required this.onEnd,
    required this.onPause,
  });

  final LiveGameSnapshot snapshot;
  final VoidCallback onEnd;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final s = snapshot.stats;
    final opponent = snapshot.opponent?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s3, CiSpace.s6, CiSpace.s3),
          child: Row(
            children: [
              CiAvatar(
                name: snapshot.playerName,
                size: 40,
                ringColor: c.border,
                ringWidth: 1.35,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // The opponent names the game. Without one it is still
                      // this player's game, so their name carries the line
                      // rather than leaving it blank.
                      opponent == null || opponent.isEmpty
                          ? snapshot.playerName
                          : 'vs $opponent',
                      style: CiType.bodySm.copyWith(
                          color: c.text, fontWeight: CiWeight.medium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    const _LiveDot(),
                  ],
                ),
              ),
              _IconTap(
                semanticLabel: 'Pause game',
                onTap: onPause,
                child: Icon(Icons.pause, size: 20, color: c.text),
              ),
              const SizedBox(width: CiSpace.s2),
              Semantics(
                button: true,
                label: 'End game',
                container: true,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onEnd,
                  borderRadius: CiRadius.chipR,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: CiSpace.s3, vertical: CiSpace.s3),
                    child: Text('End',
                        style: CiType.buttonSm.copyWith(color: c.text)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: CiSpace.hairline, color: c.hairline),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${s.points}',
                  style: CiType.statXl.copyWith(color: c.text, fontSize: 54)),
              const SizedBox(width: CiSpace.s2),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('PTS',
                    style: CiType.rowLabel.copyWith(color: c.textMuted)),
              ),
              const Spacer(),
              _MiniStat(value: s.rebounds, label: 'REB'),
              _MiniStat(value: s.assists, label: 'AST'),
              _MiniStat(value: s.steals, label: 'STL'),
              _MiniStat(value: s.blocks, label: 'BLK'),
              _MiniStat(value: s.turnovers, label: 'TO'),
            ],
          ),
        ),
        Container(height: CiSpace.hairline, color: c.hairline),
      ],
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      label: 'Live',
      container: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration:
                BoxDecoration(color: c.accentEnergy, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text('LIVE',
              style: CiType.badge.copyWith(
                  color: c.accentEnergy, fontWeight: CiWeight.bold)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: CiSpace.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value',
              style: CiType.unit
                  .copyWith(color: c.text, fontWeight: CiWeight.light)),
          const SizedBox(height: 2),
          Text(label, style: CiType.micro.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}

/// One shooting row: a wide white Make, a narrow dark Miss, and the running
/// counts beneath.
///
/// TAPPING A COUNT UNDOES ONE. The frame shows no undo control, but a mis-tap
/// during a game is certain and there is otherwise no way back - the counters
/// below have minus buttons and these did not. The count is the natural place:
/// it is the thing that went wrong, and it is already on screen.
class _ShotRow extends StatelessWidget {
  const _ShotRow({
    required this.label,
    required this.makeLabel,
    required this.made,
    required this.missed,
    required this.onMake,
    required this.onMiss,
    required this.onUndoMade,
    required this.onUndoMissed,
  });

  final String label;
  final String makeLabel;
  final int made;
  final int missed;
  final VoidCallback onMake;
  final VoidCallback onMiss;
  final VoidCallback onUndoMade;
  final VoidCallback onUndoMissed;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s4, CiSpace.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(label,
                      style: CiType.h4.copyWith(color: c.text)),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: '$label $makeLabel',
                    container: true,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: onMake,
                      borderRadius: CiRadius.chipR,
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // White, and twice the width of Miss. The frame's
                          // judgement about which tap happens under pressure.
                          color: c.surfaceInvert,
                          borderRadius: CiRadius.chipR,
                        ),
                        child: Text(makeLabel,
                            style: CiType.h4.copyWith(color: c.textInvert)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CiSpace.s2),
                Semantics(
                  button: true,
                  label: '$label miss',
                  container: true,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onMiss,
                    borderRadius: CiRadius.chipR,
                    child: Container(
                      width: 92,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.surfaceSunk,
                        borderRadius: CiRadius.chipR,
                        border: Border.all(color: c.border),
                      ),
                      child: Text('Miss',
                          style: CiType.rowTitle.copyWith(color: c.text)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CiSpace.s3),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Row(
              children: [
                _UndoCount(
                  label: 'Made',
                  value: made,
                  onUndo: onUndoMade,
                  semanticLabel: 'Undo one made $label',
                ),
                const SizedBox(width: CiSpace.s7),
                _UndoCount(
                  label: 'Missed',
                  value: missed,
                  onUndo: onUndoMissed,
                  semanticLabel: 'Undo one missed $label',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UndoCount extends StatelessWidget {
  const _UndoCount({
    required this.label,
    required this.value,
    required this.onUndo,
    required this.semanticLabel,
  });

  final String label;
  final int value;
  final VoidCallback onUndo;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: value > 0,
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        // Nothing to undo at zero, so it is not a target.
        onTap: value > 0 ? onUndo : null,
        borderRadius: CiRadius.chipR,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: CiSpace.s2, vertical: CiSpace.s2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: CiType.caption.copyWith(color: c.textMuted)),
              const SizedBox(width: CiSpace.s2),
              Text('$value',
                  style: CiType.rowLabel.copyWith(color: c.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterGrid extends StatelessWidget {
  const _CounterGrid({required this.stats, required this.onTap});

  final LiveGameStats stats;
  final void Function(LiveStat, int) onTap;

  @override
  Widget build(BuildContext context) {
    const pairs = [
      [(LiveStat.offReb, 'OReb'), (LiveStat.defReb, 'DReb')],
      [(LiveStat.assists, 'Assists'), (LiveStat.steals, 'Steals')],
      [(LiveStat.blocks, 'Blocks'), (LiveStat.turnovers, 'Turnovers')],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
      child: Column(
        children: [
          for (final row in pairs)
            Padding(
              padding: const EdgeInsets.only(bottom: CiSpace.s2),
              child: Row(
                children: [
                  for (var i = 0; i < row.length; i++) ...[
                    if (i > 0) const SizedBox(width: CiSpace.s2),
                    Expanded(
                      child: _CounterTile(
                        label: row[i].$2,
                        value: readStat(stats, row[i].$1),
                        onMinus: () => onTap(row[i].$1, -1),
                        onPlus: () => onTap(row[i].$1, 1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Container(
      height: 83,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: c.surfaceSunk,
        borderRadius: CiRadius.chipR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CiType.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Row(
            children: [
              _IconTap(
                semanticLabel: 'One fewer $label',
                // Nothing to remove at zero.
                onTap: value > 0 ? onMinus : null,
                child: Icon(Icons.remove,
                    size: 20,
                    color: value > 0 ? c.text : c.textFaint),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: CiType.statInlineLg.copyWith(color: c.text),
                ),
              ),
              _IconTap(
                semanticLabel: 'One more $label',
                onTap: onPlus,
                child: Icon(Icons.add, size: 20, color: c.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A 40pt tap target around a 20pt glyph.
///
/// 40 because these are tapped repeatedly, fast, by someone watching a game
/// rather than the screen. A 20pt icon's own bounds would be a miss waiting to
/// happen.
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
      enabled: onTap != null,
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}
