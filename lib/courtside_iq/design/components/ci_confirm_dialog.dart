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
// Cancel reads first and is the plain choice; the destructive action is the
// one wearing the accent. That ordering is deliberate and should not be
// flipped per call site.

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
