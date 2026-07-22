// CiConfirmDialog — the app's one "are you sure?"
//
// Extracted from the delete-player dialog (Dialog — Confirm · Destructive,
// 370:1886), which was the only styled confirm in the app. Everything else
// that needed one reached for a raw Material AlertDialog and got the
// framework's default typography and blue text - visibly not this app, and
// always at the moment a parent is deciding whether to destroy something.
//
// A DISMISS IS ALWAYS NO. Tapping outside returns null and this reports
// false. Consent has to be explicit, because the confirming action here is
// the one that cannot be undone.
//
// DOES NOT MATCH THE APPROVED FRAMES. Verified against 370:1886 (destructive)
// and 371:1901 (neutral) on 2026-07-22: both draw a CENTERED ExtraBold title,
// centered muted body, then the CONFIRMING ACTION FIRST as a full-width pill -
// orange when destructive, ink when not - with Cancel as a full-width grey
// pill beneath it.
//
// This is a Material AlertDialog with small corner text buttons, Cancel
// first, confirm in orange text. Wrong layout, wrong controls, wrong order.
//
// How it got here: delete_player_dialog was built without reading the frame,
// and this component was extracted from it - so the error was shared to the
// discard dialog rather than found. The paused and resume dialogs DO follow
// the frames, which is why the confirms look foreign next to them.
//
// Fix is one component; both call sites follow. Copy is approved and should
// carry over unchanged - see the gendered-pronoun note in
// delete_player_dialog.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

/// Returns true only on an explicit confirm.
Future<bool> showCiConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',

  /// Paints the confirming action in the energy accent. Off for a confirm
  /// that merely proceeds - spending the accent on those would leave nothing
  /// to distinguish the ones that destroy data.
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final c = CiColors.of(context);
      return AlertDialog(
        backgroundColor: c.bg,
        shape: const RoundedRectangleBorder(borderRadius: CiRadius.dialogR),
        title: Text(title, style: CiType.h3.copyWith(color: c.text)),
        content: Text(
          message,
          style: CiType.body.copyWith(color: c.textSoft, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
            CiSpace.s4, 0, CiSpace.s4, CiSpace.s4),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel,
                style: CiType.rowLabel.copyWith(color: c.text)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel,
                style: CiType.rowLabel
                    .copyWith(color: destructive ? c.accentEnergy : c.text)),
          ),
        ],
      );
    },
  );
  // A tap outside returns null, and null is not consent.
  return result ?? false;
}
