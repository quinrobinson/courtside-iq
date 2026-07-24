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
//
// A live game shows the LIVE pill on its row (683:2752). RESUMING from the
// list is deferred to 4.13: v1 resumes through a client-state flag with no
// game id, and the 2.0 live tracker does not exist yet, so a live row taps to
// Game Detail like any other rather than to an invented resume flow.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_empty_state.dart';
import '/courtside_iq/design/components/ci_nav_icon.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/games_list_builder.dart';
import 'live_game_flow.dart';
import 'live_game_store.dart';
import 'resume_game_dialog.dart';
import '/features/home/widgets/game_feed_row.dart';
import '/features/nav/ci_nav_bar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'games_repository.dart';

class GamesListPage extends StatefulWidget {
  const GamesListPage({
    super.key,
    this.repository = const GamesRepository(),
    this.store = const LiveGameStore(),
  });

  final GamesRepository repository;

  /// Where an unfinished game lives. Read from disk, NOT from the server:
  /// tracking writes no game row until Save, so there is nothing to fetch.
  final LiveGameStore store;

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late Future<GamesData> _future = widget.repository.load();

  String _playerId = kAllPlayersId;
  String _dateId = kAllDatesKey;

  /// Start a new game. Same destination as the empty state's "Start a game",
  /// so the two cannot drift apart.
  void _newGame() => context.pushNamed(NewGameWidget.routeName);

  /// The game still being tracked on this phone, if there is one.
  LiveGameSnapshot? _live;

  @override
  void initState() {
    super.initState();
    _readLive();
  }

  Future<void> _readLive() async {
    final live = await widget.store.read();
    if (mounted) setState(() => _live = live);
  }

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() {
      _future = next;
    });
    await Future.wait([next, _readLive()]);
  }

  /// Open the resume dialog for the unfinished game.
  ///
  /// Both outcomes end with a reload: resuming returns here once the game is
  /// saved or discarded, and discarding removes the row that was tapped.
  Future<void> _openLive(LiveGameSnapshot snapshot) async {
    final choice = await showResumeGameDialog(context, snapshot: snapshot);
    if (!mounted || choice == null) return;

    if (choice == ResumeChoice.discard) {
      await widget.store.clear();
      if (mounted) await _refresh();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveGameFlow.resume(snapshot: snapshot),
      ),
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(
        builder: (context) {
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
                  return Column(
                    children: [
                      _Header(onAdd: _newGame),
                      const Expanded(child: _Loading()),
                    ],
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

                // The unfinished game obeys the same filters as the list it
                // sits in - a row that ignored them would look like a bug. It
                // has no date, so any date filter excludes it: that filter is a
                // question about days already played.
                final live = _live;
                final showLive =
                    live != null &&
                    dateId == kAllDatesKey &&
                    (_playerId == kAllPlayersId || _playerId == live.playerId);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(onAdd: _newGame),
                    // The filter chrome (chips + hairline) only appears when
                    // there ARE games to filter. With none, showing filters
                    // over an empty list is noise - and it pushed the empty
                    // state down so it no longer lined up with the Players
                    // empty state. Hidden here, the no-games layout is
                    // header + empty, exactly like Players, so the shared 0.18
                    // spacer lands both at the same place.
                    if (all.isNotEmpty) ...[
                      // The chips must not touch the header. With one player the
                      // player row is hidden, so the DATE row would otherwise
                      // butt straight against the ink.
                      if (players.isNotEmpty || dates.isNotEmpty)
                        const SizedBox(height: CiSpace.s3),
                      if (players.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: CiSpace.s3),
                          child: CiChipBar(
                            labels: [for (final p in players) p.label],
                            index: players.indexWhere((p) => p.id == _playerId),
                            padding: const EdgeInsets.symmetric(
                              horizontal: CiSpace.screen,
                            ),
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
                              horizontal: CiSpace.screen,
                            ),
                            onChanged: (i) =>
                                setState(() => _dateId = dates[i].id),
                          ),
                        ),
                      const CiHairline(),
                    ],
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: rows.isEmpty && !showLive
                            ? _Empty(
                                // Naming the player turns "nothing here" into
                                // an answer to the question they just asked.
                                playerName: _playerId.isEmpty
                                    ? null
                                    : players
                                          .firstWhere(
                                            (p) => p.id == _playerId,
                                            orElse: () =>
                                                const GameFilterOption(
                                                  id: '',
                                                  label: '',
                                                ),
                                          )
                                          .label,
                                filtered: all.isNotEmpty,
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                // +1 so the LAST row is closed by a rule too.
                                // Without it the list stopped mid-air against
                                // the nav bar, which reads as content cut off
                                // rather than a list that ended.
                                // The live game leads. It is the newest thing
                                // that happened and the only row still
                                // changing, so anything above it would be
                                // stale by comparison.
                                itemCount: rows.length + (showLive ? 1 : 0) + 1,
                                separatorBuilder: (_, __) => const CiHairline(),
                                itemBuilder: (context, i) {
                                  if (showLive) {
                                    if (i == 0) {
                                      return GameFeedRow(
                                        entry: GameFeedEntry(
                                          gameId: 'live',
                                          playerName: live.playerName,
                                          opponent: live.opponent,
                                          // No date: it has not finished, so
                                          // there is no day to name yet, and
                                          // the LIVE pill takes that slot.
                                          points: live.stats.points,
                                          rebounds: live.stats.rebounds,
                                          assists: live.stats.assists,
                                          steals: live.stats.steals,
                                          turnovers: live.stats.turnovers,
                                          isLive: true,
                                        ),
                                        onTap: () => _openLive(live),
                                      );
                                    }
                                    i -= 1;
                                  }
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
                                      isLive: g.isLive,
                                    ),
                                    onTap: () => context.pushNamed(
                                      GameStatsWidget.routeName,
                                      queryParameters: {
                                        'playerID': serializeParam(
                                          g.playerId,
                                          ParamType.String,
                                        ),
                                        'gameID': serializeParam(
                                          g.gameId,
                                          ParamType.String,
                                        ),
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
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    // Deliberately identical to the Players list header. If one changes, both
    // should - including the add button: a parent who learns "+" starts a
    // player on one tab should not have to hunt for how to start a game on
    // the next. The empty state's "Start a game" is the same action, but it
    // disappears the moment there is one game in the list.
    return CiSurface.ink(
      statusBar: true,
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          return SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CiSpace.screen,
                CiSpace.s5,
                CiSpace.screen,
                CiSpace.s6,
              ),
              // Matches the height of the Players header, whose row is set by a
              // 40pt icon button. Text alone is ~31, so without this the two
              // headers sat 9pt apart - visible when switching tabs, and the
              // kind of difference that reads as a bug rather than a choice.
              child: SizedBox(
                height: kCiListHeaderContentHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Games',
                        style: CiType.h2.copyWith(
                          color: c.text,
                          fontWeight: CiWeight.extraBold,
                        ),
                      ),
                    ),
                    CiIconButton(
                      icon: Icons.add,
                      onDark: true,
                      semanticLabel: 'New game',
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Measured from BOTH empty frames: No Games (206:1025) and No Games (Player
/// Filter) (683:2910). They are the same layout - an 80 sunk circle with a 34
/// basketball, ExtraBold 24, Medium 15 muted, and a lime "Start a game" - and
/// differ ONLY in copy. An earlier version of this had the no-games case on an
/// ink "Track a Game" button; that was invented, not read.
///
/// THREE NOTHINGS, none sharing copy:
///   no games at all       "No games yet" - an invitation to the first game
///   a player with none    names them, and offers to start one FOR them
///   a filter that matched  says the games are still there
///
/// Telling a parent with twenty games to log their first would read as data
/// loss; telling a parent with none to "try a different filter" is a dead end.
///
/// The third case has no frame and is effectively unreachable - date chips are
/// built from already-filtered games, so a date can never match zero. It is
/// kept as a defensive fallback, not a designed surface.
class _Empty extends StatelessWidget {
  const _Empty({required this.filtered, this.playerName});

  final bool filtered;

  /// Null unless a specific player is selected.
  final String? playerName;

  @override
  Widget build(BuildContext context) {
    final who = playerName;
    final forPlayer = who != null && who.isNotEmpty;

    final title = !filtered
        ? 'No games yet'
        : forPlayer
        ? 'No games for $who yet'
        : 'No games match these filters';
    final body = !filtered
        ? 'Track your first game to see how your player performed and what it '
              'means for their growth.'
        : forPlayer
        ? 'Track a game with $who to see how they performed and what it '
              'means for their growth.'
        : 'Try a different player or date.';

    // A designed empty state - no games at all, or a named player - gets the
    // lime invitation. The undesigned filter fallback does not: it is a dead
    // end, not an invitation, so it should not wear the button that starts a
    // game.
    final invites = !filtered || forPlayer;

    return CiEmptyState(
      icon: CiNavIcon.games,
      title: title,
      body: body,
      // The dead-end filter fallback offers no button - see [invites]; the
      // designed empties (no games, or a named player) get "Start a game".
      ctaLabel: invites ? 'Start a game' : null,
      onCta: invites ? () => context.pushNamed(NewGameWidget.routeName) : null,
    );
  }
}
