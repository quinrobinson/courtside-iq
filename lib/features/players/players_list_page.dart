// Players — Phase 4.11a
//
// Built from Players — List (272:1557) and Players — Empty (206:806).
//
// The same hybrid ground as Today: an ink header block over a light list. The
// header carries "Players" and the add button; the rows are the light body.
//
// Gating (free add-gate, 3-player cap, premium-lapsed lock) is 4.11a.2 and not
// wired here yet. The add button opens the existing AddPlayerSheet.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_nav_icon.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/players_list_builder.dart';
import '/features/home/entitlement_status.dart';
import '/features/home/widgets/today_promo_banner.dart';
import '/features/players/add_player_flow.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import '/features/flags.dart';
import '/features/nav/ci_nav_bar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import 'players_repository.dart';
import 'widgets/player_list_row.dart';

class PlayersListPage extends StatefulWidget {
  const PlayersListPage({
    super.key,
    this.repository = const PlayersRepository(),
    this.entitlementReader = fetchEntitlementStatus,
  });

  final PlayersRepository repository;

  /// Injectable so gating can be tested without RevenueCat.
  final Future<EntitlementStatus> Function() entitlementReader;

  @override
  State<PlayersListPage> createState() => _PlayersListPageState();
}

class _PlayersListPageState extends State<PlayersListPage> {
  late Future<List<PlayerListEntry>> _future = widget.repository.load();

  /// Client-side RevenueCat read. Starts at never - the safe default is to
  /// invite rather than nag, and it must never tell a paying parent their
  /// premium ended because a fetch was slow.
  EntitlementStatus _entitlement = EntitlementStatus.never;

  /// Known once the list resolves; gating needs it.
  int _playerCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEntitlement();
  }

  Future<void> _loadEntitlement() async {
    final status = await widget.entitlementReader();
    if (mounted) setState(() => _entitlement = status);
  }

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() {
      _future = next;
    });
    await Future.wait([next, _loadEntitlement()]);
  }

  Future<void> _openPaywall() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: const PaywallWidget(),
      ),
    );
    // RE-READ AFTER THE PAYWALL CLOSES. Entitlement was fetched once on
    // init, so a parent who subscribed came back to a screen that still
    // believed they were on the free tier - the gate kept appearing until
    // something else happened to refresh. A purchase must take effect the
    // moment they return.
    if (mounted) await _loadEntitlement();
  }

  /// Delegates to the shared flow so this screen, the create sheet and the
  /// profile's switcher cannot disagree about who may add a player.
  ///
  /// On the cap branch that flow just closes the dialog, which is right here:
  /// the parent is already ON the list, and that is where a player is removed
  /// from. Sending them somewhere else would be a detour to where they are.
  Future<void> _addPlayer() => runAddPlayerFlow(
        context,
        entitlement: _entitlement,
        playerCount: _playerCount,
        onPlayerAdded: _refresh,
        openPaywall: _openPaywall,
      );

  void _openProfile(PlayerListEntry e) {
    context.pushNamed(
      PlayersProfileWidget.routeName,
      queryParameters: {'playerID': e.playerId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: FutureBuilder<List<PlayerListEntry>>(
            future: _future,
            builder: (context, snap) {
              final players = snap.data;
              // Kept for gating. Assigned during build rather than in a
              // callback because the future resolves outside our control.
              if (players != null) _playerCount = players.length;
              return Column(
                children: [
                  _Header(onAdd: _addPlayer),
                  // A lapsed parent keeps their players and their list; the
                  // banner is the only difference, offering the way back.
                  if (_entitlement == EntitlementStatus.lapsed)
                    TodayPromoBanner(
                      purpose: TodayPromoPurpose.lapse,
                      onTap: _openPaywall,
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: c.text,
                      child: _body(context, snap, players),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: kUseNavBar2
              ? CiNavBar(active: CiNavTab.players, onPlayerAdded: _refresh)
              : const CustomNavBarWidget(page: 'Players'),
        );
      }),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncSnapshot<List<PlayerListEntry>> snap,
    List<PlayerListEntry>? players,
  ) {
    if (snap.connectionState == ConnectionState.waiting && players == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snap.hasError) {
      return _Message(
        title: 'Could not load your players',
        body: 'Pull down to try again.',
      );
    }
    if (players == null || players.isEmpty) {
      return _EmptyState(onAdd: _addPlayer);
    }

    final c = CiColors.of(context);
    // A hairline BENEATH every row, including the last, so the list reads as
    // closed rather than trailing off. ListView.separated only puts them
    // BETWEEN items, which leaves the final row unbounded.
    Widget hairline() =>
        Container(height: CiSpace.hairline, color: c.hairline);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      // Zero, explicitly. A scroll view under a SafeArea header inherits the
      // ambient MediaQuery padding, which put a large unexplained gap above
      // the first row.
      padding: EdgeInsets.zero,
      itemCount: players.length,
      itemBuilder: (context, i) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayerListRow(
            entry: players[i],
            onTap: () => _openProfile(players[i]),
          ),
          hairline(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s6),
            // Height shared with the Games header, which has no icon button
            // and would otherwise sit 9pt shorter. See
            // kCiListHeaderContentHeight.
            child: SizedBox(
              height: kCiListHeaderContentHeight,
              child: Row(
              children: [
                Expanded(
                  child: Text('Players',
                      style: CiType.h2.copyWith(
                          color: c.text, fontWeight: CiWeight.extraBold)),
                ),
                CiIconButton(
                  icon: Icons.add,
                  onDark: true,
                  semanticLabel: 'Add player',
                  onPressed: onAdd,
                ),
              ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // Scrollable so pull-to-refresh still works with no content.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(color: c.surfaceSunk, shape: BoxShape.circle),
            child: CiNavIconGlyph(
                icon: CiNavIcon.players, color: c.textMuted, size: 30),
          ),
        ),
        const SizedBox(height: CiSpace.s5),
        Text('No players yet',
            textAlign: TextAlign.center,
            style: CiType.h3.copyWith(color: c.text)),
        const SizedBox(height: CiSpace.s2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.s8),
          child: Text(
            'Add your player to start tracking how they grow game by game.',
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted),
          ),
        ),
        const SizedBox(height: CiSpace.s6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
          child: CiButton(
            label: 'Add player',
            style: CiButtonStyle.lime,
            expand: true,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
        Text(title,
            textAlign: TextAlign.center,
            style: CiType.h3.copyWith(color: c.text)),
        const SizedBox(height: CiSpace.s2),
        Text(body,
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted)),
      ],
    );
  }
}
