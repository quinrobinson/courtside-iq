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

// ---------------------------------------------------------------------------
// Game gating — roadmap 3.8
//
// Free is 1 player AND 3 games. Same shape as the player gate above: pure Dart,
// UI decisions only. The server enforces the limit in the games INSERT policy
// (20261004000000), which also lets an upsert of an EXISTING game through, so a
// retry of the third game is never refused.
//
// A "game" is every saved game on the account, across all players. The wall
// sits BEFORE a game starts, never at save: a parent must not track a whole
// game and then lose it.

/// Free tier game allowance. Mirrors `free_game_limit()`. Premium is unlimited.
const int kFreeGameLimit = 3;

enum StartGameAction {
  /// Go to New Game setup.
  allowed,

  /// Free or lapsed, and already at (or over) the free allowance. Offer premium.
  upgradeGate,
}

/// Whether the parent may start another game, and what to show if not.
///
/// [isPremium] is the ACTIVE entitlement, exactly as for players: a lapsed
/// subscriber is free here. Accounts already over the allowance keep every game
/// (the policy is INSERT-only); they are gated on their next new one.
StartGameAction startGameAction({
  required bool isPremium,
  required int gameCount,
}) {
  if (isPremium) return StartGameAction.allowed;
  return gameCount >= kFreeGameLimit
      ? StartGameAction.upgradeGate
      : StartGameAction.allowed;
}

/// Convenience for call sites that only need yes or no.
bool canStartGame({required bool isPremium, required int gameCount}) =>
    startGameAction(isPremium: isPremium, gameCount: gameCount) ==
    StartGameAction.allowed;

/// Free games remaining, or null for premium (no allowance to count).
int? freeGamesLeft({required bool isPremium, required int gameCount}) {
  if (isPremium) return null;
  final left = kFreeGameLimit - gameCount;
  return left < 0 ? 0 : left;
}

/// The quiet hint above Start Game on New Game setup, or null when it should
/// not show. Approved frames (Figma 1182:5522 / 1182:5585): hidden for premium,
/// hidden before the first game (the first one should feel free, not counted),
/// and never shown at the allowance (the gate has already taken over).
String? freeGamesUsedHint({required bool isPremium, required int gameCount}) {
  if (isPremium) return null;
  if (gameCount <= 0 || gameCount >= kFreeGameLimit) return null;
  return '$gameCount of $kFreeGameLimit free games used';
}

/// The Create sheet's "New game" subtitle override, or null to keep the normal
/// subtitle. Approved frame (Figma 1184:5451): shown ONLY when one free game is
/// left, because that is the moment the count is worth knowing.
String? newGameRowFreeHint({required bool isPremium, required int gameCount}) {
  return freeGamesLeft(isPremium: isPremium, gameCount: gameCount) == 1
      ? '1 free game left'
      : null;
}
