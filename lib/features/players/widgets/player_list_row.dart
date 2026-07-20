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
import '/courtside_iq/design/components/dot_gauge.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/players_list_builder.dart';

/// Growth IQ runs 40..99, so a raw /100 would draw a nearly empty ring for a
/// real score. Map the range onto the full sweep. Shared with the header.
double _gaugeValue(int score) => ((score - 40) / (99 - 40)).clamp(0.0, 1.0);

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s5),
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
    final label = entry.trendLabel;
    return Column(
      children: [
        DotGauge(
          size: 96,
          value: _gaugeValue(entry.growthIq!),
          child: Text('${entry.growthIq}',
              style: CiType.h1.copyWith(
                  color: c.text, fontWeight: CiWeight.light)),
        ),
        if (label != null) ...[
          const SizedBox(height: CiSpace.s2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.accentGood,
              borderRadius: CiRadius.chipR,
            ),
            child: Text(label,
                style: CiType.micro.copyWith(
                    color: c.onAccent, fontWeight: CiWeight.bold)),
          ),
        ],
      ],
    );
  }
}
