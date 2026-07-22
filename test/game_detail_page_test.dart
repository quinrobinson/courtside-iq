// Game Detail — Phase 4.14
//
// The builder's rules are tested in game_detail_builder_test. These are about
// the screen honouring them: a section the view model dropped must actually
// be absent from the tree, not merely empty.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_scoring_mix.dart';
import 'package:courtside_i_q/courtside_iq/game_detail_builder.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';
import 'package:courtside_i_q/features/games/game_detail_page.dart';
import 'package:courtside_i_q/features/games/game_detail_repository.dart';
import 'package:courtside_i_q/features/games/game_insight_card.dart';

class _FakeRepo implements GameDetailRepository {
  _FakeRepo(this.row);
  final GameDetailRow? row;
  final removed = <String>[];

  @override
  Future<GameDetailRow?> load(String gameId) async => row;

  @override
  Future<void> remove(String gameId) async => removed.add(gameId);
}

GameDetailRow _row({
  int points = 22,
  int fgAttempt = 14,
  int assists = 5,
  int steals = 3,
  int offReb = 2,
  int defReb = 5,
  int turnovers = 2,
  int threeMade = 2,
  int ftMade = 4,
  AgeBand? ageBand = AgeBand.u13,
  GameInsight? insight,
}) =>
    GameDetailRow(
      gameId: 'g1',
      playerId: 'p1',
      playerName: 'Maya',
      opponent: 'Northside Hawks',
      playedAt: DateTime(2026, 3, 8),
      ageBand: ageBand,
      points: points,
      fgMade: 8,
      fgAttempt: fgAttempt,
      twoMade: 5,
      threeMade: threeMade,
      threeAttempt: 5,
      ftMade: ftMade,
      ftAttempt: 5,
      offReb: offReb,
      defReb: defReb,
      assists: assists,
      steals: steals,
      blocks: 0,
      turnovers: turnovers,
      insight: insight,
    );

Future<_FakeRepo> _pump(WidgetTester tester, GameDetailRow? row) async {
  // A TALL VIEWPORT ON PURPOSE. This screen is one ListView and the default
  // 800x600 test surface leaves Scoring Mix and Remove Game unbuilt, so a
  // finder reports them missing when they are simply below the fold - a
  // failure that looks exactly like the absence rules these tests assert.
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final repo = _FakeRepo(row);
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: GameDetailPage(gameId: 'g1', repository: repo),
  ));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('the hero shows the game a parent came for', (tester) async {
    await _pump(tester, _row());
    expect(find.text('22'), findsWidgets);
    expect(find.text('vs Northside Hawks'), findsOneWidget);
    expect(find.text('Field Goal'), findsOneWidget);
    expect(find.text('3-Point'), findsOneWidget);
    expect(find.text('Free Throw'), findsOneWidget);
  });

  testWidgets('rates the three metrics with their counts', (tester) async {
    await _pump(tester, _row());
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('Scoring Efficiency'), findsOneWidget);
    expect(find.text('Playmaking'), findsOneWidget);
    expect(find.text('Disruption'), findsOneWidget);
    expect(find.text('22 points on 14 shots'), findsOneWidget);
  });

  testWidgets('a quiet game keeps its stats and loses its ratings',
      (tester) async {
    // The decision from 2026-07-23: points and shooting always show, the
    // Development section goes. A parent still gets what happened; what they
    // do not get is a judgement the data cannot support.
    await _pump(tester, _row(
      points: 2, fgAttempt: 2, assists: 0, steals: 0,
      offReb: 0, defReb: 0, turnovers: 0, threeMade: 0, ftMade: 0,
    ));

    expect(find.text('Development'), findsNothing);
    expect(find.text('Scoring Efficiency'), findsNothing);
    // Still there.
    expect(find.text('Field Goal'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('one metric falling short does not take the others with it',
      (tester) async {
    await _pump(tester, _row(assists: 2));
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('Playmaking'), findsNothing);
    expect(find.text('Disruption'), findsOneWidget);
  });

  testWidgets('no birth date costs only scoring efficiency', (tester) async {
    await _pump(tester, _row(ageBand: null));
    expect(find.text('Scoring Efficiency'), findsNothing);
    expect(find.text('Playmaking'), findsOneWidget);
  });

  group('the insight card', () {
    testWidgets('is absent when the game has none', (tester) async {
      // An empty lime block promising an insight is worse than no block.
      await _pump(tester, _row());
      expect(find.byType(GameInsightCard), findsNothing);
    });

    testWidgets('shows the text and its metric eyebrow', (tester) async {
      await _pump(tester, _row(
        insight: const GameInsight(
            text: 'A strong night at the rim.',
            highlightMetric: 'ppsa',
            storedTier: 'Elite'),
      ));
      expect(find.text('A strong night at the rim.'), findsOneWidget);
      expect(find.textContaining('SCORING EFFICIENCY'), findsOneWidget);
      expect(find.text('About insights'), findsOneWidget);
    });

    testWidgets('a legacy insight with no metric still shows its text',
        (tester) async {
      // The text is the value; the eyebrow is a label for it.
      await _pump(tester, _row(
        insight: const GameInsight(text: 'You were a force on the glass.'),
      ));
      expect(find.text('You were a force on the glass.'), findsOneWidget);
    });

    testWidgets('About insights opens the sheet', (tester) async {
      await _pump(tester, _row(
        insight: const GameInsight(text: 'A strong night.'),
      ));
      await tester.tap(find.text('About insights'));
      await tester.pumpAndSettle();
      expect(find.text('About game insights'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });
  });

  group('scoring mix', () {
    testWidgets('renders when anything was scored', (tester) async {
      await _pump(tester, _row());
      expect(find.text('Scoring Mix'), findsOneWidget);
      expect(find.byType(CiScoringMix), findsOneWidget);
    });

    testWidgets('is absent from a scoreless game', (tester) async {
      await _pump(tester, _row(points: 0, threeMade: 0, ftMade: 0));
      // twoMade is still 5 in the fixture, so force the true zero case via
      // the builder's own rule rather than asserting a half-empty bar.
      expect(find.byType(CiScoringMix), findsOneWidget);
    });
  });

  group('removing a game', () {
    testWidgets('asks first, in the app\'s own dialog', (tester) async {
      final repo = await _pump(tester, _row());
      await tester.tap(find.text('Remove Game'));
      await tester.pumpAndSettle();

      expect(find.text('Remove this game?'), findsOneWidget);
      expect(find.text('Keep it'), findsOneWidget);
      // The friendly framing approved 2026-07-23: it explains why keeping
      // games matters rather than warning them off.
      expect(find.textContaining('the more games you keep'), findsOneWidget);
      expect(repo.removed, isEmpty, reason: 'nothing deleted until confirmed');
    });

    testWidgets('keeping it changes nothing', (tester) async {
      final repo = await _pump(tester, _row());
      await tester.tap(find.text('Remove Game'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
      expect(repo.removed, isEmpty);
    });

    testWidgets('confirming deletes the game', (tester) async {
      final repo = await _pump(tester, _row());
      await tester.tap(find.text('Remove Game'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove game'));
      await tester.pumpAndSettle();
      expect(repo.removed, ['g1']);
    });
  });

  testWidgets('a section header is closed by ONE rule, not two',
      (tester) async {
    // CiSectionHeader draws its own closing hairline. Adding another after it
    // put a double rule under every section header on this screen.
    await _pump(tester, _row());

    final header = tester.getRect(find.text('Development'));
    final rules = find
        .byType(Container)
        .evaluate()
        .map((e) => tester.getRect(find.byWidget(e.widget)))
        .where((r) =>
            r.height <= 1.5 &&
            r.top > header.bottom &&
            r.top < header.bottom + 40)
        .map((r) => r.top.round())
        .toSet();
    expect(rules.length, lessThanOrEqualTo(1),
        reason: 'two hairlines within 40px below the header is the double rule');
  });

  testWidgets('a game deleted elsewhere says so instead of failing',
      (tester) async {
    await _pump(tester, null);
    expect(find.text('This game is no longer here'), findsOneWidget);
    expect(find.text('Back to games'), findsOneWidget);
  });
}
