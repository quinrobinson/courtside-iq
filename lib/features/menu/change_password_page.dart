// Change Password — Phase 4.15b
//
// Measured from 496:2020: three fields at 92pt intervals - CURRENT PASSWORD,
// NEW PASSWORD, CONFIRM NEW PASSWORD - then "Use at least 8 characters." and
// a lime "Update password".
//
// THE CURRENT PASSWORD FIELD IS LOAD-BEARING, and only because the repository
// makes it so. Supabase's updateUser trusts the session and never checks the
// old password, so without a deliberate re-authentication this field would be
// decoration: anyone holding an unlocked phone could change the password and
// lock the owner out of their own account. See AccountRepository.
//
// A WRONG CURRENT PASSWORD IS REPORTED ON ITS OWN FIELD, not as a general
// error. It is the only one of the three the parent cannot check by looking.

import 'package:flutter/material.dart';

import '/courtside_iq/auth_validation.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'account_repository.dart';
import '/courtside_iq/design/components/ci_toast.dart';

class ChangePasswordPage extends StatefulWidget {
  /// A REAL ROUTE, not a Navigator.push.
  ///
  /// v1 has no change-password screen, so there was no FlutterFlow route to
  /// switch and the first wiring pushed a bare MaterialPageRoute. It never
  /// appeared: this app sets GoRouter.optionURLReflectsImperativeAPIs, and a
  /// raw route pushed onto GoRouter's navigator is discarded the next time
  /// the router rebuilds. Edit Name and Edit Email worked only because they
  /// had v1 routes to push by name.
  static const String routeName = 'ChangePassword';
  static const String routePath = '/changePassword';

  const ChangePasswordPage({
    super.key,
    this.repository = const AccountRepository(),
  });

  final AccountRepository repository;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool _showCurrent = false;
  bool _showNext = false;
  bool _saving = false;

  String? _currentError;
  String? _nextError;
  String? _confirmError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _filled =>
      _current.text.isNotEmpty &&
      _next.text.isNotEmpty &&
      _confirm.text.isNotEmpty;

  Future<void> _save() async {
    final nextProblem = validateNewPassword(_next.text);
    final confirmProblem = validateConfirmPassword(_next.text, _confirm.text);

    if (nextProblem != null || confirmProblem != null) {
      setState(() {
        _nextError = nextProblem;
        _confirmError = confirmProblem;
      });
      return;
    }

    setState(() {
      _currentError = null;
      _nextError = null;
      _confirmError = null;
      _saving = true;
    });

    final ok = await widget.repository.changePassword(
      currentPassword: _current.text,
      newPassword: _next.text,
    );
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _saving = false;
        // On the field it belongs to. A banner saying "something went wrong"
        // would leave a parent retyping all three.
        _currentError = "That's not your current password.";
      });
      return;
    }

    Navigator.of(context).maybePop();
    showCiToast(context, 'Your password has been updated.',
        type: CiToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CiSubPageHeader(title: 'Change password'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen, CiSpace.s6, CiSpace.screen, CiSpace.s6),
                    children: [
                      CiField(
                        label: 'Current password',
                        controller: _current,
                        obscure: !_showCurrent,
                        errorText: _currentError,
                        trailing: _showCurrent ? 'Hide' : 'Show',
                        onTrailingTap: () =>
                            setState(() => _showCurrent = !_showCurrent),
                        onChanged: (_) => setState(() => _currentError = null),
                      ),
                      const SizedBox(height: CiSpace.s5),
                      CiField(
                        label: 'New password',
                        controller: _next,
                        obscure: !_showNext,
                        errorText: _nextError,
                        trailing: _showNext ? 'Hide' : 'Show',
                        onTrailingTap: () =>
                            setState(() => _showNext = !_showNext),
                        onChanged: (_) => setState(() => _nextError = null),
                      ),
                      const SizedBox(height: CiSpace.s5),
                      CiField(
                        label: 'Confirm new password',
                        controller: _confirm,
                        // Follows the new-password toggle rather than having
                        // its own: revealing one and hiding the other makes
                        // comparing them impossible, which is the entire job
                        // of this field.
                        obscure: !_showNext,
                        errorText: _confirmError,
                        onChanged: (_) => setState(() => _confirmError = null),
                      ),
                      const SizedBox(height: CiSpace.s4),
                      Text('Use at least 8 characters.',
                          style: CiType.rowLabel.copyWith(color: c.textFaint)),
                      const SizedBox(height: CiSpace.s8),
                      CiButton(
                        label: 'Update password',
                        style: CiButtonStyle.lime,
                        expand: true,
                        busy: _saving,
                        onPressed: _filled && !_saving ? _save : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
