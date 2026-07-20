// Courtside IQ 2.0 — theme wiring (Phase 4.7)
//
// ONE theme, two grounds. 2.0 is not a light/dark mode pair the user toggles:
// it is a single hybrid black-and-white design where a white Today feed and a
// dark auth screen coexist in the same build. So there is one [CiTheme.base],
// and any region that sits on ink wraps itself in [CiSurface.ink].
//
// Binds the design tokens into a ThemeData. Widgets should read
// tokens through `CiColors.of(context)` and `CiType.*` rather than Material's
// colorScheme, which cannot express this system (two meaning-carrying accents,
// a separate "deep" surface, wash tints). ThemeData is populated mainly so
// stock Material widgets in the tree do not look foreign.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens/ci_colors.dart';
import 'tokens/ci_metrics.dart';
import 'tokens/ci_type.dart';

/// Status-bar overlay styles by ground.
///
/// The app pins DARK icons globally, from when it was a light-mode design.
/// That is correct on light ground and wrong on ink - the clock and signal
/// bars go black on near-black. Every full-screen ink surface wraps itself in
/// an AnnotatedRegion with [onInk] to override it; light screens inherit the
/// global default and need nothing.
abstract final class CiSystemUi {
  /// Light icons, for ink-ground screens.
  static const SystemUiOverlayStyle onInk = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android
    statusBarBrightness: Brightness.dark, // iOS
  );
}

abstract final class CiTheme {
  /// The app theme. Light ground - the default for most screens.
  static ThemeData base() => _build(CiColors.onLight, Brightness.light);

  /// Ink ground. Not an app theme: [CiSurface.ink] applies this to a REGION.
  /// Exposed for tests and the token gallery.
  static ThemeData ink() => _build(CiColors.onInk, Brightness.dark);

  static ThemeData _build(CiColors c, Brightness brightness) {
    final textTheme = TextTheme(
      displayLarge: CiType.display,
      headlineLarge: CiType.h1,
      headlineMedium: CiType.h2,
      headlineSmall: CiType.h3,
      titleLarge: CiType.h4,
      titleMedium: CiType.rowTitle,
      titleSmall: CiType.rowLabel,
      bodyLarge: CiType.body,
      bodyMedium: CiType.bodySm,
      bodySmall: CiType.bodyXs,
      labelLarge: CiType.label,
      labelMedium: CiType.caption,
      labelSmall: CiType.micro,
    ).apply(bodyColor: c.text, displayColor: c.text);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: textTheme,

      // Material's ColorScheme cannot represent this system faithfully - it has
      // one primary, and we have two accents that carry different meanings.
      // Populated so stock widgets are not jarring; do not treat as the source
      // of truth.
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.accentGood,
        onPrimary: c.onAccent,
        secondary: c.accentEnergy,
        onSecondary: c.onAccent,
        surface: c.surface,
        onSurface: c.text,
        error: c.accentEnergy,
        onError: c.onAccent,
      ),

      dividerTheme: DividerThemeData(
        color: c.hairline,
        thickness: CiSpace.hairline,
        space: CiSpace.hairline,
      ),

      // Ink, not black, and never a Material tint.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.surfaceInvert,
          foregroundColor: c.textInvert,
          minimumSize: const Size.fromHeight(CiSpace.hitMin),
          shape: const RoundedRectangleBorder(borderRadius: CiRadius.controlR),
          textStyle: CiType.rowLabel,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.border),
          minimumSize: const Size.fromHeight(CiSpace.hitMin),
          shape: const RoundedRectangleBorder(borderRadius: CiRadius.controlR),
          textStyle: CiType.rowLabel,
        ),
      ),

      // Label ABOVE the field, never placeholder-as-label: no labelText here.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.fieldFill,
        hintStyle: CiType.body.copyWith(color: c.textFaint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CiSpace.s4,
          vertical: CiSpace.s3,
        ),
        border: const OutlineInputBorder(
          borderRadius: CiRadius.controlR,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CiRadius.controlR,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CiRadius.controlR,
          borderSide: BorderSide(color: c.focusRing, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: CiRadius.controlR,
          borderSide: BorderSide(color: c.accentEnergy),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: CiRadius.sheetTopR),
        showDragHandle: true,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: CiRadius.dialogR),
        titleTextStyle: CiType.h3.copyWith(color: c.text),
        contentTextStyle: CiType.body.copyWith(color: c.textMuted),
      ),

      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CiRadius.sheetR,
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CiType.h3.copyWith(color: c.text),
        iconTheme: IconThemeData(color: c.text),
      ),

      iconTheme: IconThemeData(color: c.text),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      extensions: <ThemeExtension<dynamic>>[c],
    );
  }
}

/// Puts a region on ink ground.
///
/// Wrap any subtree that sits on a dark background - auth, first-run, premium
/// callouts - and every CiColors read inside it resolves to [CiColors.onInk].
/// This replaces swapping a global theme, which 2.0 does not have.
///
/// Paints [CiColors.onInk.bg] by default so the ground and the tokens can
/// never disagree; pass `paint: false` if the caller already painted it.
class CiSurface extends StatelessWidget {
  const CiSurface._(
      {super.key,
      required this.child,
      required this.onInk,
      this.paint = true,
      this.statusBar = false});

  /// The dark ground: auth, onboarding, premium callouts.
  ///
  /// Pass `statusBar: true` for a full-SCREEN ink surface, so the status-bar
  /// icons go light. Leave it false for a partial ink region - a mid-screen
  /// promo banner must not flip the whole screen's status bar.
  const CiSurface.ink({
    Key? key,
    required Widget child,
    bool paint = true,
    bool statusBar = false,
  }) : this._(
            key: key,
            child: child,
            onInk: true,
            paint: paint,
            statusBar: statusBar);

  /// The light ground. Rarely needed at the top level, but necessary to return
  /// a subtree to light ground from inside an ink region.
  const CiSurface.light({Key? key, required Widget child, bool paint = true})
      : this._(key: key, child: child, onInk: false, paint: paint);

  final Widget child;
  final bool onInk;
  final bool paint;

  /// Whether this surface owns the status bar. See [CiSurface.ink].
  final bool statusBar;

  CiColors get colors => onInk ? CiColors.onInk : CiColors.onLight;

  @override
  Widget build(BuildContext context) {
    Widget out =
        Theme(data: onInk ? CiTheme.ink() : CiTheme.base(), child: child);
    if (paint) out = ColoredBox(color: colors.bg, child: out);
    if (statusBar) {
      out = AnnotatedRegion<SystemUiOverlayStyle>(
        value: onInk ? CiSystemUi.onInk : SystemUiOverlayStyle.dark,
        child: out,
      );
    }
    return out;
  }
}
