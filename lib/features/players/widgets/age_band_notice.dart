// Age-band transition notice — Phase 4.11b
//
// Measured from AgeBandTransition (687:2892): sits directly under the tabs,
// 16 top / 4 bottom, 24 side. Card on sunk fill, radius 6, padding 16/14,
// title SemiBold 15, body Medium 13 muted, dismiss X 16 at the top right.
//
// The tone is deliberately NOT a warning. A player moving up an age band is
// a milestone, and the note's job is to explain why their numbers may shift
// before a parent reads the shift as their child getting worse.

import 'package:flutter/material.dart';

import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

class AgeBandNotice extends StatelessWidget {
  const AgeBandNotice({
    super.key,
    required this.firstName,
    required this.ageBand,
    this.onDismiss,
  });

  final String firstName;
  final String ageBand;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final who = firstName.trim().isEmpty ? 'Your player' : firstName.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s1),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceSunk,
          borderRadius: CiRadius.chipR,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: CiSpace.s4, vertical: CiSpace.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$who moved up to $ageBand',
                      style: CiType.rowTitle.copyWith(color: c.text)),
                  const SizedBox(height: 5),
                  Text(
                    'Ratings are now calibrated for the $ageBand age band, '
                    'so comparisons stay fair.',
                    style: CiType.labelTight
                        .copyWith(color: c.textMuted, height: 1.3),
                  ),
                ],
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: CiSpace.s3),
              Semantics(
                button: true,
                label: 'Dismiss',
                child: InkWell(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 16, color: c.textMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
