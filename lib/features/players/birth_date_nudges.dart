// Birth-date nudges — Phase 4.11d
//
// Two surfaces asking for the same thing at two volumes:
//
//   Birth Date Prompt (647:2189)   a dialog, shown at most once a week
//   caveat banner (649:2201)       inline, wherever a rating is shown
//
// THE BANNER IS THE HONEST ONE. A rating computed without a birth date is not
// age-normalised, which means it is not what the app says it is. The banner
// sits next to that rating and says so. The dialog just asks.
//
// Both lead to the same birth date sheet. Neither blocks anything: a player
// without a birth date keeps every screen, they just get a rating the app is
// upfront about.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

/// The dialog. Returns true when the parent chose to add one.
///
/// "Not now", never "Cancel". Cancel implies the parent is abandoning
/// something they started; this was the app's idea, and they are allowed to
/// decline it without it reading as a failure.
Future<bool> showBirthDatePrompt(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final c = CiColors.of(context);
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
              Text('Add a birth date',
                  textAlign: TextAlign.center,
                  style: CiType.h3.copyWith(
                      color: c.text, fontWeight: CiWeight.extraBold)),
              const SizedBox(height: 10),
              Text(
                "Adding a birth date calibrates ratings to your player's age "
                'band.',
                textAlign: TextAlign.center,
                style: CiType.bodySm.copyWith(
                    color: c.textSoft,
                    fontWeight: CiWeight.medium,
                    height: 1.43),
              ),
              const SizedBox(height: 18),
              CiButton(
                label: 'Add birth date',
                style: CiButtonStyle.lime,
                expand: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 10),
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
    },
  );
  // Dismissed by tapping outside is a "not now", not a yes.
  return result ?? false;
}

/// The inline caveat, shown beside ratings computed without a birth date.
///
/// NAMES THE PLAYER. "these ratings" alone leaves a parent with two players
/// guessing which one is uncalibrated.
class BirthDateCaveat extends StatelessWidget {
  const BirthDateCaveat({
    super.key,
    required this.firstName,
    required this.onAdd,
  });

  final String firstName;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // Possessive on BOTH branches. Without it the nameless case read "for
    // your player age", which is not a sentence.
    final who = firstName.trim().isEmpty
        ? "your player's"
        : "${firstName.trim()}'s";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceSunk,
          borderRadius: CiRadius.chipR,
        ),
        padding: const EdgeInsets.symmetric(horizontal: CiSpace.s4),
        constraints: const BoxConstraints(minHeight: 72),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: CiSpace.s4),
                child: Text(
                  'Add a birth date to calibrate these ratings for $who age.',
                  style: CiType.bodySm.copyWith(
                      color: c.textSoft,
                      fontWeight: CiWeight.medium,
                      height: 1.36),
                ),
              ),
            ),
            const SizedBox(width: CiSpace.s3),
            CiButton(
              label: 'Add',
              style: CiButtonStyle.lime,
              size: CiButtonSize.sm,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
