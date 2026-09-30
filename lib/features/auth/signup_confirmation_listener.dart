// Signup confirmation deep link — Phase 4.18
//
// A confirmation email carries a link to courtsideiq://login-callback. Tapping
// it verifies the email and, on the implicit flow, hands the app a full session
// - so the SDK would sign the parent straight in and drop them at first-run,
// after a flash of the signed-out onboarding intro on the way.
//
// WE DELIBERATELY DO NOT LEAVE THEM SIGNED IN. The same email can be opened on a
// DIFFERENT device than the one they signed up on, where the link cannot sign
// anyone in and they must come back and sign in by hand. The only way to make
// the two cases behave the same is to land everyone on the sign-in screen after
// confirming. It also matches the copy CheckEmailPage already shows ("...then
// sign in") and removes the onboarding flash.
//
// WHY A SEPARATE LISTENER FROM PasswordRecoveryListener. Recovery gets its own
// auth EVENT (passwordRecovery); signup confirmation only fires a plain
// signedIn, indistinguishable from a normal login. So the LINK is the only
// clean signal, and this reads it via app_links - which is already a direct
// dependency and is what supabase_flutter itself uses under the hood. The
// login-callback host is unique to signup confirmation; reset uses
// reset-password, so the two never cross.

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import '/flutter_flow/nav/nav.dart';
import '/index.dart';

/// Whether [uri] is the signup-confirmation deep link.
///
/// Pure and public so it can be tested without the SDK. The host is the
/// discriminator: signup uses `login-callback`, recovery uses `reset-password`.
/// Matching recovery here would sign out a parent mid password reset, so this
/// must stay narrow.
bool isSignupConfirmLink(Uri uri) =>
    uri.scheme == 'courtsideiq' &&
    (uri.host == 'login-callback' || uri.path.contains('login-callback'));

/// Lands a confirmed signup on the sign-in screen with a success toast.
///
/// Idempotent: [start] replaces any previous subscription rather than stacking
/// listeners that would both try to navigate.
class SignupConfirmationListener {
  SignupConfirmationListener._();
  static final instance = SignupConfirmationListener._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// True while one confirmation is being resolved. The link can arrive twice
  /// (an initial-link read plus a stream event on a cold start), and handling
  /// it twice would sign out mid-navigation.
  bool _handling = false;

  /// Flip to true to trace a confirmation that lands on the wrong screen, the
  /// same escape hatch PasswordRecoveryListener keeps - this is deep-link plus
  /// auth timing, where a silent wrong-destination is the likely failure.
  static const bool _kLog = false;
  static void _log(String m) {
    if (_kLog) debugPrint('[signup-confirm] $m');
  }

  Future<void> start() async {
    _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(_onLink);
    // A cold start FROM the confirm link: the launch URI is not delivered on
    // the stream, only here.
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _onLink(initial);
    _log('listening');
  }

  void _onLink(Uri uri) {
    _log('link=$uri');
    if (!isSignupConfirmLink(uri)) return;
    if (_handling) {
      _log('ignored: already handling');
      return;
    }
    _handling = true;
    _waitForSessionThenLandOnSignIn();
  }

  /// The confirm link signs the parent in via the SDK, but on a separate clock
  /// from [AppStateNotifier]. Signing out before the session lands would no-op
  /// and leave them signed in; so wait until the app agrees they are signed in,
  /// then sign out and route. Same two-clocks problem the recovery flow has.
  void _waitForSessionThenLandOnSignIn() {
    final notifier = AppStateNotifier.instance;
    Timer? timeout;

    late void Function() attempt;
    attempt = () {
      if (!notifier.loggedIn) {
        _log('waiting: app not signed in yet');
        return;
      }
      if (appNavigatorKey.currentContext == null) {
        _log('waiting: no navigator context yet');
        return;
      }
      notifier.removeListener(attempt);
      timeout?.cancel();
      _land();
    };

    notifier.addListener(attempt);
    timeout = Timer(const Duration(seconds: 15), () {
      _log('GAVE UP after 15s: session never reported signed in');
      notifier.removeListener(attempt);
      _handling = false;
    });
    // May already be there on a warm start.
    attempt();
  }

  Future<void> _land() async {
    _log('session established; signing out to land on sign-in');
    // Discard the auto-established session so the parent reaches the sign-in
    // screen rather than being carried into the app.
    await SupaFlow.client.auth.signOut();

    // FFRoute stashes a "resume here once you sign in" location when it bounces
    // a signed-out user off a protected route. Clear it, or the next sign-in
    // jumps them past the screen they should land on.
    AppStateNotifier.instance.clearRedirectLocation();

    final context = appNavigatorKey.currentContext;
    if (context != null) {
      // goNamed, not push: they arrived from an email, so there is no in-app
      // stack behind this worth keeping.
      context.goNamed(UserAuthEmailWidget.routeName);
      // After the sign-in screen is up. The toast floats at the app level, so
      // it shows over whatever is there, but the post-frame keeps a valid
      // context and lets the navigation settle first.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final c = appNavigatorKey.currentContext;
        if (c != null) {
          showCiToast(c, 'Your email is confirmed. Sign in to get started.',
              type: CiToastType.success);
        }
      });
    }

    // Released after a beat so a second genuine confirmation later in the same
    // session still works.
    Future<void>.delayed(const Duration(seconds: 3), () => _handling = false);
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
