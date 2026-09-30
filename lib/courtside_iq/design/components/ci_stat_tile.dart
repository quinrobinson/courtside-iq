// CiStatTile + CiStatGrid — Phase 4.8
//
// Measured from Components / StatTile (Size):
//   Md  170x161, padding 24, gap 12, value Light 48
//   Sm  140x120, padding 16, gap  8, value Light 32
//   both: radius 0, 1px border on all sides, label Medium 13 muted
//
// The zero radius and full border are the point: tiles butt against each
// other and their borders become the grid seams. That is why a stat tile is
// square-cornered when nothing else in this system is.
//
// SEAMS ARE NOT OPTIONAL. Every multi-column stat grid shows vertical seams,
// including PARTIAL rows - a final row of two tiles in a three-column grid
// still needs a seam at the third column boundary, or the grid looks like it
// lost a tooth. CiStatGrid handles that; hand-rolling a Row of tiles does not.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';
import 'ci_badge.dart';

enum CiStatTileSize { md, sm }

class CiStatTile extends StatelessWidget {
  const CiStatTile({
    super.key,
    required this.label,
    required this.value,
    this.size = CiStatTileSize.md,
    this.trend,
    this.bordered = true,
    this.onTap,
  });

  final String label;

  /// Pre-formatted. The tile does not round or format - a stat's precision is
  /// a metric decision, not a layout one.
  final String value;

  final CiStatTileSize size;

  /// Optional delta pill. Build it with CiBadge.delta so tone follows meaning
  /// rather than sign.
  final CiBadge? trend;

  /// Off inside a CiStatGrid, which draws the seams itself. Leaving it on
  /// there would double every interior line to 2px.
  final bool bordered;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final md = size == CiStatTileSize.md;

    final body = Container(
      padding: EdgeInsets.all(md ? CiSpace.s6 : CiSpace.s4),
      decoration: BoxDecoration(
        color: c.surface,
        border: bordered ? Border.all(color: c.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: CiType.labelTight.copyWith(color: c.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: md ? CiSpace.s3 : CiSpace.s2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: (md ? CiType.statMd : CiType.statSm)
                  .copyWith(color: c.text),
            ),
          ),
          if (trend != null) ...[
            SizedBox(height: md ? CiSpace.s3 : CiSpace.s2),
            trend!,
          ],
        ],
      ),
    );

    if (onTap == null) return body;
    return InkWell(onTap: onTap, child: body);
  }
}

/// Lays stat tiles out in a grid with proper seams.
///
/// Seams are drawn by the container showing through 1px gaps ("gap reveal")
/// rather than by each tile carrying a border, so interior lines stay 1px
/// instead of doubling to 2px where tiles meet.
class CiStatGrid extends StatelessWidget {
  const CiStatGrid({
    super.key,
    required this.tiles,
    this.columns = 3,
    this.outerBorder = true,
  });

  final List<CiStatTile> tiles;
  final int columns;

  /// Frame the whole grid. Off when it sits inside an already-bordered card.
  final bool outerBorder;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    if (tiles.isEmpty) return const SizedBox.shrink();

    final rows = <List<CiStatTile>>[];
    for (var i = 0; i < tiles.length; i += columns) {
      rows.add(tiles.sublist(
          i, i + columns > tiles.length ? tiles.length : i + columns));
    }

    return Container(
      // The seam color: gaps between children reveal it.
      color: c.hairline,
      padding: outerBorder
          ? const EdgeInsets.all(CiSpace.hairline)
          : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: CiSpace.hairline),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < columns; i++) ...[
                    if (i > 0) const SizedBox(width: CiSpace.hairline),
                    Expanded(
                      // A partial row still occupies every column, so the
                      // trailing seam lands on the same boundary as the rows
                      // above it. Without this the grid reads as broken.
                      child: i < rows[r].length
                          ? _cell(rows[r][i])
                          : Container(color: c.surface),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Strips the tile's own border so interior seams stay 1px.
  Widget _cell(CiStatTile t) => CiStatTile(
        label: t.label,
        value: t.value,
        size: t.size,
        trend: t.trend,
        bordered: false,
        onTap: t.onTap,
      );
}
