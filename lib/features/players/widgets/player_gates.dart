// Player gate surfaces — Phase 4.11a.2
//
// Two states, measured from Add Player Gate (Free) 652:2192 and 3-Player Cap
// State 651:2199. They are deliberately different SHAPES because they mean
// different things:
//
//   upgrade gate  a bottom SHEET on ink: dot-burst mark, "Track more players",
//                 a benefit checklist, lime "See plans", "Not now".
//                 An invitation, so it arrives from the bottom like an offer.
//
//   cap reached   a centred DIALOG on light: "You've reached 3 players",
//                 lime "Manage players", "Not now".
//                 A limit, so it interrupts and asks for a decision.
//
// THE CAP DIALOG DOES NOT SELL. The parent already pays; offering them premium
// at their own cap would be insulting. It offers management instead.
//
// Roadmap 3.8 adds two GAME gates on the same ink sheet (Figma 1182:5313 and
// the offline-held 1182:5370). All three share _InkGateSheet so they cannot
// drift apart.
//
// Display and routing only - no surface here reads or writes entitlement.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/player_gating.dart';

/// The free-tier upgrade gate. Returns true if the parent chose to see plans.
Future<bool> showAddPlayerUpgradeGate(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    // Covers the nav bar: a sheet pushed on a shell BRANCH navigator
    // renders inside the branch, leaving the tabs sitting over it.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _InkGateSheet(
      title: 'Track more players',
      body: 'Free includes $kFreePlayerLimit player. '
          'Go Premium to track up to $kPremiumPlayerLimit.',
      benefits: [
        'Track up to $kPremiumPlayerLimit players',
        'Development trends over time',
        'The full player story',
      ],
      quietLabel: 'Not now',
    ),
  );
  return result ?? false;
}

/// The free-tier GAME gate (roadmap 3.8, Figma 1182:5313): a free parent
/// starting a 4th game. Same ink sheet family as the player gate. Returns true
/// if the parent chose to see plans.
///
/// The line names no number on purpose, so it stays true for accounts that
/// were already over three games when the limit arrived.
Future<bool> showGameLimitGate(
  BuildContext context, {
  String? playerFirstName,
}) =>
    _showInkGate(
      context,
      _InkGateSheet(
        title: "You've used your $kFreeGameLimit free games",
        body: playerFirstName == null
            ? 'Your games and insights stay right where they are. '
                'Go Premium to keep tracking.'
            : "$playerFirstName's games and insights stay right where they "
                'are. Go Premium to keep tracking.',
        benefits: [
          'Unlimited games every season',
          'Track up to $kPremiumPlayerLimit players',
          playerFirstName == null
              ? 'Growth IQ and the player story keep building'
              : "Growth IQ and $playerFirstName's story keep building",
        ],
        quietLabel: 'Not now',
      ),
    );

/// The offline-held variant (Figma 1182:5370): a 4th game tracked with no
/// signal that the server refused at sync. The game is NOT lost - it stays on
/// the phone indefinitely - so the quiet action says so instead of "Not now",
/// which could read as discarding it. Returns true if the parent chose plans.
Future<bool> showOfflineGameHeldGate(
  BuildContext context, {
  String? opponent,
  String? playerFirstName,
}) {
  final who = playerFirstName == null ? 'your' : "$playerFirstName's";
  final hasOpponent = opponent != null && opponent.trim().isNotEmpty;
  return _showInkGate(
    context,
    _InkGateSheet(
      title: 'Your game is safe on this phone',
      body: hasOpponent
          ? 'You tracked a game vs ${opponent.trim()} offline after your '
              '$kFreeGameLimit free games. Go Premium to add it to $who games.'
          : 'You tracked a game offline after your $kFreeGameLimit free '
              'games. Go Premium to add it to $who games.',
      benefits: [
        'Unlimited games every season',
        'Track up to $kPremiumPlayerLimit players',
        playerFirstName == null
            ? 'Growth IQ and the player story keep building'
            : "Growth IQ and $playerFirstName's story keep building",
      ],
      quietLabel: 'Keep it on this phone',
    ),
  );
}

Future<bool> _showInkGate(BuildContext context, Widget sheet) async {
  final result = await showModalBottomSheet<bool>(
    // Covers the nav bar, as the player gate does.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
  return result ?? false;
}

/// The premium cap notice. Returns true if the parent chose to manage players.
Future<bool> showPlayerCapReached(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _CapDialog(),
  );
  return result ?? false;
}

/// The ink upgrade sheet shared by the player gate and the two game gates, so
/// the three cannot drift apart (Figma 652:2192, 1182:5313, 1182:5370).
class _InkGateSheet extends StatelessWidget {
  const _InkGateSheet({
    required this.title,
    required this.body,
    required this.benefits,
    required this.quietLabel,
  });

  final String title;
  final String body;
  final List<String> benefits;
  final String quietLabel;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grab handle: this arrived from the bottom and can be
                // dismissed by dragging, which the handle is what says.
                const CiSheetHandle(),
                const SizedBox(height: CiSpace.s7),
                // The mark alone at 64 (Figma 652:2192, 2026-09-28): the
                // Dot-burst C is itself a burst, so the old burst went.
                const CiLogoMark(size: 64),
                const SizedBox(height: CiSpace.s5),
                Text(title,
                    textAlign: TextAlign.center,
                    style: CiType.h3.copyWith(color: c.text)),
                const SizedBox(height: CiSpace.s2),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: CiType.bodySm.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: CiSpace.s6),
                for (final b in benefits) _Benefit(b),
                const SizedBox(height: CiSpace.s7),
                CiButton(
                  label: 'See plans',
                  style: CiButtonStyle.lime,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: CiSpace.s2),
                _QuietAction(
                  label: quietLabel,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CiSpace.s3),
      child: Row(
        children: [
          Icon(Icons.check, size: 18, color: c.text),
          const SizedBox(width: CiSpace.s3),
          Expanded(
            child: Text(label,
                style: CiType.bodySm.copyWith(color: c.text)),
          ),
        ],
      ),
    );
  }
}

class _CapDialog extends StatelessWidget {
  const _CapDialog();

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      paint: false,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Dialog(
          backgroundColor: c.surface,
          shape: const RoundedRectangleBorder(borderRadius: CiRadius.dialogR),
          insetPadding: const EdgeInsets.symmetric(horizontal: CiSpace.s8),
          child: Padding(
            padding: const EdgeInsets.all(CiSpace.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("You've reached $kPremiumPlayerLimit players",
                    textAlign: TextAlign.center,
                    style: CiType.h4.copyWith(
                        color: c.text, fontWeight: CiWeight.extraBold)),
                const SizedBox(height: CiSpace.s2),
                Text(
                  'Your plan tracks up to $kPremiumPlayerLimit players at a '
                  'time. Remove a player to add a new one.',
                  textAlign: TextAlign.center,
                  style: CiType.bodySm.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: CiSpace.s6),
                CiButton(
                  label: 'Manage players',
                  style: CiButtonStyle.lime,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: CiSpace.s2),
                CiButton(
                  label: 'Not now',
                  style: CiButtonStyle.secondary,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _QuietAction extends StatelessWidget {
  const _QuietAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        child: Padding(
          // Padded to a real touch target; the label alone is too short.
          padding: const EdgeInsets.symmetric(
              vertical: CiSpace.s3, horizontal: CiSpace.s4),
          child: Text(label,
              style: CiType.bodySm.copyWith(color: c.textMuted)),
        ),
      ),
    );
  }
}
