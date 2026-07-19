// Courtside IQ 2.0 — type scale (Phase 4.7)
//
// Ported from the Figma text styles in `uvHb6HXvIVFwzSSXPtEVoc`, PLUS the
// high-frequency size/weight combinations the screens actually use.
//
// Why both: the file defines 15 named styles, but the 2.0 screens use ~30
// distinct combinations. Encoding only the named styles would give us a
// "correct" scale that does not match the frames. The extras below are named
// after where they are used and carry their usage count, so it is obvious
// which are canonical and which are pragmatic.
//
// Line heights in Figma are percentages; Flutter's `height` is a multiplier,
// so 104% becomes 1.04. Figma tracking is in px and maps 1:1 to letterSpacing.

import 'package:flutter/widgets.dart';

/// Hanken Grotesk weights as they appear in Figma.
abstract final class CiWeight {
  static const light = FontWeight.w300;
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extraBold = FontWeight.w800;
}

abstract final class CiType {
  /// The bundled family. Registered in pubspec.yaml at weights 300-800.
  ///
  /// Deliberately BUNDLED rather than fetched via google_fonts. Fetching meant
  /// a network request to fonts.gstatic.com just to build a theme, so a cold
  /// start with no signal rendered every 2.0 screen in a fallback face. This
  /// app is built to work in gyms with no wifi; its typeface should be too.
  static const family = 'HankenGrotesk';

  /// Single point of indirection so a family change is one edit.
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required double heightPct,
    double tracking = 0,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: heightPct / 100,
        letterSpacing: tracking,
      );

  // --- Canonical styles (named in Figma) -------------------------------------

  /// 92 Light. The hero number, e.g. Growth IQ on the profile.
  static TextStyle get statXl =>
      _base(size: 92, weight: CiWeight.light, heightPct: 100, tracking: -2);

  /// 64 Light.
  static TextStyle get statLg =>
      _base(size: 64, weight: CiWeight.light, heightPct: 100, tracking: -2);

  /// 48 Light.
  static TextStyle get statMd =>
      _base(size: 48, weight: CiWeight.light, heightPct: 104, tracking: -2);

  /// 32 Light.
  static TextStyle get statSm =>
      _base(size: 32, weight: CiWeight.light, heightPct: 104, tracking: -2);

  /// 46 ExtraBold. Splash and onboarding headlines.
  static TextStyle get display =>
      _base(size: 46, weight: CiWeight.extraBold, heightPct: 104, tracking: -1.5);

  /// 28 ExtraBold. Player name in a profile hero.
  static TextStyle get name =>
      _base(size: 28, weight: CiWeight.extraBold, heightPct: 104, tracking: -1.5);

  static TextStyle get h1 =>
      _base(size: 34, weight: CiWeight.extraBold, heightPct: 104, tracking: -1.5);

  static TextStyle get h2 =>
      _base(size: 26, weight: CiWeight.extraBold, heightPct: 118, tracking: -1.5);

  static TextStyle get h3 =>
      _base(size: 20, weight: CiWeight.bold, heightPct: 118, tracking: -1);

  static TextStyle get h4 =>
      _base(size: 17, weight: CiWeight.semiBold, heightPct: 118);

  /// 16 Regular. Default reading size.
  static TextStyle get body =>
      _base(size: 16, weight: CiWeight.regular, heightPct: 145);

  static TextStyle get bodySm =>
      _base(size: 14, weight: CiWeight.regular, heightPct: 145);

  static TextStyle get bodyXs =>
      _base(size: 13, weight: CiWeight.regular, heightPct: 145);

  /// 13 Medium, +1 tracking. Section headers and eyebrow labels.
  static TextStyle get label =>
      _base(size: 13, weight: CiWeight.medium, heightPct: 118, tracking: 1);

  /// 18 Regular. The unit beside a stat value ("pts", "reb").
  static TextStyle get unit =>
      _base(size: 18, weight: CiWeight.regular, heightPct: 100);

  // --- Additional styles the screens actually use ----------------------------
  //
  // Not in the Figma style sheet, but heavily used. Counts are occurrences
  // across the 2.0 Screens page at the time of the port.

  /// 10 Medium. Tab-bar labels and the smallest captions. (197 uses)
  static TextStyle get micro =>
      _base(size: 10, weight: CiWeight.medium, heightPct: 118);

  /// 11 Medium. Chip and pill labels. (89 uses)
  static TextStyle get chipLabel =>
      _base(size: 11, weight: CiWeight.medium, heightPct: 118);

  /// 12 Medium. Captions and secondary metadata. (102 uses)
  static TextStyle get caption =>
      _base(size: 12, weight: CiWeight.medium, heightPct: 118);

  /// 13 Medium, no tracking. Like [label] but inside dense rows. (143 uses)
  static TextStyle get labelTight =>
      _base(size: 13, weight: CiWeight.medium, heightPct: 118);

  /// 15 SemiBold. Primary text in a list row. (175 uses)
  static TextStyle get rowTitle =>
      _base(size: 15, weight: CiWeight.semiBold, heightPct: 118);

  /// 14 SemiBold. Secondary emphasis in rows and buttons. (104 uses)
  static TextStyle get rowLabel =>
      _base(size: 14, weight: CiWeight.semiBold, heightPct: 118);

  /// 12 SemiBold. Small emphasized labels. (51 uses)
  static TextStyle get labelStrong =>
      _base(size: 12, weight: CiWeight.semiBold, heightPct: 118);

  /// 22 Light. Inline stat values in grids. (149 uses)
  static TextStyle get statInline =>
      _base(size: 22, weight: CiWeight.light, heightPct: 104, tracking: -1);

  /// 24 Light. Slightly larger inline stat. (33 uses)
  static TextStyle get statInlineLg =>
      _base(size: 24, weight: CiWeight.light, heightPct: 104, tracking: -1);

  /// 24 ExtraBold. Section titles inside cards. (20 uses)
  static TextStyle get sectionTitle =>
      _base(size: 24, weight: CiWeight.extraBold, heightPct: 118, tracking: -1);

  /// 9.5 Bold. The smallest badge text. Below the accessibility floor for body
  /// copy - use ONLY for short non-essential badges, never for readable text.
  /// (52 uses)
  static TextStyle get badge =>
      _base(size: 9.5, weight: CiWeight.bold, heightPct: 118, tracking: 0.5);
}
