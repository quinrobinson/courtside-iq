// Game Detail view model — Phase 4.14
//
// The rules under test are all one principle: a rating the data cannot
// support is worse than no rating. What makes them worth testing is that the
// threshold is PER METRIC, so a single game can qualify for one and not the
// others - which is exactly the case a screen built from a happy-path mock
// never exercises.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/game_detail_builder.dart';
import 'package:courtside_i_q/courtside_iq/game_metrics.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';

GameDetailRow _row({
  int points = 22,
  int fgMade = 8,
  int fgAttempt = 14,
  int twoMade = 5,
  int threeMade = 2,
  int threeAttempt = 5,
  int ftMade = 4,
  int ftAttempt = 5,
  int offReb = 2,
  int defReb = 5,
  int assists = 5,
  int steals = 3,
  int blocks = 0,
  int turnovers = 2,
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
      fgMade: fgMade,
      fgAttempt: fgAttempt,
      twoMade: twoMade,
      threeMade: threeMade,
      threeAttempt: threeAttempt,
      ftMade: ftMade,
      ftAttempt: ftAttempt,
      offReb: offReb,
      defReb: defReb,
      assists: assists,
      steals: steals,
      blocks: blocks,
      turnovers: turnovers,
      insight: insight,
    );

void main() {
  group('the Development section', () {
    test('rates all three when the game supports all three', () {
      final v = buildGameDetail(_row());
      expect(v.development.map((d) => d.metric),
          ['ppsa', 'ast_tov', 'disrupt']);
      expect(v.showDevelopment, isTrue);
    });

    test('drops ONLY the metric that fell short', () {
      // 2 assists is below the gate; the shooting and disruption in this same
      // game are untouched. A whole-game switch would hide two real ratings.
      final v = buildGameDetail(_row(assists: 2));
      expect(v.development.map((d) => d.metric), ['ppsa', 'disrupt']);
    });

    test('a quiet game shows no section at all', () {
      // Three unrated rows would be a section that says nothing at length.
      final v = buildGameDetail(_row(
        points: 2, fgMade: 1, fgAttempt: 2, twoMade: 1, threeMade: 0,
        threeAttempt: 0, ftMade: 0, ftAttempt: 0,
        offReb: 0, defReb: 0, assists: 0, steals: 0, blocks: 0, turnovers: 0,
      ));
      expect(v.development, isEmpty);
      expect(v.showDevelopment, isFalse);
    });

    test('no birth date costs scoring efficiency and nothing else', () {
      // PPSA is the only age-relative metric. Playmaking and disruption are
      // absolute, so they still rate.
      final v = buildGameDetail(_row(ageBand: null));
      expect(v.development.map((d) => d.metric), ['ast_tov', 'disrupt']);
    });

    test('the detail line carries the counts behind the rating', () {
      final v = buildGameDetail(_row());
      final byMetric = {for (final d in v.development) d.metric: d.detail};
      // FIELD GOAL attempts (14), matching the frame's "22 points on 14
      // shots" beside its 8/14 field goal figure. PPSA's gate still counts
      // free throws; this line is the explanation, not the formula.
      expect(byMetric['ppsa'], '22 points on 14 shots');
      expect(byMetric['ast_tov'], '5 assists, 2 turnovers');
      // Rebounds are offensive AND defensive, matching the frame.
      expect(byMetric['disrupt'], '3 steals, 7 rebounds');
    });

    test('singulars read as singular', () {
      // "1 assists, 1 turnovers" is the kind of thing a parent notices.
      final v = buildGameDetail(_row(assists: 3, turnovers: 1, steals: 1));
      final byMetric = {for (final d in v.development) d.metric: d.detail};
      expect(byMetric['ast_tov'], '3 assists, 1 turnover');
      expect(byMetric['disrupt'], startsWith('1 steal,'));
    });
  });

  group('the insight card label', () {
    test('uses the tier THIS client computed, not the stored one', () {
      // The stored tier is stale or from a different formula. Trusting it
      // would let the card read ELITE above a row reading Good - the same
      // two-classifier bug Growth IQ had.
      final v = buildGameDetail(_row(
        insight: const GameInsight(
            text: 'A strong night.',
            highlightMetric: 'ppsa',
            storedTier: 'Elite'),
      ));
      final rowTier =
          v.development.firstWhere((d) => d.metric == 'ppsa').tier.label;
      expect(v.insightLabel, 'SCORING EFFICIENCY · ${rowTier.toUpperCase()}');
    });

    test('falls back to the stored tier for a metric it cannot compute', () {
      // 'effort' came from the v0 prompt and no current formula covers it.
      final v = buildGameDetail(_row(
        insight: const GameInsight(
            text: 'Great effort.',
            highlightMetric: 'effort',
            storedTier: 'Good'),
      ));
      expect(v.insightLabel, 'EFFORT · GOOD');
    });

    test('is absent on a legacy insight with no metric or tier', () {
      final v = buildGameDetail(_row(
        insight: const GameInsight(text: 'You were a force on the glass.'),
      ));
      expect(v.insightLabel, isNull);
      // The insight itself still shows. The text is the value; the eyebrow
      // is a label for it.
      expect(v.showInsight, isTrue);
    });

    test('no text, no card', () {
      // An empty lime block promising an insight is worse than no block.
      expect(buildGameDetail(_row()).showInsight, isFalse);
      expect(
          buildGameDetail(_row(insight: const GameInsight(text: '  ')))
              .showInsight,
          isFalse);
    });
  });

  group('the scoring mix', () {
    test('is points from each source, not makes', () {
      // 5 twos, 2 threes, 4 free throws = 10 / 6 / 4, summing to the 20 those
      // shots produced.
      final v = buildGameDetail(_row());
      expect(
          {for (final s in v.scoringMix) s.label: s.points},
          {'2PT': 10, '3PT': 6, 'FT': 4});
    });

    test('drops a source that never scored', () {
      // A zero segment is an invisible sliver with a legend entry explaining
      // it.
      final v = buildGameDetail(_row(threeMade: 0, ftMade: 0));
      expect(v.scoringMix.map((s) => s.label), ['2PT']);
    });

    test('derives twos from field goals on older rows', () {
      // Rows predating the 2.0 tracker have fg_made only. Without this they
      // would show no 2PT segment at all.
      final v = buildGameDetail(_row(twoMade: 0, fgMade: 8, threeMade: 2));
      expect(v.scoringMix.first.points, (8 - 2) * 2);
    });

    test('survives a game with no scoring', () {
      final v = buildGameDetail(_row(
          points: 0, fgMade: 0, fgAttempt: 0, twoMade: 0, threeMade: 0,
          ftMade: 0, ftAttempt: 0));
      expect(v.scoringMix, isEmpty);
    });
  });

  group('shooting percentages', () {
    test('a shot never taken has no percentage', () {
      // "0%" would report a miss that never happened.
      expect(shootingPct(made: 0, attempted: 0), isNull);
      expect(shootingPct(made: 8, attempted: 14), closeTo(57.1, 0.1));
    });
  });
}
