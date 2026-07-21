// Create flow — Phase 4.11d
//
// What the nav bar's plus does. Lives here rather than inside CiNavBar
// because it needs to KNOW THINGS - how many players exist, and whether the
// parent is premium - and the bar is shared chrome that should stay dumb.
//
// The reads happen on tap rather than being held: the sheet's contents and
// the gate both turn on state that can change while the app is open, and a
// stale count would either hide "New game" from someone who just added their
// first player or wave a fourth player past the cap.

import 'package:flutter/material.dart';

import '/features/home/entitlement_status.dart';
import '/features/players/add_player_flow.dart';
import '/features/players/players_repository.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import 'create_sheet.dart';

/// [onPlayerAdded] is how the SCREEN BEHIND THE SHEET learns to refetch.
///
/// Without it a player added from the nav bar saved correctly and then
/// appeared nowhere until the parent pulled to refresh - which reads as the
/// save having failed. The sheet cannot refresh the screen it was opened
/// over; only the screen can.
Future<void> handleCreateTap(
  BuildContext context, {
  PlayersRepository repository = const PlayersRepository(),
  VoidCallback? onPlayerAdded,
}) async {
  final players = await repository.load();
  if (!context.mounted) return;

  final choice = await presentCreateSheet(
    context,
    hasPlayers: players.isNotEmpty,
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case CreateChoice.newGame:
      context.pushNamed(NewGameWidget.routeName);
    case CreateChoice.newPlayer:
      // Entitlement is read HERE, after the sheet closed, rather than up
      // front: it is only needed on this branch, and a parent who never taps
      // "New player" should not pay a RevenueCat round trip for opening a
      // sheet.
      final entitlement = await fetchEntitlementStatus();
      if (!context.mounted) return;
      await runAddPlayerFlow(
        context,
        entitlement: entitlement,
        playerCount: players.length,
        onPlayerAdded: onPlayerAdded,
        openPaywall: () => _openPaywall(context),
      );
  }
}

Future<void> _openPaywall(BuildContext context) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: const PaywallWidget(),
    ),
  );
}
