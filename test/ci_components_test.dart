import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_badge.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_segment_bar.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_stat_tile.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_stepper.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: CiTheme.light(),
        home: Scaffold(body: child),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('intrinsic width', () {
    // A Container with an alignment and no explicit width fills its
    // constraints instead of hugging its child. That silently stretched every
    // badge and button to full width, and only became visible once badges sat
    // inside a stat tile. These tests pin the behaviour.

    testWidgets('badge hugs its content inside a wide parent',
        (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [CiBadge(label: '+4.2')],
          ),
        ),
      );
      final w = tester.getSize(find.byType(CiBadge)).width;
      expect(w, lessThan(120), reason: 'badge stretched to $w');
      expect(w, greaterThan(20));
    });

    testWidgets('button hugs its content unless expand is set',
        (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [CiButton(label: 'See plans', onPressed: () {})],
          ),
        ),
      );
      expect(tester.getSize(find.byType(CiButton)).width, lessThan(300));
    });

    testWidgets('button fills the width when expand is set', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 400,
          child: Column(
            children: [
              CiButton(label: 'See plans', expand: true, onPressed: () {}),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(CiButton)).width, 400);
    });

    testWidgets('badge inside a stat tile does not stretch the tile',
        (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 400,
          child: CiStatTile(
            label: 'Points',
            value: '18.5',
            trend: CiBadge.delta(value: 4.2),
          ),
        ),
      );
      expect(tester.getSize(find.byType(CiBadge)).width, lessThan(120));
    });
  });

  group('CiBadge.delta tone follows meaning, not sign', () {
    CiBadgeTone toneOf(WidgetTester t) =>
        t.widget<CiBadge>(find.byType(CiBadge)).tone;

    testWidgets('a gain is good when higher is better', (tester) async {
      await _pump(tester, CiBadge.delta(value: 4.2));
      expect(toneOf(tester), CiBadgeTone.good);
    });

    testWidgets('a drop is energy when higher is better', (tester) async {
      await _pump(tester, CiBadge.delta(value: -1.4));
      expect(toneOf(tester), CiBadgeTone.energy);
    });

    testWidgets('fewer turnovers is GOOD despite a negative number',
        (tester) async {
      // The trap: a naive sign check paints this orange and tells a parent
      // their kid regressed at the moment they improved.
      await _pump(tester, CiBadge.delta(value: -1.4, higherIsBetter: false));
      expect(toneOf(tester), CiBadgeTone.good);
      expect(find.text('-1.4'), findsOneWidget);
    });

    testWidgets('more turnovers is energy', (tester) async {
      await _pump(tester, CiBadge.delta(value: 1.4, higherIsBetter: false));
      expect(toneOf(tester), CiBadgeTone.energy);
    });

    testWidgets('no change is neutral in either direction', (tester) async {
      await _pump(tester, CiBadge.delta(value: 0));
      expect(toneOf(tester), CiBadgeTone.neutral);
    });
  });

  group('CiStatGrid seams', () {
    testWidgets('a partial row still occupies every column', (tester) async {
      // Two tiles in a three-column grid must still span the full width, so
      // the trailing seam lands on the same boundary as the rows above.
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: CiStatGrid(
            columns: 3,
            tiles: [
              CiStatTile(label: 'Steals', value: '1.4'),
              CiStatTile(label: 'Turnovers', value: '1.8'),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(CiStatGrid)).width, 360);
      expect(find.byType(CiStatTile), findsNWidgets(2));
    });

    testWidgets('renders an empty grid without throwing', (tester) async {
      await _pump(tester, const CiStatGrid(tiles: []));
      expect(tester.takeException(), isNull);
    });
  });

  group('CiSegmentBar', () {
    testWidgets('drops zero-value segments rather than drawing slivers',
        (tester) async {
      late CiColors c;
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.light(),
        home: Builder(builder: (context) {
          c = CiColors.of(context);
          return Scaffold(
            body: CiSegmentBar.scoringMix(
                twoPoint: 14, threePoint: 0, freeThrow: 3, colors: c),
          );
        }),
      ));
      // 14 and 3 render; the zero three-point segment is absent.
      expect(find.text('14'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('an all-zero bar renders nothing but does not throw',
        (tester) async {
      await _pump(tester, const CiSegmentBar(segments: []));
      expect(tester.takeException(), isNull);
    });
  });

  group('CiStepper', () {
    testWidgets('cannot go below zero', (tester) async {
      var value = 0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => CiStepper(
            label: 'Rebounds',
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.tap(find.text('−'));
      await tester.pump();
      // There is no such thing as minus one rebound.
      expect(value, 0);
    });

    testWidgets('increments and decrements', (tester) async {
      var value = 5;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => CiStepper(
            label: 'Points',
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.tap(find.text('+'));
      await tester.pump();
      expect(value, 6);

      await tester.tap(find.text('−'));
      await tester.pump();
      expect(value, 5);
    });

    testWidgets('respects max', (tester) async {
      var value = 3;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => CiStepper(
            label: 'Points',
            value: value,
            max: 3,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.tap(find.text('+'));
      await tester.pump();
      expect(value, 3);
    });

    testWidgets('step buttons meet the touch-target minimum', (tester) async {
      await _pump(
        tester,
        CiStepper(label: 'Points', value: 1, onChanged: (_) {}),
      );
      // A parent taps these one-handed while watching their kid, not the
      // screen. 56 is deliberate headroom over the 44 minimum.
      for (final glyph in ['−', '+']) {
        final box = find.ancestor(
          of: find.text(glyph),
          matching: find.byType(Container),
        );
        expect(tester.getSize(box.first).height, greaterThanOrEqualTo(44));
      }
    });
  });
}
