// Edit Email — Phase 4.15b
//
// Measured from 496:1986, which is Edit Name with a different label.
//
// NOTHING CHANGES WHEN YOU TAP SAVE. Supabase mails a confirmation link to
// the NEW address and the account keeps signing in with the OLD one until it
// is clicked. So the frame's silence about that is the problem, not the
// layout: a screen that pops with "Email updated" would be repeating the
// "Save to unlock" mistake - stating an outcome the system has not produced.
//
// The helper text under the field says so BEFORE the tap, and the
// confirmation after it says a link was sent, not that anything moved. A
// parent who never opens that email is still signing in with the address they
// always used, which is the safe failure.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/auth_validation.dart';
import 'account_repository.dart';
import 'ci_account_snackbar.dart';

class EditEmailPage extends StatefulWidget {
  const EditEmailPage({super.key, this.repository = const AccountRepository()});

  final AccountRepository repository;

  @override
  State<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  final _controller = TextEditingController();
  String _original = '';
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await widget.repository.load();
    if (!mounted) return;
    setState(() {
      _original = profile.email;
      _controller.text = _original;
      _loaded = true;
    });
  }

  bool get _dirty =>
      _controller.text.trim().toLowerCase() != _original.trim().toLowerCase();

  Future<void> _save() async {
    final email = _controller.text.trim();
    final problem = validateEmail(email);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final outcome = await widget.repository.requestEmailChange(email);
    if (!mounted) return;

    if (outcome == EmailChangeOutcome.failed) {
      setState(() {
        _saving = false;
        _error = 'That address could not be used. It may already have an '
            'account.';
      });
      return;
    }

    Navigator.of(context).maybePop();
    // NOT "Email updated". It is not, and will not be until the link in that
    // message is opened.
    showAccountResult(context,
        message: 'Check $email for a link to confirm the change.');
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
                const CiSubPageHeader(title: 'Edit email'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen, CiSpace.s6, CiSpace.screen, CiSpace.s6),
                    children: [
                      CiField(
                        label: 'Email',
                        controller: _controller,
                        enabled: _loaded,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _error,
                        // Said BEFORE the tap, not only after it. A parent
                        // deciding whether to change the address they sign in
                        // with should know a confirmation is involved first.
                        helperText:
                            "We'll email the new address to confirm it. You'll "
                            'keep signing in with your current one until then.',
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      const SizedBox(height: 48),
                      CiButton(
                        label: 'Save changes',
                        style: CiButtonStyle.lime,
                        expand: true,
                        busy: _saving,
                        onPressed: _dirty && !_saving ? _save : null,
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
