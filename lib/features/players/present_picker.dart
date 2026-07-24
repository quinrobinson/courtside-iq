// Picker presentation — Phase 4.11d
//
// The 2.0 replacement for presentPickerSheet in picker_sheet.dart. The SHEET
// is CiOptionSheet; this is the part around it, and it exists because that
// part is where v1 learned two things the hard way.
//
// Both are carried over deliberately. Neither is visible in any frame, and
// both would be lost in a re-skin that only looked at the design.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/components/ci_toast.dart';

/// Opens a single-choice sheet and returns the chosen option, or null.
Future<T?> presentCiPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  T? current,
}) async {
  // DROP FOCUS FIRST. Opened from a sheet with a focused TextField, the
  // keyboard's viewInsets shove the new sheet up the screen. The delay lets
  // the keyboard actually leave before the sheet is measured.
  FocusScope.of(context).unfocus();
  await Future<void>.delayed(const Duration(milliseconds: 60));
  if (!context.mounted) return null;

  // NOTHING TO PICK. An empty list produces a near-zero-height sheet, which
  // is indistinguishable from "the picker did not open" - which is exactly
  // how a failed options load presents to a parent. Say so instead.
  if (options.isEmpty) {
    showCiToast(context, 'Could not load options. Check your connection.',
        type: CiToastType.error);
    return null;
  }

  return showCiSheet<T>(
    context,
    child: CiOptionSheet<T>(
      title: title,
      options: options,
      labelOf: labelOf,
      current: current,
    ),
  );
}
