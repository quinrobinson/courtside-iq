// Settings rows — Phase 4.15
//
// Measured from Menu (294:1331) and Your Profile (295:1385), which agree
// exactly, so one component serves both and the seven screens behind them:
//
//   row     52 tall, label SemiBold 17 at 24, value Regular 16 muted
//           RIGHT-ALIGNED and ending at 340, chevron 18 at 348
//   group   uppercase Medium 13 muted at 24, 20 above and 6 below
//   rule    FULL BLEED, x0 to the screen edge
//
// THE HAIRLINES ARE FULL BLEED because these are screens, not sheets. The
// convention was set in 4.11d after inset rules on a screen read as a
// mistake: screens run their rules edge to edge, sheets inset to 24.
//
// The value is right-aligned rather than left-aligned in a fixed column. The
// frame draws it in a 180-wide box ending at 340, and an email long enough to
// fill that box has to meet the chevron, not float away from it.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

/// One tappable settings row.
class CiSettingsRow extends StatelessWidget {
  const CiSettingsRow({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
  });

  final String label;

  /// The current setting: "Free", an email, or "Change" where there is
  /// nothing to show. Muted, because the LABEL is what a parent scans for.
  final String? value;

  final VoidCallback? onTap;

  /// Paints the label in the energy accent. For rows that destroy something.
  final bool destructive;

  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: onTap != null,
      label: value == null ? label : '$label, $value',
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: kCiSettingsRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
            child: Row(
              children: [
                Text(label,
                    style: CiType.rowTitle.copyWith(
                        color: destructive ? c.accentEnergy : c.text,
                        fontWeight: CiWeight.semiBold)),
                const SizedBox(width: CiSpace.s4),
                Expanded(
                  child: value == null
                      ? const SizedBox.shrink()
                      : Text(
                          value!,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CiType.body.copyWith(color: c.textMuted),
                        ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: CiSpace.s2),
                  Icon(Icons.chevron_right, size: 18, color: c.textMuted),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "ACCOUNT", "SUPPORT", "ABOUT" — the uppercase label above a group.
class CiSettingsGroupLabel extends StatelessWidget {
  const CiSettingsGroupLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(CiSpace.screen, 20, CiSpace.screen, 6),
      child: Text(
        // Uppercased HERE rather than expecting call sites to shout. A
        // lowercase group label passed in should still render as the frame
        // draws it.
        label.toUpperCase(),
        style: CiType.rowLabel.copyWith(color: c.textMuted),
      ),
    );
  }
}
