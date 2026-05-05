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

  // v1.5 standard FF color mapping
  late Color primary = const Color(0xFF1B1D24);           // ink
  late Color secondary = const Color(0xFF0FA889);         // jade500
  late Color tertiary = const Color(0xFF6B35C9);          // royal500
  late Color alternate = const Color(0xFFF2A43A);         // spark500
  late Color primaryText = const Color(0xFF1B1D24);       // ink
  late Color secondaryText = const Color(0xFF4A4D56);     // ink2
  late Color primaryBackground = const Color(0xFFEFEFF1); // canvas
  late Color secondaryBackground = const Color(0xFFFFFFFF); // surface
  late Color accent1 = const Color(0xFFE04867);           // rose500
  late Color accent2 = const Color(0xFF2558B8);           // steel500
  late Color accent3 = const Color(0xFFE5E5E8);           // canvasSunk
  late Color accent4 = const Color(0xFFE2E2E5);           // hairline
  late Color success = const Color(0xFF44D600);
  late Color warning = const Color(0xFFFFCC00);
  late Color error = const Color(0xFFFB3442);
  late Color info = const Color(0xFF1B1D24);              // ink

  // v1.5 semantic extras — updated to nearest token
  late Color gray4 = const Color(0xFFF7F7F9);             // surfaceAlt
  late Color gray1 = const Color(0xFF1B1D24);             // ink
  late Color gray2 = const Color(0xFF797B85);             // ink3
  late Color gray3 = const Color(0xFFABADB5);             // ink4
  late Color neon = const Color(0xFF9DFF00);              // no v1.5 mapping
  late Color primaryButtonText = const Color(0xFFFFFFFF); // inkOnBrand (primary is now Ink)
  late Color grayButton = const Color(0xFF797B85);        // ink3
  late Color pbg30 = const Color(0x4DFFFFFF);             // no v1.5 mapping
  late Color pbg0 = const Color(0x000F0F0F);              // no v1.5 mapping
  late Color bottomSheetBg = const Color(0x9A0F0F0F);     // no v1.5 mapping
  late Color disableText = const Color(0xFFABADB5);       // ink4
  late Color vividViolet = const Color(0xFF6B35C9);       // royal500
  late Color blackAlway = const Color(0xFF1B1D24);        // ink
  late Color shadow = const Color(0x57FFFFFF);            // no v1.5 mapping
  late Color zeroStatBG = const Color(0x00F0F0F0);        // transparent — unchanged
  late Color violet4550 = const Color(0x726B35C9);        // royal500 @ 45% opacity
  late Color violet1520 = const Color(0x0E6B35C9);        // royal500 @ 5% opacity
  late Color globalBackground = const Color(0xFFEFEFF1);  // canvas (exact value)
  late Color techBlue = const Color(0xFF023BFF);          // no v1.5 mapping
  late Color crispCyan = const Color(0xFF22D3EE);         // no v1.5 mapping
  late Color imperial = const Color(0xFFFB3640);          // no v1.5 mapping
  late Color teal = const Color(0xFF0FA889);              // jade500
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

  // v1.5: DM Sans throughout. Display styles → weight 400 (THE INVERSION).
  // Headings → 700/700/600. Body/small → 400.

  String get displayLargeFamily => 'DM Sans';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 56.0,
      );
  String get displayMediumFamily => 'DM Sans';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 40.0,
      );
  String get displaySmallFamily => 'DM Sans';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 28.0,
      );
  String get headlineLargeFamily => 'DM Sans';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 22.0,
      );
  String get headlineMediumFamily => 'DM Sans';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 17.0,
      );
  String get headlineSmallFamily => 'DM Sans';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      );
  String get titleLargeFamily => 'DM Sans';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      );
  String get titleMediumFamily => 'DM Sans';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  String get titleSmallFamily => 'DM Sans';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  String get labelLargeFamily => 'DM Sans';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.dmSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.w700,
        fontSize: 14.0,
      );
  String get labelMediumFamily => 'DM Sans';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.dmSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.w700,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'DM Sans';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.dmSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
      );
  String get bodyLargeFamily => 'DM Sans';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      );
  String get bodyMediumFamily => 'DM Sans';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'DM Sans';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.dmSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 13.0,
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
      color: Color(0x1A000000),
      offset: Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 6.0,
      color: Color(0x1A000000),
      offset: Offset(0.0, 3.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 15.0,
      color: Color(0x1A000000),
      offset: Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 25.0,
      color: Color(0x1A000000),
      offset: Offset(0.0, 16.0),
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
