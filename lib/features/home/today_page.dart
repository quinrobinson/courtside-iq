// Today — Phase 4.10a
//
// Built from Screens / Today 65:7 and Today - Empty (No Players) 204:763.
//
// A HYBRID-GROUND SCREEN, and the first one. The hero is ink, the feed below
// it is light, and they meet without a divider. This is what the 2.0 palette
// was reshaped for: not a mode a parent picks, but two grounds coexisting in
// one screen.
//
// THREE STATES, and telling them apart matters:
//
//   no players          the Empty frame: reduced hero, "Add your first player"
//   players, no games   reduced hero with whatever games exist beneath. Every
//                       new user lives here for their first days.
//   players with games  full hero with the Growth IQ carousel
//
// The middle one has no frame of its own and does not need one: it is the
// Empty frame's hero with the real feed under it.
//
// The bottom nav is still the v1 CustomNavBarWidget. It is shared chrome
// across four screens and rebuilding it is its own item, so on device this
// screen sits above an old-looking nav bar until that lands.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_nav_icon.dart';
import '/courtside_iq/design/components/ci_info_sheet.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/features/flags.dart';
import '/features/players/birth_date_gate.dart';
import '/features/players/info_copy.dart';
import '/features/nav/ci_nav_bar.dart';
import '/features/menu/account_repository.dart';
import '/features/premium/paywall_launcher.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import 'entitlement_status.dart';
import 'widgets/today_promo_banner.dart';
import 'widgets/today_skeleton.dart';
import 'today_repository.dart';
import '/features/games/live_game_flow.dart';
import '/features/players/add_player_flow.dart';
import '/features/games/live_game_store.dart';
import '/features/games/resume_game_dialog.dart';
import 'widgets/game_feed_row.dart';
import 'widgets/today_hero.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({
    super.key,
    this.repository = const TodayRepository(),
    this.entitlementReader = fetchEntitlementStatus,
    this.store = const LiveGameStore(),
  });

  /// Injectable so the screen can be tested without Supabase.
  final TodayRepository repository;

  /// Where an unfinished game lives, read from disk. Nothing reaches the
  /// server until Save, so there is no row to fetch for one.
  final LiveGameStore store;

  /// Injectable so the screen can be tested without RevenueCat.
  final Future<EntitlementStatus> Function() entitlementReader;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<TodayData> _future = widget.repository.load();

  /// Client-side RevenueCat read. Starts at never - the safe default is to
  /// invite, not to nag - and resolves once the customer is fetched. A
  /// separate future so a slow entitlement read never delays the games.
  EntitlementStatus _entitlement = EntitlementStatus.never;

  /// The game still being tracked on this phone, if there is one.
  LiveGameSnapshot? _live;

  /// The signed-in parent's name, for the header avatar's initials. Loaded
  /// from public.users (via AccountRepository), NOT currentUserDisplayName,
  /// which is permanently empty in this app - passing it left the avatar
  /// showing a "?" for everyone.
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadEntitlement();
    _loadAccount();
    _readLive();
    // The v1 gate lives on home_widget, which this screen replaces, so
    // without this the birth-date prompt is dead on every 2.0 build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      maybePromptForBirthDate(context).then((_) {
        // A birth date added from the prompt changes the age band, and the
        // header is built on it.
        if (mounted) _refresh();
      });
    });
  }

  Future<void> _loadEntitlement() async {
    final status = await widget.entitlementReader();
    if (mounted) setState(() => _entitlement = status);
  }

  Future<void> _loadAccount() async {
    final profile = await const AccountRepository().load();
    if (mounted) setState(() => _userName = profile.fullName);
  }

  void _openGame(GameFeedEntry entry) {
    if (entry.gameId.isEmpty) return;
    context.pushNamed(
      GameStatsWidget.routeName,
      queryParameters: {
        'playerID': serializeParam(entry.playerId, ParamType.String),
        'gameID': serializeParam(entry.gameId, ParamType.String),
      }.withoutNulls,
    );
  }

  Future<void> _readLive() async {
    final live = await widget.store.read();
    if (mounted) setState(() => _live = live);
  }

  /// Resume or discard the unfinished game. Same dialog the Games list uses -
  /// a second way in, not a second design.
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

  Future<void> _refresh() async {
    final next = widget.repository.load();
    // Block body, not an arrow: an arrow RETURNS the assigned Future, and
    // Flutter asserts that a setState callback returns nothing. It only ever
    // ran from pull-to-refresh before, which is why it went unnoticed.
    setState(() {
      _future = next;
    });
    await Future.wait([next, _loadEntitlement(), _readLive(), _loadAccount()]);
  }

  /// Opens the add-player flow directly. On the empty home screen the button
  /// used to push the PLAYERS LIST, so a parent tapped "Add player", landed
  /// on the list, and had to tap "Add player" AGAIN. One tap now does it.
  Future<void> _addPlayer() => runAddPlayerFlow(
    context,
    entitlement: _entitlement,
    // Zero here by definition: this button only exists when the account
    // has no players.
    playerCount: 0,
    onPlayerAdded: _refresh,
    openPaywall: _openPaywall,
  );

  Future<void> _openPaywall() async {
    await showPaywall(context);
    // RE-READ AFTER THE PAYWALL CLOSES. Entitlement was fetched once on
    // init, so a parent who subscribed came back to a screen that still
    // believed they were on the free tier - the gate kept appearing until
    // something else happened to refresh. A purchase must take effect the
    // moment they return.
    if (mounted) await _loadEntitlement();
  }

  @override
  Widget build(BuildContext context) {
    // The PAGE is light ground; the hero paints its own ink.
    return CiSurface.light(
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            // Light icons: the hero is ink, so the global dark default would put
            // the clock and signal bars black on near-black. See CiSystemUi.
            value: CiSystemUi.onInk,
            child: Scaffold(
              // Transparent: the two-tone backdrop below owns the ground, not
              // the scaffold. A SINGLE scaffold colour cannot be ink at the top
              // and light at the bottom, and both overscroll ends reveal it -
              // which is why every earlier attempt fixed one end and broke the
              // other.
              backgroundColor: Colors.transparent,
              body: FutureBuilder<TodayData>(
                future: _future,
                builder: (context, snap) {
                  // Hero first, always. It carries the brand bar, so a bare
                  // spinner would blank the top of the app on every open.
                  final data = snap.data;
                  return Stack(
                    children: [
                      // TWO-TONE BACKDROP behind the transparent scroll view.
                      // Light fills everything, so the BOTTOM overscroll reveals
                      // light. A tall ink cap is anchored to the top, so the TOP
                      // overscroll reveals ink under the dark hero. The cap's
                      // lower seam sits at 360, always behind the opaque hero and
                      // feed, so it is never seen - the content fills the viewport
                      // in every state, guaranteeing at least that much cover.
                      Positioned.fill(child: ColoredBox(color: c.bg)),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 360,
                        child: ColoredBox(color: CiColors.onInk.bg),
                      ),
                      RefreshIndicator(
                        onRefresh: _refresh,
                        // Sits on the ink overscroll, so both match it.
                        color: CiColors.onInk.text,
                        backgroundColor: CiColors.onInk.surfaceSunk,
                        child: CustomScrollView(
                          // Always scrollable, or pull-to-refresh dies whenever
                          // the content is shorter than the screen - exactly the
                          // empty states.
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: TodayHero(
                                snapshots: data?.headerPlayers ?? const [],
                                loading:
                                    snap.connectionState ==
                                        ConnectionState.waiting &&
                                    data == null,
                                userName: _userName,
                                onProfile: () =>
                                    context.pushNamed(MenuWidget.routeName),
                                onPlayerTap: (s) => context.pushNamed(
                                  PlayersListWidget.routeName,
                                ),
                                onAboutGrowthIq: () => showCiInfoSheet(
                                  context,
                                  title: InfoCopy.growthIqTitle,
                                  body: InfoCopy.growthIqBody,
                                ),
                              ),
                            ),
                            // Everything below the hero is light ground, whatever
                            // state it is in.
                            ..._bodySlivers(context, c, snap, data),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              // CiNavBar owns its own ground and safe area, so the ColoredBox
              // and SafeArea wrapper this screen used to need for the v1 bar
              // are gone. The v1 bar had neither, which is why the
              // home-indicator strip fell through to the ink scaffold.
              // Three cases, and the middle one is easy to lose: under the
              // shell this screen renders NO bar, because the shell owns the
              // only one. Collapsing that into `kUseNavBar2 && !kUseNavShell`
              // fell through to the v1 bar instead of to nothing.
              bottomNavigationBar: kUseNavShell
                  ? null
                  : kUseNavBar2
                      ? CiNavBar(
                          active: CiNavTab.home, onPlayerAdded: _refresh)
                      : ColoredBox(
                          color: c.bg,
                          child: const SafeArea(
                            top: false,
                            child: CustomNavBarWidget(page: 'Home'),
                          ),
                        ),
            ),
          );
        },
      ),
    );
  }

  /// Wraps each sliver in the light ground so the ink scaffold only ever shows
  /// through the top overscroll.
  List<Widget> _bodySlivers(
    BuildContext context,
    CiColors c,
    AsyncSnapshot<TodayData> snap,
    TodayData? data,
  ) {
    Widget light(Widget sliver) => DecoratedSliver(
      decoration: BoxDecoration(color: c.bg),
      sliver: sliver,
    );

    if (snap.connectionState == ConnectionState.waiting && data == null) {
      // The screen's own outline, not a spinner: Today has a fixed shape, so
      // showing it reads as "arriving" and holds the layout still.
      return [
        light(const SliverToBoxAdapter(child: TodayFeedSkeleton())),
        light(
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.shrink(),
          ),
        ),
      ];
    }
    if (snap.hasError) {
      return [
        light(
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _Message(
              title: 'Could not load your games',
              body: 'Pull down to try again.',
            ),
          ),
        ),
      ];
    }
    if (data == null) return const [];
    if (data.hasNoPlayers) {
      return [
        // THE PROMO BANNER SHOWS HERE TOO. This branch returned early, so a
        // brand new parent - the one most worth telling what premium is -
        // was the only one who never saw it.
        ..._promoSlivers(),
        light(
          SliverFillRemaining(
            hasScrollBody: false,
            child: _AddFirstPlayer(onAdd: _addPlayer),
          ),
        ),
      ];
    }

    return [
      // Promo banner between hero and feed, for a non-premium parent. It is
      // ink, so it is NOT wrapped in the light ground the feed uses.
      ..._promoSlivers(),
      ..._feedSlivers(context, data).map(light),
    ];
  }

  /// The upgrade or lapse banner, or nothing for a premium parent.
  List<Widget> _promoSlivers() {
    final purpose = switch (_entitlement) {
      EntitlementStatus.premium => null,
      EntitlementStatus.lapsed => TodayPromoPurpose.lapse,
      EntitlementStatus.never => TodayPromoPurpose.upgrade,
    };
    if (purpose == null) return const [];
    return [
      SliverToBoxAdapter(
        child: TodayPromoBanner(purpose: purpose, onTap: _openPaywall),
      ),
    ];
  }

  /// The unfinished game, as a row for the top of Recent Games.
  ///
  /// TODAY GETS IT TOO. The Games list was the only place it appeared, which
  /// meant a parent who reopened the app landed on a home screen that said
  /// nothing about the game they were in the middle of - they had to know to
  /// go looking. This is the screen the app opens on, so it is where an
  /// unfinished game most needs to be visible.
  Widget? _liveRow() {
    final live = _live;
    if (live == null) return null;
    return GameFeedRow(
      entry: GameFeedEntry(
        gameId: 'live',
        playerName: live.playerName,
        opponent: live.opponent,
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

  List<Widget> _feedSlivers(BuildContext context, TodayData data) {
    final liveRow = _liveRow();

    if (data.recentGames.isEmpty && liveRow != null) {
      // Nothing logged yet, but a game is in progress. The "No games yet"
      // message would be a flat contradiction of the row above it.
      return [
        const SliverToBoxAdapter(
          child: FeedSectionHeader(title: 'Recent Games'),
        ),
        SliverToBoxAdapter(child: liveRow),
        const SliverToBoxAdapter(child: FeedHairline()),
        const SliverToBoxAdapter(child: SizedBox(height: CiSpace.s8)),
      ];
    }

    if (data.recentGames.isEmpty) {
      // Players exist but nothing has been logged. Not an error, and not the
      // no-players screen either.
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: _Message(
            title: 'No games yet',
            body: 'Log a game and their development starts here.',
          ),
        ),
      ];
    }

    return [
      const SliverToBoxAdapter(child: FeedSectionHeader(title: 'Recent Games')),
      // Ahead of the finished games: it is the only one still changing.
      if (liveRow != null) ...[
        SliverToBoxAdapter(child: liveRow),
        const SliverToBoxAdapter(child: FeedHairline()),
      ],
      SliverList.separated(
        itemCount: data.recentGames.length,
        separatorBuilder: (_, __) => const FeedHairline(),
        itemBuilder: (context, i) => GameFeedRow(
          entry: data.recentGames[i],
          // OPENS THE GAME, not the games list. Every recent-games row on
          // this screen went to the list instead, since 4.10a - a parent who
          // tapped a specific game got a list and had to find it again.
          onTap: () => _openGame(data.recentGames[i]),
        ),
      ),
      const SliverToBoxAdapter(child: FeedHairline()),
      SliverToBoxAdapter(
        child: _ViewAllGames(
          onTap: () => context.pushNamed(AllGamesWidget.routeName),
        ),
      ),
      // The frame closes the list with a hairline below View All Games, so
      // the section reads as bounded rather than trailing off.
      const SliverToBoxAdapter(child: FeedHairline()),
      const SliverToBoxAdapter(child: SizedBox(height: CiSpace.s8)),
      // Fills whatever is left with light ground. A SizedBox.shrink here
      // paints NOTHING, which is what let the ink scaffold show through as a
      // black bar under a short list.
      SliverFillRemaining(
        hasScrollBody: false,
        child: ColoredBox(color: CiColors.of(context).bg),
      ),
    ];
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(CiSpace.screen),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: CiType.h3.copyWith(color: c.text),
          ),
          const SizedBox(height: CiSpace.s2),
          Text(
            body,
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

/// The Empty frame's body: a user with no players at all.
class _AddFirstPlayer extends StatelessWidget {
  const _AddFirstPlayer({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(CiSpace.screen),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.surfaceSunk,
              shape: BoxShape.circle,
            ),
            child: CiNavIconGlyph(
              icon: CiNavIcon.players,
              color: c.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: CiSpace.s5),
          Text(
            'Add your first player',
            textAlign: TextAlign.center,
            style: CiType.h3.copyWith(color: c.text),
          ),
          const SizedBox(height: CiSpace.s2),
          Text(
            'Courtside IQ turns every game into a clear picture of how your player is developing. Add your player to begin.',
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: CiSpace.s6),
          CiButton(
            label: 'Add player',
            style: CiButtonStyle.lime,
            expand: true,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _ViewAllGames extends StatelessWidget {
  const _ViewAllGames({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        // Matches the section header above the list.
        height: kFeedBandHeight,
        padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
        child: Row(
          children: [
            Text(
              'View All Games',
              style: CiType.rowTitle.copyWith(
                color: c.text,
                fontWeight: CiWeight.semiBold,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: c.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
