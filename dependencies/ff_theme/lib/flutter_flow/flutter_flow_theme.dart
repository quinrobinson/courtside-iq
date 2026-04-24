// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color gray4;
  late Color gray1;
  late Color gray2;
  late Color gray3;
  late Color neon;
  late Color primaryButtonText;
  late Color grayButton;
  late Color pbg30;
  late Color pbg0;
  late Color bottomSheetBg;
  late Color disableText;
  late Color vividViolet;
  late Color blackAlway;
  late Color shadow;
  late Color zeroStatBG;
  late Color violet4550;
  late Color violet1520;
  late Color globalBackground;
  late Color techBlue;
  late Color crispCyan;
  late Color imperial;
  late Color teal;

  FFDesignTokens get designToken => FFDesignTokens(this);

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // ===========================================================================
  // Courtside IQ — tuned palette (Apr 2026)
  // Token names preserved. Values shifted for family cohesion.
  // Full rationale: docs/palette-swap-handoff.md
  // ===========================================================================

  // Material / FF defaults — aligned from dead neon scheme to Jade
  late Color primary = const Color(0xFF0FA889);           // was #9DFF00 (dead neon) → Jade-500
  late Color secondary = const Color(0xFFE04867);         // was #FB3640 → Rose-500
  late Color tertiary = const Color(0xFFF2A43A);          // was #E5A500 → Spark-500 (AI mark amber)
  late Color alternate = const Color(0xFFE8E2D7);         // was #E0E000 (dead neon yellow) → warm neutral

  // Text + surfaces
  late Color primaryText = const Color(0xFF1B1D24);       // was #0F0F0F → Ink-900 (faint cool shift)
  late Color secondaryText = const Color(0xFF3A3F4B);     // was #292928 → Ink-700
  late Color primaryBackground = const Color(0xFFFFFFFF); // unchanged
  late Color secondaryBackground = const Color(0xFFE2E0DF); // unchanged

  // Accents — aligned to semantic four
  late Color accent1 = const Color(0xFF0FA889);           // was #9DFF00 → Jade-500 (matches primary)
  late Color accent2 = const Color(0xFFE04867);           // was #FB3640 → Rose-500
  late Color accent3 = const Color(0xFF0A6B5A);           // was #287E87 → Jade-700 (Elite deep-jade)
  late Color accent4 = const Color(0xB2FFFFFF);           // unchanged

  // Semantic state
  late Color success = const Color(0xFF3F8C5C);           // was #44D600 → Moss-500 (warmer green)
  late Color warning = const Color(0xFFC77A2E);           // was #FFCC00 → burnt amber (distinct from Spark)
  late Color error = const Color(0xFFDC2626);             // was #FB3442 → true red (now distinct from Rose)
  late Color info = const Color(0xFF2558B8);              // was #1D1D1D (nonsensical) → Steel-500

  // Grayscale — warmer Ink neutrals
  late Color gray4 = const Color(0xFFF8F7F4);             // was #F5F5F5 → Ink-50
  late Color gray1 = const Color(0xFF3A3F4B);             // was #2B2B2B → Ink-700
  late Color gray2 = const Color(0xFF7A8290);             // was #8A8A8A → Ink-500
  late Color gray3 = const Color(0xFFD0D4DB);             // was #CCCCCC → Ink-300

  // Utility tokens (unchanged except noted)
  late Color neon = const Color(0xFF0FA889);              // was #9DFF00 (dead) → Jade-500
  late Color primaryButtonText = const Color(0xFF0F0F0F); // unchanged
  late Color grayButton = const Color(0xFF94918E);        // unchanged
  late Color pbg30 = const Color(0x4DFFFFFF);             // unchanged
  late Color pbg0 = const Color(0x000F0F0F);              // unchanged
  late Color bottomSheetBg = const Color(0x9A0F0F0F);     // unchanged
  late Color disableText = const Color(0xFF585858);       // unchanged
  late Color blackAlway = const Color(0xFF0F0F0F);        // unchanged
  late Color shadow = const Color(0x57FFFFFF);            // unchanged
  late Color zeroStatBG = const Color(0x00F0F0F0);        // unchanged

  // AI mark — repointed from Violet to Spark amber
  // Call sites using vividViolet/violet4550/violet1520 now render amber automatically.
  late Color vividViolet = const Color(0xFFF2A43A);       // was #9C1BFA → Spark-500
  late Color violet4550 = const Color(0x72F2A43A);        // was 0x729C1BFA → Spark-500 @ 45% alpha
  late Color violet1520 = const Color(0x0EF2A43A);        // was 0x0E9C1BFA → Spark-500 @ 5% alpha

  // Global background — warm canvas
  late Color globalBackground = const Color(0xFFF5F3EF);  // was #F0F0F0 → warm-lean neutral

  // Named brand tokens — the semantic four
  late Color techBlue = const Color(0xFF2558B8);          // was #023BFF → Steel-500 (change/info)
  late Color crispCyan = const Color(0xFF0FA889);         // was #22D3EE → Jade-500
  late Color imperial = const Color(0xFFE04867);          // was #FB3640 → Rose-500 (growth edge, softened)
  late Color teal = const Color(0xFF0FA889);              // was #2BC18C → Jade-500 (everyday primary)
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Montserrat';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 50.0,
      );
  String get displayMediumFamily => 'Montserrat';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 42.0,
      );
  String get displaySmallFamily => 'Montserrat';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 34.0,
      );
  String get headlineLargeFamily => 'Montserrat';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 30.0,
      );
  String get headlineMediumFamily => 'Montserrat';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 26.0,
      );
  String get headlineSmallFamily => 'Montserrat';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 22.0,
      );
  String get titleLargeFamily => 'IBM Plex Sans';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.ibmPlexSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
      );
  String get titleMediumFamily => 'IBM Plex Sans';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.ibmPlexSans(
        color: theme.info,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'IBM Plex Sans';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.ibmPlexSans(
        color: theme.info,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      );
  String get labelLargeFamily => 'IBM Plex Sans';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.ibmPlexSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      );
  String get labelMediumFamily => 'IBM Plex Sans';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.ibmPlexSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'IBM Plex Sans';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.ibmPlexSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 12.0,
      );
  String get bodyLargeFamily => 'IBM Plex Sans';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.ibmPlexSans(
        color: theme.primaryText,
        fontSize: 16.0,
      );
  String get bodyMediumFamily => 'IBM Plex Sans';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.ibmPlexSans(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Montserrat';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.montserrat(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
}

class FFRadius {
  const FFRadius();
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get full => 9999.0;
}

class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get sm => const BoxShadow(
      blurRadius: 3.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 6.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 3.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 15.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 25.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 16.0),
      spreadRadius: 0.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
