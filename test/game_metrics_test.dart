import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/game_metrics.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';

// These assert PARITY WITH supabase/functions/_shared/metrics.ts, not merely
// that the Dart is self-consistent. The same numbers are computed server-side
// for AI insights; if the two drift, a parent is shown two contradictory
// things about their child.

void main() {
  _tierTests();
  group('ppsa', () {
    test('weights free throws at 0.44, not as full attempts', () {
      // THE DETAIL MOST LIKELY TO BE GOT WRONG. 10 fga + 4 fta with 22 points
      // is 22 / (10 + 1.76) = 1.870..., NOT 22 / 14 = 1.571.
      final v = ppsa(fgAttempted: 10, ftAttempted: 4, points: 22);
      expect(v, closeTo(22 / (10 + 0.44 * 4), 1e-9));
      expect(v, isNot(closeTo(22 / 14, 1e-3)));
    });

    test('is zero when nothing was attempted', () {
      expect(ppsa(fgAttempted: 0, ftAttempted: 0, points: 0), 0);
      // Points without attempts should not divide by zero.
      expect(ppsa(fgAttempted: 0, ftAttempted: 0, points: 5), 0);
    });

    test('free throws alone still produce a value', () {
      expect(ppsa(fgAttempted: 0, ftAttempted: 10, points: 8),
          closeTo(8 / 4.4, 1e-9));
    });
  });

  group('attempt gate', () {
    test('counts field goals and free throws together', () {
      expect(shotAttempts(fgAttempted: 3, ftAttempted: 2), 5);
    });

    test('qualifies at the minimum, not above it', () {
      // Below this a single lucky basket reads as elite efficiency.
      expect(
          ppsaQualifies(
              fgAttempted: kPpsaMinAttempts - 1, ftAttempted: 0), isFalse);
      expect(ppsaQualifies(fgAttempted: kPpsaMinAttempts, ftAttempted: 0),
          isTrue);
      expect(ppsaQualifies(fgAttempted: 2, ftAttempted: 3), isTrue);
    });
  });

  group('disrupt', () {
    test('applies the weights and ROUNDS', () {
      // 1 dreb is 0.5, which must not silently truncate to 0.
      expect(disruptScore(steals: 0, blocks: 0, oreb: 0, dreb: 1), 1);
      expect(disruptScore(steals: 0, blocks: 0, oreb: 0, dreb: 3), 2);
    });

    test('matches a worked example', () {
      // 2 oreb (4.0) + 3 steals (4.5) + 1 block (1.0) + 4 dreb (2.0) = 11.5
      expect(disruptScore(steals: 3, blocks: 1, oreb: 2, dreb: 4), 12);
    });

    test('a quiet game does not qualify', () {
      expect(disruptQualifies(kDisruptActiveMin - 1), isFalse);
      expect(disruptQualifies(kDisruptActiveMin), isTrue);
    });
  });

  group('ast/tov', () {
    test('zero turnovers yields the ASSIST COUNT, not infinity', () {
      // Infinity breaks every comparison downstream, and a clean game should
      // read as strong rather than as an unbounded number.
      final r = astTovRatio(assists: 6, turnovers: 0);
      expect(r, 6.0);
      expect(r!.isFinite, isTrue);
    });

    test('is null below the assist minimum', () {
      // One assist and no turnovers is not a playmaking performance.
      expect(astTovRatio(assists: kAstTovMinAssists - 1, turnovers: 0), isNull);
      expect(astTovRatio(assists: kAstTovMinAssists, turnovers: 1), isNotNull);
    });

    test('divides when there are turnovers', () {
      expect(astTovRatio(assists: 6, turnovers: 2), 3.0);
    });
  });
}

// --- Tiers -------------------------------------------------------------------
//
// These mirror supabase/functions/_shared/metrics.ts. The two are read by the
// same parent about the same game - the server writes the tier into the
// insight text, the client renders the Development rows - so a disagreement
// shows up as the app contradicting itself. Every boundary here was taken
// from the TypeScript, not derived.
void _tierTests() {
  group('ppsaTier', () {
    // u13: solid 0.65, good 0.90, elite 1.15.
    test('lands on each band at its exact boundary', () {
      expect(ppsaTier(1.15, AgeBand.u13), GameTier.elite);
      expect(ppsaTier(0.90, AgeBand.u13), GameTier.good);
      expect(ppsaTier(0.65, AgeBand.u13), GameTier.solid);
    });

    test('below solid is NO rating, not a low one', () {
      // The product rule: a weak game says nothing rather than something
      // discouraging.
      expect(ppsaTier(0.64, AgeBand.u13), isNull);
      expect(ppsaTier(0, AgeBand.u13), isNull);
    });

    test('the same value tiers differently by age band', () {
      // The whole point of age-normalising. 0.80 is Good for an 8-10 and only
      // Solid for a 14-18.
      expect(ppsaTier(0.80, AgeBand.u10), GameTier.good);
      expect(ppsaTier(0.80, AgeBand.u13), GameTier.solid);
      expect(ppsaTier(0.80, AgeBand.u18), GameTier.solid);
    });

    test('NO BAND, NO TIER', () {
      // Matches get_age_band after 20260721000000 and growthIq(). These
      // cutoffs are age-relative; without an age there is nothing to be
      // relative to.
      expect(ppsaTier(2.0, null), isNull);
    });
  });

  group('disruptTier', () {
    test('lands on each band at its exact boundary', () {
      expect(disruptTier(13), GameTier.elite);
      expect(disruptTier(12), GameTier.good);
      expect(disruptTier(6), GameTier.good);
      expect(disruptTier(5), GameTier.solid);
      expect(disruptTier(3), GameTier.solid);
    });

    test('below the active minimum is no rating', () {
      expect(disruptTier(2), isNull);
      expect(disruptTier(0), isNull);
    });
  });

  group('astTovTier', () {
    test('elite needs a high ratio AND enough assists to earn it', () {
      // 4 assists to 1 turnover is elite. The same 4.0 ratio off 3 assists is
      // a small sample, and drops to Good.
      expect(astTovTier(assists: 4, turnovers: 1), GameTier.elite);
      expect(astTovTier(assists: 3, turnovers: 0), GameTier.good);
    });

    test('zero turnovers uses the assist count, not infinity', () {
      // A clean game reads as strong rather than as an unbounded number.
      expect(astTovTier(assists: 8, turnovers: 0), GameTier.elite);
    });

    test('below the assist minimum is no rating', () {
      // 2 assists and 0 turnovers is a perfect ratio and means nothing.
      expect(astTovTier(assists: 2, turnovers: 0), isNull);
    });

    test('a qualifying game always gets SOME tier', () {
      // Unlike the other two, which fall through to null. Past the assist
      // gate there is enough to say something, and Solid is a real answer.
      expect(astTovTier(assists: 3, turnovers: 9), GameTier.solid);
    });
  });

  test('the labels are the approved hierarchy', () {
    // Solid is the ENTRY level, not a weak rating. This has been misread.
    expect(GameTier.solid.label, 'Solid');
    expect(GameTier.good.label, 'Good');
    expect(GameTier.elite.label, 'Elite');
  });
}
