import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_metrics.dart';

/// These assert the tokens still match the Figma file `uvHb6HXvIVFwzSSXPtEVoc`.
/// If a value legitimately changes in Figma, update BOTH the token and the
/// expectation here — the point is that a silent drift fails loudly.
void main() {
  // Building a theme resolves text styles, and google_fonts reaches for the
  // platform binding to load Hanken Grotesk. Without this, any test that
  // touches CiTheme fails with "Binding has not yet been initialized".
  //
  // This is a symptom of fetching the typeface at runtime rather than bundling
  // it - see the TODO in ci_type.dart.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('primitives match Figma', () {
    test('ink and black are distinct and not swapped', () {
      // The single most confusable pair in this system. #0F0F0F is the standard
      // dark background; #000000 is reserved for surfaces that must sit deeper.
      expect(CiPalette.inkDefault, const Color(0xFF0F0F0F));
      expect(CiPalette.black, const Color(0xFF000000));
      expect(CiPalette.inkDefault, isNot(CiPalette.black));
    });

    test('accents are exactly the approved two', () {
      expect(CiPalette.lime, const Color(0xFF9DFF00));
      expect(CiPalette.orange, const Color(0xFFFF4F00));
    });
  });

  group('locked design rules', () {
    test('content on an accent is ALWAYS ink, in both modes', () {
      // Never white on lime or orange. Locked decision.
      expect(CiColors.light.onAccent, CiPalette.inkDefault);
      expect(CiColors.dark.onAccent, CiPalette.inkDefault);
    });

    test('accents do not change between modes', () {
      // Meaning is carried by the accent, so it must read identically in both.
      expect(CiColors.light.accentGood, CiColors.dark.accentGood);
      expect(CiColors.light.accentEnergy, CiColors.dark.accentEnergy);
    });

    test('dark background is ink, not pure black', () {
      expect(CiColors.dark.bg, CiPalette.inkDefault);
      expect(CiColors.dark.bg, isNot(CiPalette.black));
    });

    test('surfaceDeep is pure black in both modes', () {
      // It exists to sit beneath/above ink, so it does not flip with the theme.
      expect(CiColors.light.surfaceDeep, CiPalette.black);
      expect(CiColors.dark.surfaceDeep, CiPalette.black);
    });

    test('no two surface tokens share a value in the same mode', () {
      // A duplicate token is worse than a missing one: two names for one value
      // means two developers choose differently for the same surface.
      // surfaceRaised was removed for exactly this reason.
      for (final m in {'light': CiColors.light, 'dark': CiColors.dark}.entries) {
        final c = m.value;
        expect(c.surface, isNot(c.surfaceSunk), reason: '${m.key}: surface == sunk');
        expect(c.surface, isNot(c.surfaceDeep), reason: '${m.key}: surface == deep');
        expect(c.surfaceSunk, isNot(c.surfaceDeep), reason: '${m.key}: sunk == deep');
      }
    });

    test('light and dark invert each other for text and surface', () {
      expect(CiColors.light.text, CiColors.dark.textInvert);
      expect(CiColors.dark.text, CiColors.light.textInvert);
      expect(CiColors.light.surfaceInvert, CiColors.dark.bg);
    });
  });

  group('metrics match Figma', () {
    test('radius scale', () {
      expect(CiRadius.chip, 6);
      expect(CiRadius.control, 10);
      expect(CiRadius.sheet, 14);
      expect(CiRadius.dialog, 18); // all four corners, locked
      expect(CiRadius.pill, 999);
    });

    test('spacing aliases resolve to the right steps', () {
      expect(CiSpace.screen, 24);
      expect(CiSpace.card, 24);
      expect(CiSpace.cardSm, 16);
      expect(CiSpace.cardLg, 32);
      expect(CiSpace.hairline, 1);
      expect(CiSpace.tabBar, 76);
    });

    test('minimum touch target meets the accessibility floor', () {
      expect(CiSpace.hitMin, greaterThanOrEqualTo(44.0));
    });
  });

  group('theme wiring', () {
    test('CiColors is reachable through ThemeData in both modes', () {
      expect(CiTheme.light().extension<CiColors>(), CiColors.light);
      expect(CiTheme.dark().extension<CiColors>(), CiColors.dark);
    });

    test('scaffold background follows the bg token', () {
      expect(CiTheme.light().scaffoldBackgroundColor, CiColors.light.bg);
      expect(CiTheme.dark().scaffoldBackgroundColor, CiColors.dark.bg);
    });

    test('dividers are hairline width and use the hairline token', () {
      final d = CiTheme.dark().dividerTheme;
      expect(d.thickness, CiSpace.hairline);
      expect(d.color, CiColors.dark.hairline);
    });

    testWidgets('CiColors.of falls back to light without our theme',
        (tester) async {
      // A widget rendered outside CiTheme must not crash.
      late CiColors seen;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            seen = CiColors.of(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(seen, CiColors.light);
    });

    testWidgets('CiColors.of resolves the dark tokens under CiTheme',
        (tester) async {
      late CiColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: CiTheme.dark(),
          home: Builder(builder: (context) {
            seen = CiColors.of(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(seen.bg, CiPalette.inkDefault);
      expect(seen.text, CiPalette.white);
    });
  });

  group('lerp', () {
    test('interpolates between modes without throwing', () {
      final mid = CiColors.light.lerp(CiColors.dark, 0.5);
      expect(mid, isA<CiColors>());
      expect(mid.bg, isNot(CiColors.light.bg));
    });

    test('returns self when given a foreign extension', () {
      expect(CiColors.light.lerp(null, 0.5), CiColors.light);
    });
  });
}
