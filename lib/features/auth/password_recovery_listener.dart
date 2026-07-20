// Password recovery deep link — Phase 4.9 Part A
//
// A recovery email carries a link. Where that link points decides whether a
// parent can get back into their account, so this file is about one thing:
// making the app the thing that receives it.
//
// HOW IT ARRIVES. supabase_flutter already listens for incoming app links and
// processes auth callbacks itself - that is what the `app_links` dependency in
// pubspec actually is, despite never being imported here. When a
// `courtsideiq://reset-password#...` link opens the app, the SDK parses the
// fragment, establishes a recovery session, and emits `passwordRecovery`. So
// there is no link parsing in this file, and there should not be: hand-rolling
// it would mean duplicating token handling the SDK already does correctly.
//
// WHAT THIS ADDS is the last step the SDK cannot know about - which screen to
// show. It navigates on the root navigator, because the event can arrive with
// the app cold-started, backgrounded, or sitting on any screen.

import 'dart:async';


import '/backend/supabase/supabase.dart';
import '/flutter_flow/nav/nav.dart';
import '/index.dart';

/// Routes a recovery link to the Reset Password screen.
///
/// Idempotent: calling [start] twice replaces the previous subscription rather
/// than stacking two listeners that would both try to navigate.
class PasswordRecoveryListener {
  PasswordRecoveryListener._();
  static final instance = PasswordRecoveryListener._();

  StreamSubscription<AuthState>? _sub;

  /// True while a recovery session is being resolved on the reset screen.
  ///
  /// The recovery event can fire more than once for a single link - a cold
  /// start plus a session refresh, for instance - and navigating twice would
  /// stack two reset screens.
  bool _navigating = false;

  void start() {
    _sub?.cancel();
    _sub = SupaFlow.client.auth.onAuthStateChange.listen((state) {
      if (state.event != AuthChangeEvent.passwordRecovery) return;
      _openResetPassword();
    });
  }

  void _openResetPassword() {
    if (_navigating) return;
    _navigating = true;
    _waitForAuthThenNavigate();
  }

  /// Navigates once the APP agrees the parent is signed in.
  ///
  /// Two clocks are running and they do not agree. Supabase emits
  /// passwordRecovery the moment it parses the link, but AppStateNotifier is
  /// driven by a separate user stream that has not caught up yet. Navigating
  /// on the Supabase event alone sends the parent to a `requireAuth` route
  /// while the app still believes nobody is signed in, and FFRoute bounces
  /// them straight to /onBoard.
  ///
  /// So: wait for `loggedIn`, then go. Both bounces seen on device came from
  /// jumping the gun - first onto Home via a stale redirect stash, then onto
  /// onboarding via requireAuth.
  void _waitForAuthThenNavigate() {
    final notifier = AppStateNotifier.instance;
    Timer? timeout;

    void attempt() {
      if (!notifier.loggedIn) return;
      final context = appNavigatorKey.currentContext;
      if (context == null) return;

      notifier.removeListener(attempt);
      timeout?.cancel();

      // FFRoute stashes a "come back here once you log in" location whenever
      // it bounces a signed-out user off a protected route. Recovery is the
      // one sign-in that must NOT resume where they left off, or the router
      // pulls them onto Home before they can type a password.
      notifier.clearRedirectLocation();

      // goNamed, not push: they arrived from an email, not from inside the
      // app, so there is no stack behind this worth preserving.
      context.goNamed(ResetPasswordWidget.routeName);

      // Released after a beat rather than never, so a SECOND genuine recovery
      // later in the same session still works.
      Future<void>.delayed(const Duration(seconds: 3), () {
        _navigating = false;
      });
    }

    notifier.addListener(attempt);

    // Gives up rather than listening forever: a recovery session that never
    // materialises should leave the app usable, not wedged.
    timeout = Timer(const Duration(seconds: 15), () {
      notifier.removeListener(attempt);
      _navigating = false;
    });

    // The state may already be there on a warm start.
    attempt();
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
