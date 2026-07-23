// Reset Successful — Phase 4.9
//
// Measured from Screens / Reset Successful 608:2198. Ink ground, back button,
// dot burst with the logo mark, CENTRED "Password updated" h1 and subhead,
// lime "Back to sign in" pinned to the bottom.
//
// The only auth screen whose text is centred, which is why AuthScaffold takes
// a centreText flag rather than three screens each doing their own alignment.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'widgets/auth_scaffold.dart';

class ResetSuccessfulPage extends StatelessWidget {
  const ResetSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      centerText: true,
      header: const Center(
        child: DotBurst(size: 220, markSize: 50, child: CiLogoMark(size: 50)),
      ),
      title: 'Password updated',
      subtitle: "You're all set. Sign in with your new password.",
      actionLabel: 'Back to sign in',
      // goNamed, not push: the reset is finished. Back must not walk into the
      // middle of a completed recovery flow.
      onAction: () => context.goNamed(UserAuthEmailWidget.routeName),
      onBack: () => context.goNamed(UserAuthEmailWidget.routeName),
      children: const [],
    );
  }
}
