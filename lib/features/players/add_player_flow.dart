// Add-player flow — Phase 4.11d
//
// ONE PATH INTO ADDING A PLAYER, shared by every entry point: the Players
// list, the create sheet behind the nav bar's plus, and the dashed slot in
// the profile's player switcher.
//
// Extracted the moment there was a second caller. Three screens each deciding
// for themselves who may add a player is how two of them end up disagreeing -
// the same failure the trend classifier had, and it would be worse here
// because one of the answers is a paywall.

import 'package:flutter/material.dart';

import '/courtside_iq/player_gating.dart';
import '/features/premium/premium_gate_sheet.dart';
import '/features/home/entitlement_status.dart';
import '/features/players/add_player_sheet_v2.dart';
import '/features/players/widgets/player_gates.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Runs the gate and then whichever screen it decides on.
///
/// [openPaywall] is passed in rather than called directly because each screen
/// has to RE-READ its own entitlement afterwards: a parent who subscribes must
/// not come back to a screen still gating them.
Future<void> runAddPlayerFlow(
  BuildContext context, {
  required EntitlementStatus entitlement,
  required int playerCount,
  required Future<void> Function() openPaywall,
  VoidCallback? onPlayerAdded,
}) async {
  final action = addPlayerAction(
    // A LAPSED subscriber is not premium here. Their premium ended, so they
    // get the upgrade path rather than the cap - see addPlayerAction.
    isPremium: entitlement == EntitlementStatus.premium,
    playerCount: playerCount,
  );

  switch (action) {
    case AddPlayerAction.allowed:
      // Tracked here rather than trusted from the sheet's return: both sheets
      // pop the same way whether they saved or the parent backed out, and
      // only onPlayerAdded distinguishes them.
      var added = false;
      void onAdded() {
        added = true;
        onPlayerAdded?.call();
      }

      await showAddPlayerSheetV2(context, onPlayerAdded: onAdded);

      // LAND ON THE PLAYERS LIST. Wherever the parent started - Today, the
      // nav bar, the profile switcher - the new player is what they just
      // made, so the app should show it rather than leave them on a screen
      // where a count quietly went up.
      //
      // goNamed, not push: this is a tab, and pushing would stack a second
      // Players list under a back arrow that leads to the screen they left.
      if (added && context.mounted) {
        context.goNamed(PlayersListWidget.routeName);
      }
    case AddPlayerAction.upgradeGate:
      // The gate sheet (335:1881). "See plans" hands to the injected
      // openPaywall, which is what re-reads entitlement when it closes.
      final wantsPlans = await showPremiumGateSheet(context) ?? false;
      if (wantsPlans && context.mounted) {
        await openPaywall();
      }
    case AddPlayerAction.capReached:
      // Offers management, not a purchase: selling to someone who already
      // pays would be insulting.
      await showPlayerCapReached(context);
  }
}
