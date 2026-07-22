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
    this.dot = false,
    this.semanticLabel,
  });

  final String label;
  final CiBadgeTone tone;
  final IconData? icon;

  /// A 5pt filled dot before the label, in the label's own colour.
  final bool dot;

  /// Spoken instead of the label. Set it for any badge whose text is an
  /// abbreviation or an all-caps word, which a screen reader otherwise reads
  /// out one letter at a time.
  final String? semanticLabel;

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
  ///   Rising   lime     - the only thing that earns the positive accent
  ///   Steady   neutral
  ///   Dipping  neutral  - the WORD carries it, not the colour
  ///
  /// Dipping was tried in orange on 2026-07-21 and reverted the same day. It
  /// was jarring: Growth IQ is a composite judgement about a CHILD, sitting at
  /// the top of the app every time their parent opens it, and an accent colour
  /// there reads as "something is wrong with them" rather than "this number
  /// moved down".
  ///
  /// This deliberately DIFFERS from the Averages tiles, which do paint a
  /// declining stat orange via CiBadge.delta. That is not an oversight. "Free
  /// throws are down 4%" is a narrow, actionable fact and orange helps a parent
  /// find it. Growth IQ is the whole child in one number, and it does not get
  /// the same treatment. Scope is the reason the two rules differ.
  ///
  /// The movement is never hidden: the chip says "Dipping -13" in words. What
  /// the neutral tone withholds is the alarm, not the information.
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
      tone: trend == GrowthTrend.rising
          ? CiBadgeTone.good
          : CiBadgeTone.neutral,
    );
  }

  /// "LIVE" — a game being tracked right now.
  ///
  /// ORANGE MEANS "HAPPENING NOW" HERE, not "attention". It is the only place
  /// in the app that uses it that way, and it earns it: this is the one state
  /// a parent can lose data by ignoring.
  ///
  /// Built here rather than hand-rolled at each call site, which is what it
  /// was: the games row and the tracker header each drew their own, at their
  /// own size, neither of them the system's 24. A status pill and a filter
  /// chip are different things, but two LIVE pills that disagree with each
  /// other are just a mistake.
  ///
  /// The dot is not decoration. Orange alone would leave the meaning to
  /// colour; the dot and the word carry it for anyone who cannot use that.
  factory CiBadge.live({Key? key}) => CiBadge(
        key: key,
        label: 'LIVE',
        tone: CiBadgeTone.energy,
        dot: true,
        // Without this a screen reader spells out L-I-V-E.
        semanticLabel: 'Live',
      );

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

    final badge = Container(
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
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: CiType.labelStrong.copyWith(color: fg)),
        ],
      ),
    );

    if (semanticLabel == null) return badge;
    return Semantics(
      label: semanticLabel,
      // container + exclude, or the inner text merges over the label and the
      // abbreviation is read out anyway.
      container: true,
      excludeSemantics: true,
      child: badge,
    );
  }
}
