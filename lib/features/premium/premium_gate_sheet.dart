// Premium gate sheet — Phase 4.16
//
// Measured from 335:1881: a light bottom sheet with the logo, "A Premium
// feature", a one-line reason, three ticked benefits, a lime "See plans" and
// a muted "Not now".
//
// NO PRICES HERE. This is the doorway, not the paywall. It says what premium
// is for and hands off to the carousel, which is where money is discussed. A
// parent who hit the player cap wants to know why first, not be sold to
// before they understand what they would get.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/player_gating.dart';

/// Shows the gate sheet. Returns true if the parent chose "See plans", so the
/// caller opens the paywall; false or null on "Not now" or a dismiss.
Future<bool?> showPremiumGateSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    // Covers the nav bar: a sheet pushed on a shell BRANCH navigator
    // renders inside the branch, leaving the tabs sitting over it.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _PremiumGateSheet(),
  );
}

const List<String> _benefits = [
  'Game-by-game insights',
  'Development trends over time',
  'The full player story',
];

class _PremiumGateSheet extends StatelessWidget {
  const _PremiumGateSheet();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return ColoredBox(
      color: c.bg,
      child: SafeArea(
        top: false,
        child: Padding(
          // Top padding is 0: the handle carries its own inset and has to
          // sit at the top of the panel, not below the content margin.
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, 0, CiSpace.screen, CiSpace.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CiSheetHandle(),
              const SizedBox(height: CiSpace.s5),
              const CiLogoMark(size: 30),
              const SizedBox(height: CiSpace.s5),
              Text('A Premium feature',
                  style: CiType.h3.copyWith(
                      color: c.text, fontWeight: CiWeight.extraBold)),
              const SizedBox(height: CiSpace.s3),
              Text(
                "You're at your $kFreePlayerLimit free player. "
                'Premium tracks up to $kPremiumPlayerLimit.',
                textAlign: TextAlign.center,
                style: CiType.bodySm.copyWith(color: c.textMuted, height: 1.4),
              ),
              const SizedBox(height: CiSpace.s6),
              for (final benefit in _benefits) ...[
                _Benefit(label: benefit),
                const SizedBox(height: CiSpace.s3),
              ],
              const SizedBox(height: CiSpace.s4),
              CiButton(
                label: 'See plans',
                style: CiButtonStyle.lime,
                expand: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: CiSpace.s2),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Not now',
                    style: CiType.body.copyWith(color: c.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Row(
      children: [
        Icon(Icons.check, size: 18, color: c.accentGood),
        const SizedBox(width: CiSpace.s3),
        Expanded(
          child: Text(label,
              style: CiType.bodySm.copyWith(color: c.text)),
        ),
      ],
    );
  }
}
