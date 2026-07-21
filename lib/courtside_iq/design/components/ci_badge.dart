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

import '../../growth_iq.dart';
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

  /// The Growth IQ trend chip: "Rising +5", "Dipping -13", "Steady +2".
  ///
  /// THE ONE PLACE THAT COLOURS A TREND:
  ///   Rising   lime      - the only thing that earns the positive accent
  ///   Steady   neutral   - no movement worth colouring
  ///   Dipping  orange    - attention, not alarm
  ///
  /// Dipping WAS neutral, on the reasoning that an accent colour would read as
  /// "something is wrong" about a child. Changed 2026-07-21 for two reasons.
  /// It under-signalled: a parent asked twice why a 13-point drop looked like
  /// nothing. And it was inconsistent - the Averages tiles on the SAME profile
  /// already paint a declining stat orange via CiBadge.delta, so the app gave
  /// two answers to "this went down" one tab apart.
  ///
  /// Orange, never red. Red is for errors and this is not one; the system has
  /// no red token and should not gain one for this. The gentleness lives in
  /// the WORD - "Dipping", never "Declining" - which is where it belongs. A
  /// colour that hides the movement is not kindness, it is withholding.
  ///
  /// THE WORD AND THE NUMBER TRAVEL TOGETHER, always on this chip and never
  /// split across the gauge. Today and the profile briefly put the word inside
  /// the gauge and the number on the chip; on device that read as two separate
  /// facts about the player rather than one, and the number lost the word that
  /// explains it. The gauge holds the score. This chip holds the movement.
  factory CiBadge.growthTrend({
    Key? key,
    required GrowthTrend trend,
    int? delta,
  }) {
    final word = switch (trend) {
      GrowthTrend.rising => 'Rising',
      GrowthTrend.steady => 'Steady',
      GrowthTrend.dipping => 'Dipping',
    };
    final number = delta == null ? '' : '${delta >= 0 ? '+' : ''}$delta';
    return CiBadge(
      key: key,
      label: [word, number].where((s) => s.isNotEmpty).join(' '),
      tone: switch (trend) {
        GrowthTrend.rising => CiBadgeTone.good,
        GrowthTrend.steady => CiBadgeTone.neutral,
        GrowthTrend.dipping => CiBadgeTone.energy,
      },
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
