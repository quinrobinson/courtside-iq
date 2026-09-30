// The quiet "tell me more" link: an info circle and a muted caption.
//
// Extracted 2026-09-29 from the "About insights" link under the game insight
// card, so the game timeline's "How to read this" is the SAME control rather
// than a near copy (Quin: one shared component, not per-screen lookalikes).
// It carries no ground of its own and no padding, so each caller owns its
// spacing; the timeline key depends on that to hold the link still while it
// opens.

import 'package:flutter/material.dart';

import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

class CiInfoLink extends StatelessWidget {
  const CiInfoLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 15, color: c.textMuted),
          const SizedBox(width: 6),
          Text(label, style: CiType.caption.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}
