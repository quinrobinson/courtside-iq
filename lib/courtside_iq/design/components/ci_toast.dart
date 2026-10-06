// CiToast — the app's toast / snackbar. Phase 4.19d
//
// Measured from Snackbar — Error / Success (521:2009):
//
//   chip     #141414, radius 6, padding 16/18, 12 gap, floating above the
//            tab bar, dismissing after a few seconds
//   dot      10, and it CARRIES THE MEANING: orange = problem, lime = done
//   message  white, 14.5 Medium, up to two lines
//   action   optional, trailing, 14.5 SemiBold in the status accent ("Retry")
//
// FIXED DARK, NOT GROUND-DEPENDENT. A toast floats over whatever screen is up -
// a white Today or a dark auth - so it owns its colours instead of reading
// CiColors.of(context). White on #141414 is legible on both; a ground-aware
// toast would flip to ink text on the light screens and vanish.
//
// THE DOT REPLACES AN ICON on purpose: it is the same dot language as the rest
// of the system, and one 10px disc says success/failure without a glyph set.
//
// A styled floating SnackBar rather than a bespoke overlay, so it reuses the
// platform's timing and swipe-to-dismiss and drops into every existing
// ScaffoldMessenger call site unchanged.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_type.dart';

enum CiToastType { neutral, success, error }

extension _Dot on CiToastType {
  Color get color => switch (this) {
        CiToastType.success => CiPalette.lime,
        CiToastType.error => CiPalette.orange,
        // Pure information, neither win nor failure: a plain white dot.
        CiToastType.neutral => CiPalette.white,
      };

  /// Errors linger; a confirmation should not overstay.
  Duration get duration => this == CiToastType.error
      ? const Duration(seconds: 5)
      : const Duration(seconds: 3);
}

/// Shows a toast. [type] sets the dot colour and how long it stays. Pass
/// [actionLabel] + [onAction] for a trailing tap (a save that offers "Retry").
void showCiToast(
  BuildContext context,
  String message, {
  CiToastType type = CiToastType.neutral,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final hasAction = actionLabel != null && onAction != null;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: CiPalette.inkRaised,
      behavior: SnackBarBehavior.floating,
      // 24 each side matches the 342 chip on a 390 screen; a small bottom
      // gap floats it clear of the very edge. Floating already respects the
      // system inset.
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      elevation: 6,
      duration: duration ?? type.duration,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      content: _CiToastContent(
        message: message,
        dotColor: type.color,
        actionLabel: hasAction ? actionLabel : null,
        onAction: hasAction
            ? () {
                messenger.hideCurrentSnackBar();
                onAction();
              }
            : null,
      ),
    ));
}

class _CiToastContent extends StatelessWidget {
  const _CiToastContent({
    required this.message,
    required this.dotColor,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final Color dotColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CiType.bodySm.copyWith(
                color: CiPalette.white,
                fontSize: 14.5,
                fontWeight: CiWeight.medium,
                height: 1.3,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionLabel!,
                style: CiType.bodySm.copyWith(
                  // The action echoes the status accent - orange on an error,
                  // as the frame draws "Retry".
                  color: dotColor,
                  fontSize: 14.5,
                  fontWeight: CiWeight.semiBold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
