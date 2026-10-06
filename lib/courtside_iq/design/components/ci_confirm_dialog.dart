// CiConfirmDialog — the app's one "are you sure?"
//
// Measured from 370:1886 (destructive) and 371:1901 (neutral): a 312-wide
// white dialog, radius 18, pt 28 / pb 20 / px 24, centered ExtraBold 19 title
// over centered Medium 14 body, then two full-width pills stacked with 10
// between them.
//
// THE CONFIRMING ACTION COMES FIRST, on top, and it is the filled one -
// orange when it destroys something, ink when it merely proceeds. Cancel sits
// beneath it in grey.
//
// That ordering is the frame's and it is worth stating why it is safe: the
// destructive button is not the easy one to hit by accident, because reaching
// this dialog at all took a deliberate tap on Discard or Delete. What the
// parent needs here is to see plainly WHAT they are about to do, and burying
// it under Cancel would make the dialog quieter than the act.
//
// A DISMISS IS ALWAYS NO. Tapping outside returns null and this reports
// false. Consent has to be explicit, because the confirming action here is
// the one that cannot be undone.
//
// It was previously a Material AlertDialog with small corner text buttons and
// Cancel first - built from reasoning without reading the frame, then
// extracted into this component, so the error reached a second call site
// instead of being found. Corrected 2026-07-22 against both frames.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';
import 'ci_button.dart';

/// Returns true only on an explicit confirm.
Future<bool> showCiConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',

  /// Paints the confirming action orange. Off for a confirm that merely
  /// proceeds, which takes ink instead (371:1901) - spending the accent on
  /// those would leave nothing to mark the ones that destroy data.
  bool destructive = true,
}) async {
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: CiType.h3
                    .copyWith(color: c.text, fontWeight: CiWeight.extraBold),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: CiType.bodySm
                    .copyWith(color: c.textSoft, height: 20 / 14),
              ),
              const SizedBox(height: 18),
              CiButton(
                label: confirmLabel,
                style: destructive
                    ? CiButtonStyle.orange
                    : CiButtonStyle.primary,
                expand: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 10),
              CiButton(
                label: cancelLabel,
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
  // A tap outside returns null, and null is not consent.
  return result ?? false;
}
