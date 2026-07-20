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
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import 'today_repository.dart';
import 'widgets/game_feed_row.dart';
import 'widgets/today_hero.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, this.repository = const TodayRepository()});

  /// Injectable so the screen can be tested without Supabase.
  final TodayRepository repository;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<TodayData> _future = widget.repository.load();

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    // The PAGE is light ground; the hero paints its own ink.
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          // LIGHT status-bar icons. The app pins DARK ones globally because
          // it was a light-mode design, but Today's hero is ink, so the clock
          // and signal bars were black on near-black.
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light, // Android
            statusBarBrightness: Brightness.dark, // iOS
          ),
          child: Scaffold(
            // INK. Overscrolling at the top reveals whatever is behind the
            // scroll view, and that must be ink beneath a dark hero. Every
            // sliver below the hero paints its own light ground, INCLUDING a
            // trailing filler - the previous attempt left that filler empty,
            // so it had nothing to paint and the ink showed through as a
            // black bar at the bottom.
            backgroundColor: CiColors.onInk.bg,
            body: FutureBuilder<TodayData>(
              future: _future,
              builder: (context, snap) {
                // Hero first, always. It carries the brand bar, so a bare
                // spinner would blank the top of the app on every open.
                final data = snap.data;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  // Sits on the ink overscroll, so both match it.
                  color: CiColors.onInk.text,
                  backgroundColor: CiColors.onInk.surfaceSunk,
                  child: CustomScrollView(
                    // Always scrollable, or pull-to-refresh dies whenever the
                    // content is shorter than the screen - exactly the empty
                    // states.
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: TodayHero(
                          snapshots: data?.headerPlayers ?? const [],
                          userName: currentUserDisplayName,
                          onProfile: () =>
                              context.pushNamed(MenuWidget.routeName),
                          onPlayerTap: (s) => context.pushNamed(
                            PlayersListWidget.routeName,
                          ),
                        ),
                      ),
                      // Everything below the hero is light ground, whatever
                      // state it is in.
                      ..._bodySlivers(context, c, snap, data),
                    ],
                  ),
                );
              },
            ),
            // WHITE behind the nav and the home-indicator strip below it.
            //
            // The scaffold is ink so the top overscroll reveals ink under the
            // dark hero, but the v1 nav is a fixed 60pt bar with no bottom
            // safe-area handling, so the strip beneath it fell through to that
            // ink and read as a black band. The nav is a separate Scaffold
            // slot from the body, so painting it light here does not affect
            // the overscroll at all - the two are not one background.
            bottomNavigationBar: ColoredBox(
              color: c.bg,
              child: const SafeArea(
                top: false,
                child: CustomNavBarWidget(page: 'Home'),
              ),
            ),
          ),
        );
      }),
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
      return [
        light(const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        )),
      ];
    }
    if (snap.hasError) {
      return [
        light(const SliverFillRemaining(
          hasScrollBody: false,
          child: _Message(
            title: 'Could not load your games',
            body: 'Pull down to try again.',
          ),
        )),
      ];
    }
    if (data == null) return const [];
    if (data.hasNoPlayers) {
      return [
        light(const SliverFillRemaining(
          hasScrollBody: false,
          child: _AddFirstPlayer(),
        )),
      ];
    }
    return _feedSlivers(context, data).map(light).toList();
  }

  List<Widget> _feedSlivers(BuildContext context, TodayData data) {
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
      SliverList.separated(
        itemCount: data.recentGames.length,
        separatorBuilder: (_, __) => const FeedHairline(),
        itemBuilder: (context, i) => GameFeedRow(
          entry: data.recentGames[i],
          onTap: () => context.pushNamed(AllGamesWidget.routeName),
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
          Text(title,
              textAlign: TextAlign.center,
              style: CiType.h3.copyWith(color: c.text)),
          const SizedBox(height: CiSpace.s2),
          Text(body,
              textAlign: TextAlign.center,
              style: CiType.body.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}

/// The Empty frame's body: a user with no players at all.
class _AddFirstPlayer extends StatelessWidget {
  const _AddFirstPlayer();

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
            child: Icon(Icons.people_outline, color: c.textMuted, size: 28),
          ),
          const SizedBox(height: CiSpace.s5),
          Text('Add your first player',
              textAlign: TextAlign.center,
              style: CiType.h3.copyWith(color: c.text)),
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
            onPressed: () => context.pushNamed(PlayersListWidget.routeName),
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
            Text('View All Games',
                style: CiType.rowTitle.copyWith(
                    color: c.text, fontWeight: CiWeight.semiBold)),
            const Spacer(),
            Icon(Icons.chevron_right, color: c.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
