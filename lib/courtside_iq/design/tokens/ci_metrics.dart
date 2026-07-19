// Courtside IQ 2.0 — spacing and radius (Phase 4.7)
//
// Ported from the Figma "Spacing" and "Radius" variable collections in
// `uvHb6HXvIVFwzSSXPtEVoc`.

import 'package:flutter/widgets.dart';

/// Spacing scale. Prefer the semantic aliases at the bottom over raw steps
/// when one applies - `CiSpace.screen` says why, `CiSpace.s6` only says how much.
abstract final class CiSpace {
  static const s0 = 0.0;

  /// 1px. Hairline dividers, which are ALWAYS full-bleed edge to edge.
  static const hairline = 1.0;

  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s7 = 32.0;
  static const s8 = 40.0;
  static const s9 = 48.0;
  static const s10 = 56.0;
  static const s12 = 72.0;
  static const s16 = 104.0;

  // --- Semantic aliases ------------------------------------------------------

  /// Horizontal screen gutter. Content sits on this; hairlines ignore it.
  static const screen = s6; // 24

  /// Standard card padding.
  static const card = s6; // 24

  /// Compact card padding.
  static const cardSm = s4; // 16

  /// Roomy card padding.
  static const cardLg = s7; // 32

  /// Minimum touch target. Anything tappable must be at least this in both
  /// axes, even when the painted control looks smaller.
  static const hitMin = 44.0;

  /// Bottom tab bar height.
  static const tabBar = 76.0;
}

/// Corner radii. Bind these rather than typing numbers, so a shape change is
/// one edit - the "shape-consistency lock".
abstract final class CiRadius {
  static const none = 0.0;

  /// Chips and small pills.
  static const chip = 6.0;

  /// Buttons, inputs, and most controls.
  static const control = 10.0;

  /// Bottom sheets and large cards.
  static const sheet = 14.0;

  /// Dialogs. All four corners, deliberately - a locked decision.
  static const dialog = 18.0;

  /// Fully rounded. Avatars, lime/orange pills.
  static const pill = 999.0;

  static const chipR = BorderRadius.all(Radius.circular(chip));
  static const controlR = BorderRadius.all(Radius.circular(control));
  static const sheetR = BorderRadius.all(Radius.circular(sheet));
  static const dialogR = BorderRadius.all(Radius.circular(dialog));
  static const pillR = BorderRadius.all(Radius.circular(pill));

  /// Sheets round only their top corners when anchored to the bottom edge.
  static const sheetTopR = BorderRadius.vertical(top: Radius.circular(sheet));
}
