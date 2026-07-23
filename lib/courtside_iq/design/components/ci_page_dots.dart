// CiPageDots — Phase 4.10
//
// Paging indicator: the active page is a wide pill, the rest are dots.
//
// Shape carries position, not colour alone, so it survives a glance and does
// not depend on colour perception. Measured from Today's hero (active 18x6,
// inactive 6x6) and used by Onboarding at the same proportions.
//
// Extracted on its second use rather than copied. The first copy lived inside
// onboarding_page.dart; a second would have been the point where the two
// quietly drifted apart.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';

class CiPageDots extends StatelessWidget {
  const CiPageDots({
    super.key,
    required this.count,
    required this.index,
    this.activeColor,
    this.inactiveColor,
  });

  final int count;
  final int index;

  /// Default to the ground's text colour and its faint counterpart.
  final Color? activeColor;
  final Color? inactiveColor;

  static const double _dot = 6;
  static const double _pill = 18;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    // ONE PAGE IS NOT A CAROUSEL. A lone dot invites a swipe that does
    // nothing, which reads as a broken control rather than a complete one.
    if (count < 2) return const SizedBox.shrink();

    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        // HUGS its dots. With the default max it filled the row and centred
        // internally, so a parent's Align(centerLeft) did nothing - the
        // paywall's dots stayed centred through two attempted fixes.
        // Alignment is the parent's call now; a Column still centres it.
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: _dot,
              width: i == index ? _pill : _dot,
              decoration: BoxDecoration(
                color: i == index
                    ? (activeColor ?? c.text)
                    : (inactiveColor ?? c.textFaint),
                borderRadius: BorderRadius.circular(_dot / 2),
              ),
            ),
        ],
      ),
    );
  }
}
