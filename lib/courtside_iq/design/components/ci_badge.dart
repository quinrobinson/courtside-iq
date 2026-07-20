// CiBadge — Phase 4.8
//
// Measured from Components / Badge (Tone):
//   h24, radius 6 (chip), padding 8 horizontal / 4 vertical, SemiBold 12
//   Good     lime fill,   ink label
//   Energy   orange fill, ink label
//   Neutral  sunk fill,   1px border, muted label
//
// This is the delta pill ("+4.2"), the tier tag, and the small status chip.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

enum CiBadgeTone {
  good,
  energy,
  neutral,

  /// Outline only: no fill, a 1px border, current text colour.
  ///
  /// Measured from Today's hero, where "18.5 PPG" is a ghost tag rather than
  /// a filled chip. A filled grey pill beside a Growth IQ score competes with
  /// it; an outline states the figure without claiming the same weight.
  ghost,
}

class CiBadge extends StatelessWidget {
  const CiBadge({
    super.key,
    required this.label,
    this.tone = CiBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final CiBadgeTone tone;
  final IconData? icon;

  /// Pick a tone from what a change MEANS, not from its sign.
  ///
  /// This is the trap the design review caught: fewer turnovers is a NEGATIVE
  /// number and a GOOD outcome. Passing `higherIsBetter: false` for turnovers
  /// keeps the badge lime where a naive sign check would paint it orange and
  /// tell a parent their kid got worse.
  factory CiBadge.delta({
    Key? key,
    required double value,
    bool higherIsBetter = true,
    int decimals = 1,
    String? suffix,
  }) {
    final improved = higherIsBetter ? value > 0 : value < 0;
    final flat = value == 0;
    final sign = value > 0 ? '+' : '';
    return CiBadge(
      key: key,
      label: '$sign${value.toStringAsFixed(decimals)}${suffix ?? ''}',
      tone: flat
          ? CiBadgeTone.neutral
          : improved
              ? CiBadgeTone.good
              : CiBadgeTone.energy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    final (Color bg, Color fg, Color? border) = switch (tone) {
      CiBadgeTone.good => (c.accentGood, c.onAccent, null),
      CiBadgeTone.energy => (c.accentEnergy, c.onAccent, null),
      CiBadgeTone.neutral => (c.surfaceSunk, c.textMuted, c.border),
      // No fill at all, so it reads as an annotation rather than a chip.
      CiBadgeTone.ghost => (Colors.transparent, c.text, c.border),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.s2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: CiRadius.chipR,
        border: border == null ? null : Border.all(color: border),
      ),
      // No `alignment` here on purpose: a Container with an alignment and no
      // explicit width expands to fill its constraints instead of hugging its
      // child, which stretched badges to the full width of a stat tile. The
      // Row's MainAxisSize.min is what sizes this, and Row centres vertically
      // by default.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: CiType.labelStrong.copyWith(color: fg)),
        ],
      ),
    );
  }
}
