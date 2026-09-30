// List loading skeletons — Phase 4.27
//
// The point of these tests is the ANTI-JUMP CONTRACT. A skeleton whose
// placeholder is a different size from the thing it stands in for is worse
// than a spinner: the list visibly shifts the moment data arrives. Both
// loading frames drew geometry that disagreed with the built components
// (a 188 row against a 208 one, a 14 chip row against a 32 one), so these
// lock the built sizes rather than the drawn ones.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_skeleton.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/games/games_list_skeleton.dart';
import 'package:courtside_i_q/features/players/widgets/player_list_row.dart';
import 'package:courtside_i_q/features/players/widgets/players_list_skeleton.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: Scaffold(body: child),
  ));
  await tester.pump();
}

void main() {
  group('PlayersListSkeleton', () {
    testWidgets('every rendered row is exactly as tall as a real PlayerListRow',
        (tester) async {
      // 515:1975 draws 188. The built row is 208. A skeleton 20pt short would
      // shift the whole list up as the players land, which is the one thing
      // it exists to prevent.
      await _pump(tester, const PlayersListSkeleton());

      final rows = find.byWidgetPredicate(
        (w) => w is SizedBox && w.height == kPlayerRowHeight,
      );
      expect(rows, findsWidgets);
      for (final size in tester.widgetList<SizedBox>(rows)) {
        expect(size.height, kPlayerRowHeight);
      }
    });

    testWidgets('builds the number of rows asked for', (tester) async {
      // Asserted on the list rather than on rendered children: ListView.builder
      // is lazy, so a count of what happens to be on screen measures the test
      // viewport, not the widget.
      await _pump(tester, const PlayersListSkeleton(rows: 5));
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(list.semanticChildCount, 5);
    });

    testWidgets('the discs match the real avatar and gauge sizes',
        (tester) async {
      // The frame draws a 96 gauge; DotGauge is 112. The avatar is 40 in both.
      await _pump(tester, const PlayersListSkeleton(rows: 1));
      final discs = find.byWidgetPredicate(
        (w) => w is CiBone && w.width == null && w.height == 0,
      );
      final sizes = [
        for (var i = 0; i < discs.evaluate().length; i++)
          tester.getSize(discs.at(i)),
      ];
      expect(sizes, contains(const Size(40, 40)), reason: 'the avatar');
      expect(
        sizes,
        contains(const Size(kPlayerRowGaugeSize, kPlayerRowGaugeSize)),
        reason: "the gauge stand-in must be kPlayerRowGaugeSize, not the "
            "frame's 96",
      );
    });
  });

  group('GamesListSkeleton', () {
    testWidgets('both chip rows are 32 tall, matching CiChipBar',
        (tester) async {
      // 682:2785 draws the player row as 14-tall bars. CiChipBar is h32, so
      // reserving 14 would drop the list 18pt on arrival.
      await _pump(tester, const GamesListSkeleton());

      final chipRows = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.height == 32);
      expect(chipRows.length, greaterThanOrEqualTo(2),
          reason: 'a player chip row and a date chip row, both at 32');
    });

    testWidgets('renders four game rows at the built row height',
        (tester) async {
      await _pump(tester, const GamesListSkeleton());
      final rows = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.height == 124);
      expect(rows.length, 4);
    });
  });

  group('CiBone', () {
    testWidgets('uses border, not surfaceSunk', (tester) async {
      // surfaceSunk on ink is #1A1A1A against a #0F0F0F ground, which is very
      // nearly invisible. The frames draw #E7E7E7 and #3D3D3D; border is the
      // closest the palette has.
      await _pump(tester, const CiBone(width: 40, height: 10));

      final box = tester.widget<Container>(find.byType(Container));
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, CiColors.onLight.border);
      expect(decoration.color, isNot(CiColors.onLight.surfaceSunk));
    });

    testWidgets('a circle bone is square and round', (tester) async {
      await _pump(tester, const CiBone.circle(24));
      final box = tester.widget<Container>(find.byType(Container));
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull,
          reason: 'a circle must not also carry a borderRadius');
      expect(tester.getSize(find.byType(Container)), const Size(24, 24));
    });
  });
}
