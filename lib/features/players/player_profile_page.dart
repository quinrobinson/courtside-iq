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
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/players_list_builder.dart';
import '/features/flags.dart';
import '/features/nav/ci_nav_bar.dart';
import '/features/player_insight/data/player_insight_service.dart';
import '/features/player_insight/models/player_insight.dart';
import '/features/player_insight/widgets/averages_tab.dart';
import '/features/player_insight/widgets/games_tab.dart';
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

  /// Rendered instantly when it matches the player's current game. See
  /// PlayerInsightService.readCached - it deliberately returns nothing when
  /// the cached story describes an older game.
  PlayerInsight? _cachedInsight;

  @override
  void initState() {
    super.initState();
    _playersFuture = widget.repository.load();
    _loadInsight();
  }

  void _loadInsight() {
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
      _loadInsight();
    });
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
                    onEdit: player == null
                        ? null
                        : () => context.pushNamed(
                              EditPlayerWidget.routeName,
                              queryParameters: {'playerID': player.playerId},
                            ),
                  ),
                  CiSegmentedTabs(
                    labels: const ['Averages', 'Development', 'Games'],
                    index: _tab.index,
                    onChanged: (i) =>
                        setState(() => _tab = ProfileTab.values[i]),
                  ),
                  Expanded(child: _body(player)),
                ],
              );
            },
          ),
          bottomNavigationBar: kUseNavBar2
              ? const CiNavBar(active: CiNavTab.players)
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
        AveragesTab(playerId: _playerId),
        _DevelopmentPlaceholder(
          playerId: _playerId,
          firstName: player?.firstName ?? '',
          gamesCount: player?.totalGames,
          insightFuture: _insightFuture,
          cached: _cachedInsight,
        ),
        GamesTab(playerId: _playerId),
      ],
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
    this.onEdit,
  });

  final List<PlayerListEntry> players;
  final String currentId;
  final PlayerListEntry? player;
  final ValueChanged<String> onSelect;
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
      if (p.ageBand != null && p.ageBand!.trim().isNotEmpty) p.ageBand!.trim(),
    ];
    return parts.isEmpty ? ' ' : parts.join(' · ');
  }
}

/// Temporary seam: the Development tab still owns its own rendering and is
/// re-skinned in the next step of 4.11b. It now RECEIVES the hoisted future
/// rather than starting its own, which is what removes the refetch-on-remount.
class _DevelopmentPlaceholder extends StatelessWidget {
  const _DevelopmentPlaceholder({
    required this.playerId,
    required this.firstName,
    required this.gamesCount,
    required this.insightFuture,
    required this.cached,
  });

  final String playerId;
  final String firstName;
  final int? gamesCount;
  final Future<PlayerInsightResponse>? insightFuture;
  final PlayerInsight? cached;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return FutureBuilder<PlayerInsightResponse>(
      future: insightFuture,
      builder: (context, snap) {
        final insight = snap.data?.insight ?? cached;
        if (insight == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(CiSpace.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(insight.headline ?? '',
                  style: CiType.h3.copyWith(color: c.text)),
              const SizedBox(height: CiSpace.s3),
              Text(insight.text ?? '',
                  style: CiType.body.copyWith(color: c.textMuted)),
            ],
          ),
        );
      },
    );
  }
}
