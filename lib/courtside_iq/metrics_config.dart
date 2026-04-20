// Age bands mirror the SQL get_age_band function.
// Null birth date falls back to u13 (middle band).
enum AgeBand { u10, u13, u18 }

AgeBand ageBandFromString(String? band) {
  switch (band) {
    case '8U-10U':
      return AgeBand.u10;
    case '14U-18U':
      return AgeBand.u18;
    case '11U-13U':
    default:
      return AgeBand.u13;
  }
}

// PPSA — points per shot attempt, age-band-aware
class PpsaThresholds {
  final double solidMin;
  final double goodMin;
  final double eliteMin;
  const PpsaThresholds({
    required this.solidMin,
    required this.goodMin,
    required this.eliteMin,
  });
}

const Map<AgeBand, PpsaThresholds> kPpsaThresholds = {
  AgeBand.u10: PpsaThresholds(solidMin: 0.55, goodMin: 0.80, eliteMin: 1.05),
  AgeBand.u13: PpsaThresholds(solidMin: 0.65, goodMin: 0.90, eliteMin: 1.15),
  AgeBand.u18: PpsaThresholds(solidMin: 0.75, goodMin: 1.00, eliteMin: 1.25),
};

const int kPpsaMinAttempts = 5;

// AST/TOV — assist-to-turnover ratio
const int kAstTovMinAssists = 3;
const int kAstTovEliteMinAssists = 4;
const double kAstTovGoodMin = 2.0;
const double kAstTovEliteMin = 4.0;

// Effort + Disruption score
const double kDisruptWeightOreb = 2.0;
const double kDisruptWeightSteals = 1.5;
const double kDisruptWeightBlocks = 1.0;
const double kDisruptWeightDreb = 0.5;

const int kDisruptActiveMin = 3;
const int kDisruptSolidMax = 5;
const int kDisruptGoodMin = 6;
const int kDisruptGoodMax = 12;
const int kDisruptEliteMin = 13;
