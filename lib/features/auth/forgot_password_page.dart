// Forgot Password — Phase 4.9
//
// Measured from Screens / Forgot Password 608:2152. Ink ground, back button,
// left-aligned h1 + subhead, one email field, lime CTA pinned to the bottom
// with "Back to sign in" beneath it.
//
// THE REDIRECT IS THE IMPORTANT PART OF THIS FILE. The recovery email carries
// a link, and where that link points decides whether a parent can get back
// into their account. v1 points it at a FlutterFlow-hosted web page, and
// FlutterFlow is retired - so that page is a live dependency on a service we
// no longer use. It is deliberately a named constant rather than an inline
// string so the deep-link change is one edit in one place.
//
// NO FRAME EXISTS for what this screen shows after sending. v1 popped a
// dialog. Using the design system's Snackbar (Figma 521:2009) instead of
// inventing a dialog or a fourth screen. Logged against 4.9.

import 'package:flutter/material.dart';

import '/courtside_iq/auth_validation.dart';
import 'check_email_page.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'widgets/auth_scaffold.dart';

/// Where the recovery link lands.
///
/// A `courtsideiq://` deep link, so reset happens in the app rather than on a
/// FlutterFlow-hosted web page that outlived the service it came from.
///
/// THE OLD URL HAS TO KEEP WORKING ANYWAY. Every recovery email already sent
/// points at it, and older app versions still in the wild keep sending it. The
/// FlutterFlow page cannot be retired the day this ships - only once those
/// links have expired and those installs have updated.
const kPasswordResetRedirect = 'courtsideiq://reset-password';

/// The address this replaced. Kept as a record of what still has to stay
/// alive, not used anywhere.
const kLegacyPasswordResetRedirect =
    'https://courtside-iq.flutterflow.app/resetPassword';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _busy = false;
  bool _submitted = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    // Drives the CTA's enabled state as they type.
    _email.addListener(_onChanged);
  }

  @override
  void dispose() {
    _email
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {
      if (_submitted) _emailError = validateEmail(_email.text);
    });
  }

  Future<void> _send() async {
    setState(() {
      _submitted = true;
      _emailError = validateEmail(_email.text);
    });
    if (_emailError != null || _busy) return;

    setState(() => _busy = true);
    final error = await actions.sendRecoveryEmail(
      _email.text.trim(),
      kPasswordResetRedirect,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null && error.isNotEmpty) {
      _snack(error, isError: true);
      return;
    }

    // A screen, not a snackbar. The frame for this exists now (765:3370), and
    // a snackbar vanishes - leaving a parent on a form they already submitted
    // with no way to resend.
    //
    // Still says nothing about whether the account exists.
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CheckEmailPage(
        purpose: CheckEmailPurpose.passwordReset,
        email: _email.text.trim(),
      ),
    ));
  }

  void _snack(String message, {bool isError = false}) {
    const c = CiColors.onInk;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? c.accentEnergy : c.surfaceInvert,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot password?',
      subtitle:
          "Enter the email for your account and we'll send a link to reset your password.",
      actionLabel: 'Send reset link',
      actionBusy: _busy,
      // Disabled until something is typed, matching v1. The full check runs
      // on submit so a half-typed address is not called invalid mid-word.
      onAction: _email.text.trim().isEmpty || _busy ? null : _send,
      linkLabel: 'Back to sign in',
      onLink: _busy ? null : () => _goToSignIn(context),
      children: [
        CiField(
          label: 'Email address',
          placeholder: 'you@email.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          enabled: !_busy,
        ),
      ],
    );
  }

  void _goToSignIn(BuildContext context) {
    // goNamed, not push: "back to sign in" should not stack another copy of
    // the auth screen behind this one.
    context.goNamed(UserAuthEmailWidget.routeName);
  }
}
