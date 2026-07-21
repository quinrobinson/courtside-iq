// Delete player confirmation — Phase 4.11d
//
// THE ONLY SAFETY NET. Deleting a player cascades: their games, their stats,
// their teams, their development insights and their trend snapshots all go
// with them. There is no undo and no soft delete, so this dialog is the
// entire distance between a mis-tap and a season of a child's history being
// gone.
//
// Copy approved 2026-07-21. Three things it does deliberately:
//
//   NAMES THE PLAYER. "Delete player?" is a category; "Delete Maya?" is the
//   actual consequence, and it is what makes a wrong tap obvious.
//   SAYS WHAT ELSE GOES. A parent thinking they are tidying up a roster has
//   to know the games go too.
//   SAYS IT CANNOT BE UNDONE, plainly, rather than implying it.
//
// Cancel is the default action and reads first.

import 'package:flutter/material.dart';

import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

/// Returns true only on an explicit confirm. A dismiss is a NO.
Future<bool> showDeletePlayerDialog(
  BuildContext context, {
  required String firstName,
}) async {
  final who = firstName.trim().isEmpty ? 'this player' : firstName.trim();
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final c = CiColors.of(context);
      return AlertDialog(
        backgroundColor: c.bg,
        shape: const RoundedRectangleBorder(borderRadius: CiRadius.dialogR),
        title: Text('Delete $who?',
            style: CiType.h3.copyWith(color: c.text)),
        content: Text(
          // "them", not "her". The copy approved for review said "her"
          // because the mock player is Maya, but the app NEVER RECORDS A
          // PLAYER'S GENDER - there is no such column and no such question in
          // the add form. A gendered pronoun here would be a guess, and it
          // would be wrong for some real child on the first day it shipped.
          'This removes $who and every game you have logged for them. '
          'It cannot be undone.',
          style: CiType.body.copyWith(color: c.textSoft, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
            CiSpace.s4, 0, CiSpace.s4, CiSpace.s4),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: CiType.rowLabel.copyWith(color: c.text)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete',
                style: CiType.rowLabel.copyWith(color: c.accentEnergy)),
          ),
        ],
      );
    },
  );
  // A tap outside returns null, and null is not consent.
  return result ?? false;
}
