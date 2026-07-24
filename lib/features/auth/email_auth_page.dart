// Email Auth — Phase 4.9
//
// Measured from Screens / Email Auth (Sign In) 253:972, (Sign Up) 254:975,
// and States & Validation / Email Auth — Validation Error 524:2009:
//
//   ground   #0F0F0F, ink - the whole screen is CiSurface.ink
//   back     40x40 IconButton, radius 6, #2E2E2E border, top 52
//   toggle   two chips at top 124: white + ink selected, #1F1F1F + muted not
//   form     top 178, width 350, 20px between fields
//   field    label 12 Medium tracking 0.72, 8px gap, input h48 radius 6,
//            fill #000000, border #2E2E2E
//   CTA      lime pill h48, INK label, full width
//
// THE CHIPS ARE A MODE TOGGLE, and that is deliberate despite the house rule
// that chips are filters and tabs are navigation. The Validation Error frame
// draws this control as underline tabs, but a second tab idiom here would
// undercut the real navigation tabs elsewhere in the app. Decided 2026-07-19:
// chips win, the tab treatment in that one frame is stale. Do not "fix" this.
//
// Sign in and sign up are ONE screen, not two routes. They share the email and
// password the parent has already typed, so toggling does not wipe their work -
// which is the whole reason the control sits inside the form rather than above
// it.

import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/auth/supabase_auth/supabase_user_provider.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/auth_validation.dart';
import 'check_email_page.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

enum AuthMode { signIn, signUp }

class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  late AuthMode _mode = widget.initialMode;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _busy = false;

  /// Errors are shown only after the first submit, then kept live as they type.
  /// Validating on every keystroke from empty would tell a parent their email
  /// is invalid while they are still typing the first letter of it.
  bool _submitted = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // The rules live in lib/courtside_iq/auth_validation.dart as pure Dart, so
  // they can be tested without pumping a widget - and so a VALID input in a
  // test does not fall through to the real authManager and hit Supabase.
  void _validate() {
    _emailError = validateEmail(_email.text);
    // Length is a rule about creating a password, not about typing an existing
    // one. Enforcing it on sign in locks out every account made before the
    // rule existed.
    _passwordError = _isSignUp
        ? validateNewPassword(_password.text)
        : validatePassword(_password.text);
    // Only meaningful on sign up, and cleared on sign in so a stale message
    // cannot survive a toggle.
    _confirmError = _isSignUp
        ? validateConfirmPassword(_password.text, _confirm.text)
        : null;
  }

  bool get _hasErrors =>
      _emailError != null || _passwordError != null || _confirmError != null;

  void _onChanged(String _) {
    if (!_submitted) return;
    setState(_validate);
  }

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      // Toggling is not a failed attempt. Clear the errors so switching to
      // sign up does not greet the parent with red text they have not earned.
      _submitted = false;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _validate();
    });
    if (_hasErrors || _busy) return;

    setState(() => _busy = true);
    try {
      // Suppresses the router refresh that the auth-state change would
      // otherwise fire mid-flow, which would interrupt the navigation below.
      GoRouter.of(context).prepareAuthEvent();

      final email = _email.text.trim();
      final password = _password.text;

      if (_isSignUp) {
        final handled = await _signUp(email, password);
        if (handled) return;
      } else {
        // authManager surfaces its own error snackbar and returns null.
        final user = await authManager.signInWithEmail(context, email, password);
        if (user == null) return;
      }
      if (!mounted) return;

      // NAVIGATE EXPLICITLY. Signing in updates the auth stream, but nothing
      // redirects an authenticated user off this route - so without this the
      // sign-in succeeds and the parent sits on the auth screen watching
      // nothing happen, which reads as a dead button.
      if (loggedIn) {
        context.pushNamedAuth(
          HomeWidget.routeName,
          context.mounted,
        );
      }
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  /// Signs up, and returns true when it has already handled the outcome.
  ///
  /// NOT authManager.createAccountWithEmail. That routes through
  /// emailCreateAccountFunc, which returns NULL when the account is
  /// unconfirmed:
  ///
  ///   return res.user?.lastSignInAt == null ? null : res.user;
  ///
  /// which is indistinguishable from a failure. With email confirmation ON -
  /// the prod configuration - every signup would look like an error, the
  /// screen would bail, and nothing at all would happen. That is the exact
  /// failure CheckEmailPage exists to prevent, and it hid here because test
  /// had confirmation OFF.
  ///
  /// Calling signUp directly is what makes the two cases distinguishable: the
  /// SESSION, not the user, says whether they are signed in.
  ///
  /// The shared function is deliberately left alone. v1 still calls it, and it
  /// relies on that null to skip a users-table insert it would otherwise
  /// attempt with no session.
  Future<bool> _signUp(String email, String password) async {
    try {
      final res = await SupaFlow.client.auth.signUp(
        email: email,
        password: password,
      );
      if (!mounted) return true;

      // No session means confirmation is required: the account exists, but
      // they are not signed in until they click the link.
      if (res.session == null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CheckEmailPage(
            purpose: CheckEmailPurpose.signup,
            email: email,
          ),
        ));
        return true;
      }

      // Signed in immediately, so confirmation is off. Mirror the bookkeeping
      // authManager does, or the app's own auth state lags behind Supabase's
      // and the navigation below runs against a stale `loggedIn`.
      if (res.user != null) {
        final authUser = CourtsideIQSupabaseUser(res.user);
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return false;
    } on AuthException catch (e) {
      if (!mounted) return true;
      showCiToast(
        context,
        e.message.contains('User already registered')
            ? 'That email is already in use by a different account.'
            : 'Error: ${e.message}',
        type: CiToastType.error,
      );
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  CiSpace.screen, CiSpace.s3, CiSpace.screen, CiSpace.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CiIconButton(
                    icon: Icons.chevron_left,
                    onDark: true,
                    semanticLabel: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  // The mark, carried over from the auth landing so the two
                  // screens read as one flow. Same 50-in-220 pairing and the
                  // same gap above it; the form moves down to make room, which
                  // is the intended trade. Centre-aligned inside a column that
                  // otherwise starts at the left, like the landing's buttons.
                  const SizedBox(height: CiSpace.s4),
                  const Center(
                    child: DotBurst(
                      size: 220,
                      markSize: 50,
                      child: CiLogoMark(size: 50),
                    ),
                  ),
                  const SizedBox(height: CiSpace.s6),
                  _ModeChips(mode: _mode, onChanged: _setMode),
                  const SizedBox(height: CiSpace.s6),
                  CiField(
                    label: 'Email address',
                    placeholder: 'you@email.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    enabled: !_busy,
                    onChanged: _onChanged,
                  ),
                  const SizedBox(height: CiSpace.s5),
                  CiField(
                    label: 'Password',
                    placeholder: '••••••••',
                    controller: _password,
                    obscure: !_showPassword,
                    trailing: _showPassword ? 'Hide' : 'Show',
                    onTrailingTap: () =>
                        setState(() => _showPassword = !_showPassword),
                    errorText: _passwordError,
                    enabled: !_busy,
                    onChanged: _onChanged,
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: CiSpace.s5),
                    CiField(
                      label: 'Confirm password',
                      placeholder: '••••••••',
                      controller: _confirm,
                      obscure: !_showConfirm,
                      trailing: _showConfirm ? 'Hide' : 'Show',
                      onTrailingTap: () =>
                          setState(() => _showConfirm = !_showConfirm),
                      errorText: _confirmError,
                      enabled: !_busy,
                      onChanged: _onChanged,
                    ),
                  ],
                  // Forgot password belongs to sign in only. On sign up there
                  // is no account yet to recover.
                  if (!_isSignUp) ...[
                    const SizedBox(height: CiSpace.s4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _busy ? null : _openForgotPassword,
                        behavior: HitTestBehavior.opaque,
                        child: Semantics(
                          button: true,
                          child: Padding(
                            // Padded to a real touch target: the label alone is
                            // well under 44pt tall.
                            padding: const EdgeInsets.symmetric(
                                vertical: CiSpace.s3, horizontal: CiSpace.s2),
                            child: Text('Forgot password?',
                                style: CiType.bodySm
                                    .copyWith(color: c.textMuted)),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: CiSpace.s6),
                  const SizedBox(height: CiSpace.s4),
                  CiButton(
                    label: _isSignUp ? 'Create account' : 'Sign in',
                    style: CiButtonStyle.lime,
                    expand: true,
                    busy: _busy,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openForgotPassword() {
    // pushNamed, not goNamed: back from Forgot Password returns to whatever
    // the parent had already typed here.
    context.pushNamed(
      ForgotPasswordWidget.routeName,
    );
  }
}

/// Sign in / Sign up mode toggle. Chips, not tabs - see the file header.
class _ModeChips extends StatelessWidget {
  const _ModeChips({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CiChip(
          label: 'Sign in',
          selected: mode == AuthMode.signIn,
          onTap: () => onChanged(AuthMode.signIn),
        ),
        const SizedBox(width: CiSpace.s2),
        CiChip(
          label: 'Sign up',
          selected: mode == AuthMode.signUp,
          onTap: () => onChanged(AuthMode.signUp),
        ),
      ],
    );
  }
}
