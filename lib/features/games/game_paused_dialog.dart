// Game Paused — Phase 4.13
//
// Measured from 459:1934: a 312-wide white dialog over a near-black scrim,
// holding the player, the matchup, the score so far, and two ways out.
//
// IT SHOWS THE SCORE. A parent pausing mid-game is usually checking something
// - did that basket count, what is the assist tally - so the dialog answers
// the likely question rather than only asking one.
//
// NO DISMISS BY TAPPING OUTSIDE, and no X. Both routes out are deliberate,
// because one of them ends the game. A stray tap on the scrim resuming is
// fine; a stray tap ending is not, so neither is offered.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'live_game_store.dart';

/// What the parent chose.
enum PausedChoice { resume, end }

/// Shows the paused dialog. Returns [PausedChoice.resume] on dismissal.
///
/// Dismissal resumes because that is the harmless answer: the game is still
/// running either way, and treating a stray tap as "end" would throw away a
/// game a parent is still tracking.
Future<PausedChoice> showGamePausedDialog(
  BuildContext context, {
  required LiveGameSnapshot snapshot,
}) async {
  final result = await showDialog<PausedChoice>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xFF0A0A0A).withValues(alpha: 0.92),
    builder: (context) => _PausedDialog(snapshot: snapshot),
  );
  return result ?? PausedChoice.resume;
}

class _PausedDialog extends StatelessWidget {
  const _PausedDialog({required this.snapshot});

  final LiveGameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final s = snapshot.stats;
    final opponent = (snapshot.opponent ?? '').trim();

    return Dialog(
      backgroundColor: c.bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 39),
      shape: const RoundedRectangleBorder(borderRadius: CiRadius.dialogR),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            CiSpace.screen, 28, CiSpace.screen, CiSpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game paused',
                style: CiType.h3
                    .copyWith(color: c.text, fontWeight: CiWeight.extraBold)),
            const SizedBox(height: CiSpace.s5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CiAvatar(name: snapshot.playerName, size: 36),
                const SizedBox(width: CiSpace.s3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.playerName,
                        style: CiType.bodySm.copyWith(
                            color: c.text, fontWeight: CiWeight.semiBold)),
                    if (opponent.isNotEmpty)
                      Text('vs $opponent',
                          style:
                              CiType.caption.copyWith(color: c.textSoft)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: CiSpace.s5),
            Row(
              children: [
                _Mini(value: s.points, label: 'PTS'),
                _Mini(value: s.rebounds, label: 'REB'),
                _Mini(value: s.assists, label: 'AST'),
                _Mini(value: s.steals, label: 'STL'),
                _Mini(value: s.turnovers, label: 'TO'),
              ],
            ),
            const SizedBox(height: CiSpace.s6),
            CiButton(
              label: 'Resume',
              style: CiButtonStyle.lime,
              expand: true,
              onPressed: () =>
                  Navigator.of(context).pop(PausedChoice.resume),
            ),
            const SizedBox(height: 10),
            CiButton(
              label: 'End game',
              // Secondary, not orange. Ending a game is the normal way a game
              // finishes - it leads to the save screen, not to data loss - so
              // dressing it as destructive would be a lie.
              style: CiButtonStyle.secondary,
              expand: true,
              onPressed: () => Navigator.of(context).pop(PausedChoice.end),
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
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: CiType.rowTitle.copyWith(color: c.text)),
          const SizedBox(height: 2),
          Text(label,
              style: CiType.badge.copyWith(
                  color: c.textSoft, fontWeight: CiWeight.medium)),
        ],
      ),
    );
  }
}
