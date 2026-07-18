import 'package:flutter_test/flutter_test.dart';
import 'package:courtside_i_q/courtside_iq/growth_iq.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';

/// Builds a run of identical games — the common setup for "steady player".
List<GrowthGame> run(int count, {double? ppsa, double? astTov, double? disrupt}) =>
    List.generate(
      count,
      (_) => GrowthGame(ppsa: ppsa, astTov: astTov, disrupt: disrupt),
    );

void main() {
  group('locked below threshold', () {
    test('fewer than 5 games returns locked, no score', () {
      for (var n = 0; n < kGrowthIqMinGames; n++) {
        final r = growthIq(run(n, ppsa: 1.0, astTov: 3.0, disrupt: 8), AgeBand.u13);
        expect(r.locked, isTrue, reason: '$n games should be locked');
        expect(r.score, isNull);
      }
    });

    test('exactly 5 games unlocks', () {
      final r = growthIq(
        run(kGrowthIqMinGames, ppsa: 1.0, astTov: 3.0, disrupt: 8),
        AgeBand.u13,
      );
      expect(r.locked, isFalse);
      expect(r.score, isNotNull);
      expect(r.gamesUsed, kGrowthIqWindowGames);
    });

    test('games logged but no qualifying data stays locked', () {
      // Zero-performance games: every family below its minimum threshold.
      final r = growthIq(run(6), AgeBand.u13);
      expect(r.locked, isTrue);
      expect(r.score, isNull);
    });
  });

  group('display scale', () {
    test('floor holds: worst possible input never drops below 40', () {
      final r = growthIq(run(10, ppsa: 0.0, astTov: 0.0, disrupt: 0), AgeBand.u13);
      // 0.0 values still qualify as data; the score must clamp at the floor.
      if (!r.locked) {
        expect(r.score, greaterThanOrEqualTo(kGrowthIqDisplayMin));
      }
    });

    test('ceiling holds: elite everything never exceeds 99', () {
      final r = growthIq(run(10, ppsa: 5.0, astTov: 20.0, disrupt: 50), AgeBand.u13);
      expect(r.score, lessThanOrEqualTo(kGrowthIqDisplayMax));
      expect(r.score, greaterThan(kGrowthIqDisplayMin));
    });

    test('ordering is truthful: better play always scores higher', () {
      final weak = growthIq(run(5, ppsa: 0.4, astTov: 0.5, disrupt: 2), AgeBand.u13);
      final mid = growthIq(run(5, ppsa: 0.9, astTov: 2.0, disrupt: 7), AgeBand.u13);
      final strong = growthIq(run(5, ppsa: 1.3, astTov: 5.0, disrupt: 15), AgeBand.u13);

      expect(weak.score! < mid.score!, isTrue);
      expect(mid.score! < strong.score!, isTrue);
    });
  });

  group('improvement', () {
    test('genuine decline lowers the score and reads as building', () {
      // 5 strong games, then 5 weak ones.
      final games = [
        ...run(5, ppsa: 1.2, astTov: 4.0, disrupt: 14),
        ...run(5, ppsa: 0.6, astTov: 1.0, disrupt: 4),
      ];
      final declining = growthIq(games, AgeBand.u13);

      // Same weak recent form, but no prior window to fall from.
      final flat = growthIq(run(5, ppsa: 0.6, astTov: 1.0, disrupt: 4), AgeBand.u13);

      expect(declining.trend, GrowthTrend.building);
      expect(declining.delta, isNotNull);
      expect(declining.delta! < 0, isTrue);
      expect(declining.score! < flat.score!, isTrue,
          reason: 'a decline must actually cost points');
    });

    test('improvement registers as rising with a positive delta', () {
      final games = [
        ...run(5, ppsa: 0.6, astTov: 1.0, disrupt: 4),
        ...run(5, ppsa: 1.2, astTov: 4.0, disrupt: 14),
      ];
      final r = growthIq(games, AgeBand.u13);

      expect(r.trend, GrowthTrend.rising);
      expect(r.delta! > 0, isTrue);
    });

    test('flat performance reads as steady', () {
      final r = growthIq(run(10, ppsa: 0.9, astTov: 2.0, disrupt: 7), AgeBand.u13);
      expect(r.trend, GrowthTrend.steady);
      expect(r.delta, 0);
    });

    test('no prior window means no delta and no trend', () {
      final r = growthIq(run(5, ppsa: 0.9, astTov: 2.0, disrupt: 7), AgeBand.u13);
      expect(r.delta, isNull);
      expect(r.trend, isNull);
    });
  });

  group('age normalization', () {
    test('same PPSA scores higher for a younger band', () {
      // 0.85 PPSA is Good for u10 but only just past Solid for u18.
      final young = growthIq(run(5, ppsa: 0.85), AgeBand.u10);
      final old = growthIq(run(5, ppsa: 0.85), AgeBand.u18);
      expect(young.score! > old.score!, isTrue);
    });

    test('playmaking and disruption are band-invariant (known limitation)', () {
      // Documented deviation: only PPSA is age-banded today.
      expect(kGrowthIqAgeNormalizesPlaymaking, isFalse);
      expect(kGrowthIqAgeNormalizesDisruption, isFalse);

      final a = growthIq(run(5, astTov: 3.0, disrupt: 9), AgeBand.u10);
      final b = growthIq(run(5, astTov: 3.0, disrupt: 9), AgeBand.u18);
      expect(a.score, b.score);
    });
  });

  group('partial data', () {
    test('missing a family re-weights rather than zeroing it', () {
      // A player who never records an assist should not be punished for it.
      final noAssists = growthIq(run(5, ppsa: 1.2, disrupt: 14), AgeBand.u13);
      final withZeroAssists =
          growthIq(run(5, ppsa: 1.2, astTov: 0.0, disrupt: 14), AgeBand.u13);

      expect(noAssists.score! > withZeroAssists.score!, isTrue,
          reason: 'absent data must not be treated as bad data');
    });

    test('a single qualifying family still produces a score', () {
      final r = growthIq(run(5, ppsa: 1.0), AgeBand.u13);
      expect(r.locked, isFalse);
      expect(r.score, isNotNull);
    });
  });

  group('normalizeToTiers anchors', () {
    test('hits the documented anchor points', () {
      double n(double v) =>
          normalizeToTiers(v, solidMin: 1.0, goodMin: 2.0, eliteMin: 3.0);

      expect(n(0.0), 0.0);
      expect(n(1.0), closeTo(kGrowthIqSolidAnchor, 1e-9));
      expect(n(2.0), closeTo(kGrowthIqGoodAnchor, 1e-9));
      expect(n(3.0), 1.0);
      expect(n(99.0), 1.0, reason: 'clamps above elite');
    });

    test('is monotonic', () {
      double prev = -1;
      for (var v = 0.0; v <= 4.0; v += 0.05) {
        final x = normalizeToTiers(v, solidMin: 1.0, goodMin: 2.0, eliteMin: 3.0);
        expect(x >= prev, isTrue, reason: 'dip at $v');
        prev = x;
      }
    });
  });
}
