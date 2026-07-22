// Games tab — Phase 4.11b
//
// Measured from Player Profile — Games (98:583):
//
//   header  SectionHeader "Games" / "N Games"
//   rows    RecentGameRow with showPlayer = false, 124 tall, hairline between
//
// The row is the SAME component Today uses, with the avatar and player name
// dropped. Repeating the player's name on every row of their own profile
// says nothing, so the opponent takes the title line and the date drops to
// the subtitle.
//
// A PURE RENDERER, like the other two tabs.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/features/home/widgets/game_feed_row.dart';

class GamesView extends StatelessWidget {
  const GamesView({
    super.key,
    required this.games,
    this.onOpenGame,
  });

  /// Newest first.
  final List<GameFeedEntry> games;

  final void Function(String gameId)? onOpenGame;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CiSpace.s8),
          child: Text(
            'Games appear here once you log one.',
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      // +2: the header at index 0, and a zero-height item at the end. The
      // trailing item exists only so the separator BEFORE it draws the rule
      // that closes the last game - without it the list stopped mid-air, the
      // one open thing from the earlier review.
      itemCount: games.length + 2,
      // CiSectionHeader draws its own hairline, so adding one after it would
      // render a 2px double rule under the header.
      separatorBuilder: (context, i) => i == 0
          ? const SizedBox.shrink()
          : Container(height: CiSpace.hairline, color: c.hairline),
      itemBuilder: (context, i) {
        if (i == 0) {
          return CiSectionHeader(
            title: 'Games',
            trailing:
                '${games.length} ${games.length == 1 ? 'Game' : 'Games'}',
          );
        }
        if (i == games.length + 1) return const SizedBox.shrink();
        final g = games[i - 1];
        return GameFeedRow(
          entry: g,
          showPlayer: false,
          onTap: onOpenGame == null ? null : () => onOpenGame!(g.gameId),
        );
      },
    );
  }
}
