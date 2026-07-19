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

import 'package:supabase_flutter/supabase_flutter.dart';

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
    final nav = appNavigatorKey.currentContext;
    if (nav == null) return;

    _navigating = true;
    // goNamed, not push: the parent arrived from an email, not from inside the
    // app, so there is no stack behind this worth preserving.
    nav.goNamed(ResetPasswordWidget.routeName);

    // Released on the next frame rather than never, so a SECOND, genuine
    // recovery later in the session still works.
    Future<void>.delayed(const Duration(seconds: 2), () {
      _navigating = false;
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
