// CiInfoSheet — Phase 4.11c
//
// Measured from About Story Sheet (648:2195) and About Growth IQ (691:2845),
// which are the same sheet with different copy:
//
//   grabber  36x4, radius 2, centred, 12 from the top
//   title    Bold 20 at 24/34, close IconButton 40 at right 24 / top 24
//   body     Regular 15.5 / 24 line height, textSoft, 24 side inset
//   CTA      "Got it", LIME, full width, 48 tall
//
// One component, not two screens. The two frames differ only in height (420
// vs 364), and that difference is entirely the length of the paragraph - so
// this sizes to its content rather than pinning a height.
//
// EXPLAIN ONLY. An info sheet never performs an action: its single button
// dismisses it. Anything with a consequence belongs on the screen that owns
// the consequence, not behind a "what is this?" tap.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';
import 'ci_avatar.dart';
import 'ci_button.dart';

/// Presents [CiInfoSheet] with the app's standard modal treatment.
Future<void> showCiInfoSheet(
  BuildContext context, {
  required String title,
  required String body,
  String cta = 'Got it',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CiInfoSheet(title: title, body: body, cta: cta),
  );
}

class CiInfoSheet extends StatelessWidget {
  const CiInfoSheet({
    super.key,
    required this.title,
    required this.body,
    this.cta = 'Got it',
  });

  final String title;
  final String body;

  /// Dismiss label. "Got it", never "OK" or "Close": the parent has just been
  /// told something, and the button should acknowledge that rather than read
  /// as a dialog they need to clear.
  final String cta;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: CiRadius.sheetTopR,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  CiSpace.screen, 18, CiSpace.s4, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      // Aligns the title's optical centre with the close
                      // button beside it, which is 40 tall against a 24 cap.
                      padding: const EdgeInsets.only(top: CiSpace.s2),
                      child: Text(title,
                          style: CiType.h3.copyWith(color: c.text)),
                    ),
                  ),
                  const SizedBox(width: CiSpace.s3),
                  CiIconButton(
                    icon: Icons.close,
                    semanticLabel: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s7),
              child: Text(
                body,
                // 15.5/24 in the frame. Rounded to the body token with the
                // frame's line height kept, since 24/16 is what makes a
                // paragraph this long readable.
                style: CiType.body.copyWith(color: c.textSoft, height: 1.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(CiSpace.screen, 0,
                  CiSpace.screen, CiSpace.s6),
              child: CiButton(
                label: cta,
                // Lime, not ink. This button ends a friendly explanation; it
                // is the one place a positive accent is doing exactly what it
                // says.
                style: CiButtonStyle.lime,
                expand: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
