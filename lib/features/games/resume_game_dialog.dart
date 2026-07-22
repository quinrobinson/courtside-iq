// Resume Game — Phase 4.13
//
// Measured from 379:1901: a 312-wide white dialog over a near-black scrim,
// "Game in progress" ExtraBold 19, then a ruled block holding the matchup and
// the running stats, then Resume in lime over Discard in grey.
//
// THIS IS THE ONLY DOOR BACK TO A GAME THE APP LOST. Backgrounding keeps the
// tracker on screen; a force-quit, a crash or a flat battery does not. The
// snapshot survives all three, and without this dialog it survives
// unreachably - which is the same as losing it, from a parent's side.
//
// It shows the stats for the same reason the paused dialog does: the parent is
// deciding whether this is the game they think it is, and the score answers
// that faster than the matchup alone.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'live_game_store.dart';

/// What the parent chose.
enum ResumeChoice { resume, discard }

/// Shows the resume dialog. Returns null if it was dismissed.
///
/// DISMISSING CHANGES NOTHING. Neither answer is safe to assume: resuming
/// would hijack a parent who tapped the row to see what it was, and
/// discarding would delete a tracked game on a stray tap. So a dismissal
/// leaves the snapshot exactly where it was, and the row is still there.
Future<ResumeChoice?> showResumeGameDialog(
  BuildContext context, {
  required LiveGameSnapshot snapshot,
}) {
  return showDialog<ResumeChoice>(
    context: context,
    barrierColor: const Color(0xFF0A0A0A).withValues(alpha: 0.92),
    builder: (context) => _ResumeDialog(snapshot: snapshot),
  );
}

class _ResumeDialog extends StatelessWidget {
  const _ResumeDialog({required this.snapshot});

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 28),
          Text('Game in progress',
              style: CiType.h3
                  .copyWith(color: c.text, fontWeight: CiWeight.extraBold)),
          const SizedBox(height: 10),
          // Ruled top AND bottom, which is what separates this from the
          // paused dialog: there the stats are the whole point, here they are
          // evidence for a decision, so they sit in their own band.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: c.border),
                bottom: BorderSide(color: c.border),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: CiSpace.screen, vertical: CiSpace.s4),
            child: Column(
              children: [
                Row(
                  children: [
                    CiAvatar(name: snapshot.playerName, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(snapshot.playerName,
                              style: CiType.bodySm.copyWith(
                                  color: c.text,
                                  fontWeight: CiWeight.semiBold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (opponent.isNotEmpty)
                            Text('vs $opponent',
                                style: CiType.caption
                                    .copyWith(color: c.textSoft),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Mini(value: s.points, label: 'PTS'),
                    _Mini(value: s.rebounds, label: 'REB'),
                    _Mini(value: s.assists, label: 'AST'),
                    _Mini(value: s.steals, label: 'STL'),
                    _Mini(value: s.turnovers, label: 'TO'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, 18, CiSpace.screen, CiSpace.s5),
            child: Column(
              children: [
                CiButton(
                  label: 'Resume game',
                  style: CiButtonStyle.lime,
                  expand: true,
                  onPressed: () =>
                      Navigator.of(context).pop(ResumeChoice.resume),
                ),
                const SizedBox(height: 10),
                CiButton(
                  label: 'Discard game',
                  // Grey, not orange. The frame's judgement, and the right
                  // one: this button destroys a tracked game, so it should
                  // not be the eye-catching one on the dialog.
                  style: CiButtonStyle.secondary,
                  expand: true,
                  onPressed: () =>
                      Navigator.of(context).pop(ResumeChoice.discard),
                ),
              ],
            ),
          ),
        ],
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
        Text('$value',
            style: CiType.body
                .copyWith(color: c.text, fontWeight: CiWeight.semiBold)),
        const SizedBox(height: 2),
        Text(label,
            style: CiType.micro.copyWith(
                color: c.textSoft,
                fontWeight: CiWeight.medium,
                letterSpacing: 0.18)),
      ],
    );
  }
}
