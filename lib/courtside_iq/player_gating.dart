// Player gating — Phase 4.11a.2
//
// What happens when a parent taps "add player". Pure Dart: an entitlement
// status and a player count in, a decision out, so every branch is testable
// without a purchase or a network.
//
// THIS IS UI GATING, NOT ENFORCEMENT. The server enforces the free limit in an
// INSERT-only RLS policy (20260719000001). This decides which screen to show;
// it is not what stops an over-limit insert.
//
// THE TWO LIMITS COME FROM DIFFERENT PLACES, deliberately:
//
//   free    1 player, matching `free_player_limit()` server-side.
//   premium 3 players, a CLIENT-ONLY product rule. The server treats premium
//           as unlimited ("Premium is unlimited via is_premium()"), so this
//           cap exists only in the app and in the designs. Worth knowing
//           before anyone assumes the database will refuse a fourth.

/// Free tier allowance. Mirrors `free_player_limit()`.
const int kFreePlayerLimit = 1;

/// Premium allowance. Client-side product rule; the server does not enforce it.
const int kPremiumPlayerLimit = 3;

enum AddPlayerAction {
  /// Open the add-player sheet.
  allowed,

  /// Free or lapsed, and already at the free allowance. Offer premium.
  upgradeGate,

  /// Premium and at the cap. Removing a player is the only way forward, so
  /// this offers management rather than a purchase - selling to someone who
  /// already pays would be insulting.
  capReached,
}

/// Whether the parent may add another player, and what to show if not.
///
/// [isPremium] is the ACTIVE entitlement. A lapsed subscriber is treated as
/// free here: their premium has ended, so they get the upgrade path rather
/// than the cap. They keep the players they already have - the server policy
/// is INSERT-only and never removes anything.
AddPlayerAction addPlayerAction({
  required bool isPremium,
  required int playerCount,
}) {
  if (isPremium) {
    return playerCount >= kPremiumPlayerLimit
        ? AddPlayerAction.capReached
        : AddPlayerAction.allowed;
  }
  return playerCount >= kFreePlayerLimit
      ? AddPlayerAction.upgradeGate
      : AddPlayerAction.allowed;
}
