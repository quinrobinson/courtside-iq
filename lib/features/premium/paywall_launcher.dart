// Opening the paywall — Phase 4.16
//
// One entry point so the three callers - the add-player gate, the Menu
// Subscription row, and the Today banner - all reach the same screen the same
// way, behind one flag. When kUsePaywall2 is off they fall back to the v1
// PaywallWidget together.
//
// THE GATE SHEET COMES FIRST FROM THE ADD-PLAYER PATH ONLY. Hitting the player
// cap is a surprise, so it gets the soft "A Premium feature" doorway before
// any pricing. The Menu row and the banner are deliberate taps on "premium" -
// they go straight to the plans.

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/features/flags.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import 'paywall_page.dart';
import 'premium_gate_sheet.dart';

/// Opens the paywall. Returns true if the parent left premium (bought or was
/// already premium), so a caller can refresh entitlement.
Future<bool> showPaywall(BuildContext context) async {
  if (!kUsePaywall2) {
    await showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: const PaywallWidget(),
      ),
    );
    return false;
  }

  // pushNamed, NOT Navigator.push. A raw route under this app's GoRouter is
  // discarded on the next rebuild - the Change Password bug. The paywall's
  // FFRoute wires its own close/purchase/terms/privacy.
  final purchased = await context.pushNamed<bool?>(PaywallPage.routeName);
  return purchased ?? false;
}

/// The add-player gate: the sheet, then the paywall only if they want plans.
Future<bool> showPremiumGate(BuildContext context) async {
  final wantsPlans = await showPremiumGateSheet(context);
  if (wantsPlans != true || !context.mounted) return false;
  return showPaywall(context);
}
