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
import '/features/home/entitlement_status.dart';
import '/features/flags.dart';
import '/features/players/add_player_sheet.dart';
import '/features/players/add_player_sheet_v2.dart';
import '/features/players/widgets/player_gates.dart';

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
      await (kUseAddPlayer2
          ? showAddPlayerSheetV2(context, onPlayerAdded: onPlayerAdded)
          : showAddPlayerSheet(context, onPlayerAdded: onPlayerAdded));
    case AddPlayerAction.upgradeGate:
      if (await showAddPlayerUpgradeGate(context) && context.mounted) {
        await openPaywall();
      }
    case AddPlayerAction.capReached:
      // Offers management, not a purchase: selling to someone who already
      // pays would be insulting.
      await showPlayerCapReached(context);
  }
}
