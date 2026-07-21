import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_segmented_tabs.dart';
import 'package:courtside_i_q/courtside_iq/player_averages.dart';
import 'package:courtside_i_q/features/players/full_breakdown_page.dart';

AveragesGameRow _g({int points = 10, int assist = 4, int turnover = 2}) =>
    AveragesGameRow(
      points: points,
      assist: assist,
      turnover: turnover,
      offReb: 2,
      defReb: 4,
      steal: 1,
      block: 1,
      fgMade: 4,
      fgAttempt: 10,
      ftMade: 2,
      ftAttempt: 3,
    );

Future<void> _pump(WidgetTester tester, List<AveragesGameRow> games) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: FullBreakdownPage(playerName: 'Maya Chen', games: games),
  ));
}

void main() {
  testWidgets('names the screen and the player it is about', (tester) async {
    await _pump(tester, [_g()]);
    expect(find.text('Full Breakdown'), findsOneWidget);
    expect(find.text('Maya Chen'), findsOneWidget);
  });

  testWidgets('shows all four sections', (tester) async {
    await _pump(tester, [_g()]);
    expect(find.text('Scoring'), findsOneWidget);
    // The rest are below the fold on a phone-sized viewport.
    for (final s in ['Rebounding', 'Playmaking', 'Defense']) {
      await tester.scrollUntilVisible(find.text(s), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(s), findsOneWidget, reason: s);
    }
  });

  testWidgets('a short season hides the window control entirely',
      (tester) async {
    // One window is not a control. Showing "Season" alone as a tab invites a
    // tap that changes nothing.
    await _pump(tester, [_g(), _g(), _g()]);
    expect(find.byType(CiSegmentedTabs), findsNothing);
    expect(find.text('Last 5'), findsNothing);
  });

  testWidgets('windows appear once the player has earned them', (tester) async {
    await _pump(tester, List.generate(11, (_) => _g()));
    expect(find.byType(CiSegmentedTabs), findsOneWidget);
    expect(find.text('Last 5'), findsOneWidget);
    expect(find.text('Last 10'), findsOneWidget);
    expect(find.text('Season'), findsOneWidget);
  });

  testWidgets('opens on Season, the widest window available', (tester) async {
    // Opening on Last 5 would answer a question about form before the parent
    // has seen the season it is measured against.
    await _pump(tester, List.generate(11, (_) => _g()));
    final tabs = tester.widget<CiSegmentedTabs>(find.byType(CiSegmentedTabs));
    expect(tabs.labels[tabs.index], 'Season');
  });

  testWidgets('switching the window rewrites the numbers', (tester) async {
    final games = [
      ...List.generate(5, (_) => _g(points: 30)),
      ...List.generate(6, (_) => _g(points: 10)),
    ];
    await _pump(tester, games);

    // Season: (5*30 + 6*10) / 11 = 19.1
    expect(find.text('19.1'), findsOneWidget);

    await tester.tap(find.text('Last 5'));
    await tester.pumpAndSettle();
    expect(find.text('30.0'), findsOneWidget);
    expect(find.text('19.1'), findsNothing);
  });

  testWidgets('a withheld value renders a dash, not a gap', (tester) async {
    // An empty cell in a seamed grid reads as a rendering failure.
    await _pump(tester, [_g(assist: 1, turnover: 1)]);
    expect(find.text('—'), findsWidgets);
  });
}
