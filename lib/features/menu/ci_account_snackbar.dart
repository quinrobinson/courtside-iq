// Account confirmations — Phase 4.15b
//
// Name, email and password have no confirmation FRAME. Success Confirmation
// (667:2553) reads "Thanks, we've got it. We read every note." - that is Send
// Feedback's, not a generic one, and pressing it into service here would put
// feedback copy after a password change.
//
// So these use the snackbar pattern (521:2009), which is also how v1 confirms
// exactly these three. Lime for success, orange for failure, matching every
// other place those two accents are spent.

import 'package:flutter/material.dart';

import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

void showAccountResult(
  BuildContext context, {
  required String message,
  bool success = true,
}) {
  final c = CiColors.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        message,
        // Ink on both, because both grounds are bright. White on lime is
        // unreadable and this is the one line telling a parent whether their
        // change took.
        style: CiType.bodySm.copyWith(color: c.onAccent),
      ),
      backgroundColor: success ? c.accentGood : c.accentEnergy,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: success ? 3 : 5),
    ));
}
