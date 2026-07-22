// Delete Account — Phase 4.15d
//
// Measured from 505:1961: header "Delete account", a SemiBold 18 statement of
// permanence, a Regular 15 paragraph of what goes, then an orange "Delete my
// account" and a muted Cancel.
//
// THE FRAME'S COPY IS CHANGED IN ONE PLACE, approved 2026-07-23. It said
// "Your subscription will also stop renewing." That is not true and it is the
// expensive kind of untrue: an app store subscription is owned by Apple or
// Google, and deleting rows in our database does nothing to it. A parent
// would delete their account believing billing had stopped and be charged
// again a month later for an app they cannot sign into. The copy now names
// the actual step.
//
// A SECOND CONFIRMATION, which the frame does not have. Approved for the same
// reason the copy changed: this destroys a season of a child's history and
// one orange button is one mis-tap. The dialog restates what goes rather than
// asking "are you sure" about nothing.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_confirm_dialog.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'account_repository.dart';
import 'ci_account_snackbar.dart';

class DeleteAccountPage extends StatefulWidget {
  /// Its own route. Delete Account has no v1 screen to inherit one from, and
  /// a bare MaterialPageRoute is discarded under this app's GoRouter setup -
  /// the fault that made Change Password do nothing.
  static const String routeName = 'DeleteAccount';
  static const String routePath = '/deleteAccount';

  const DeleteAccountPage({
    super.key,
    this.repository = const AccountRepository(),
    this.onDeleted,
  });

  final AccountRepository repository;

  /// Called once the account is gone, to sign out and return to the entry
  /// screen. There is no session left to route with afterwards.
  final Future<void> Function()? onDeleted;

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _deleting = false;

  Future<void> _delete() async {
    final confirmed = await showCiConfirmDialog(
      context,
      title: 'Delete your account?',
      // Restates the loss rather than asking "are you sure" about nothing.
      // The screen behind this one already explained; a second step that
      // said less than the first would just be a speed bump.
      message: 'Every player, every game you have logged and every insight '
          'will be gone. This cannot be undone.',
      confirmLabel: 'Delete forever',
      cancelLabel: 'Keep my account',
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    final ok = await widget.repository.deleteAccount();
    if (!mounted) return;

    if (!ok) {
      setState(() => _deleting = false);
      // NOT "check your connection". The failure is as likely to be the
      // server as the network - the first attempt on test was a 500, not a
      // dropped request - and blaming their signal sends them to fix the one
      // thing that was fine.
      showAccountResult(context,
          message: "That didn't work. Please try again in a moment.",
          success: false);
      return;
    }

    await widget.onDeleted?.call();
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
                const CiSubPageHeader(title: 'Delete account'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen, CiSpace.s7, CiSpace.screen, CiSpace.s6),
                    children: [
                      Text(
                        'Deleting your account is permanent.',
                        style: CiType.h4.copyWith(
                            color: c.text, fontWeight: CiWeight.semiBold),
                      ),
                      const SizedBox(height: CiSpace.s3),
                      Text(
                        'This removes your profile, all your players, their '
                        "full game history, and every insight we've created. "
                        "We won't be able to bring any of it back.",
                        style:
                            CiType.body.copyWith(color: c.textSoft, height: 1.5),
                      ),
                      const SizedBox(height: CiSpace.s5),
                      // SEPARATE PARAGRAPH, not folded into the one above.
                      // It is the only sentence here describing something the
                      // parent still has to go and do, and burying it in a
                      // list of what we delete is how it gets skipped.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(CiSpace.s4),
                        decoration: BoxDecoration(
                          color: c.surfaceSunk,
                          borderRadius: CiRadius.controlR,
                        ),
                        child: Text(
                          'Your subscription is billed by the app store and '
                          'will not stop on its own. Cancel it in your app '
                          'store subscriptions, or you may be charged again.',
                          style: CiType.bodySm
                              .copyWith(color: c.text, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      CiSpace.screen, 0, CiSpace.screen, CiSpace.s5),
                  child: Column(
                    children: [
                      CiButton(
                        label: 'Delete my account',
                        style: CiButtonStyle.orange,
                        expand: true,
                        busy: _deleting,
                        onPressed: _deleting ? null : _delete,
                      ),
                      const SizedBox(height: CiSpace.s3),
                      Semantics(
                        button: true,
                        label: 'Cancel',
                        container: true,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: _deleting
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: CiSpace.s3),
                            child: Text('Cancel',
                                textAlign: TextAlign.center,
                                style: CiType.body
                                    .copyWith(color: c.textMuted)),
                          ),
                        ),
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
