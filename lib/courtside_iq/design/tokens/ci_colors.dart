// Courtside IQ 2.0 — color tokens (Phase 4.7)
//
// Ported directly from the Figma variable collections in
// `uvHb6HXvIVFwzSSXPtEVoc` (Primitives + Color). Figma is the source of truth;
// if a value here disagrees with the file, the file wins and this should be
// corrected rather than the design changed to match.
//
// Two layers, deliberately:
//
//   CiPalette  - raw primitives. Never reference these from a widget. They
//                exist so the semantic layer has something to point at, exactly
//                as in Figma.
//   CiColors   - semantic tokens, resolved per theme mode. Widgets use ONLY
//                these, so a theme change is a token change and not a hunt
//                through call sites.

import 'package:flutter/material.dart';

/// Raw primitives. Mirrors the Figma "Primitives" collection.
///
/// Do not use directly in widgets — reach for [CiColors] instead.
abstract final class CiPalette {
  // Base
  static const white = Color(0xFFFFFFFF);

  /// True black. NOT the standard dark background — see [CiColors.surfaceDeep].
  static const black = Color(0xFF000000);

  /// The standard dark background. Buttons, dark screens, dark heroes.
  static const inkDefault = Color(0xFF0F0F0F);
  static const inkSoft = Color(0xFF1A1A1A);

  // Neutrals
  static const gray50 = Color(0xFFF7F7F7);
  static const gray100 = Color(0xFFF1F1F1);
  static const gray150 = Color(0xFFE9E9E9);
  static const gray200 = Color(0xFFDFDFDF);
  static const gray300 = Color(0xFFC9C9C9);
  static const gray400 = Color(0xFFA8A8A8);
  static const gray500 = Color(0xFF8A8A8A);
  static const gray600 = Color(0xFF6B6B6B);
  static const gray700 = Color(0xFF474747);
  static const gray800 = Color(0xFF2A2A2A);

  // Accents. Exactly two, and both carry meaning rather than decoration.
  static const lime = Color(0xFF9DFF00);
  static const limeHover = Color(0xFF93EE00);
  static const limeWash = Color(0xFFF1FFD2);
  static const orange = Color(0xFFFF4F00);
  static const orangeHover = Color(0xFFEC4900);
  static const orangeWash = Color(0xFFFFE7DC);

  // Dark-mode borders
  static const darkBorder = Color(0xFF2E2E2E);
  static const darkBorderFaint = Color(0xFF222222);
}

/// Semantic color tokens for one theme mode.
///
/// Mirrors the Figma "Color" collection, which has Light and Dark modes.
@immutable
class CiColors extends ThemeExtension<CiColors> {
  const CiColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunk,
    required this.surfaceInvert,
    required this.surfaceDeep,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.textInvert,
    required this.border,
    required this.borderStrong,
    required this.borderFaint,
    required this.hairline,
    required this.accentGood,
    required this.accentEnergy,
    required this.accentGoodWash,
    required this.accentEnergyWash,
    required this.onAccent,
    required this.focusRing,
    required this.navGlass,
  });

  /// Screen background.
  final Color bg;

  /// Default card / sheet surface.
  final Color surface;

  /// Recessed surface: inactive chips, wells, grouped rows.
  ///
  /// NOTE: Figma also defines `color/surface-raised`, deliberately NOT ported.
  /// It resolves to the same value as `surface` in light and the same value as
  /// this token in dark, so it was a synonym rather than a level. Two names for
  /// one value means two developers pick differently for the same surface. If a
  /// genuinely elevated surface is needed later, add it with a distinct value.
  final Color surfaceSunk;

  /// Inverted surface: dark blocks on light screens, and vice versa.
  final Color surfaceInvert;

  /// True black, for surfaces that must read as DEEPER than the dark
  /// background rather than blending into it.
  ///
  /// Two established uses in the 2.0 designs: dark input fields on the auth
  /// and first-run screens, and the full-bleed premium callout banners
  /// (Upgrade / Lapse). Both sit on `#0F0F0F` and need separation from it.
  ///
  /// Buttons are NOT this - they use [surfaceInvert] / ink.
  final Color surfaceDeep;

  final Color text;
  final Color textMuted;
  final Color textFaint;

  /// Text on an inverted surface.
  final Color textInvert;

  final Color border;
  final Color borderStrong;
  final Color borderFaint;

  /// Divider color. Hairlines are ALWAYS full-bleed edge to edge, never inset.
  final Color hairline;

  /// Lime. Signals positive movement and earned progress.
  final Color accentGood;

  /// Orange. Signals energy and attention, never error.
  final Color accentEnergy;

  /// Tinted lime background for "what's working" blocks.
  final Color accentGoodWash;

  /// Tinted orange background for "room to grow" blocks.
  final Color accentEnergyWash;

  /// Content sitting ON an accent. ALWAYS ink, on both lime and orange -
  /// never white. This is a locked rule.
  final Color onAccent;

  final Color focusRing;

  /// Nav bar backdrop, blurred over content.
  final Color navGlass;

  // --- Light -----------------------------------------------------------------

  static const light = CiColors(
    bg: CiPalette.white,
    surface: CiPalette.white,
    surfaceSunk: CiPalette.gray50,
    surfaceInvert: CiPalette.inkDefault,
    surfaceDeep: CiPalette.black,
    text: CiPalette.inkDefault,
    textMuted: CiPalette.gray500,
    textFaint: CiPalette.gray400,
    textInvert: CiPalette.white,
    border: CiPalette.gray150,
    borderStrong: CiPalette.inkDefault,
    borderFaint: CiPalette.gray100,
    hairline: CiPalette.gray150,
    accentGood: CiPalette.lime,
    accentEnergy: CiPalette.orange,
    accentGoodWash: CiPalette.limeWash,
    accentEnergyWash: CiPalette.orangeWash,
    onAccent: CiPalette.inkDefault,
    focusRing: CiPalette.inkDefault,
    navGlass: CiPalette.white,
  );

  // --- Dark ------------------------------------------------------------------

  static const dark = CiColors(
    bg: CiPalette.inkDefault,
    surface: CiPalette.inkDefault,
    surfaceSunk: CiPalette.inkSoft,
    surfaceInvert: CiPalette.white,
    surfaceDeep: CiPalette.black,
    text: CiPalette.white,
    textMuted: CiPalette.gray400,
    textFaint: CiPalette.gray600,
    textInvert: CiPalette.inkDefault,
    border: CiPalette.darkBorder,
    borderStrong: CiPalette.white,
    borderFaint: CiPalette.darkBorderFaint,
    hairline: CiPalette.darkBorder,
    accentGood: CiPalette.lime,
    accentEnergy: CiPalette.orange,
    accentGoodWash: CiPalette.limeWash,
    accentEnergyWash: CiPalette.orangeWash,
    onAccent: CiPalette.inkDefault,
    focusRing: CiPalette.white,
    navGlass: CiPalette.inkDefault,
  );

  /// Convenience accessor: `CiColors.of(context).text`
  static CiColors of(BuildContext context) =>
      Theme.of(context).extension<CiColors>() ?? light;

  @override
  CiColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSunk,
    Color? surfaceInvert,
    Color? surfaceDeep,
    Color? text,
    Color? textMuted,
    Color? textFaint,
    Color? textInvert,
    Color? border,
    Color? borderStrong,
    Color? borderFaint,
    Color? hairline,
    Color? accentGood,
    Color? accentEnergy,
    Color? accentGoodWash,
    Color? accentEnergyWash,
    Color? onAccent,
    Color? focusRing,
    Color? navGlass,
  }) =>
      CiColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surfaceSunk: surfaceSunk ?? this.surfaceSunk,
        surfaceInvert: surfaceInvert ?? this.surfaceInvert,
        surfaceDeep: surfaceDeep ?? this.surfaceDeep,
        text: text ?? this.text,
        textMuted: textMuted ?? this.textMuted,
        textFaint: textFaint ?? this.textFaint,
        textInvert: textInvert ?? this.textInvert,
        border: border ?? this.border,
        borderStrong: borderStrong ?? this.borderStrong,
        borderFaint: borderFaint ?? this.borderFaint,
        hairline: hairline ?? this.hairline,
        accentGood: accentGood ?? this.accentGood,
        accentEnergy: accentEnergy ?? this.accentEnergy,
        accentGoodWash: accentGoodWash ?? this.accentGoodWash,
        accentEnergyWash: accentEnergyWash ?? this.accentEnergyWash,
        onAccent: onAccent ?? this.onAccent,
        focusRing: focusRing ?? this.focusRing,
        navGlass: navGlass ?? this.navGlass,
      );

  @override
  CiColors lerp(ThemeExtension<CiColors>? other, double t) {
    if (other is! CiColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return CiColors(
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      surfaceSunk: c(surfaceSunk, other.surfaceSunk),
      surfaceInvert: c(surfaceInvert, other.surfaceInvert),
      surfaceDeep: c(surfaceDeep, other.surfaceDeep),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textFaint: c(textFaint, other.textFaint),
      textInvert: c(textInvert, other.textInvert),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      borderFaint: c(borderFaint, other.borderFaint),
      hairline: c(hairline, other.hairline),
      accentGood: c(accentGood, other.accentGood),
      accentEnergy: c(accentEnergy, other.accentEnergy),
      accentGoodWash: c(accentGoodWash, other.accentGoodWash),
      accentEnergyWash: c(accentEnergyWash, other.accentEnergyWash),
      onAccent: c(onAccent, other.onAccent),
      focusRing: c(focusRing, other.focusRing),
      navGlass: c(navGlass, other.navGlass),
    );
  }
}
