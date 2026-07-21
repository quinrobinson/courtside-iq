// Full Breakdown — Phase 4.11c
//
// Measured from Full Breakdown (435:1922):
//
//   hero     116: back IconButton at 12/52, "Full Breakdown" centred, the
//            player's name beneath it
//   window   SegmentedTabs: Last 5 / Last 10 / Season
//   body     four sections, each a SectionHeader over rows of three centred
//            tiles: value Light 24, label Medium 11, sub Medium 10
//
// Reached from the Averages tab's "Full Breakdown" button, per the entry
// label in the frame gutter.
//
// LIGHT GROUND throughout, including the hero. This is the one screen in the
// profile flow that is not topped with ink: it is a reference table, not a
// place a parent lands, and the ink hero belongs to the profile it came from.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/player_averages.dart';
import '/courtside_iq/player_breakdown.dart';

/// Tiles per row, and the seam count that follows from it.
const int _kColumns = 3;

class FullBreakdownPage extends StatefulWidget {
  const FullBreakdownPage({
    super.key,
    required this.playerName,
    required this.games,
  });

  final String playerName;

  /// Newest first. Passed in rather than fetched: the profile already loaded
  /// exactly these rows for the Averages tab, and re-querying them to show a
  /// different arrangement of the same numbers is waste the parent pays for
  /// in latency.
  final List<AveragesGameRow> games;

  @override
  State<FullBreakdownPage> createState() => _FullBreakdownPageState();
}

class _FullBreakdownPageState extends State<FullBreakdownPage> {
  late final List<BreakdownWindow> _windows =
      availableWindows(widget.games.length);

  /// Opens on the widest window the player has earned. "Last 5" first would
  /// answer a question about form before the parent has seen the season it is
  /// measured against.
  late BreakdownWindow _window = _windows.last;

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        final sections = buildBreakdown(widget.games, _window);

        // No AnnotatedRegion: light screens inherit the app's dark status bar
        // icons. Only ink screens override, and this one is light throughout.
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Hero(playerName: widget.playerName),
                if (_windows.length > 1)
                  CiSegmentedTabs(
                    labels: [for (final w in _windows) w.label],
                    index: _windows.indexOf(_window),
                    onChanged: (i) => setState(() => _window = _windows[i]),
                  )
                else
                  const CiHairline(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final s in sections) ...[
                        CiSectionHeader(title: s.title),
                        _Grid(tiles: s.tiles),
                      ],
                      const SizedBox(height: CiSpace.s8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.playerName});

  final String playerName;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // 116 in the frame INCLUDING the status bar; this sits inside SafeArea,
    // so it is the remainder.
    return SizedBox(
      height: 72,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Full Breakdown',
                    style: CiType.rowTitle.copyWith(color: c.text)),
                const SizedBox(height: CiSpace.s1),
                Text(playerName,
                    style: CiType.bodySm.copyWith(color: c.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: CiSpace.s3),
              child: CiIconButton(
                icon: Icons.chevron_left,
                semanticLabel: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rows of [_kColumns] tiles, seamed like the Averages grid.
class _Grid extends StatelessWidget {
  const _Grid({required this.tiles});

  final List<BreakdownTile> tiles;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final rows = <List<BreakdownTile>>[];
    for (var i = 0; i < tiles.length; i += _kColumns) {
      rows.add(tiles.sublist(
          i, i + _kColumns > tiles.length ? tiles.length : i + _kColumns));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _kColumns; i++) ...[
                  if (i > 0)
                    Container(width: CiSpace.hairline, color: c.hairline),
                  // A partial row still occupies every column, so its seams
                  // land on the same boundaries as the rows above. Scoring has
                  // five tiles, so the last row is always partial.
                  Expanded(
                    child: i < row.length
                        ? _Tile(tile: row[i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        const CiHairline(),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile});

  final BreakdownTile tile;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final value = tile.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: CiSpace.s1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              // A dash, not a blank: an empty cell in a seamed grid reads as
              // a rendering failure rather than as missing data.
              value ?? '—',
              style: CiType.statInlineLg
                  .copyWith(color: value == null ? c.textFaint : c.text),
            ),
          ),
          const SizedBox(height: 3),
          Text(tile.label,
              style: CiType.chipLabel.copyWith(color: c.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(tile.sub,
              style: CiType.micro.copyWith(color: c.textFaint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
