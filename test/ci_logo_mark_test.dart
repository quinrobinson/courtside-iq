// CiLogoMark — the Dot-burst C (Release 2.1, 2026-09-28).
//
// The mark is one geometry (dot_c_mark_geometry.dart) painted in-app and
// generated into the app icon. These tests hold the shape to what was approved
// in Figma, hold the icon to the geometry, and pin which colour each ground
// gets.

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/brand/dot_c_mark_geometry.dart';
import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_logo_mark.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

const _lime = Color(0xFF9DFF00);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

Color _painted(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(CiLogoMark),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter! as DotCMarkPainter).color;
}

void main() {
  group('geometry', () {
    const inner = 11, outer = 15;

    test('two rings: 11 inner dots, then 15 outer', () {
      expect(kMarkDots, hasLength(inner + outer));
    });

    for (final (name, ring) in [
      ('inner', kMarkDots.sublist(0, inner)),
      ('outer', kMarkDots.sublist(inner)),
    ]) {
      test('$name ring grows and fades in from bottom tip to top tip', () {
        for (var i = 1; i < ring.length; i++) {
          expect(ring[i].r, greaterThan(ring[i - 1].r), reason: 'dot $i');
          expect(
            ring[i].opacity,
            greaterThan(ring[i - 1].opacity),
            reason: 'dot $i',
          );
        }
        expect(ring.first.opacity, closeTo(0.30, 1e-9));
        expect(ring.last.opacity, closeTo(1.00, 1e-9));
        // 45% to 100% of the ring's base size (D6 wide).
        expect(ring.first.r / ring.last.r, closeTo(0.45, 0.01));
      });
    }

    test('no two dots crowd each other (the breathing-room ask)', () {
      for (var i = 0; i < kMarkDots.length; i++) {
        for (var j = i + 1; j < kMarkDots.length; j++) {
          final a = kMarkDots[i], b = kMarkDots[j];
          final dx = a.x - b.x, dy = a.y - b.y;
          final gap = sqrt(dx * dx + dy * dy) - a.r - b.r;
          // Refined D6 wide: every neighbour sits 7 units apart (256 box).
          expect(gap, greaterThan(6.9), reason: 'dots $i and $j');
        }
      }
    });
  });

  test('the iOS icon layer is generated from the geometry', () {
    // Re-run scripts/build_dot_c_icon.dart after any geometry change.
    final svg = File(
      'ios/Runner/courtside-iq.icon/Assets/Mark.svg',
    ).readAsStringSync();
    final circles = RegExp(
      r'cx="([\d.]+)" cy="([\d.]+)" r="([\d.]+)" fill="#9DFF00" '
      r'fill-opacity="([\d.]+)"',
    ).allMatches(svg).toList();
    expect(circles, hasLength(kMarkDots.length));
    const k = 1024 / kMarkIconBox;
    for (var i = 0; i < kMarkDots.length; i++) {
      final d = kMarkDots[i], m = circles[i];
      expect(double.parse(m.group(1)!), closeTo(d.x * k, 0.01));
      expect(double.parse(m.group(2)!), closeTo(d.y * k, 0.01));
      expect(double.parse(m.group(3)!), closeTo(d.r * k, 0.01));
      expect(double.parse(m.group(4)!), closeTo(d.opacity, 0.001));
    }
  });

  testWidgets('keeps its box at every size it is used at', (tester) async {
    for (final size in const [20.0, 26.0, 64.0, 96.0, 128.0]) {
      await _pump(tester, CiLogoMark(size: size));
      expect(tester.getSize(find.byType(CiLogoMark)), Size(size, size));
    }
  });

  testWidgets('primary on ink is lime', (tester) async {
    await _pump(
      tester,
      const CiSurface.ink(child: Center(child: CiLogoMark())),
    );
    expect(_painted(tester), _lime);
  });

  testWidgets('primary on light is ink (mono on white)', (tester) async {
    await _pump(
      tester,
      const CiSurface.light(child: Center(child: CiLogoMark())),
    );
    expect(_painted(tester), CiColors.onLight.text);
  });

  testWidgets('mono on ink is white', (tester) async {
    await _pump(
      tester,
      const CiSurface.ink(
        child: Center(child: CiLogoMark(tone: CiLogoTone.mono)),
      ),
    );
    expect(_painted(tester), CiColors.onInk.text);
  });
}
