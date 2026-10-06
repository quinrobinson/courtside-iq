// The empty-state layout — Phase 4.19b
//
// ONE component for every "nothing here yet" list screen, so Players and Games
// (and any future list) are IDENTICAL by construction rather than separately
// tuned copies that drift - which is exactly what happened: one got a 64 icon
// and the other an 80, one gutter differed from the other, and they no longer
// lined up when a parent switched tabs.
//
// Built to the Figma EmptyState component: an 80 IconBadge (28 glyph, surface
// sunk), an ExtraBold-24 title, a Medium-15 muted body on a 300 measure, and an
// optional lime CTA.
//
// SCROLLABLE, so pull-to-refresh still works with no content. Sits 0.18 down
// the screen - where the frames place it, and where the eye lands first on an
// otherwise empty screen.

import 'package:flutter/material.dart';

import 'ci_button.dart';
import 'ci_nav_icon.dart';
import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

class CiEmptyState extends StatelessWidget {
  const CiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCta,
  });

  final CiNavIcon icon;
  final String title;
  final String body;

  /// Omitted for a dead-end empty (a filter that matched nothing): there is no
  /// single action to offer, so no button is drawn.
  final String? ctaLabel;
  final VoidCallback? onCta;

  /// The frame's measure: a 300 block centred on a 390 screen.
  static const double _gutter = 45;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.surfaceSunk,
              shape: BoxShape.circle,
            ),
            child: CiNavIconGlyph(icon: icon, color: c.textMuted, size: 28),
          ),
        ),
        const SizedBox(height: CiSpace.s5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: CiType.sectionTitle.copyWith(color: c.text),
        ),
        const SizedBox(height: CiSpace.s2),
        Text(
          body,
          textAlign: TextAlign.center,
          style: CiType.rowTitle.copyWith(
            color: c.textMuted,
            fontWeight: CiWeight.medium,
            height: 1.45,
          ),
        ),
        if (ctaLabel != null) ...[
          const SizedBox(height: CiSpace.s6),
          CiButton(
            label: ctaLabel!,
            style: CiButtonStyle.lime,
            expand: true,
            onPressed: onCta,
          ),
        ],
      ],
    );
  }
}
