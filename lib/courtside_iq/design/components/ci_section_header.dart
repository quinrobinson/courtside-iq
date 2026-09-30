// CiSectionHeader — Phase 4.11b
//
// Measured from Components / SectionHeader (91:174):
//   56 tall, padding 24 horizontal / 18 vertical, full-bleed hairline BELOW
//   title     SemiBold 15
//   trailing  Medium 13, right-aligned, optional
//
// The hairline is under the header, never over it, so the header reads as the
// top of the section it labels rather than as a floating caption.
//
// Promoted from Today's private FeedSectionHeader once the profile tabs
// needed the same band. Two private copies of a shared band is how the same
// header ends up 2px different on two screens.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

/// Height of a section band. Shared with the action rows that close a section
/// (Today's "View All Games"), so a section is bounded by two matching bands.
const double kCiSectionBandHeight = 56;

class CiSectionHeader extends StatelessWidget {
  const CiSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;

  /// Right-hand qualifier: "Per Game", "14 Games". Not an action label unless
  /// [onTrailingTap] is given.
  final String? trailing;

  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    Widget band = SizedBox(
      height: kCiSectionBandHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: CiType.rowTitle.copyWith(color: c.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: CiType.labelTight.copyWith(
                      color: onTrailingTap == null ? c.textFaint : c.text)),
          ],
        ),
      ),
    );

    if (onTrailingTap != null) {
      band = InkWell(onTap: onTrailingTap, child: band);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        band,
        Container(height: CiSpace.hairline, color: c.hairline),
      ],
    );
  }
}
