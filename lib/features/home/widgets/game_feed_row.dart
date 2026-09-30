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
//
// SAVED GAMES SAY WHAT THE GAME MEANT (Quin, 2026-09-29 design review). The
// five-stat grid above now belongs to the LIVE row only. A saved game is one
// horizontal row, 24 side / 16 vertical padding, 12 gaps:
//
//   left    avatar 38 (when showPlayer)
//   middle  title SemiBold 15, "vs Opponent · date" Medium 12 muted, then
//           ONE meaning line (game_row_meaning.dart), 6pt below (10 for insight):
//             insight  lime-wash card, radius 10, padding 10/8: the spark 14
//                      centred on line one + first sentence, Medium 13 on an
//                      18 line, 2 lines max
//             tier     the Game Detail tier chip (CiBadge.tier) + skill name
//             stats    "7 rebounds, 3 steals", Medium 13 textSoft
//   right   the lead number Light 28 over its label Medium 10 muted
//
// A zero-performance game draws neither the line nor the lead: nothing, not
// a zero. The same widget serves Today, the Games list and the profile's
// Games tab, so all three change together.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_badge.dart';
import '/courtside_iq/design/components/ci_section_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/game_detail_builder.dart';
import '/courtside_iq/game_row_meaning.dart';
import '/courtside_iq/metrics_config.dart';

/// One recent game, already reduced to what the row shows.
class GameFeedEntry {
  const GameFeedEntry({
    required this.gameId,
    this.playerId = '',
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
    this.isLive = false,
    this.blocks = 0,
    this.offRebounds = 0,
    this.fgAttempt = 0,
    this.ftAttempt = 0,
    this.insight,
    this.ageBand,
  });

  final String gameId;

  /// Needed to open the game. Empty on rows built before 4.14, which is why
  /// it defaults rather than being required.
  final String playerId;

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

  /// The game is still being tracked. Draws the LIVE pill (683:2752).
  ///
  /// `games.game_live` is the source. There is at most one at a time, so this
  /// is true for one row at most.
  final bool isLive;

  // --- What the saved-game row needs to say what the game MEANT ------------
  //
  // Defaulted, not required: live rows are built from in-memory tracker
  // stats and keep the five-stat look, so they never read these.

  final int blocks;

  /// The offensive part of [rebounds]. Disruption weighs the two kinds
  /// differently, so the total alone cannot rate the game.
  final int offRebounds;

  final int fgAttempt;
  final int ftAttempt;

  /// The stored AI insight, parsed with the same reader Game Detail uses.
  final GameInsight? insight;

  /// Needed for the scoring-efficiency tier. Null costs that tier only.
  final AgeBand? ageBand;

  /// The lead number and the meaning line. See game_row_meaning.dart.
  GameRowMeaning get meaning => buildGameRowMeaning(
        points: points,
        offReb: offRebounds,
        defReb: rebounds - offRebounds,
        assists: assists,
        steals: steals,
        blocks: blocks,
        turnovers: turnovers,
        fgAttempt: fgAttempt,
        ftAttempt: ftAttempt,
        insight: insight,
        ageBand: ageBand,
      );

  /// This entry with [band] filled in when it has none of its own. The
  /// profile knows the band once for every row, so it adds it here rather
  /// than the query carrying it per game.
  GameFeedEntry withAgeBand(AgeBand? band) => ageBand != null || band == null
      ? this
      : GameFeedEntry(
          gameId: gameId,
          playerId: playerId,
          playerName: playerName,
          playerPhotoUrl: playerPhotoUrl,
          opponent: opponent,
          playedAt: playedAt,
          eventName: eventName,
          points: points,
          rebounds: rebounds,
          assists: assists,
          steals: steals,
          turnovers: turnovers,
          isLive: isLive,
          blocks: blocks,
          offRebounds: offRebounds,
          fgAttempt: fgAttempt,
          ftAttempt: ftAttempt,
          insight: insight,
          ageBand: band,
        );

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
  Widget build(BuildContext context) =>
      entry.isLive ? _buildLive(context) : _buildSaved(context);

  /// A saved game: what it meant, not a box score. See the file header.
  Widget _buildSaved(BuildContext context) {
    final c = CiColors.of(context);
    final title = showPlayer ? entry.playerName : entry.opponentTitle;
    final subtitle = showPlayer ? entry.subtitle : entry.dateSubtitle;
    final meaning = entry.meaning;
    final lead = meaning.lead;
    final line = _MeaningLine.of(meaning);

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: c.text, fontWeight: CiWeight.semiBold),
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
                    if (line != null) ...[
                      // 10 above the insight card, which needs the air to
                      // read as its own thing; 6 above a tier or stats line.
                      SizedBox(
                          height: meaning.kind == GameRowMeaningKind.insight
                              ? 10
                              : 6),
                      line,
                    ],
                  ],
                ),
              ),
              if (lead != null) ...[
                const SizedBox(width: CiSpace.s3),
                Column(
                  key: const ValueKey('game-row-lead'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(lead.value,
                        style: CiType.statSm.copyWith(
                            color: c.text, fontSize: 28, letterSpacing: -1)),
                    const SizedBox(height: 2),
                    Text(lead.label,
                        style: CiType.micro.copyWith(
                            color: c.textMuted, fontWeight: CiWeight.medium)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The game being tracked right now. Keeps the five-stat look: nothing has
  /// been rated yet, and the numbers are still moving.
  Widget _buildLive(BuildContext context) {
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
                  // Top-aligned with the title, per the frame - the pill sits
                  // at the row's top-right, not centred on the taller header.
                  if (entry.isLive) CiBadge.live(),
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

/// The one line under the opponent and date. Null for a game with nothing
/// to say, so the row draws no empty gap.
class _MeaningLine extends StatelessWidget {
  const _MeaningLine._(this.meaning);

  static Widget? of(GameRowMeaning m) =>
      m.kind == GameRowMeaningKind.none || m.text == null
          ? null
          : _MeaningLine._(m);

  final GameRowMeaning meaning;

  /// One line of the insight sentence: 13pt text on an 18pt line.
  static const double _insightLineHeight = 18;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final text = meaning.text!;
    final style = CiType.labelTight.copyWith(fontWeight: CiWeight.medium);
    return switch (meaning.kind) {
      // ON THE LIME WASH (Quin, 2026-09-30 device check): as a bare line
      // under the date it sat too tight and blended in with the tier and
      // stats rows. The wash is the Game Detail insight card's own ground, so
      // the row previews what the tap opens; full width so it reads as a
      // card, never as a second tier chip.
      GameRowMeaningKind.insight => Container(
          key: const ValueKey('game-row-insight'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: CiSpace.s2 + 2, vertical: CiSpace.s2),
          decoration: BoxDecoration(
            color: c.accentGoodWash,
            borderRadius: CiRadius.controlR,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // THE insight spark, as on the insight card and the profile's
              // development blocks: this line is Courtside IQ's own words.
              // Boxed at one line's height so it centres on the FIRST line
              // however the sentence wraps.
              SizedBox(
                width: 14,
                height: _insightLineHeight,
                child: Center(
                  child: Icon(Icons.auto_awesome, size: 14, color: c.onAccent),
                ),
              ),
              const SizedBox(width: CiSpace.s2),
              Expanded(
                child: Text(text,
                    style: style.copyWith(
                        color: c.onAccent, height: _insightLineHeight / 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      GameRowMeaningKind.tier => Row(
          key: const ValueKey('game-row-tier'),
          children: [
            CiBadge.tier(tier: meaning.tier!),
            const SizedBox(width: CiSpace.s2),
            Flexible(
              child: Text(text,
                  style: style.copyWith(color: c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      _ => Text(text,
          key: const ValueKey('game-row-stats'),
          style: style.copyWith(color: c.textSoft),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    };
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
