// Start-game flow — roadmap 3.8
//
// ONE PATH INTO STARTING A GAME, shared by every entry point: the create sheet
// behind the nav bar's plus, the Games tab's add button and empty state, and
// the player profile's "Track a game". Same reason add_player_flow.dart exists:
// four screens each deciding who may start a game is how two of them end up
// disagreeing, and one of the answers is a paywall.
//
// THE WALL SITS HERE, BEFORE SETUP, never at save. A parent must never track a
// whole game and then be told it cannot be kept.

import 'package:flutter/material.dart';

import '/courtside_iq/player_gating.dart';
import '/features/players/widgets/player_gates.dart';
import '/features/premium/paywall_launcher.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'game_allowance.dart';

/// Runs the game gate, then New Game setup or the free-games sheet.
///
/// [allowance] lets a caller that already read it (the create flow, which
/// needs it for the "1 free game left" subtitle) skip a second round trip.
Future<void> runStartGameFlow(
  BuildContext context, {
  GameAllowance? allowance,
}) async {
  final a = allowance ?? await loadGameAllowance();
  if (!context.mounted) return;

  final action =
      startGameAction(isPremium: a.isPremium, gameCount: a.gameCount);
  switch (action) {
    case StartGameAction.allowed:
      context.pushNamed(NewGameWidget.routeName);
    case StartGameAction.upgradeGate:
      final wantsPlans =
          await showGameLimitGate(context, playerFirstName: a.playerFirstName);
      if (!wantsPlans || !context.mounted) return;
      await showPaywall(context);
      if (!context.mounted) return;
      // RE-READ after the paywall: a parent who just subscribed came here to
      // track a game, so take them straight to setup rather than back to the
      // screen they started from. The client trusts RevenueCat here; the
      // server's subscriptions row may land a moment later (see step 5).
      final after = await loadGameAllowance();
      if (!context.mounted) return;
      if (canStartGame(
          isPremium: after.isPremium, gameCount: after.gameCount)) {
        context.pushNamed(NewGameWidget.routeName);
      }
  }
}
