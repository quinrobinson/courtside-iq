// CiInfoSheet — Phase 4.11c
//
// Measured from About Story Sheet (648:2195) and About Growth IQ (691:2845),
// which are the same sheet with different copy - the 56pt height difference
// between the frames is entirely the length of the paragraph.
//
// The shell (grabber, title, close, lime CTA, square corners) is CiSheet.
// This adds only the paragraph.
//
// EXPLAIN ONLY. An info sheet never performs an action: its single button
// dismisses it. Anything with a consequence belongs on the screen that owns
// the consequence, not behind a "what is this?" tap.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';
import 'ci_sheet.dart';

/// Presents [CiInfoSheet] with the app's standard modal treatment.
Future<void> showCiInfoSheet(
  BuildContext context, {
  required String title,
  required String body,
  String cta = 'Got it',
}) {
  return showCiSheet<void>(
    context,
    child: CiInfoSheet(title: title, body: body, cta: cta),
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

    return CiSheet(
      title: title,
      cta: cta,
      onCta: () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            CiSpace.screen, CiSpace.s5, CiSpace.screen, 0),
        child: Text(
          body,
          // 15.5/24 in the frame. Rounded to the body token with the frame's
          // line height kept, since 24/16 is what makes a paragraph this long
          // readable.
          style: CiType.body.copyWith(color: c.textSoft, height: 1.5),
        ),
      ),
    );
  }
}
