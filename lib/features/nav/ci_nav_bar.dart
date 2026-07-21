// Bottom navigation — Phase 4.10c
//
// Measured from the TabBar component in Today (68:264):
//
//   bar      390x70, white
//   slots    five, evenly spaced: Home, Players, Create, Games, Menu
//   create   44x44 ink circle, radius 999, white plus
//   icons    24x24 stroke, active #0F0F0F, inactive #A8A8A8
//
// SWITCHES TABS, IT DOES NOT STACK THEM. The v1 nav used pushNamed for every
// tab, so tapping Home from Players pushed ANOTHER Home on top and the stack
// grew for as long as the app stayed open - back then walked history in
// reverse instead of leaving. goNamed replaces, which is what a tab bar means.
// This is a deliberate behaviour fix, not a port.
//
// OWNS ITS OWN SAFE AREA. The v1 bar was a fixed 60pt container with none, so
// every screen had to paint the home-indicator strip itself. Today carried a
// workaround for exactly that; it comes out when this lands.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/features/nav/create_flow.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_util.dart';

enum CiNavTab {
  home,
  players,
  games,
  menu,

  /// Not a destination: the centre button opens a sheet. Present so a screen
  /// can say "none of the tabs are active".
  none,
}

class CiNavBar extends StatelessWidget {
  const CiNavBar({
    super.key,
    required this.active,
    this.onCreate,
    this.onPlayerAdded,
  });

  final CiNavTab active;

  /// Defaults to the 2.0 create sheet. Overridable so a screen can take the
  /// whole interaction over, and so tests can avoid the network.
  final VoidCallback? onCreate;

  /// Called after a player is successfully added from the create sheet.
  ///
  /// EVERY SCREEN THAT SHOWS PLAYERS MUST PASS THIS. The bar is shared
  /// chrome and cannot know how to refresh the screen it sits under, so
  /// without it the new player saves and then appears nowhere - which reads
  /// as a failed save.
  final VoidCallback? onPlayerAdded;

  static const double barHeight = 70;

  @override
  Widget build(BuildContext context) {
    // Declares its ground rather than only painting it, so the icons resolve
    // the light palette wherever the bar is placed - including under an ink
    // screen like Today.
    return CiSurface.light(
      child: Builder(builder: (context) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Tab(
                  // Rounded family throughout: the outlined icons read sharp,
                  // and the brand is round. Closer to the Figma marks too.
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                  selected: active == CiNavTab.home,
                  onTap: () => _go(context, HomeWidget.routeName),
                ),
                _Tab(
                  icon: Icons.groups_rounded,
                  label: 'Players',
                  selected: active == CiNavTab.players,
                  onTap: () => _go(context, PlayersListWidget.routeName),
                ),
                _CreateButton(
                  onTap: onCreate ??
                      () => handleCreateTap(context,
                          onPlayerAdded: onPlayerAdded),
                ),
                _Tab(
                  icon: Icons.scoreboard_rounded,
                  label: 'Games',
                  selected: active == CiNavTab.games,
                  onTap: () => _go(context, AllGamesWidget.routeName),
                ),
                _Tab(
                  icon: Icons.menu_rounded,
                  label: 'Menu',
                  selected: active == CiNavTab.menu,
                  onTap: () => _go(context, MenuWidget.routeName),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// goNamed, never pushNamed. See the header.
  static void _go(BuildContext context, String routeName) =>
      context.goNamed(routeName);

}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;

  /// Not rendered: the frame shows icons only. It names the target for a
  /// screen reader, which an icon alone cannot.
  final String label;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: SizedBox(
          // Comfortably past the 44pt minimum: this is tapped one-handed,
          // often while watching a game rather than the screen.
          width: 56,
          height: CiNavBar.barHeight,
          child: Icon(
            icon,
            size: 24,
            // Active is ink, inactive is muted. Shape stays identical, so the
            // difference is carried by weight of colour alone - acceptable
            // here because the bar is five fixed, learnable positions.
            color: selected ? c.text : c.textMuted,
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      label: 'Create',
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.surfaceInvert,
            borderRadius: CiRadius.pillR,
          ),
          child: Icon(Icons.add_rounded, size: 22, color: c.textInvert),
        ),
      ),
    );
  }
}
