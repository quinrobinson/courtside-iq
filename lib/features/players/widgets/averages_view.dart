// Averages tab — Phase 4.11b
//
// Measured from Player Profile — Averages (97:340):
//
//   header    SectionHeader "Season Averages" / "Per Game"
//   grid      six StatTile Md in two columns, 161 tall, hairline seams
//   header    SectionHeader "Shooting"
//   grid      three StatTile Sm in one row
//   note      info icon + "Ratings calibrated for the U14 age band"
//   actions   "View trends" and "Full Breakdown", both pill primary
//
// A PURE RENDERER, like DevelopmentView. It takes a PlayerAverages rather
// than a player id, which is what lets it be tested without Supabase.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/components/ci_stat_tile.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/player_averages.dart';

class AveragesView extends StatelessWidget {
  const AveragesView({
    super.key,
    required this.averages,
    this.ageBand,
    this.onViewTrends,
    this.onFullBreakdown,
    this.locked = false,
    this.onLockedTap,
  });

  final PlayerAverages averages;

  /// Drives the calibration note. Omitted when the player has no birth date,
  /// since the note would then claim a calibration that is not happening.
  final String? ageBand;

  /// Both null until 4.11c builds their destinations. The action row is only
  /// rendered when at least one exists - a button that goes nowhere is worse
  /// than no button.
  final VoidCallback? onViewTrends;
  final VoidCallback? onFullBreakdown;

  /// Premium content is not available to this parent (free or lapsed).
  ///
  /// The averages themselves STAY VISIBLE - 663:2426 leaves every number on
  /// screen and locks only the way deeper. The lapse strip above already
  /// explains it: high-level stats only.
  final bool locked;

  /// Where a locked chip goes: the paywall, not the breakdown.
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final a = averages;

    if (a.games == 0) {
      return _Empty();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const CiSectionHeader(title: 'Season Averages', trailing: 'Per Game'),
        CiStatGrid(
          columns: 2,
          outerBorder: false,
          tiles: [
            _tile('Points', a.points),
            _tile('Rebounds', a.rebounds),
            _tile('Assists', a.assists),
            _tile('Steals', a.steals),
            _tile('Blocks', a.blocks),
            // Fewer turnovers is an improvement, so the chip follows meaning
            // rather than sign. See CiBadge.delta.
            _tile('Turnovers', a.turnovers, higherIsBetter: false),
          ],
        ),
        Container(height: CiSpace.hairline, color: c.hairline),
        if (a.hasShooting) ...[
          const CiSectionHeader(title: 'Shooting'),
          CiStatGrid(
            columns: 3,
            outerBorder: false,
            tiles: [
              if (a.fieldGoal != null) _pctTile('Field Goal', a.fieldGoal!),
              if (a.threePoint != null) _pctTile('3-Point', a.threePoint!),
              if (a.freeThrow != null) _pctTile('Free Throw', a.freeThrow!),
            ],
          ),
          Container(height: CiSpace.hairline, color: c.hairline),
        ],
        if (ageBand != null && ageBand!.trim().isNotEmpty)
          _CalibrationNote(ageBand: ageBand!.trim()),
        if (onViewTrends != null || onFullBreakdown != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s2, CiSpace.screen, CiSpace.s7),
            child: Row(
              children: [
                if (onViewTrends != null)
                  Expanded(
                    child: CiButton(
                      label: 'View trends',
                      expand: true,
                      onPressed: onViewTrends,
                    ),
                  ),
                if (onViewTrends != null && onFullBreakdown != null)
                  const SizedBox(width: CiSpace.s3),
                if (onFullBreakdown != null)
                  Expanded(
                    child: locked
                        ? _LockedChip(
                            label: 'Breakdown',
                            onTap: onLockedTap,
                          )
                        : CiButton(
                            label: 'Full Breakdown',
                            expand: true,
                            onPressed: onFullBreakdown,
                          ),
                  ),
              ],
            ),
          )
        else
          const SizedBox(height: CiSpace.s7),
      ],
    );
  }

  static CiStatTile _tile(String label, AverageStat stat,
          {bool higherIsBetter = true}) =>
      CiStatTile(
        label: label,
        value: stat.value.toStringAsFixed(1),
        trend: stat.delta == null
            ? null
            : CiBadge.delta(
                value: stat.delta!,
                higherIsBetter: higherIsBetter,
              ),
      );

  /// Percentages are whole numbers on this screen. A tenth of a percent is
  /// noise at youth volumes and it costs the tile a digit of headroom.
  static CiStatTile _pctTile(String label, AverageStat stat) => CiStatTile(
        label: label,
        value: '${stat.value.round()}%',
        size: CiStatTileSize.sm,
        trend: stat.delta == null
            ? null
            : CiBadge.delta(
                value: stat.delta!,
                decimals: 0,
                suffix: '%',
              ),
      );
}

class _CalibrationNote extends StatelessWidget {
  const _CalibrationNote({required this.ageBand});

  final String ageBand;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: c.textFaint),
          const SizedBox(width: CiSpace.s3),
          Expanded(
            child: Text('Ratings calibrated for the $ageBand age band',
                style: CiType.bodyXs.copyWith(color: c.textFaint)),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CiSpace.s8),
        child: Text(
          'Averages appear once a game is logged.',
          textAlign: TextAlign.center,
          style: CiType.body.copyWith(color: c.textMuted),
        ),
      ),
    );
  }
}

/// A premium action a parent cannot take yet (663:2426).
///
/// It READS as disabled but is still tappable, and that is deliberate: a
/// dead control tells a parent nothing, while this one explains itself by
/// opening the plans. The padlock and the word carry the meaning, so the
/// state does not depend on colour alone.
class _LockedChip extends StatelessWidget {
  const _LockedChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      label: '$label, locked. Opens plans.',
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: CiRadius.pillR,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.surfaceSunk,
            borderRadius: CiRadius.pillR,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 15, color: c.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text('$label · Locked',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CiType.buttonSm.copyWith(color: c.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
