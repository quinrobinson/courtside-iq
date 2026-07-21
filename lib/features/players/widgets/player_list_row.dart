// Player list row — Phase 4.11a
//
// Measured from Players — List (272:1557):
//
//   avatar    circle 40, sunk fill, initials
//   name      SemiBold 17; subtitle "position, band · N games" Regular 13 muted
//   averages  PPG / RPG / APG, value Light 24 over label Medium 10 muted
//   gauge     DotGauge 108 on the right, Growth IQ Light 34 inside, a lime
//             trend chip ("Rising +5") beneath it
//
// LIGHT GROUND. Full-bleed hairline between rows.
//
// The gauge and chip only appear when a Growth IQ exists. A player with too
// few games shows identity and averages but no gauge - the same rule as the
// header, since a zero would be a claim about the child.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/dot_gauge.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/growth_iq.dart';
import '/courtside_iq/players_list_builder.dart';

/// Reserved height for the trend chip, so a row without one is not shorter.
///
/// 24 to match CiBadge, which is what Today's Growth IQ chips use - the two
/// screens show the same kind of chip and must not differ in height.
const double _kChipHeight = 24;

const double _kGaugeSize = 112;

/// EVERY ROW IS THIS TALL, whatever the player has.
///
/// Reserving the chip slot alone was not enough: a player with no Growth IQ at
/// all omits the whole gauge column, so the row collapsed to the left side and
/// a brand-new player sat visibly shorter than the rest. A fixed height makes
/// the list rhythm independent of how much data any one player happens to
/// have - which is the point, since players join the list with none.
///
/// Sized to the tallest configuration: gauge + gap + chip, plus the padding.
const double _kRowHeight =
    _kGaugeSize + CiSpace.s2 + _kChipHeight + (_kRowPadding * 2);

/// Vertical breathing room around each row's content.
///
/// Applied symmetrically, and with TOP alignment this is exactly the space
/// above the player's name AND below the trend chip - the two the device
/// review asked to match. Centring made them differ: the gauge column is
/// taller than the identity column, so centring pushed the name down by half
/// the difference on top of this padding.
const double _kRowPadding = 32;

class PlayerListRow extends StatelessWidget {
  const PlayerListRow({super.key, required this.entry, this.onTap});

  final PlayerListEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: _kRowHeight,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, _kRowPadding, CiSpace.screen, _kRowPadding),
          // TOP-ALIGNED, so the space above the name equals the space below
          // the chip - the two the device review asked to match.
          //
          // Both columns end up filling the row height anyway: the gauge
          // column is the tallest content, and the identity column is an
          // Expanded Column defaulting to mainAxisSize.max. Stating `start`
          // regardless, so the intent does not depend on that coincidence.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CiAvatar(name: entry.displayName, imageUrl: entry.profilePic, size: 40),
                        const SizedBox(width: CiSpace.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.displayName,
                                  style: CiType.h4.copyWith(
                                      color: c.text,
                                      fontWeight: CiWeight.semiBold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(entry.subtitle,
                                  style: CiType.bodySm
                                      .copyWith(color: c.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CiSpace.s5),
                    Row(
                      children: [
                        _Avg(value: entry.ppg, label: 'PPG'),
                        const SizedBox(width: CiSpace.s7),
                        _Avg(value: entry.rpg, label: 'RPG'),
                        const SizedBox(width: CiSpace.s7),
                        _Avg(value: entry.apg, label: 'APG'),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.hasGrowthIq) ...[
                const SizedBox(width: CiSpace.s3),
                _GrowthGauge(entry: entry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avg extends StatelessWidget {
  const _Avg({required this.value, required this.label});

  /// Null when there are no games; the row shows a dash rather than "0.0",
  /// which would state a season that never happened.
  final String? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value ?? '—',
            style: CiType.h2.copyWith(
                color: value == null ? c.textFaint : c.text,
                fontWeight: CiWeight.light)),
        const SizedBox(height: 2),
        Text(label,
            style: CiType.micro
                .copyWith(color: c.textMuted, fontWeight: CiWeight.medium)),
      ],
    );
  }
}

class _GrowthGauge extends StatelessWidget {
  const _GrowthGauge({required this.entry});

  final PlayerListEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      children: [
        DotGauge(
          // There are never more than three players, so the row can afford a
          // gauge that fills its space rather than floating in it.
          size: _kGaugeSize,
          value: growthIqGaugeValue(entry.growthIq!),
          child: Text('${entry.growthIq}',
              style: CiType.h1.copyWith(
                  color: c.text, fontWeight: CiWeight.light)),
        ),
        const SizedBox(height: CiSpace.s2),
        // The chip slot is ALWAYS reserved, even when there is no trend to
        // show. Jada carries a chip and Jordan does not, so letting the slot
        // collapse made her row ~28pt taller than his - the uneven heights
        // in the device review. Reserving it keeps every row identical.
        SizedBox(
          height: _kChipHeight,
          child: entry.trend == null
              ? null
              // The colour rule lives in CiBadge.growthTrend so Today, this
              // list, and the profile cannot disagree about the same drop.
              : CiBadge.growthTrend(
                  trend: entry.trend!, delta: entry.growthIqDelta),
        ),
      ],
    );
  }
}
