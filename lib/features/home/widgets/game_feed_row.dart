// Recent game row — Phase 4.10a
//
// Measured from Screens / Today, RecentGameRow (68:93):
//
//   row      124 tall, full bleed, hairline beneath
//   header   avatar 38, name SemiBold 15, "vs Opponent  ·  Sat, Mar 8"
//            Medium 12 muted
//   stats    five columns: value Light 22 over label Medium 10 muted
//
// LIGHT GROUND. This sits below the ink hero, and is the first substantial
// light-ground surface in 2.0.
//
// The stat values are Light 22, the same relationship the hero uses: numbers
// are large but not heavy, so a row of them reads as information rather than
// as five competing headlines.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

/// One recent game, already reduced to what the row shows.
class GameFeedEntry {
  const GameFeedEntry({
    required this.gameId,
    required this.playerName,
    this.playerPhotoUrl,
    this.opponent,
    this.playedAt,
    this.eventName,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.steals,
    required this.turnovers,
  });

  final String gameId;
  final String playerName;
  final String? playerPhotoUrl;

  /// Null when the game was logged without one.
  final String? opponent;
  final DateTime? playedAt;

  /// The tournament or league the game belonged to.
  ///
  /// Fills the slot the frame labels "Home", which has no column behind it:
  /// the schema has never recorded home or away. The event is the real
  /// qualifier a parent has for a game, and it is already what the v1 tab
  /// lets them filter by.
  final String? eventName;

  final int points;
  final int rebounds;
  final int assists;
  final int steals;
  final int turnovers;

  /// "vs Northside Hawks  ·  Sat, Mar 8", dropping whichever half is missing.
  ///
  /// A game logged in a hurry may have no opponent, and the row must not read
  /// "vs   ·  Sat, Mar 8" or leave a dangling separator.
  String get subtitle {
    final parts = <String>[
      if (opponent != null && opponent!.trim().isNotEmpty)
        'vs ${opponent!.trim()}',
      if (playedAt != null) DateFormat('EEE, MMM d').format(playedAt!),
    ];
    return parts.join('  ·  ');
  }

  /// Title when the row is already inside one player's profile: the opponent
  /// carries the line, since repeating the player's name on every row of
  /// their own profile says nothing.
  String get opponentTitle {
    final o = opponent?.trim();
    return (o == null || o.isEmpty) ? 'Game' : 'vs $o';
  }

  /// "Sat, Mar 8 · Spring Classic", dropping whichever half is missing.
  String get dateSubtitle {
    final parts = <String>[
      if (playedAt != null) DateFormat('EEE, MMM d').format(playedAt!),
      if (eventName != null && eventName!.trim().isNotEmpty) eventName!.trim(),
    ];
    return parts.join(' · ');
  }
}

class GameFeedRow extends StatelessWidget {
  const GameFeedRow({
    super.key,
    required this.entry,
    this.onTap,
    this.showPlayer = true,
  });

  final GameFeedEntry entry;
  final VoidCallback? onTap;

  /// Off inside a player's own profile (the Games tab). Matches the frame's
  /// `showPlayer` property: the avatar and name go, and the opponent takes
  /// over the title line.
  final bool showPlayer;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final title = showPlayer ? entry.playerName : entry.opponentTitle;
    final subtitle = showPlayer ? entry.subtitle : entry.dateSubtitle;

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showPlayer) ...[
                    CiAvatar(
                      name: entry.playerName,
                      imageUrl: entry.playerPhotoUrl,
                      size: 38,
                    ),
                    const SizedBox(width: CiSpace.s3),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: CiType.rowTitle.copyWith(
                                color: c.text,
                                fontWeight: CiWeight.semiBold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: CiType.caption.copyWith(
                                  color: c.textMuted,
                                  fontWeight: CiWeight.medium),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CiSpace.s4),
              // spaceBetween, NOT five Expanded slots. In the frame the
              // columns start at 0, 88, 169, 249, 329 across a 342 row - the
              // last ENDS at the right edge. Equal slots left a visible gap
              // on the right because each column hugs its own narrow number.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Stat(value: entry.points, label: 'PTS'),
                  _Stat(value: entry.rebounds, label: 'REB'),
                  _Stat(value: entry.assists, label: 'AST'),
                  _Stat(value: entry.steals, label: 'STL'),
                  _Stat(value: entry.turnovers, label: 'TO'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      // Centre the label UNDER the number. Left-aligned, "PTS" is wider than
      // "12" and spills to the right of it rather than sitting beneath it.
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$value', style: CiType.heroLine.copyWith(color: c.text)),
        const SizedBox(height: 2),
        Text(label,
            style: CiType.micro.copyWith(
                color: c.textMuted, fontWeight: CiWeight.medium)),
      ],
    );
  }
}

/// Height shared by the section header and the View All Games row.
///
/// The two bracket the list, so they have to match. Measured from the frame:
/// 56 for the header, 54 for the footer - close enough that the difference
/// read as a mistake rather than a rhythm.
const double kFeedBandHeight = kCiSectionBandHeight;

/// "Recent Games" with the hairline the frame puts beneath it.
///
/// Now a thin alias over the design system's CiSectionHeader. It was written
/// here first, before the profile tabs needed the same band; keeping a second
/// implementation is how the two screens end up with headers that differ by a
/// weight or two and nobody notices until they are side by side.
class FeedSectionHeader extends StatelessWidget {
  const FeedSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => CiSectionHeader(title: title);
}

/// Full-bleed hairline. Never inset - the locked treatment.
class FeedHairline extends StatelessWidget {
  const FeedHairline({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: CiSpace.hairline,
        color: CiColors.of(context).hairline,
      );
}
