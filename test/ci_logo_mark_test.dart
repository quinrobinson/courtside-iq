// CiLogoMark — Phase 4.19e
//
// The mark moved from a CustomPainter to a tinted SVG when the refreshed brand
// mark landed (Figma Branding page, 923:3515) - its channel moved to centre,
// widened, and its cut terminations became rounded, which is a shape to take
// from the design rather than re-derive from constants.
//
// That swap trades one risk for another: a painter cannot fail to load, an
// asset can - and it would fail SILENTLY on every brand surface at once.
//
// PUMPING THE WIDGET DOES NOT CATCH THAT. flutter_svg does not surface a
// missing asset through `tester.takeException()`; a deliberately bogus path
// was verified to render an empty box and pass. So the load is tested by
// reading the file and running it through the real parser instead.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_logo_mark.dart';
import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

/// The paths CiLogoMark asks for. If any drift, that half of the mark
/// silently disappears - which is exactly the failure this file exists to
/// prevent. Two files since Release 2.1, when the mark became two colours.
const _assetPaths = [kLogoMarkLeftAsset, kLogoMarkRightAsset];

const _lime = Color(0xFF9DFF00);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

/// The left and right halves' tints, in paint order.
List<ColorFilter?> _filters(WidgetTester tester) => tester
    .widgetList<SvgPicture>(find.byType(SvgPicture))
    .map((p) => p.colorFilter)
    .toList();

void main() {
  for (final path in _assetPaths) {
    test('$path exists at the path CiLogoMark asks for', () {
      expect(
        File(path).existsSync(),
        isTrue,
        reason:
            'CiLogoMark loads $path; without it half the mark renders as '
            'an empty box on Splash, auth, the paywall and every other hero',
      );
    });

    test('$path is valid SVG that the real parser can draw', () async {
      final raw = File(path).readAsStringSync();
      final picture = await vg.loadPicture(SvgStringLoader(raw), null);
      addTearDown(picture.picture.dispose);

      // Both halves are drawn on the FULL mark canvas, so stacking them
      // re-assembles the disc. A non-square box means a broken export or a
      // half cropped to its own bounds, which would misalign when stacked.
      expect(picture.size.width, greaterThan(0));
      expect(picture.size.aspectRatio, closeTo(1.0, 0.02));
    });
  }

  test('the halves match the app icon layers exactly', () {
    // The in-app mark and the app icon are one mark. Same paths, or the two
    // drift apart with nobody noticing until they sit side by side.
    String d(String path) => RegExp(
      r' d="([^"]+)"',
    ).firstMatch(File(path).readAsStringSync())!.group(1)!;
    const icon = 'ios/Runner/courtside-iq.icon/Assets';
    expect(d(kLogoMarkLeftAsset), d('$icon/Left.svg'));
    expect(d(kLogoMarkRightAsset), d('$icon/Right.svg'));
  });

  testWidgets('renders both halves at every size it is used at', (
    tester,
  ) async {
    for (final size in const [20.0, 26.0, 32.0, 44.0, 50.0, 60.0]) {
      await _pump(tester, CiLogoMark(size: size));
      expect(find.byType(SvgPicture), findsNWidgets(2));
    }
  });

  testWidgets('keeps its intrinsic box, which DotBurst spaces its rings off', (
    tester,
  ) async {
    await _pump(tester, const CiLogoMark(size: 50));
    expect(tester.getSize(find.byType(CiLogoMark)), const Size(50, 50));
  });

  testWidgets('on ink: white left, lime right', (tester) async {
    await _pump(
      tester,
      const CiSurface.ink(child: Center(child: CiLogoMark(size: 44))),
    );
    expect(_filters(tester), [
      ColorFilter.mode(CiColors.onInk.text, BlendMode.srcIn),
      const ColorFilter.mode(_lime, BlendMode.srcIn),
    ]);
  });

  testWidgets('on light: ink left, lime right (L1, Quin 2026-09-28)', (
    tester,
  ) async {
    await _pump(
      tester,
      const CiSurface.light(child: Center(child: CiLogoMark(size: 44))),
    );
    final filters = _filters(tester);
    expect(
      filters.last,
      const ColorFilter.mode(_lime, BlendMode.srcIn),
      reason: 'lime on light too - the deeper lime was rejected',
    );
    expect(
      filters.first,
      isNot(ColorFilter.mode(CiColors.onInk.text, BlendMode.srcIn)),
      reason: 'the left half follows the ground; white on white vanishes',
    );
  });

  testWidgets('classic: right half is the left at 50%, no lime', (
    tester,
  ) async {
    const white = Color(0xFFFFFFFF);
    await _pump(
      tester,
      const CiLogoMark(size: 20, color: white, tone: CiLogoTone.classic),
    );
    expect(_filters(tester), [
      const ColorFilter.mode(white, BlendMode.srcIn),
      ColorFilter.mode(white.withValues(alpha: 0.5), BlendMode.srcIn),
    ]);
  });

  testWidgets('an explicit colour sets the left half only', (tester) async {
    const c = Color(0xFF123456);
    await _pump(tester, const CiLogoMark(size: 44, color: c));
    final filters = _filters(tester);
    expect(filters.first, const ColorFilter.mode(c, BlendMode.srcIn));
    expect(filters.last, const ColorFilter.mode(_lime, BlendMode.srcIn));
  });
}
