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

import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_settings_row.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

class YourProfilePage extends StatelessWidget {
  const YourProfilePage({
    super.key,
    this.onEditName,
    this.onEditEmail,
    this.onChangePassword,
    this.onEditPhoto,
    this.onDeleteAccount,
  });

  final VoidCallback? onEditName;
  final VoidCallback? onEditEmail;
  final VoidCallback? onChangePassword;
  final VoidCallback? onEditPhoto;

  /// Null until 4.15d builds the screen behind it. The row is still drawn -
  /// the frame has it, and hiding it would make this screen look finished
  /// when it is not.
  final VoidCallback? onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        final email = currentUserEmail;
        final name = currentUserDisplayName.trim();

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
                        name: name.isEmpty ? email : name,
                        imageUrl:
                            currentUserPhoto.isEmpty ? null : currentUserPhoto,
                        size: 88,
                      ),
                      Semantics(
                        button: true,
                        label: 'Change photo',
                        container: true,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: onEditPhoto,
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
                                size: 15, color: c.textInvert),
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
                  onTap: onEditName,
                ),
                const CiHairline(),
                CiSettingsRow(
                  label: 'Email',
                  value: email,
                  onTap: onEditEmail,
                ),
                const CiHairline(),
                CiSettingsRow(
                  // No value to show and nothing safe to show, so the frame
                  // uses the action as the value.
                  label: 'Password',
                  value: 'Change',
                  onTap: onChangePassword,
                ),
                const CiHairline(),
                const SizedBox(height: 96),
                Semantics(
                  button: true,
                  label: 'Delete account',
                  container: true,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onDeleteAccount,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: CiSpace.s3),
                      child: Text(
                        'Delete account',
                        textAlign: TextAlign.center,
                        style: CiType.rowTitle.copyWith(
                            color: onDeleteAccount == null
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
