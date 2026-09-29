// Game row meaning — 2026-09-29
//
// Every branch a parent would see on a game row: the lead number and its
// fallback, each kind of meaning line, the tie orders, the words, and the
// zero-performance rule that says nothing rather than a zero.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/game_detail_builder.dart';
import 'package:courtside_i_q/courtside_iq/game_metrics.dart';
import 'package:courtside_i_q/courtside_iq/game_row_meaning.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';

GameRowMeaning _m({
  int points = 0,
  int offReb = 0,
  int defReb = 0,
  int assists = 0,
  int steals = 0,
  int blocks = 0,
  int turnovers = 0,
  int fgAttempt = 0,
  int ftAttempt = 0,
  String? insight,
  AgeBand? ageBand,
}) =>
    buildGameRowMeaning(
      points: points,
      offReb: offReb,
      defReb: defReb,
      assists: assists,
      steals: steals,
      blocks: blocks,
      turnovers: turnovers,
      fgAttempt: fgAttempt,
      ftAttempt: ftAttempt,
      insight: insight == null ? null : GameInsight(text: insight),
      ageBand: ageBand,
    );

void main() {
  group('lead', () {
    test('points lead whenever there are any', () {
      expect(_m(points: 22, fgAttempt: 15, defReb: 9).lead,
          const GameRowLead('22', 'PTS'));
    });

    test('without points, the top count leads', () {
      expect(_m(defReb: 7, assists: 3, fgAttempt: 4).lead,
          const GameRowLead('7', 'REB'));
      expect(_m(blocks: 4, steals: 1).lead, const GameRowLead('4', 'BLK'));
    });

    test('ties go REB, AST, STL, BLK in that order', () {
      expect(_m(assists: 2, steals: 2, blocks: 2).lead,
          const GameRowLead('2', 'AST'));
      expect(_m(offReb: 1, assists: 1).lead, const GameRowLead('1', 'REB'));
    });

    test('nothing to lead with: no lead', () {
      // Missed shots and a turnover: a real game, but no count worth leading.
      expect(_m(fgAttempt: 3, turnovers: 1).lead, isNull);
    });
  });

  group('meaning: insight', () {
    test('the first sentence of the insight', () {
      final m = _m(
        points: 12,
        fgAttempt: 9,
        insight: 'Maya attacked the rim all night. Her free throws lagged.',
      );
      expect(m.kind, GameRowMeaningKind.insight);
      expect(m.text, 'Maya attacked the rim all night.');
    });

    test('! and ? end a sentence too', () {
      expect(_m(points: 2, insight: 'What a finish! More to come.').text,
          'What a finish!');
      expect(_m(points: 2, insight: 'Ready for more?  Next game.').text,
          'Ready for more?');
    });

    test('a decimal is not a sentence end', () {
      expect(
          _m(points: 2, insight: 'She scored 1.4 points per shot. Great.')
              .text,
          'She scored 1.4 points per shot.');
    });

    test('no terminator: the whole trimmed text', () {
      expect(_m(points: 2, insight: '  Steady night at the line  ').text,
          'Steady night at the line');
    });

    test('an insight beats a tier', () {
      final m = _m(
        points: 14,
        fgAttempt: 10,
        ageBand: AgeBand.u13,
        insight: 'Efficient.',
      );
      expect(m.kind, GameRowMeaningKind.insight);
    });

    test('a blank insight falls through', () {
      expect(_m(defReb: 2, insight: '   ').kind, GameRowMeaningKind.stats);
    });
  });

  group('meaning: tier', () {
    test('the best tier wins, named as on Game Detail', () {
      // PPSA 1.4 at 11U-13U is Elite; 3 assists, 0 turnovers is Good.
      final m = _m(
        points: 14,
        fgAttempt: 10,
        assists: 3,
        ageBand: AgeBand.u13,
      );
      expect(m.kind, GameRowMeaningKind.tier);
      expect(m.tier, GameTier.elite);
      expect(m.text, 'Scoring Efficiency');
    });

    test('ties go to Game Detail order: ppsa, then ast_tov, then disrupt',
        () {
      // PPSA 1.0 at 11U-13U is Good; 3 assists to 1 turnover is Good.
      final m = _m(
        points: 10,
        fgAttempt: 10,
        assists: 3,
        turnovers: 1,
        ageBand: AgeBand.u13,
      );
      expect(m.tier, GameTier.good);
      expect(m.text, 'Scoring Efficiency');
    });

    test('a missing age band drops the scoring tier, not the others', () {
      final m = _m(points: 14, fgAttempt: 10, assists: 3);
      expect(m.kind, GameRowMeaningKind.tier);
      expect(m.text, 'Playmaking');
      expect(m.tier, GameTier.good);
    });

    test('disruption', () {
      // 2 steals (3) + 2 defensive rebounds (1) = 4: Solid.
      final m = _m(steals: 2, defReb: 2);
      expect(m.text, 'Disruption');
      expect(m.tier, GameTier.solid);
    });

    test('below every gate there is no tier', () {
      // 4 attempts is under the PPSA minimum, even at an elite rate.
      expect(_m(points: 8, fgAttempt: 4, ageBand: AgeBand.u13).kind,
          GameRowMeaningKind.none);
    });
  });

  group('meaning: standout stats', () {
    test('the top two counts in words, ties in order', () {
      // Nothing rates: 2 defensive rebounds + 1 block is a disruption of 2.
      final m = _m(points: 4, fgAttempt: 3, defReb: 2, assists: 1, blocks: 1);
      expect(m.kind, GameRowMeaningKind.stats);
      expect(m.text, '2 rebounds, 1 assist');
    });

    test('singular for one', () {
      expect(_m(points: 2, fgAttempt: 2, blocks: 1).text, '1 block');
    });

    test('plural otherwise', () {
      expect(_m(points: 2, fgAttempt: 2, assists: 2, blocks: 2).text,
          '2 assists, 2 blocks');
    });
  });

  group('zero performance', () {
    test('an empty game says nothing at all', () {
      final m = _m();
      expect(m.lead, isNull);
      expect(m.kind, GameRowMeaningKind.none);
      expect(m.text, isNull);
    });

    test('even an insight is not shown on an empty game', () {
      expect(_m(insight: 'Tough night.').kind, GameRowMeaningKind.none);
    });

    test('any recorded play is a performance', () {
      bool zero({int turnovers = 0, int fgAttempt = 0, int ftAttempt = 0}) =>
          isZeroPerformance(
            points: 0,
            offReb: 0,
            defReb: 0,
            assists: 0,
            steals: 0,
            blocks: 0,
            turnovers: turnovers,
            fgAttempt: fgAttempt,
            ftAttempt: ftAttempt,
          );
      expect(zero(), isTrue);
      expect(zero(turnovers: 1), isFalse);
      expect(zero(fgAttempt: 1), isFalse);
      expect(zero(ftAttempt: 2), isFalse);
    });
  });

  group('parseGameInsight', () {
    test('reads the stored jsonb', () {
      final i = parseGameInsight({
        'text': 'Nice game.',
        'highlight_metric': 'ppsa',
        'tier_context': 'Good',
      });
      expect(i!.text, 'Nice game.');
      expect(i.highlightMetric, 'ppsa');
      expect(i.storedTier, 'Good');
    });

    test('null for anything it cannot read', () {
      expect(parseGameInsight(null), isNull);
      expect(parseGameInsight('text'), isNull);
      expect(parseGameInsight({'tier_context': 'Good'}), isNull);
    });
  });
}
