import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_burst.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_gauge.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: CiTheme.ink(),
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DotGauge', () {
    testWidgets('renders across the full value range without throwing',
        (tester) async {
      for (final v in [0.0, 0.001, 0.5, 0.833, 0.999, 1.0]) {
        await _pump(tester, DotGauge(value: v));
        expect(tester.takeException(), isNull, reason: 'value $v');
      }
    });

    testWidgets('clamps out-of-range values rather than throwing',
        (tester) async {
      // A gauge that crashes on bad data is worse than one that pins.
      for (final v in [-1.0, -0.01, 1.01, 5.0, double.infinity]) {
        await _pump(tester, DotGauge(value: v));
        expect(tester.takeException(), isNull, reason: 'value $v');
      }
    });

    testWidgets('survives NaN', (tester) async {
      // clamp() propagates NaN, so this asserts the painter tolerates it.
      await _pump(tester, const DotGauge(value: double.nan));
      expect(tester.takeException(), isNull);
    });

    testWidgets('honours the requested size', (tester) async {
      await _pump(tester, const DotGauge(value: 0.5, size: 96));
      expect(tester.getSize(find.byType(DotGauge)), const Size(96, 96));
    });

    testWidgets('renders centred child content', (tester) async {
      await _pump(
        tester,
        const DotGauge(value: 0.7, child: Text('71')),
      );
      expect(find.text('71'), findsOneWidget);
    });

    testWidgets('renders at small sizes and with the compact ring set',
        (tester) async {
      for (final size in [44.0, 56.0, 72.0]) {
        await _pump(tester,
            DotGauge(value: 0.6, size: size, rings: DotGaugeRings.compact));
        expect(tester.takeException(), isNull, reason: 'size $size');
      }
    });

    test('ring config matches the measured Figma component', () {
      // Components / DotGauge, 168x168: outer 30 dots r74 d6, inner 24 r56 d5.
      final r = DotGaugeRings.standard;
      expect(r.length, 2);
      expect(r[0].dotCount, 30);
      expect(r[0].radiusFactor, closeTo(74 / 84, 1e-9));
      expect(r[0].dotSizeFactor, closeTo(6 / 84, 1e-9));
      expect(r[1].dotCount, 24);
      expect(r[1].radiusFactor, closeTo(56 / 84, 1e-9));
      expect(r[1].dotSizeFactor, closeTo(5 / 84, 1e-9));
    });
  });

  group('AnimatedDotGauge', () {
    testWidgets('animates to the target without throwing', (tester) async {
      await _pump(tester, const AnimatedDotGauge(value: 0.83));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DotGauge), findsOneWidget);
    });
  });

  group('DotBurst', () {
    testWidgets('renders and honours its size', (tester) async {
      await _pump(tester, const DotBurst(size: 220));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(DotBurst)), const Size(220, 220));
    });

    testWidgets('renders centred child content', (tester) async {
      await _pump(tester, const DotBurst(size: 200, child: Text('CIQ')));
      expect(find.text('CIQ'), findsOneWidget);
    });

    testWidgets('tolerates a tiny radius without producing zero dots',
        (tester) async {
      // Dot count is derived from circumference; the painter floors at 6 so a
      // small ring cannot collapse to nothing.
      await _pump(tester,
          const DotBurst(size: 60, innerRadius: 4, ringGap: 3, dotSpacing: 40));
      expect(tester.takeException(), isNull);
    });
  });

  group('DotBurst scales with its size', () {
    // The geometry was absolute, calibrated for the 390 Splash frame. Rendering
    // at 220 kept the 390-sized ring gaps inside a burst two thirds as wide, so
    // the rings visibly drifted apart. Anything derived from the reference must
    // reproduce the original numbers exactly at 390.

    test('reference size reproduces the original constants', () {
      const b = DotBurst();
      expect(b.size, 390);
      expect(b.innerRadius, 62);
      expect(b.ringGap, 34);
      expect(b.dotSpacing, 22);
    });

    test('a smaller burst scales every dimension proportionally', () {
      const b = DotBurst(size: 195);
      expect(b.innerRadius, 31);
      expect(b.ringGap, 17);
      expect(b.dotSpacing, 11);
    });

    test('ring gap stays a constant fraction of the burst', () {
      // The actual symptom: gap relative to size must not change with size.
      const big = DotBurst();
      const small = DotBurst(size: 220);
      expect(small.ringGap / small.size,
          closeTo(big.ringGap / big.size, 0.0001));
      expect(small.innerRadius / small.size,
          closeTo(big.innerRadius / big.size, 0.0001));
    });

    test('an explicit value still overrides the derived one', () {
      const b = DotBurst(size: 220, ringGap: 40);
      expect(b.ringGap, 40);
      expect(b.innerRadius, closeTo(62 * 220 / 390, 0.0001));
    });
  });

  group('DotBurst spaces the first ring off the mark', () {
    // The rule: the gap between the mark and the first ring must match the gap
    // between rings. Four call sites got this wrong by passing no innerRadius,
    // so the first ring hugged the mark. markSize makes it correct by
    // construction, and these pin that so it cannot drift back.

    test('markSize puts the first ring exactly one ring-gap off the mark edge',
        () {
      const b = DotBurst(size: 220, markSize: 50);
      // mark radius 25, plus one ring gap. The gap the rings have between them.
      expect(b.innerRadius, closeTo(25 + b.ringGap, 0.0001));
    });

    test('so the mark-to-ring gap equals the ring-to-ring gap', () {
      const b = DotBurst(size: 220, markSize: 50);
      final markToFirstRing = b.innerRadius - 25; // first ring radius - mark r
      expect(markToFirstRing, closeTo(b.ringGap, 0.0001));
    });

    test('an explicit innerRadius still wins over markSize', () {
      // The escape hatch for a child whose visual radius is not half its box.
      const b = DotBurst(size: 220, markSize: 50, innerRadius: 90);
      expect(b.innerRadius, 90);
    });

    test('without markSize it falls back to the scaled default', () {
      // Unchanged behaviour for the bursts that carry no centred mark.
      const b = DotBurst(size: 220);
      expect(b.innerRadius, closeTo(62 * 220 / 390, 0.0001));
    });
  });

  group('DotBurst glow', () {
    // The frame carries a 220x220 ellipse on the burst's centre, behind every
    // dot. Figma's codegen exports no gradient fills, so the first build
    // dropped it silently and the burst read as flat.

    test('is on by default and stays subtle', () {
      const b = DotBurst();
      expect(b.glowOpacity, greaterThan(0), reason: 'glow must be present');
      // Depth behind the dots, never neon. The house rule is no oversaturated
      // glow by default; this earns its place by being in the design.
      expect(b.glowOpacity, lessThan(0.25));
    });

    test('can be switched off', () {
      expect(const DotBurst(glowOpacity: 0).glowOpacity, 0);
    });

    testWidgets('renders with and without the glow', (tester) async {
      for (final o in [0.0, 0.16, 0.24]) {
        await tester.pumpWidget(MaterialApp(
          theme: CiTheme.ink(),
          home: Scaffold(body: Center(child: DotBurst(size: 220, glowOpacity: o))),
        ));
        expect(tester.takeException(), isNull, reason: 'glowOpacity=$o');
      }
    });
  });
}
