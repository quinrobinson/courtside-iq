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
  String? summary,
  String? firstName,
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
      insight: insight == null
          ? null
          : GameInsight(text: insight, summary: summary),
      ageBand: ageBand,
      playerFirstName: firstName,
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

  group('meaning: insight summary', () {
    test("the model's summary wins over the text", () {
      final m = _m(
        points: 18,
        fgAttempt: 12,
        firstName: 'Jada',
        insight: 'Jada made efficient use of her scoring opportunities with '
            '18 points, showing she is developing a reliable touch.',
        summary: 'Made efficient use of her chances with 18 points',
      );
      expect(m.kind, GameRowMeaningKind.insight);
      expect(m.text, 'Made efficient use of her chances with 18 points');
    });

    test('a summary that leads with the name loses it', () {
      expect(
          cleanSummary("Maya's best shooting night yet.", firstName: 'Maya'),
          'Best shooting night yet');
      expect(cleanSummary('maya attacked the rim', firstName: 'Maya'),
          'Attacked the rim');
    });

    test('a summary over the limit is not shown clipped', () {
      final long = 'A' * (kSummaryMaxChars + 1);
      expect(cleanSummary(long), isNull);
      // ... so the row derives one from the text instead.
      expect(
          _m(points: 2, insight: 'Steady night at the line.', summary: long)
              .text,
          'Steady night at the line');
    });

    // The real older insights from the test database, 2026-09-30.
    test('older insights: first clause, no name', () {
      expect(
          deriveSummary(
              "Jordan's scoring efficiency was really impressive this game, "
              "showing he's making smart decisions when he has the ball.",
              firstName: 'Jordan'),
          'Scoring efficiency was really impressive this game');
      expect(
          deriveSummary(
              'Jada made efficient use of her scoring opportunities with 18 '
              "points, showing she's developing a reliable offensive touch.",
              firstName: 'Jada'),
          // 62 characters whole, so it is cut at the last natural break.
          'Made efficient use of her scoring opportunities');
    });

    test('older insights: a long clause is shortened at a natural break', () {
      expect(
          deriveSummary(
              'Jordan showed good activity on the court with 7 points and '
              'solid decision-making as a combo guard. With more games...',
              firstName: 'Jordan'),
          'Showed good activity on the court with 7 points');
    });

    test('older insights: parentheses are dropped', () {
      final s = deriveSummary(
          "Jada's efficiency with her scoring opportunities (0.85 points per "
          "shot attempt) shows she's making smart decisions when she gets "
          'the ball in her spots as a stretch 4, and her solid effort.',
          firstName: 'Jada')!;
      expect(s.contains('('), isFalse);
      expect(s.startsWith('Jada'), isFalse);
      expect(s.length, lessThanOrEqualTo(kSummaryMaxChars));
    });

    test('every derived summary fits and never ends in a period', () {
      const samples = [
        "Jada's 21 points came with Elite-level efficiency, showing she's "
            'making excellent decisions with the ball.',
        'Jada put on an impressive scoring performance with 17 points, and '
            'what really stands out is her Elite-level efficiency.',
        'You were a force on the glass with 6 total rebounds including 2 on '
            'the offensive end.',
        'Jada showed real offensive polish this game, converting her scoring '
            'chances at a Good level for her age group.',
      ];
      for (final t in samples) {
        final s = deriveSummary(t, firstName: 'Jada');
        expect(s, isNotNull, reason: t);
        expect(s!.length, lessThanOrEqualTo(kSummaryMaxChars), reason: s);
        expect(s.endsWith('.'), isFalse, reason: s);
        expect(s.startsWith('Jada'), isFalse, reason: s);
      }
    });

    test('nothing fits: falls through to the next meaning, never clipped', () {
      final m = _m(
        defReb: 3,
        insight: 'Supercalifragilisticexpialidocious-level rebounding '
            'performances everywhere tonight across every single quarter.',
      );
      expect(m.kind, GameRowMeaningKind.stats);
    });

    test('firstSentence still ends at . ! or ? and skips decimals', () {
      expect(firstSentence('What a finish! More to come.'), 'What a finish!');
      expect(firstSentence('She scored 1.4 points per shot. Great.'),
          'She scored 1.4 points per shot.');
      expect(firstSentence('  Steady night  '), 'Steady night');
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
