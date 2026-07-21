// Games — List — Phase 4.12
//
// Measured from 263:1016:
//
//   header   "Games" ExtraBold 24 at 24/62
//   chips    player row at 162, date row at 206, both 32 tall
//   rule     full bleed at 250
//   rows     RecentGameRow, the same one Today and the profile use
//
// THE HEADER IS INK, matching the Players list exactly - same ground, same
// h2 ExtraBold, same padding, and it claims the status bar itself. The frame
// draws it on light, but Games and Players are the same kind of screen and
// two list headers that differ read as a mistake rather than a distinction.
//
// The two chip rows behave differently on purpose. Players is a CLOSED set of
// at most three, so it wraps and is hidden entirely when there is only one.
// Dates is OPEN-ENDED - one chip per day a game was logged - so it scrolls,
// or the filter block would grow taller than the list it filters.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/games_list_builder.dart';
import '/features/home/widgets/game_feed_row.dart';
import '/features/nav/ci_nav_bar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'games_repository.dart';

class GamesListPage extends StatefulWidget {
  const GamesListPage({super.key, this.repository = const GamesRepository()});

  final GamesRepository repository;

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late Future<GamesData> _future = widget.repository.load();

  String _playerId = kAllPlayersId;
  String _dateId = kAllDatesKey;

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          // No SafeArea here: the ink header claims the status bar itself,
          // exactly as the Players list does. Wrapping the page would leave a
          // white strip above a black header.
          body: FutureBuilder<GamesData>(
            future: _future,
            builder: (context, snap) {
            final data = snap.data;
            if (data == null) {
              // The header still renders: it is the screen's identity and
              // does not depend on the games arriving.
              return const Column(
                children: [_Header(), Expanded(child: _Loading())],
              );
            }

              final all = data.games;
            // From the ROSTER, so a player with no games still gets a chip -
            // and the "No games for X yet" state is reachable at all.
            final players = playerOptions(data.roster);
              // The player filter narrows what dates are even possible, so
              // the date chips are built from the ALREADY-FILTERED rows. A
              // chip that yields nothing is a dead control the parent
              // cannot explain.
              final byPlayer = filterGames(all, playerId: _playerId);
              final dates = dateOptions(byPlayer);

              // A selection can outlive its chip - a deleted game, or a
              // player filter that removed that day entirely.
              final dateId = reconcileSelection(_dateId, dates);
              final rows = filterGames(byPlayer, dateId: dateId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  // The chips must not touch the header. With one player the
                  // player row is hidden, so the DATE row would otherwise butt
                  // straight against the ink.
                  if (players.isNotEmpty || dates.isNotEmpty)
                    const SizedBox(height: CiSpace.s3),
                  if (players.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: CiSpace.s3),
                      child: CiChipBar(
                        labels: [for (final p in players) p.label],
                        index: players.indexWhere((p) => p.id == _playerId),
                        padding: const EdgeInsets.symmetric(
                            horizontal: CiSpace.screen),
                        onChanged: (i) => setState(() {
                          _playerId = players[i].id;
                          // The date may not exist for the new player.
                          _dateId = kAllDatesKey;
                        }),
                      ),
                    ),
                  if (dates.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: CiSpace.s3),
                      child: CiChipBar(
                        labels: [for (final d in dates) d.label],
                        index: dates.indexWhere((d) => d.id == dateId),
                        scrollable: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: CiSpace.screen),
                        onChanged: (i) =>
                            setState(() => _dateId = dates[i].id),
                      ),
                    ),
                  const CiHairline(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: rows.isEmpty
                          ? _Empty(
                              // Naming the player turns "nothing here" into
                              // an answer to the question they just asked.
                              playerName: _playerId.isEmpty
                                  ? null
                                  : players
                                      .firstWhere((p) => p.id == _playerId,
                                          orElse: () => const GameFilterOption(
                                              id: '', label: ''))
                                      .label,
                              filtered: all.isNotEmpty,
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              // +1 so the LAST row is closed by a rule too.
                              // Without it the list stopped mid-air against
                              // the nav bar, which reads as content cut off
                              // rather than a list that ended.
                              itemCount: rows.length + 1,
                              separatorBuilder: (_, __) => const CiHairline(),
                              itemBuilder: (context, i) {
                                if (i == rows.length) {
                                  return const SizedBox.shrink();
                                }
                                final g = rows[i];
                                return GameFeedRow(
                                  entry: GameFeedEntry(
                                    gameId: g.gameId,
                                    playerName: g.playerName,
                                    playerPhotoUrl: g.playerPhotoUrl,
                                    opponent: g.opponent,
                                    playedAt: g.playedAt,
                                    points: g.points,
                                    rebounds: g.rebounds,
                                    assists: g.assists,
                                    steals: g.steals,
                                    turnovers: g.turnovers,
                                  ),
                                  onTap: () => context.pushNamed(
                                    GameStatsWidget.routeName,
                                    queryParameters: {
                                      'playerID': serializeParam(
                                          g.playerId, ParamType.String),
                                      'gameID': serializeParam(
                                          g.gameId, ParamType.String),
                                    }.withoutNulls,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: const CiNavBar(active: CiNavTab.games),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // Deliberately identical to the Players list header. If one changes, both
    // should.
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s6),
            // Matches the height of the Players header, whose row is set by a
            // 40pt icon button. Text alone is ~31, so without this the two
            // headers sat 9pt apart - visible when switching tabs, and the
            // kind of difference that reads as a bug rather than a choice.
            child: SizedBox(
              height: kCiListHeaderContentHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Games',
                    style: CiType.h2.copyWith(
                        color: c.text, fontWeight: CiWeight.extraBold)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Two different nothings.
///
/// A parent with no games at all needs an invitation. A parent whose FILTER
/// emptied the list needs to know the games are still there - telling them to
/// log their first game when they have twenty would read as data loss.
/// Measured from Games — No Games (Player Filter) (683:2910): an 80 sunk
/// circle with a 34 basketball, an ExtraBold 24 line, a Medium 15 muted
/// paragraph, and a lime CTA.
///
/// THREE DIFFERENT NOTHINGS, and they must not share copy:
///   no games at all       an invitation
///   a player with none    names them, and offers to start one FOR them
///   a filter that matched  says the games are still there
/// Telling a parent with twenty games to log their first would read as data
/// loss; telling them "try a different filter" when they have none is a
/// dead end.
class _Empty extends StatelessWidget {
  const _Empty({required this.filtered, this.playerName});

  final bool filtered;

  /// Null unless a specific player is selected.
  final String? playerName;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final who = playerName;
    final forPlayer = who != null && who.isNotEmpty;

    final title = !filtered
        ? 'No games yet'
        : forPlayer
            ? 'No games for $who yet'
            : 'No games match these filters';
    final body = !filtered
        ? 'Track a game and it will show up here.'
        : forPlayer
            ? 'Track a game with $who to see how they performed and what it '
                'means for their growth.'
            : 'Try a different player or date.';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      children: [
        const SizedBox(height: CiSpace.s12),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.surfaceSunk,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sports_basketball_rounded,
                size: 34, color: c.textMuted),
          ),
        ),
        const SizedBox(height: CiSpace.s5),
        Text(title,
            textAlign: TextAlign.center,
            style: CiType.sectionTitle.copyWith(color: c.text)),
        const SizedBox(height: CiSpace.s2),
        Text(
          body,
          textAlign: TextAlign.center,
          style: CiType.rowTitle.copyWith(
              color: c.textMuted, fontWeight: CiWeight.medium, height: 1.45),
        ),
        const SizedBox(height: CiSpace.s5),
        CiButton(
          // "Start a game", per the frame. Not "Track a Game": this offers to
          // begin one now, which is what a parent looking at an empty list
          // for their child is being invited to do.
          label: forPlayer ? 'Start a game' : 'Track a Game',
          style: forPlayer ? CiButtonStyle.lime : CiButtonStyle.primary,
          expand: true,
          onPressed: () => context.pushNamed(NewGameWidget.routeName),
        ),
        const SizedBox(height: CiSpace.s8),
      ],
    );
  }
}
