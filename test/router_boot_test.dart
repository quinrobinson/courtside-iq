// Booting the app through the REAL router — Phase 4.19f
//
// THIS IS THE TEST CLASS THAT WAS MISSING, and its absence cost three
// regressions in a row, all the same shape:
//
//   1. no bottom nav on a cold start   ('/' rendered home outside the shell)
//   2. Home stuck on the splash        (a branch built mid-splash is cached)
//   3. tab destinations stacking       (pushing a branch route from a branch)
//
// Every existing test mounts a SCREEN directly, or drives a synthetic router
// built in the test itself. Neither ever starts the app at '/', so neither can
// see what the entry path resolves to - which is exactly where all three bugs
// lived.
//
// WHAT THIS ASSERTS, AND WHAT IT DOES NOT. It boots the real route table and
// checks the STRUCTURE the entry path lands in: is the shell there or not.
// The screens themselves reach Supabase in initState and throw here, so their
// content is not asserted and those exceptions are drained deliberately. That
// is fine - the shell being present or absent is the invariant these bugs
// broke, and it is checkable without a backend.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/auth/base_auth_user_provider.dart';
import 'package:courtside_i_q/features/nav/ci_nav_shell.dart';
import 'package:courtside_i_q/flutter_flow/nav/nav.dart';

class _SignedIn extends BaseAuthUser {
  @override
  bool get loggedIn => true;
  @override
  bool get emailVerified => true;
  @override
  AuthUserInfo get authUserInfo => const AuthUserInfo(uid: 'u1');
  @override
  Future? delete() => null;
  @override
  Future? updateEmail(String email) => null;
  @override
  Future? updatePassword(String p) => null;
  @override
  Future? sendEmailVerification() => null;
}

/// Boots the real router at '/' and returns once it has settled.
///
/// Screen-level exceptions (Supabase is not initialised in a test) are drained
/// so they cannot fail the run; this file is about routing structure.
Future<void> _boot(WidgetTester tester, {required bool loading}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final notifier = AppStateNotifier.instance
    ..user = _SignedIn()
    ..showSplashImage = loading;

  await tester.pumpWidget(
    MaterialApp.router(routerConfig: createRouter(notifier)),
  );
  await tester.pump(const Duration(milliseconds: 500));
  while (tester.takeException() != null) {}
}

void main() {
  testWidgets('a signed-in cold start lands INSIDE the shell', (tester) async {
    await _boot(tester, loading: false);
    expect(
      find.byType(CiNavShell),
      findsOneWidget,
      reason: "'/' builds home inline; if it does not hand over to the "
          'shell-owned route there is no bottom nav anywhere on Today',
    );
  });

  testWidgets('but NOT while the splash is still showing', (tester) async {
    await _boot(tester, loading: true);
    // The shell's indexedStack keeps branch pages alive, so a branch entered
    // mid-splash is built AS the splash and never recovers. '/' has to hold
    // the splash itself, outside the shell, until loading is done.
    expect(
      find.byType(CiNavShell),
      findsNothing,
      reason: 'entering a branch mid-splash caches the splash forever',
    );
  });
}
