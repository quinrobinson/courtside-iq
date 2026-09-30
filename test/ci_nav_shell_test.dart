// The persistent nav shell — Phase 4.19f
//
// The whole point of the shell is that the bar SURVIVES a tab change instead
// of being torn down and rebuilt with the page. So these drive a real
// StatefulShellRoute and assert the bar is the same widget across a switch,
// and that a branch keeps its state - the two things that were broken before
// and that a screenshot cannot tell you.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:courtside_i_q/features/nav/ci_nav_bar.dart';
import 'package:courtside_i_q/features/nav/ci_nav_shell.dart';
import 'package:courtside_i_q/features/onboarding/first_run_gate.dart';
import 'package:courtside_i_q/features/onboarding/whats_new_gate.dart';

/// Both gates decline, so the shell renders and nothing reaches the network.
class _QuietFirstRun implements FirstRunPolicy {
  const _QuietFirstRun();
  @override
  Future<bool> shouldShow() async => false;
  @override
  Future<void> markSeen() async {}
}

class _QuietWhatsNew implements WhatsNew2Policy {
  const _QuietWhatsNew();
  @override
  Future<bool> shouldShow() async => false;
  @override
  Future<void> markSeen() async {}
}

/// A body that counts its own mounts, so we can tell a preserved branch from a
/// rebuilt one.
class _Counting extends StatefulWidget {
  const _Counting(this.label);
  final String label;
  static final mounts = <String, int>{};
  @override
  State<_Counting> createState() => _CountingState();
}

class _CountingState extends State<_Counting> {
  @override
  void initState() {
    super.initState();
    _Counting.mounts.update(widget.label, (v) => v + 1, ifAbsent: () => 1);
  }

  @override
  Widget build(BuildContext context) => Text(widget.label);
}

GoRouter _router() => GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => CiNavShell(
            navigationShell: navigationShell,
            firstRunPolicy: const _QuietFirstRun(),
            whatsNewPolicy: const _QuietWhatsNew(),
          ),
          branches: [
            // Players carries a pushable detail route, so the reset-to-root
            // behaviour can be exercised; the rest are single-screen.
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const _Counting('HOME'),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/players',
                builder: (_, __) => const _Counting('PLAYERS'),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, __) => const _Counting('PLAYER_DETAIL'),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/games',
                builder: (_, __) => const _Counting('GAMES'),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/menu',
                builder: (_, __) => const _Counting('MENU'),
              ),
            ]),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester) async {
  _Counting.mounts.clear();
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp.router(routerConfig: _router()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders one bar, and the starting branch', (tester) async {
    await _pump(tester);
    expect(find.byType(CiNavBar), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('the bar survives a tab change instead of remounting',
      (tester) async {
    await _pump(tester);
    // The Element, not the widget: CiNavBar is stateless, so a new widget
    // instance per rebuild is expected and harmless. What must NOT happen is
    // the element being discarded and recreated, which is what tearing the
    // scaffold down on every tab tap used to do.
    final before = tester.element(find.byType(CiNavBar));

    await tester.tap(find.bySemanticsLabel('Games'));
    await tester.pumpAndSettle();

    expect(find.text('GAMES'), findsOneWidget);
    expect(find.byType(CiNavBar), findsOneWidget);
    expect(identical(tester.element(find.byType(CiNavBar)), before), isTrue,
        reason: 'the bar must persist across a tab change, not remount');
  });

  testWidgets('a branch keeps its state when you come back', (tester) async {
    await _pump(tester);
    expect(_Counting.mounts['HOME'], 1);

    await tester.tap(find.bySemanticsLabel('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Home'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    // Still 1: indexedStack kept it alive, so returning does not refetch.
    expect(_Counting.mounts['HOME'], 1,
        reason: 'returning to a tab must not rebuild it');
  });

  testWidgets('tapping a tab lands on its ROOT, not a stale pushed screen',
      (tester) async {
    // The Section-C bug: open a player profile in the Players branch, leave to
    // another tab, come back - and land on that profile rather than the list.
    await _pump(tester);

    // Into a pushed detail within the Players branch.
    await tester.tap(find.bySemanticsLabel('Players'));
    await tester.pumpAndSettle();
    tester.element(find.text('PLAYERS')); // at the root first
    // Push detail by driving the router.
    final ctx = tester.element(find.byType(CiNavShell));
    GoRouter.of(ctx).go('/players/detail');
    await tester.pumpAndSettle();
    expect(find.text('PLAYER_DETAIL'), findsOneWidget);

    // Leave and come back via the tab bar.
    await tester.tap(find.bySemanticsLabel('Games'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Players'));
    await tester.pumpAndSettle();

    // Root, not the stale detail.
    expect(find.text('PLAYERS'), findsOneWidget);
    expect(find.text('PLAYER_DETAIL'), findsNothing);
  });

  testWidgets('the active tab follows the branch', (tester) async {
    await _pump(tester);
    expect(
        tester.widget<CiNavBar>(find.byType(CiNavBar)).active, CiNavTab.home);

    await tester.tap(find.bySemanticsLabel('Players'));
    await tester.pumpAndSettle();
    expect(tester.widget<CiNavBar>(find.byType(CiNavBar)).active,
        CiNavTab.players);
  });
}
