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

  late Color primary = const Color(0xFF9DFF00);
  late Color secondary = const Color(0xFFFB3640);
  late Color tertiary = const Color(0xFFE5A500);
  late Color alternate = const Color(0xFFE0E000);
  late Color primaryText = const Color(0xFF0F0F0F);
  late Color secondaryText = const Color(0xFF292928);
  late Color primaryBackground = const Color(0xFFFFFFFF);
  late Color secondaryBackground = const Color(0xFFE2E0DF);
  late Color accent1 = const Color(0xFF9DFF00);
  late Color accent2 = const Color(0xFFFB3640);
  late Color accent3 = const Color(0xFF287E87);
  late Color accent4 = const Color(0xB2FFFFFF);
  late Color success = const Color(0xFF44D600);
  late Color warning = const Color(0xFFFFCC00);
  late Color error = const Color(0xFFFB3442);
  late Color info = const Color(0xFF1D1D1D);

  late Color gray4 = const Color(0xFFF5F5F5);
  late Color gray1 = const Color(0xFF2B2B2B);
  late Color gray2 = const Color(0xFF8A8A8A);
  late Color gray3 = const Color(0xFFCCCCCC);
  late Color neon = const Color(0xFF9DFF00);
  late Color primaryButtonText = const Color(0xFF0F0F0F);
  late Color grayButton = const Color(0xFF94918E);
  late Color pbg30 = const Color(0x4DFFFFFF);
  late Color pbg0 = const Color(0x000F0F0F);
  late Color bottomSheetBg = const Color(0x9A0F0F0F);
  late Color disableText = const Color(0xFF585858);
  late Color vividViolet = const Color(0xFF9C1BFA);
  late Color blackAlway = const Color(0xFF0F0F0F);
  late Color shadow = const Color(0x57FFFFFF);
  late Color zeroStatBG = const Color(0x00F0F0F0);
  late Color violet4550 = const Color(0x729C1BFA);
  late Color violet1520 = const Color(0x0E9C1BFA);
  late Color globalBackground = const Color(0xFFF0EDE7);
  late Color techBlue = const Color(0xFF023BFF);
  late Color crispCyan = const Color(0xFF22D3EE);
  late Color imperial = const Color(0xFFFB3640);
  late Color teal = const Color(0xFF2BC18C);
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
