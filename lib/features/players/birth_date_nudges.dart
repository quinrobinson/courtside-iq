// Birth-date nudges — Phase 4.11d
//
// The proactive ask: a dialog on Today, at most once a week per player.
//
// THE CAVEAT BANNER (frame 649:2201) IS DELIBERATELY NOT HERE. It was
// designed to sit beside an uncalibrated rating and say so, which was the
// right answer while the app scored a player of unknown age against an
// assumed band. Since "no birth date, no rating" landed there IS no
// uncalibrated rating on any screen, so the banner had nothing left to
// caveat - and on the Development tab it put the same sentence on screen
// twice, above a full empty state saying it already.
//
// The Development tab's empty state is where the ask lives now. This dialog
// is the only other one, and it blocks nothing.

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
