// Feedback sent — Phase 4.15c
//
// Measured from 667:2553: a 440-tall sheet holding a 72pt lime disc with a
// white check, "Thanks, we've got it" at ExtraBold 23, a line of reassurance
// at Regular 15 muted, and a lime "Done".
//
// The frame still carries a "Position" title and an X in its top corner, left
// over from the Edit Position sheet it was duplicated from. Both are dropped
// here: a confirmation has one way out and it is the button.
//
// IT SAYS WHAT HAPPENS NEXT. "We read every note. If we need more, we'll
// reach out by email." The feedback table is insert-only, so there is no
// sent-items list a parent can check - this sentence is the entire receipt.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

Future<void> showFeedbackSentSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    // Covers the nav bar: a sheet pushed on a shell BRANCH navigator
    // renders inside the branch, leaving the tabs sitting over it.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // No dismissing by tapping away. There is one thing to do here and the
    // sheet is confirming something already done, so a stray tap should not
    // be the way it closes.
    isDismissible: false,
    enableDrag: false,
    builder: (context) => const _FeedbackSentSheet(),
  );
}

class _FeedbackSentSheet extends StatelessWidget {
  const _FeedbackSentSheet();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // NOT CiSheet. That shell requires a title and draws a close X - which is
    // exactly where the frame's leftover "Position" header and X came from.
    // A confirmation has one way out and it is the button.
    return ColoredBox(
      color: c.bg,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grabber at the top of the sheet, then a full gap before the
            // check. It used to sit ON the disc: the whole column was inset by
            // s7 and nothing separated the handle from the 72pt circle.
            const CiSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  CiSpace.screen, CiSpace.s6, CiSpace.screen, CiSpace.s6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wash disc, ink check: the solid lime disc shouted next to
                  // the lime Done button below it. The wash keeps the success
                  // colour without competing with the one real action.
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: c.accentGoodWash, shape: BoxShape.circle),
                    child: Icon(Icons.check, size: 34, color: c.text),
                  ),
                  const SizedBox(height: CiSpace.s6),
                  Text('Thanks, we\'ve got it',
                      textAlign: TextAlign.center,
                      style: CiType.h2.copyWith(
                          color: c.text, fontWeight: CiWeight.extraBold)),
                  const SizedBox(height: CiSpace.s3),
                  Text(
                    "We read every note. If we need more, we'll reach out by email.",
                    textAlign: TextAlign.center,
                    style:
                        CiType.body.copyWith(color: c.textSoft, height: 1.45),
                  ),
                  const SizedBox(height: CiSpace.s7),
                  CiButton(
                    label: 'Done',
                    style: CiButtonStyle.lime,
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
