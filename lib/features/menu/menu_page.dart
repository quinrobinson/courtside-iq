// Menu — Phase 4.15a
//
// Measured from 294:1331:
//
//   header   ink 116: "Menu" ExtraBold 24 at 24/62
//   profile  avatar 52, name Bold 20, email Regular 14 muted, chevron
//   ACCOUNT  Subscription -> its plan
//   SUPPORT  Help Center, Send Feedback
//   ABOUT    Terms of Service, Privacy Policy
//   footer   version centred muted 13, then Log out centred SemiBold 17
//
// LOG OUT IS NOT DESTRUCTIVE-COLOURED. The frame draws it in ink, and that is
// right: signing out loses nothing, since everything lives on the server and
// comes back at the next sign-in. Painting it orange would rank it with
// Delete account, which cannot be undone.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_confirm_dialog.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_settings_row.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/features/home/entitlement_status.dart';

/// Shown in the footer.
///
/// A CONST, NOT READ FROM THE BUNDLE. The app has no package_info dependency,
/// so this has to be kept in step with pubspec by hand - which is exactly the
/// two-sources-of-truth shape that has bitten this project twice. Flagged for
/// a decision; injectable so swapping the source touches one default.
const String kCiVersionLabel = 'Courtside IQ · v2.0';

/// Where the two legal links go, as v1 sends them.
///
/// TERMS POINTS AT APPLE'S STANDARD EULA, which is what v1 does and is wrong
/// on Android - a Play Store user is shown Apple's licence terms. Carried
/// over unchanged here rather than fixed silently, because which terms apply
/// is not a decision to make in a UI commit.
const String kTermsUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const String kPrivacyUrl = 'https://www.courtsideiq.app/policy';

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.entitlementReader = fetchEntitlementStatus,
    this.versionLabel = kCiVersionLabel,
    this.onSignOut,
    this.onOpenProfile,
    this.onOpenHelp,
    this.onOpenFeedback,
    this.onOpenSubscription,
  });

  final Future<EntitlementStatus> Function() entitlementReader;
  final String versionLabel;

  final Future<void> Function()? onSignOut;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onOpenFeedback;
  final VoidCallback? onOpenSubscription;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  EntitlementStatus? _entitlement;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final status = await widget.entitlementReader();
    if (mounted) setState(() => _entitlement = status);
  }

  /// The plan, or nothing until it is known.
  ///
  /// Blank rather than "Free" while loading: showing Free to a subscriber for
  /// half a second is the kind of thing that gets a support email.
  String? get _planLabel => switch (_entitlement) {
        null => null,
        EntitlementStatus.premium => 'Premium',
        EntitlementStatus.lapsed => 'Expired',
        EntitlementStatus.never => 'Free',
      };

  Future<void> _signOut() async {
    final confirmed = await showCiConfirmDialog(
      context,
      title: 'Log out?',
      message: "You'll need to sign back in to see your players.",
      confirmLabel: 'Log out',
      // Not destructive: everything is on the server and comes back at the
      // next sign-in. Matches 371:1901, the neutral confirm.
      destructive: false,
    );
    if (!confirmed) return;
    await widget.onSignOut?.call();
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _Header(),
              _ProfileRow(onTap: widget.onOpenProfile),
              const CiHairline(),
              const CiSettingsGroupLabel(label: 'Account'),
              CiSettingsRow(
                label: 'Subscription',
                value: _planLabel,
                onTap: widget.onOpenSubscription,
              ),
              const CiHairline(),
              const CiSettingsGroupLabel(label: 'Support'),
              CiSettingsRow(
                label: 'Help Center',
                onTap: widget.onOpenHelp,
              ),
              const CiHairline(),
              CiSettingsRow(
                label: 'Send Feedback',
                onTap: widget.onOpenFeedback,
              ),
              const CiHairline(),
              const CiSettingsGroupLabel(label: 'About'),
              CiSettingsRow(
                label: 'Terms of Service',
                onTap: () => _open(kTermsUrl),
              ),
              const CiHairline(),
              CiSettingsRow(
                label: 'Privacy Policy',
                onTap: () => _open(kPrivacyUrl),
              ),
              const CiHairline(),
              const SizedBox(height: 22),
              Text(widget.versionLabel,
                  textAlign: TextAlign.center,
                  style: CiType.rowLabel.copyWith(color: c.textFaint)),
              const SizedBox(height: 10),
              Semantics(
                button: true,
                label: 'Log out',
                container: true,
                excludeSemantics: true,
                child: InkWell(
                  onTap: _signOut,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: CiSpace.s3),
                    child: Text('Log out',
                        textAlign: TextAlign.center,
                        style: CiType.rowTitle.copyWith(
                            color: c.text, fontWeight: CiWeight.semiBold)),
                  ),
                ),
              ),
              const SizedBox(height: CiSpace.s8),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s6),
            child: SizedBox(
              // Shared with the Players and Games headers, which sat 9pt
              // apart until this landed.
              height: kCiListHeaderContentHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Menu',
                    style: CiType.h2.copyWith(
                        color: c.text, fontWeight: CiWeight.extraBold)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// The account itself: avatar, name and email, opening Your Profile.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final email = currentUserEmail;
    final name = currentUserDisplayName.trim();

    return Semantics(
      button: onTap != null,
      label: 'Your profile',
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s5),
          child: Row(
            children: [
              CiAvatar(
                // Falls back to the email so the initials are never blank -
                // an account can exist with no display name, and a bare grey
                // circle reads as a failed image load.
                name: name.isEmpty ? email : name,
                imageUrl: currentUserPhoto.isEmpty ? null : currentUserPhoto,
                size: 52,
              ),
              const SizedBox(width: CiSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.isEmpty ? 'Your account' : name,
                      style: CiType.h4.copyWith(
                          color: c.text, fontWeight: CiWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(email,
                          style: CiType.bodySm.copyWith(color: c.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: CiSpace.s2),
              Icon(Icons.chevron_right, size: 18, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
