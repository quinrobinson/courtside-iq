// Player Profile — Phase 4.11b
//
// Measured from Player Profile 93:211 (and its Averages / Games / Development
// variants):
//
//   hero    ink, 258: back + "Player" + edit, PlayerSwitcher, name + position
//   tabs    SegmentedTabs, 42, on light
//   body    the selected tab's content
//
// A rebuild of PlayerProfilePageV2 (Phase 2) on the 2.0 design system. The
// data layer and tab contents are proven and carried over; this replaces the
// shell and the tab control.
//
// THE INSIGHT FETCH IS HOISTED HERE, and that is the point of the rebuild.
// The old shell switched tab widgets by TYPE, so every return to Development
// destroyed and remounted it and re-fired a paid Sonnet call. Only the
// service's static dedup kept that from costing money - a billing bug held
// back by a cache. Owning the future above the tabs means switching tabs
// cannot refetch, whatever the tab control does.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import '/courtside_iq/design/components/ci_info_sheet.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/player_averages.dart';
import '/courtside_iq/players_list_builder.dart';
import '/features/flags.dart';
import '/features/home/entitlement_status.dart';
import '/features/premium/paywall_launcher.dart';
import '/features/home/widgets/today_promo_banner.dart';
import '/features/nav/ci_nav_bar.dart';
import '/features/player_insight/data/player_insight_service.dart';
import '/features/player_insight/models/player_insight.dart';
import '/features/home/widgets/game_feed_row.dart';
import '/features/players/add_player_flow.dart';
import '/features/players/birth_date_gate.dart';
import '/features/players/birth_date_sheet.dart';
import '/features/players/edit_player_page.dart';
import '/features/players/age_band_service.dart';
import '/features/players/info_copy.dart';
import '/features/players/widgets/age_band_notice.dart';
import '/features/players/widgets/averages_view.dart';
import '/features/players/full_breakdown_page.dart';
import '/features/players/widgets/development_view.dart';
import '/features/players/widgets/games_view.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'players_repository.dart';

/// Tab order matches the frames: Averages, Development, Games.
enum ProfileTab { averages, development, games }

class PlayerProfilePage extends StatefulWidget {
  const PlayerProfilePage({
    super.key,
    required this.playerId,
    this.repository = const PlayersRepository(),
  });

  final String playerId;
  final PlayersRepository repository;

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  final _service = PlayerInsightService();

  late String _playerId = widget.playerId;
  ProfileTab _tab = ProfileTab.development;

  Future<List<PlayerListEntry>>? _playersFuture;

  /// HOISTED. Created once per player and handed down, so a tab switch can
  /// never re-trigger generation. Replaced only when the player changes or a
  /// refresh is asked for.
  Future<PlayerInsightResponse>? _insightFuture;

  /// Hoisted for the same reason, though the cost here is a query rather than
  /// a generation: the tab stays mounted, so refetching on every switch would
  /// be pure waste.
  Future<PlayerAverages>? _averagesFuture;
  Future<List<GameFeedEntry>>? _gamesFuture;

  /// The raw per-game rows, kept so Full Breakdown can re-fold them without a
  /// second round trip.
  Future<List<AveragesGameRow>>? _gameRowsFuture;

  /// Set once the player's band is seen to differ from the one we last
  /// recorded. Cleared on dismiss and when switching players.
  bool _showBandNotice = false;

  /// Read once from RevenueCat. Only `lapsed` changes this screen: a parent
  /// who was never premium sees no strip here, because the profile is not
  /// where they are asked to subscribe.
  EntitlementStatus _entitlement = EntitlementStatus.premium;

  /// Rendered instantly when it matches the player's current game. See
  /// PlayerInsightService.readCached - it deliberately returns nothing when
  /// the cached story describes an older game.
  PlayerInsight? _cachedInsight;

  @override
  void initState() {
    super.initState();
    _playersFuture = widget.repository.load();
    _loadPlayerData();
    // Driven off the future rather than off build(): checking inside the
    // FutureBuilder would re-fire on every rebuild, including the one this
    // check itself causes.
    _playersFuture!.then(_checkBandFor).catchError((_) {});
    _loadEntitlement();
  }

  Future<void> _loadEntitlement() async {
    final s = await fetchEntitlementStatus();
    if (mounted) setState(() => _entitlement = s);
  }

  Future<void> _openPaywall() async {
    await showPaywall(context);
    // RE-READ AFTER THE PAYWALL CLOSES, the same rule as the Players list: a
    // parent who renews must not come back to a screen still telling them
    // their Premium has ended.
    if (mounted) await _loadEntitlement();
  }

  /// Refetches the switcher. A player added from this screen lands in that
  /// row, so without this the avatar never appears where it was added from.
  void _reloadPlayers() =>
      setState(() {
        _playersFuture = widget.repository.load();
      });

  Future<void> _addBirthDate(String playerId) async {
    final date = await presentBirthDateSheet(context);
    if (date == null || !mounted) return;
    try {
      await writeBirthDate(playerId, date);
      _reloadPlayers();
    } catch (_) {
      if (mounted) {
        showCiToast(context, 'Could not save that birth date. Please try again.',
            type: CiToastType.error);
      }
    }
  }

  Future<void> _editPlayer(PlayerListEntry player) async {
    if (!kUseEditPlayer2) {
      context.pushNamed(
        EditPlayerWidget.routeName,
        queryParameters: {'playerID': player.playerId},
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EditPlayerPage(
        playerId: player.playerId,
        onSaved: _reloadPlayers,
        // A deleted player cannot stay on screen as the profile's subject, so
        // this screen leaves with them.
        onDeleted: () {
          _reloadPlayers();
          if (mounted) Navigator.of(context).maybePop();
        },
      ),
    ));
    // Also refetch on plain dismissal: the photo is written the moment it is
    // chosen, so a parent can change it and back out without ever pressing
    // Save.
    _reloadPlayers();
  }

  Future<void> _addPlayer(List<PlayerListEntry> players) async {
    await runAddPlayerFlow(
      context,
      entitlement: _entitlement,
      playerCount: players.length,
      // A player added from here lands in the switcher, so the list behind it
      // has to be refetched or the new avatar never appears.
      onPlayerAdded: _reloadPlayers,
      openPaywall: _openPaywall,
    );
  }

  Future<void> _checkBandFor(List<PlayerListEntry> players) async {
    final id = _playerId;
    final match = players.where((p) => p.playerId == id);
    if (match.isEmpty) return;
    await _checkAgeBand(id, match.first.ageBand);
  }

  void _loadPlayerData() {
    _gameRowsFuture = widget.repository.loadGameRows(_playerId);
    _averagesFuture = _gameRowsFuture!.then(buildPlayerAverages);
    _gamesFuture = widget.repository.loadGames(_playerId);
    _insightFuture = _service.fetch(_playerId);
    _service.readCached(_playerId).then((cached) {
      if (mounted && cached != null) setState(() => _cachedInsight = cached);
    }).catchError((_) {
      // A cache miss is not a failure; the live fetch still covers it.
    });
  }

  void _selectPlayer(String playerId) {
    if (playerId == _playerId) return;
    setState(() {
      _playerId = playerId;
      // The previous player's story must not linger under the new name.
      _cachedInsight = null;
      _showBandNotice = false;
      _loadPlayerData();
    });
    _playersFuture?.then(_checkBandFor).catchError((_) {});
  }

  /// Announces a band change once, then records the new band so it is not
  /// announced again.
  ///
  /// Recorded on SIGHT rather than on dismiss: this is a one-time note, and a
  /// parent who scrolls past it without tapping the X has still seen it.
  Future<void> _checkAgeBand(String playerId, String? band) async {
    final lastSeen = await AgeBandService.lastSeenBand(playerId);
    final moved = AgeBandService.movedUp(current: band, lastSeen: lastSeen);
    await AgeBandService.recordBand(playerId, band);
    if (!mounted || !moved) return;
    if (playerId != _playerId) return; // switched away while we were reading
    setState(() => _showBandNotice = true);
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: FutureBuilder<List<PlayerListEntry>>(
            future: _playersFuture,
            builder: (context, snap) {
              final players = snap.data ?? const <PlayerListEntry>[];
              final current = players.where((p) => p.playerId == _playerId);
              final player = current.isEmpty ? null : current.first;

              return Column(
                children: [
                  _Hero(
                    players: players,
                    currentId: _playerId,
                    player: player,
                    onSelect: _selectPlayer,
                    // The dashed slot. Present whenever the parent could
                    // conceivably add - the gate behind it decides, and
                    // explains, exactly as on the Players list and the
                    // create sheet.
                    onAdd: players.isEmpty ? null : () => _addPlayer(players),
                    onEdit: player == null ? null : () => _editPlayer(player),
                  ),
                  // Above the tabs, per 663:2426. It explains what the parent
                  // is still seeing rather than hiding anything: the frame
                  // leaves every average visible.
                  if (_entitlement == EntitlementStatus.lapsed)
                    TodayPromoBanner(
                      purpose: TodayPromoPurpose.lapse,
                      compact: true,
                      onTap: _openPaywall,
                    ),
                  CiSegmentedTabs(
                    labels: const ['Averages', 'Development', 'Games'],
                    index: _tab.index,
                    onChanged: (i) =>
                        setState(() => _tab = ProfileTab.values[i]),
                  ),
                  // NO CAVEAT BANNER HERE. It was designed to sit beside an
                  // uncalibrated rating and say so - but since "no birth
                  // date, no rating" landed, there is no uncalibrated rating
                  // on any screen to caveat. The Development tab's empty
                  // state is the ask now, and running both put the same
                  // sentence on screen twice.
                  if (_showBandNotice && player?.ageBand != null)
                    AgeBandNotice(
                      firstName: player!.firstName,
                      ageBand: player.ageBand!,
                      onDismiss: () =>
                          setState(() => _showBandNotice = false),
                    ),
                  Expanded(child: _body(player)),
                ],
              );
            },
          ),
          bottomNavigationBar: kUseNavBar2
              ? CiNavBar(
                  active: CiNavTab.players,
                  onPlayerAdded: _reloadPlayers,
                )
              : null,
        );
      }),
    );
  }

  Widget _body(PlayerListEntry? player) {
    // IndexedStack keeps every tab ALIVE. Combined with the hoisted future
    // above, returning to Development re-renders rather than re-fetches.
    return IndexedStack(
      index: _tab.index,
      children: [
        _Averages(
          future: _averagesFuture,
          ageBand: player?.knownAgeBand,
          playerName: player?.displayName ?? '',
          rowsFuture: _gameRowsFuture,
          // Free AND lapsed both lose the way deeper (663:2426). The default
          // above is premium, so a subscriber never sees a lock flash while
          // RevenueCat is still answering.
          locked: _entitlement != EntitlementStatus.premium,
          onLockedTap: _openPaywall,
        ),
        _Development(
          player: player,
          insightFuture: _insightFuture,
          cached: _cachedInsight,
          onAddBirthDate: _addBirthDate,
        ),
        _Games(future: _gamesFuture, playerId: _playerId),
      ],
    );
  }
}

/// Binds the hoisted games future to the 2.0 [GamesView].
class _Games extends StatelessWidget {
  const _Games({required this.future, required this.playerId});

  final Future<List<GameFeedEntry>>? future;
  final String playerId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameFeedEntry>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return GamesView(
          games: snap.data!,
          onOpenGame: (gameId) => context.pushNamed(
            GameStatsWidget.routeName,
            queryParameters: {
              'playerID': serializeParam(playerId, ParamType.String),
              'gameID': serializeParam(gameId, ParamType.String),
            }.withoutNulls,
          ),
        );
      },
    );
  }
}

/// The ink hero: navigation, player switcher, and identity.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.players,
    required this.currentId,
    required this.player,
    required this.onSelect,
    this.onAdd,
    this.onEdit,
  });

  final List<PlayerListEntry> players;
  final String currentId;
  final PlayerListEntry? player;
  final ValueChanged<String> onSelect;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        final index = players.indexWhere((p) => p.playerId == currentId);

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s3, CiSpace.screen, CiSpace.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CiIconButton(
                      icon: Icons.chevron_left,
                      onDark: true,
                      semanticLabel: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Player',
                            style:
                                CiType.rowLabel.copyWith(color: c.textMuted)),
                      ),
                    ),
                    CiIconButton(
                      icon: Icons.edit_outlined,
                      onDark: true,
                      semanticLabel: 'Edit player',
                      onPressed: onEdit,
                    ),
                  ],
                ),
                const SizedBox(height: CiSpace.s5),
                if (players.isNotEmpty)
                  CiPlayerSwitcher(
                    names: players.map((p) => p.displayName).toList(),
                    imageUrls: players.map((p) => p.profilePic).toList(),
                    index: index < 0 ? 0 : index,
                    onSelected: (i) => onSelect(players[i].playerId),
                    onAdd: onAdd,
                  ),
                const SizedBox(height: CiSpace.s6),
                Text(
                  player?.displayName ?? ' ',
                  style: CiType.h2
                      .copyWith(color: c.text, fontWeight: CiWeight.extraBold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _identityLine(player),
                  style: CiType.bodySm.copyWith(color: c.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// "Guard · 11U-13U", dropping whichever half is missing so a player added
  /// without details does not read "null · null".
  static String _identityLine(PlayerListEntry? p) {
    if (p == null) return ' ';
    final parts = <String>[
      if (p.position != null && p.position!.trim().isNotEmpty) p.position!.trim(),
      // knownAgeBand: an assumed band must not be stated as this player's.
      if (p.knownAgeBand != null && p.knownAgeBand!.trim().isNotEmpty)
        p.knownAgeBand!.trim(),
    ];
    return parts.isEmpty ? ' ' : parts.join(' · ');
  }
}

/// Binds the hoisted averages future to the 2.0 [AveragesView].
class _Averages extends StatelessWidget {
  const _Averages({
    required this.future,
    required this.ageBand,
    required this.playerName,
    required this.rowsFuture,
    required this.locked,
    required this.onLockedTap,
  });

  /// Free or lapsed. The averages stay; only the way deeper is locked.
  final bool locked;
  final VoidCallback onLockedTap;

  final Future<PlayerAverages>? future;
  final String? ageBand;
  final String playerName;

  /// The same rows the averages were folded from. Full Breakdown is a
  /// different arrangement of these numbers, not a different query.
  final Future<List<AveragesGameRow>>? rowsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerAverages>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return AveragesView(
          averages: snap.data!,
          ageBand: ageBand,
          locked: locked,
          onLockedTap: onLockedTap,
          // "View trends" is still absent: its destination is Stats & Trends,
          // which is scoped out of 4.11. A button that goes nowhere is worse
          // than no button.
          onFullBreakdown: () async {
            final rows = await rowsFuture;
            if (rows == null || !context.mounted) return;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FullBreakdownPage(
                playerName: playerName,
                games: rows,
              ),
            ));
          },
        );
      },
    );
  }
}

/// Binds the hoisted insight future to the 2.0 [DevelopmentView].
///
/// The future is NOT created here - see the note at the top of this file. This
/// widget only chooses between the live response and the cached story, so the
/// tab has something to show on the first frame instead of a spinner.
class _Development extends StatelessWidget {
  const _Development({
    required this.player,
    required this.insightFuture,
    required this.cached,
    required this.onAddBirthDate,
  });

  final PlayerListEntry? player;
  final ValueChanged<String> onAddBirthDate;
  final Future<PlayerInsightResponse>? insightFuture;
  final PlayerInsight? cached;

  @override
  Widget build(BuildContext context) {
    final p = player;
    return FutureBuilder<PlayerInsightResponse>(
      future: insightFuture,
      builder: (context, snap) {
        return DevelopmentView(
          firstName: p?.firstName ?? '',
          insight: snap.data?.insight ?? cached,
          growthIq: player?.growthIq,
          growthIqDelta: player?.growthIqDelta,
          trend: player?.trend,
          gamesLogged: player?.totalGames,
          gamesUntilUnlock: snap.data?.gamesUntilUnlock,
          // The lock a parent cannot resolve by logging games.
          needsBirthDate: p != null && !p.hasBirthDate,
          onAddBirthDate:
              p == null ? null : () => onAddBirthDate(p.playerId),
          onTrackGame: () => context.pushNamed(NewGameWidget.routeName),
          onAbout: () => showCiInfoSheet(
            context,
            title: InfoCopy.developmentStoryTitle,
            body: InfoCopy.developmentStoryBody,
          ),
          onAboutGrowthIq: () => showCiInfoSheet(
            context,
            title: InfoCopy.growthIqTitle,
            body: InfoCopy.growthIqBody,
          ),
        );
      },
    );
  }
}
