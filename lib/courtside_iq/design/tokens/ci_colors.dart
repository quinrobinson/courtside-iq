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
/// Semantic colors for one ground.
///
/// 2.0 is a SINGLE theme with a hybrid black-and-white palette, not a
/// light/dark mode pair the user toggles. [onLight] and [onInk] are the two
/// grounds a region can sit on - a white Today feed and a dark auth screen
/// coexist in the same app, at the same time. Wrap ink regions in
/// [CiSurface.ink] rather than swapping a global theme.
@immutable
class CiColors extends ThemeExtension<CiColors> {
  const CiColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunk,
    required this.surfaceInvert,
    required this.surfaceDeep,
    required this.fieldFill,
    required this.text,
    required this.textSoft,
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

  /// Input fill. Sunk grey on light ground, pure black on ink.
  ///
  /// This is a token rather than something [CiField] derives because the
  /// component kept getting the derivation wrong. It was first an
  /// `onDeepSurface` flag every call site had to remember, then a check on
  /// theme brightness - which only makes sense if light and dark are modes a
  /// user switches between, and they are not. The palette knows which ground
  /// it is; the component should not be guessing.
  final Color fieldFill;

  final Color text;

  /// Body copy that should read easily but not carry full ink weight.
  ///
  /// Sits between [text] and [textMuted], and exists because those two are not
  /// interchangeable for a PARAGRAPH: full ink is heavier than the explainer
  /// sheets are drawn, and textMuted at 15px on white is around 3.5:1 - fine
  /// for a label, a readability regression for prose. Used by the info sheets.
  final Color textSoft;

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

  // --- On light ground -------------------------------------------------------

  static const onLight = CiColors(
    bg: CiPalette.white,
    surface: CiPalette.white,
    surfaceSunk: CiPalette.gray50,
    surfaceInvert: CiPalette.inkDefault,
    surfaceDeep: CiPalette.black,
    fieldFill: CiPalette.gray50,
    text: CiPalette.inkDefault,
    textSoft: CiPalette.gray700,
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

  // --- On ink ground ---------------------------------------------------------

  static const onInk = CiColors(
    bg: CiPalette.inkDefault,
    surface: CiPalette.inkDefault,
    surfaceSunk: CiPalette.inkSoft,
    surfaceInvert: CiPalette.white,
    surfaceDeep: CiPalette.black,
    fieldFill: CiPalette.black,
    text: CiPalette.white,
    textSoft: CiPalette.gray300,
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
      Theme.of(context).extension<CiColors>() ?? onLight;

  @override
  CiColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSunk,
    Color? surfaceInvert,
    Color? surfaceDeep,
    Color? fieldFill,
    Color? text,
    Color? textSoft,
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
        fieldFill: fieldFill ?? this.fieldFill,
        text: text ?? this.text,
        textSoft: textSoft ?? this.textSoft,
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
      fieldFill: c(fieldFill, other.fieldFill),
      text: c(text, other.text),
      textSoft: c(textSoft, other.textSoft),
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
