// Create — New Sheet — Phase 4.11d
//
// Measured from 281:1303: a 272-tall sheet titled "Create" with two action
// rows, no CTA. Replaces the v1 CreateNewWidget behind the nav bar's plus.
//
// WHICH ROWS APPEAR IS A PRODUCT RULE, and the two cases are handled
// differently on purpose:
//
//   no players yet     "New game" is HIDDEN. A game is logged FOR a player,
//                      so with none there is nothing the row could do. It
//                      also leaves a first-time parent one obvious action.
//
//   at the player cap  "New player" stays VISIBLE AND TAPPABLE. It routes
//                      through addPlayerAction, the same decision the Players
//                      list uses, which answers with the upgrade sheet or the
//                      cap dialog. Disabling it would leave a parent unable to
//                      find out WHY, and hiding it would look like the app
//                      lost a feature.
//
// The distinction: an IMPOSSIBLE action is hidden, a BLOCKED one explains
// itself.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_nav_icon.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';

/// Opens the create sheet. Returns the chosen action, or null if dismissed.
Future<CreateChoice?> presentCreateSheet(
  BuildContext context, {
  required bool hasPlayers,
}) {
  return showCiSheet<CreateChoice>(
    context,
    child: CreateSheet(hasPlayers: hasPlayers),
  );
}

enum CreateChoice { newGame, newPlayer }

class CreateSheet extends StatelessWidget {
  const CreateSheet({super.key, required this.hasPlayers});

  /// Drives whether "New game" is offered at all.
  final bool hasPlayers;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return CiSheet(
      title: 'Create',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPlayers)
            CiSheetActionRow(
              // The bottom-nav Games glyph, not a Material basketball, so a
              // parent sees the same icon for "game" here and in the nav.
              leading: CiNavIconGlyph(
                icon: CiNavIcon.games,
                color: c.text,
                size: 24,
              ),
              title: 'New game',
              subtitle: 'Track a game for a player',
              showDivider: true,
              onTap: () => Navigator.of(context).pop(CreateChoice.newGame),
            ),
          CiSheetActionRow(
            leading: CiNavIconGlyph(
              icon: CiNavIcon.players,
              color: c.text,
              size: 24,
            ),
            title: 'New player',
            // States the cap up front, so the limit is not a surprise
            // discovered by hitting it.
            subtitle: 'Add a player to track (up to 3)',
            onTap: () => Navigator.of(context).pop(CreateChoice.newPlayer),
          ),
        ],
      ),
    );
  }
}
