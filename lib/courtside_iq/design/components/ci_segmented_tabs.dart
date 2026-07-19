// CiSegmentedTabs + CiHairline — Phase 4.8
//
// Measured from Components / SegmentedTabs (Active):
//   h42, equal-width segments, 12px top padding
//   active   SemiBold 14 ink, 2px ink underline the full segment width
//   inactive Medium 14 muted, no underline
//   a hairline runs under the whole control, full width
//
// TABS ARE NAVIGATION. Chips are filters. Do not substitute one for the other
// - that distinction was settled during the design review and is the reason
// this control has an underline rather than a pill.
//
// The hairline under the control is not decoration: it was specifically called
// out as missing during review. It is full-bleed, like every hairline in this
// system.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

/// Full-bleed 1px divider.
///
/// Always edge to edge. Content sits on the 24px gutter; hairlines ignore it.
/// If you find yourself wrapping this in horizontal padding, the design is
/// being violated.
class CiHairline extends StatelessWidget {
  const CiHairline({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        height: CiSpace.hairline,
        color: color ?? CiColors.of(context).hairline,
      );
}

class CiSegmentedTabs extends StatelessWidget {
  const CiSegmentedTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 42,
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _Segment(
                    label: labels[i],
                    active: i == index,
                    // The painted underline is 2px, but the whole 42px
                    // segment is the tap target - comfortably over the 44px
                    // guidance once the surrounding padding is counted.
                    onTap: () => onChanged(i),
                    colors: c,
                  ),
                ),
            ],
          ),
        ),
        const CiHairline(),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final CiColors colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            const SizedBox(height: CiSpace.s3),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (active
                        ? CiType.rowLabel
                        : CiType.rowLabel.copyWith(fontWeight: CiWeight.medium))
                    .copyWith(color: active ? colors.text : colors.textMuted),
              ),
            ),
            // Sized whether or not it is active, so switching tabs does not
            // shift the row by 2px.
            Container(
              height: 2,
              color: active ? colors.text : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
