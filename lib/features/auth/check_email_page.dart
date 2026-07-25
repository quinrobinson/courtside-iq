// Check Your Email — Phase 4.9b
//
// Built from Screens / Signup - Check Your Email (765:3144) and
// Forgot Password - Link Sent (765:3370). Both frames are clones of Reset
// Successful and differ only in body copy and which resend they offer, so this
// is ONE screen with two purposes rather than two near-identical files.
//
// WHY THIS SCREEN EXISTS. Prod has email confirmation ON: after signing up, a
// parent is NOT signed in until they click the link. Without this screen the
// app simply sits there and signup looks like it hung. Test has confirmation
// OFF, which is exactly why the signup flow verified on device is not the one
// a real parent gets - and why this screen cannot be verified there.
//
// THE TWO PURPOSES SAY DIFFERENT THINGS ON PURPOSE, and the difference is a
// security property, not a copy preference. See [CheckEmailPurpose].

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'forgot_password_page.dart' show kPasswordResetRedirect;
import 'widgets/auth_scaffold.dart';

/// Where the signup CONFIRMATION link sends a parent back.
///
/// A `courtsideiq://` deep link, mirroring [kPasswordResetRedirect]. Without it
/// the signUp call sends nothing, so Supabase falls back to the project Site
/// URL - which defaults to localhost, the dead end a confirm link hit on
/// device. The confirm link then reopens the app on the implicit flow and the
/// SDK signs the parent in.
///
/// MUST BE IN THE TEST PROJECT'S REDIRECT-URL ALLOWLIST. Supabase honours
/// emailRedirectTo only when it matches an allowlisted URL, and silently falls
/// back to the Site URL when it does not - which is exactly the failure this
/// fixes, so a matching allowlist entry is half of the fix, not optional.
const kEmailConfirmRedirect = 'courtsideiq://login-callback';

enum CheckEmailPurpose {
  /// After creating an account. The address is NAMED, because the parent just
  /// typed it and a typo is the likeliest reason nothing ever arrives.
  signup,

  /// After requesting a password reset. The address is deliberately NOT named
  /// and the copy never confirms an account exists: this screen must read
  /// identically whether or not the address is registered, or anyone could
  /// probe which parents have accounts.
  passwordReset,
}

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({
    super.key,
    required this.purpose,
    required this.email,
  });

  final CheckEmailPurpose purpose;

  /// Shown only for [CheckEmailPurpose.signup]. Still required for reset,
  /// because resending needs it even though it is never displayed.
  final String email;

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  bool _busy = false;

  bool get _isSignup => widget.purpose == CheckEmailPurpose.signup;

  String get _body => _isSignup
      ? 'We sent a link to ${widget.email}. Tap it to confirm your account, then sign in.'
      // No "we sent you an email" - that would confirm the address exists.
      // The expiry is stated because a link that silently stops working is
      // indistinguishable from a broken app.
      : 'If that email has an account, we sent a link to reset your password. It expires in one hour.';

  Future<void> _resend() async {
    if (_busy) return;
    setState(() => _busy = true);
    String? error;
    try {
      if (_isSignup) {
        await SupaFlow.client.auth.resend(
          type: OtpType.signup,
          email: widget.email,
          // Same redirect as the original signup, or a resent link would land
          // on localhost while the first one worked.
          emailRedirectTo: kEmailConfirmRedirect,
        );
      } else {
        error = await actions.sendRecoveryEmail(
          widget.email,
          kPasswordResetRedirect,
        );
      }
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => _busy = false);

    final failed = error != null && error.isNotEmpty;
    // Neutral on success: "check your email" is a pending step, not a done
    // action, and it does not claim an account exists.
    showCiToast(context, failed ? error : 'Sent. Check your email again.',
        type: failed ? CiToastType.error : CiToastType.neutral);
  }

  void _backToSignIn() {
    // goNamed, not push: whatever brought them here is finished, and back
    // must not return into the middle of it.
    context.goNamed(UserAuthEmailWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      centerText: true,
      header: const Center(
        child: DotBurst(size: 220, markSize: 50, child: CiLogoMark(size: 50)),
      ),
      title: 'Check your email',
      subtitle: _body,
      actionLabel: 'Back to sign in',
      onAction: _busy ? null : _backToSignIn,
      onBack: _backToSignIn,
      linkLabel: _isSignup ? 'Resend email' : 'Resend link',
      onLink: _busy ? null : _resend,
      children: const [],
    );
  }
}
