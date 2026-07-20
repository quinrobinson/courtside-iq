import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/game_metrics.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';

// These assert PARITY WITH supabase/functions/_shared/metrics.ts, not merely
// that the Dart is self-consistent. The same numbers are computed server-side
// for AI insights; if the two drift, a parent is shown two contradictory
// things about their child.

void main() {
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
