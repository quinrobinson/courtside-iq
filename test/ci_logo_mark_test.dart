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

/// The path CiLogoMark asks for. If these two drift, the mark silently
/// disappears - which is exactly the failure this file exists to prevent.
const _assetPath = 'assets/images/logo-mark.svg';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('the asset exists at the path CiLogoMark asks for', () {
    expect(File(_assetPath).existsSync(), isTrue,
        reason: 'CiLogoMark loads $_assetPath; without it the mark renders as '
            'an empty box on Splash, auth, the paywall and every other hero');
  });

  test('the asset is valid SVG that the real parser can draw', () async {
    final raw = File(_assetPath).readAsStringSync();
    final picture = await vg.loadPicture(SvgStringLoader(raw), null);
    addTearDown(picture.picture.dispose);

    // Non-zero, and the square-ish viewBox the mark was exported at. A garbled
    // path would parse to an empty or wrongly-sized drawing.
    expect(picture.size.width, greaterThan(0));
    expect(picture.size.height, greaterThan(0));
    expect(picture.size.aspectRatio, closeTo(1.0, 0.02),
        reason: 'the mark is a disc; a non-square box means a broken export');
  });

  testWidgets('renders at every size it is used at', (tester) async {
    // 24 through 60 (splash/auth hero) covers the real call sites.
    for (final size in const [24.0, 44.0, 46.0, 50.0, 60.0]) {
      await _pump(tester, CiLogoMark(size: size));
      expect(find.byType(SvgPicture), findsOneWidget);
    }
  });

  testWidgets('keeps its intrinsic box, which DotBurst spaces its rings off',
      (tester) async {
    await _pump(tester, const CiLogoMark(size: 50));
    expect(tester.getSize(find.byType(CiLogoMark)), const Size(50, 50));
  });

  testWidgets('is tinted, so it reads on ink and on light', (tester) async {
    // Explicit colour wins.
    await _pump(tester, const CiLogoMark(size: 44, color: Color(0xFF9DFF00)));
    final tinted = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      tinted.colorFilter,
      const ColorFilter.mode(Color(0xFF9DFF00), BlendMode.srcIn),
    );

    // And with no colour it inherits the ground rather than shipping a flat
    // asset colour - which is the whole reason this is not the black PNG.
    await _pump(
      tester,
      const CiSurface.ink(child: Center(child: CiLogoMark(size: 44))),
    );
    final inherited = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(inherited.colorFilter, isNotNull);
    expect(inherited.colorFilter,
        isNot(const ColorFilter.mode(Color(0xFF9DFF00), BlendMode.srcIn)));
  });
}
