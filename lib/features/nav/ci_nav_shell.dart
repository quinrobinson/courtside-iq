// The persistent bottom-nav shell — Phase 4.19f
//
// ONE CiNavBar for all four tabs, living OUTSIDE the routed content.
//
// Before this, Today, Players, Games, Menu and Player Profile each rendered
// their own bar, and the tab bar navigated with `goNamed`. That replaced the
// whole scaffold - bar included - so every tab tap tore the nav down, rebuilt
// it, and slid it in with the page. That reload is the tell that made the app
// read as a web page rather than an app.
//
// Inside the shell the bar never moves: a tap switches BRANCH, and only the
// body swaps. indexedStack keeps each branch alive, so a tab remembers its
// scroll position and its loaded data instead of refetching on every visit.
//
// THE LANDING GATES LIVE HERE, NOT ON THE HOME ROUTE, and that is not tidiness.
// FirstRunFlow has to COVER the nav bar - a brand-new parent must not be able
// to tab away from onboarding - and a gate inside the Home branch would render
// underneath the bar. Wrapping the shell means first-run replaces the whole
// thing, which is what it means. It also runs the gate's one Supabase query
// once for the shell rather than on every visit to Home.
//
// Screens that must NOT have a bar (auth, the live tracker, the paywall, the
// account sub-screens) stay OUTSIDE the shell as top-level routes, so pushing
// one covers the shell entirely - exactly what they did before.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/flags.dart';
import '/features/onboarding/first_run_gate.dart';
import '/features/onboarding/whats_new_gate.dart';
import '/features/players/players_revision.dart';
import 'ci_nav_bar.dart';

/// Branch order. This is the ONLY place the mapping between a tab and its
/// branch index is written down; the router declares its branches in the same
/// order and nothing else should hardcode an index.
const List<CiNavTab> kNavShellBranches = [
  CiNavTab.home,
  CiNavTab.players,
  CiNavTab.games,
  CiNavTab.menu,
];

class CiNavShell extends StatelessWidget {
  const CiNavShell({
    super.key,
    required this.navigationShell,
    this.firstRunPolicy,
    this.whatsNewPolicy,
  });

  final StatefulNavigationShell navigationShell;

  /// Injected only by tests. Both gates query Supabase through their default
  /// policies, so a test that mounts this shell would otherwise reach the
  /// network before it could assert anything about the bar.
  final FirstRunPolicy? firstRunPolicy;
  final WhatsNew2Policy? whatsNewPolicy;

  CiNavTab get _active => navigationShell.currentIndex < kNavShellBranches.length
      ? kNavShellBranches[navigationShell.currentIndex]
      : CiNavTab.none;

  void _goTab(CiNavTab tab) {
    final index = kNavShellBranches.indexOf(tab);
    if (index < 0) return;
    // ALWAYS to the branch root, not its remembered stack. Player Profile lives
    // in the Players branch, so opening one left the Players tab pointing at
    // that profile - tapping Players from another tab then landed on a specific
    // player rather than the list, which read as the tab being stuck on a stale
    // screen. indexedStack still keeps the root screen's scroll and state; only
    // pushed routes on top of it are popped. "Tap a tab, land on its section"
    // is the predictable gesture.
    navigationShell.goBranch(index, initialLocation: true);
  }

  /// A player added from the create sheet has to appear on the screen under
  /// the bar. Each screen used to pass its own refresh, which a SHARED bar
  /// cannot do - it does not know what it is sitting on.
  ///
  /// It ANNOUNCES rather than navigating. Resetting the branch would also
  /// refresh, but it pops that tab to its root, so adding a player from Player
  /// Profile threw you back to the list. Screens subscribe and reload
  /// themselves, leaving the stack untouched.
  void _onPlayerAdded() => notifyPlayersChanged();

  @override
  Widget build(BuildContext context) {
    Widget shell = Scaffold(
      body: navigationShell,
      bottomNavigationBar: CiNavBar(
        active: _active,
        onSelectTab: _goTab,
        onPlayerAdded: _onPlayerAdded,
      ),
    );

    // Order matters: WhatsNew sits INSIDE FirstRun, so a brand-new parent
    // finishes onboarding before the upgrade sheet is even considered. The two
    // are mutually exclusive by flag anyway, but the nesting makes it true by
    // construction rather than by coincidence.
    if (kUseWhatsNew2) {
      shell = WhatsNewGate(
        policy: whatsNewPolicy ?? const SupabaseWhatsNew2Policy(),
        child: shell,
      );
    }
    if (kUseFirstRun) {
      shell = FirstRunGate(
        policy: firstRunPolicy ?? const SupabaseFirstRunPolicy(),
        child: shell,
      );
    }
    return shell;
  }
}
