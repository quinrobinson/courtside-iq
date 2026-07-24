// Router wiring for the nav shell — Phase 4.19f
//
// `_buildRoutes` looks its branch routes up BY NAME with `firstWhere`. A name
// that does not match throws while the router is being constructed, which is
// before any screen renders - the app would simply not start, and no widget
// test of a screen would catch it.
//
// It also has to be true that moving four routes into branches did not DROP
// any route: a lost name is a `goNamed` that throws the first time a parent
// taps it, which is exactly the class of bug the flat table never had.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/flags.dart';
import 'package:courtside_i_q/features/nav/ci_nav_shell.dart';
import 'package:courtside_i_q/flutter_flow/nav/nav.dart';
import 'package:courtside_i_q/index.dart';

/// Every route name in the tree, branches included.
Set<String> _names(List<RouteBase> routes) {
  final found = <String>{};
  void walk(List<RouteBase> rs) {
    for (final r in rs) {
      if (r is GoRoute && r.name != null) found.add(r.name!);
      if (r is StatefulShellRoute) {
        for (final b in r.branches) {
          walk(b.routes);
        }
      }
      walk(r.routes);
    }
  }

  walk(routes);
  return found;
}

void main() {
  test('the real router builds, and builds a shell', () {
    // Throws here if a branch route name does not match a declared route.
    final router = createRouter(AppStateNotifier.instance);
    final shells = router.configuration.routes.whereType<StatefulShellRoute>();

    expect(shells, hasLength(kUseNavShell ? 1 : 0));
    if (kUseNavShell) {
      expect(shells.first.branches, hasLength(kNavShellBranches.length),
          reason: 'a branch per tab, in the order kNavShellBranches declares');
    }
  });

  test('no route was lost by moving the tabs into branches', () {
    final names = _names(createRouter(AppStateNotifier.instance).configuration.routes);

    // Read from the widgets themselves rather than hardcoded strings, so this
    // keeps testing the real names if any of them are ever renamed.
    //
    // The four tabs plus the pushed screen that rides in a branch. If any of
    // these vanished, its tab or its push would throw at tap time.
    for (final name in [
      HomeWidget.routeName,
      PlayersListWidget.routeName,
      AllGamesWidget.routeName,
      MenuWidget.routeName,
      PlayersProfileWidget.routeName,
    ]) {
      expect(names, contains(name), reason: '$name must still be routable');
    }

    // And a sample that must have stayed OUTSIDE the shell, so pushing them
    // still covers the bar.
    for (final name in [
      GameStatsWidget.routeName,
      UserAuthWidget.routeName,
      EditPlayerWidget.routeName,
    ]) {
      expect(names, contains(name), reason: '$name must still be routable');
    }
  });

  group('the entry route hands Home over to the shell', () {
    // THE REGRESSION THIS EXISTS FOR: '/' builds the home screen inline via
    // _entryScreen, so under the shell a cold start rendered Today with NO
    // bottom nav - the shell was not in that subtree. Every widget test still
    // passed, because none of them starts the app at '/'.
    test('a signed-in, settled parent at / is sent to the shell-owned home', () {
      expect(
        shellEntryRedirect(loggedIn: true, loading: false, path: '/'),
        HomeWidget.routePath,
        reason: 'otherwise / renders Today outside the shell, with no nav bar',
      );
    });

    test('NOT while loading, or Home caches the splash forever', () {
      // The second regression: FFRoute swaps the splash in for a route's real
      // content while loading, ONCE, at page-build time - and the shell's
      // indexedStack then keeps that page alive. A Home branch entered
      // mid-splash is built AS the splash and never rebuilds, so Home sits on
      // the splash while every other tab, built later, works.
      expect(
        shellEntryRedirect(loggedIn: true, loading: true, path: '/'),
        isNull,
        reason: 'never enter a shell branch while the splash is substituted',
      );
    });

    test('a signed-out parent is left alone, and so is every other path', () {
      // A signed-out parent belongs on onboarding, not bounced at Home.
      expect(shellEntryRedirect(loggedIn: false, loading: false, path: '/'),
          isNull);
      // Anything already routed is not our business.
      expect(
          shellEntryRedirect(
              loggedIn: true, loading: false, path: HomeWidget.routePath),
          isNull);
      expect(
          shellEntryRedirect(
              loggedIn: true, loading: false, path: '/playersList'),
          isNull);
    });
  });
}
