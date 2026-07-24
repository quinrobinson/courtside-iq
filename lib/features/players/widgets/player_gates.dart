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
// Display and routing only - neither surface reads or writes entitlement.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
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
    builder: (_) => const _UpgradeGateSheet(),
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

class _UpgradeGateSheet extends StatelessWidget {
  const _UpgradeGateSheet();

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
                DotBurst(
                  size: 120,
                  markSize: 32,
                  child: CiLogoMark(size: 32, color: c.text),
                ),
                const SizedBox(height: CiSpace.s5),
                Text('Track more players',
                    textAlign: TextAlign.center,
                    style: CiType.h3.copyWith(color: c.text)),
                const SizedBox(height: CiSpace.s2),
                Text(
                  'Free includes $kFreePlayerLimit player. '
                  'Go Premium to track up to $kPremiumPlayerLimit.',
                  textAlign: TextAlign.center,
                  style: CiType.bodySm.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: CiSpace.s6),
                const _Benefit('Track up to $kPremiumPlayerLimit players'),
                const _Benefit('Development trends over time'),
                const _Benefit('The full player story'),
                const SizedBox(height: CiSpace.s7),
                CiButton(
                  label: 'See plans',
                  style: CiButtonStyle.lime,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: CiSpace.s2),
                _QuietAction(
                  label: 'Not now',
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
