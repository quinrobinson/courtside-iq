// Your Profile — Phase 4.15a
//
// Measured from 295:1385:
//
//   header  back at 12, "Your Profile" SemiBold 17 centred, rule at 104
//   hero    avatar 88 centred with a 30pt camera badge, name ExtraBold 26,
//           email Regular 16 muted, then a rule
//   rows    Name / Email / Password, each with its value and a chevron
//   footer  "Delete account" centred in the energy accent
//
// DELETE ACCOUNT SITS ALONE AT THE BOTTOM, far below the rows, and is the one
// thing on this screen wearing the accent. That distance is the design doing
// safety work: it cannot be hit while reaching for Password.

import 'package:flutter/material.dart';

import 'account_repository.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_settings_row.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

class YourProfilePage extends StatefulWidget {
  const YourProfilePage({
    super.key,
    this.repository = const AccountRepository(),
    this.onEditName,
    this.onEditEmail,
    this.onChangePassword,
    this.onEditPhoto,
    this.onDeleteAccount,
  });

  final Future<void> Function()? onEditName;
  final Future<void> Function()? onEditEmail;
  final Future<void> Function()? onChangePassword;

  /// Null: there is nowhere to PUT a user photo. `public.users` has no photo
  /// column - players have `player_profile_pic`, accounts have nothing - so
  /// the badge the frame draws renders inert rather than opening a picker
  /// whose result would be dropped. Needs a schema change to become real.
  final VoidCallback? onEditPhoto;

  /// Null until 4.15d builds the screen behind it. The row is still drawn -
  /// the frame has it, and hiding it would make this screen look finished
  /// when it is not.
  final VoidCallback? onDeleteAccount;

  /// The name comes from public.users, not auth - see AccountRepository.
  final AccountRepository repository;

  @override
  State<YourProfilePage> createState() => _YourProfilePageState();
}

class _YourProfilePageState extends State<YourProfilePage> {
  AccountProfile _profile = const AccountProfile();

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reloaded when an edit screen pops, so a changed name is on screen before
  /// the parent can wonder whether it took.
  Future<void> _load() async {
    final profile = await widget.repository.load();
    if (mounted) setState(() => _profile = profile);
  }

  /// Opens an edit screen and reloads when it closes, so a changed name is
  /// on screen before the parent can wonder whether it took.
  Future<void> _open(Future<void> Function()? go) async {
    if (go == null) return;
    await go();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        final email = _profile.email;
        final name = _profile.fullName;

        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const CiSubPageHeader(title: 'Your Profile'),
                const SizedBox(height: CiSpace.s6),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CiAvatar(
                        // Initials only. See onEditPhoto.
                        name: name.isEmpty ? email : name,
                        size: 88,
                      ),
                      Semantics(
                        button: true,
                        label: 'Change photo',
                        container: true,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: widget.onEditPhoto,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c.surfaceDeep,
                              shape: BoxShape.circle,
                              // A ring in the page colour, so the badge reads
                              // as sitting ON the avatar rather than being
                              // part of it.
                              border: Border.all(color: c.bg, width: 2),
                            ),
                            child: Icon(Icons.photo_camera_outlined,
                                size: 15,
                                color: widget.onEditPhoto == null
                                    ? c.textMuted
                                    : c.textInvert),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: CiSpace.s5),
                Text(
                  name.isEmpty ? 'Your account' : name,
                  textAlign: TextAlign.center,
                  style: CiType.h2
                      .copyWith(color: c.text, fontWeight: CiWeight.extraBold),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: CiSpace.s1),
                  Text(email,
                      textAlign: TextAlign.center,
                      style: CiType.body.copyWith(color: c.textMuted)),
                ],
                const SizedBox(height: CiSpace.s7),
                const CiHairline(),
                CiSettingsRow(
                  label: 'Name',
                  value: name.isEmpty ? 'Add your name' : name,
                  onTap: () => _open(widget.onEditName),
                ),
                const CiHairline(),
                CiSettingsRow(
                  label: 'Email',
                  value: email,
                  onTap: () => _open(widget.onEditEmail),
                ),
                const CiHairline(),
                CiSettingsRow(
                  // No value to show and nothing safe to show, so the frame
                  // uses the action as the value.
                  label: 'Password',
                  value: 'Change',
                  onTap: () => _open(widget.onChangePassword),
                ),
                const CiHairline(),
                const SizedBox(height: 96),
                Semantics(
                  button: true,
                  label: 'Delete account',
                  container: true,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: widget.onDeleteAccount,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: CiSpace.s3),
                      child: Text(
                        'Delete account',
                        textAlign: TextAlign.center,
                        style: CiType.rowTitle.copyWith(
                            color: widget.onDeleteAccount == null
                                // Muted while 4.15d is unbuilt: an accent on
                                // a dead control invites a tap that does
                                // nothing.
                                ? c.textFaint
                                : c.accentEnergy,
                            fontWeight: CiWeight.semiBold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: CiSpace.s8),
              ],
            ),
          ),
        );
      }),
    );
  }
}
