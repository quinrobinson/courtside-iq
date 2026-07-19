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
}
