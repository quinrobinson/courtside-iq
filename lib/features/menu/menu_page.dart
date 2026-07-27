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
import 'package:package_info_plus/package_info_plus.dart';
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
import 'account_repository.dart';

/// "Courtside IQ · v2.0.0 (Build 250)", READ FROM THE BUNDLE.
///
/// Not a const kept in step with pubspec by hand. A version string is the one
/// piece of text a support conversation depends on being exactly right, and a
/// hand-maintained copy is the two-sources-of-truth shape this project has
/// been bitten by twice already.
Future<String> readVersionLabel() async {
  final info = await PackageInfo.fromPlatform();
  return 'Courtside IQ · v${info.version} (Build ${info.buildNumber})';
}

/// COURTSIDE IQ'S OWN TERMS, ON BOTH PLATFORMS.
///
/// v1 pointed iOS at Apple's standard EULA. Apple permits either theirs or
/// your own, and Google has no equivalent - so Apple's left a Play Store user
/// reading terms that did not govern their copy of the app.
///
/// One document we control covers both stores and can say things Apple's
/// boilerplate does not. Verified live 2026-07-23: the page is a real Terms &
/// Conditions document. Worth checking because the site is a Framer build
/// serving one <title> for every route, so a 200 proved nothing on its own -
/// /eula and /terms-of-service 404, which is what showed the routing
/// distinguishes real pages.
///
/// APPLE REQUIRES A CUSTOM EULA TO INCLUDE THEIR MINIMUM TERMS. That is a
/// condition on the page's CONTENT, not on this link, and it is worth
/// confirming before a 2.0 submission.
const String kTermsUrl = 'https://www.courtsideiq.app/terms';

const String kPrivacyUrl = 'https://www.courtsideiq.app/policy';

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.entitlementReader = fetchEntitlementStatus,
    this.versionReader = readVersionLabel,
    this.repository = const AccountRepository(),
    this.onSignOut,
    this.onOpenProfile,
    this.onOpenHelp,
    this.onOpenFeedback,
    this.onOpenSubscription,
  });

  final Future<EntitlementStatus> Function() entitlementReader;
  final Future<String> Function() versionReader;

  /// THE NAME IS NOT IN AUTH. currentUserDisplayName is permanently empty in
  /// this app, so reading it here showed "Your account" to everyone.
  final AccountRepository repository;

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
  String _version = '';
  AccountProfile _profile = const AccountProfile();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await widget.repository.load();
    if (mounted) setState(() => _profile = profile);

    final status = await widget.entitlementReader();
    if (mounted) setState(() => _entitlement = status);
    try {
      final version = await widget.versionReader();
      if (mounted) setState(() => _version = version);
    } catch (_) {
      // A missing version line is a cosmetic loss. Failing the whole screen
      // over it would not be.
    }
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
              _ProfileRow(profile: _profile, onTap: widget.onOpenProfile),
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
              if (_version.isNotEmpty) ...[
                Text(_version,
                    textAlign: TextAlign.center,
                    style: CiType.rowLabel.copyWith(color: c.textFaint)),
                const SizedBox(height: 10),
              ],
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
          // Menu is a TAB, and it was the only one of the four with no nav
          // bar. Reaching it left a parent with no way to any other tab, so
          // it read as the bar "disappearing" - it was never there. The other
          // three set this; Menu was missed.
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
  const _ProfileRow({required this.profile, this.onTap});

  final AccountProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final email = profile.email;
    final name = profile.fullName;

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
