// The bottom-nav icons — Phase 4.19b
//
// EXPORTED FROM FIGMA, not the nearest Material glyph. The nav used
// grid_view_rounded, groups_rounded, scoreboard_rounded and menu_rounded -
// approximations of icons that were actually drawn: a four-panel dashboard, a
// two-person outline, a split scoreboard reading "2 | 6", three lines. Close
// is not aligned, and this is the reference every empty state is measured
// against, so it had to be the real thing.
//
// The SVGs are the INACTIVE export (opacity and grey stripped on the way in),
// tinted at render with a single colour so one asset serves active and
// inactive. Same reason the app paints its own dot burst and spark: a
// monochrome mark should follow the ground it sits on, not carry a baked
// colour.
//
// SPARE ICONS FOR THE SAME ACTIONS ELSEWHERE go through here too - the Players
// and Games empty states, so the icon a parent sees for "players" is the one
// in the tab they will tap.

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Every designed icon in the nav, and the empty states that mirror it.
enum CiNavIcon { home, players, games, menu }

extension _Asset on CiNavIcon {
  String get asset => switch (this) {
        CiNavIcon.home => 'assets/icons/nav/home.svg',
        CiNavIcon.players => 'assets/icons/nav/players.svg',
        CiNavIcon.games => 'assets/icons/nav/games.svg',
        CiNavIcon.menu => 'assets/icons/nav/menu.svg',
      };
}

class CiNavIconGlyph extends StatelessWidget {
  const CiNavIconGlyph({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  final CiNavIcon icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Center + SizedBox, NOT a bare SvgPicture. A Container with a fixed size
    // and no alignment - which both the nav tab and the empty-state circle
    // are - hands its child TIGHT constraints, and SvgPicture fills them,
    // ignoring width/height. That is why the icons filled the bar and
    // overflowed the circle. Center loosens the constraints so the SizedBox
    // holds, and a Material Icon was immune only because its glyph is sized
    // by font size, not by the box.
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          icon.asset,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
