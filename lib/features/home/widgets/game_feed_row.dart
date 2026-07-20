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
}

class GameFeedRow extends StatelessWidget {
  const GameFeedRow({super.key, required this.entry, this.onTap});

  final GameFeedEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final subtitle = entry.subtitle;

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
                  CiAvatar(
                    name: entry.playerName,
                    imageUrl: entry.playerPhotoUrl,
                    size: 38,
                  ),
                  const SizedBox(width: CiSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.playerName,
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
              Row(
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value',
              style: CiType.heroLine.copyWith(color: c.text)),
          const SizedBox(height: 2),
          Text(label,
              style: CiType.micro.copyWith(
                  color: c.textMuted, fontWeight: CiWeight.medium)),
        ],
      ),
    );
  }
}

/// "Recent Games" with the hairline the frame puts beneath it.
class FeedSectionHeader extends StatelessWidget {
  const FeedSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s3),
      child: Text(title,
          style: CiType.rowLabel
              .copyWith(color: c.textMuted, fontWeight: CiWeight.medium)),
    );
  }
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
