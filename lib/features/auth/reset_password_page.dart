// Reset Password — Phase 4.9
//
// Measured from Screens / Reset Password 608:2172. Ink ground, back button,
// "Set a new password" h1 + subhead, two password fields, "Use at least 8
// characters." as standing HELPER text under the confirm field, lime CTA
// pinned to the bottom.
//
// The helper is guidance, not an error: it states the rule before the parent
// breaks it. CiField shows an error INSTEAD of it, never both.
//
// REACHED BY A RECOVERY LINK, not by navigation. Supabase puts the app into a
// password-recovery session when the link is opened, and updateUser then
// applies to that session. Until the deep link lands (Part A of 4.9) this
// screen is only reachable directly, which is why the flag stays off.

import 'package:flutter/material.dart';

import '/courtside_iq/auth_validation.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'widgets/auth_scaffold.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.onAbandon});

  /// Back, which here means ABANDONING THE RESET - and that is a teardown,
  /// not a pop. This screen is reached by a recovery deep link, so it is the
  /// only route on the stack (maybePop does nothing: the button read as
  /// dead), and the link has already established a real session as a side
  /// effect. Left alone, that session survives a force-quit and the next
  /// launch opens the app SIGNED IN to the account being reset - observed on
  /// device 2026-07-26. The caller signs out and returns to sign-in, the
  /// same pattern the signup-confirmation listener uses for its own
  /// side-effect session.
  final VoidCallback? onAbandon;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _busy = false;
  bool _submitted = false;

  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _validate() {
    // validateNewPassword, not validatePassword: this password is being
    // CREATED, so the minimum applies. The sign-in form deliberately does not
    // enforce it - see auth_validation.dart.
    _passwordError = validateNewPassword(_password.text);
    _confirmError = validateConfirmPassword(_password.text, _confirm.text);
  }

  void _onChanged(String _) {
    if (!_submitted) return;
    setState(_validate);
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _validate();
    });
    if (_passwordError != null || _confirmError != null || _busy) return;

    setState(() => _busy = true);
    final error =
        await actions.updatePassword(_password.text, _confirm.text);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null && error.isNotEmpty) {
      showCiToast(context, error, type: CiToastType.error);
      return;
    }

    // goNamed, not push: the reset is done, and back must not return to a
    // form that would try to apply it twice.
    context.goNamed(ResetSuccesfulWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Set a new password',
      subtitle: 'Create a new password for your account.',
      actionLabel: 'Update password',
      actionBusy: _busy,
      onAction: _busy ? null : _submit,
      onBack: widget.onAbandon,
      children: [
        CiField(
          label: 'New password',
          placeholder: '••••••••',
          controller: _password,
          obscure: !_showPassword,
          trailing: _showPassword ? 'Hide' : 'Show',
          onTrailingTap: () => setState(() => _showPassword = !_showPassword),
          errorText: _passwordError,
          // The frame places this under CONFIRM PASSWORD, but the rule is
          // enforced on THIS field - so stating it there would show a parent
          // the rule under one field and the violation under another. Same
          // slot for guidance and error. Deliberate deviation, 2026-07-19.
          helperText: 'Use at least $kMinPasswordLength characters.',
          enabled: !_busy,
          onChanged: _onChanged,
        ),
        const SizedBox(height: CiSpace.s5),
        CiField(
          label: 'Confirm password',
          placeholder: '••••••••',
          controller: _confirm,
          obscure: !_showConfirm,
          trailing: _showConfirm ? 'Hide' : 'Show',
          onTrailingTap: () => setState(() => _showConfirm = !_showConfirm),
          errorText: _confirmError,
          enabled: !_busy,
          onChanged: _onChanged,
        ),
      ],
    );
  }
}
