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
  late Future<List<GameListRow>> _future = widget.repository.load();

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
          body: FutureBuilder<List<GameListRow>>(
            future: _future,
            builder: (context, snap) {
            final all = snap.data;
            if (all == null) {
              // The header still renders: it is the screen's identity and
              // does not depend on the games arriving.
              return const Column(
                children: [_Header(), Expanded(child: _Loading())],
              );
            }

              final players = playerOptions(all);
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
                          ? _Empty(filtered: all.isNotEmpty)
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
            child: Text('Games',
                style: CiType.h2
                    .copyWith(color: c.text, fontWeight: CiWeight.extraBold)),
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
class _Empty extends StatelessWidget {
  const _Empty({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
      children: [
        const SizedBox(height: CiSpace.s12),
        Text(
          filtered ? 'No games match these filters' : 'No games yet',
          textAlign: TextAlign.center,
          style: CiType.h3.copyWith(color: c.text),
        ),
        const SizedBox(height: CiSpace.s4),
        Text(
          filtered
              ? 'Try a different player or date.'
              : 'Track a game and it will show up here.',
          textAlign: TextAlign.center,
          style: CiType.body.copyWith(color: c.textMuted),
        ),
        if (!filtered) ...[
          const SizedBox(height: CiSpace.s7),
          CiButton(
            label: 'Track a Game',
            expand: true,
            onPressed: () => context.pushNamed(NewGameWidget.routeName),
          ),
        ],
      ],
    );
  }
}
