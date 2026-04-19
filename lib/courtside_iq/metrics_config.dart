// PPSA — points per shot attempt
const double kPpsaSolidMin = 0.75;
const double kPpsaGoodMin = 1.00;
const double kPpsaEliteMin = 1.25;
const int kPpsaMinAttempts = 5;

// AST/TOV — assist-to-turnover ratio
const int kAstTovMinAssists = 3;
const double kAstTovGoodMin = 2.0;
const double kAstTovEliteMin = 4.0;

// Effort + Disruption score
// Phase 1.6 will update: kDisruptWeightSteals → 1.5, kDisruptWeightBlocks → 1.0
const double kDisruptWeightOreb = 2.0;
const double kDisruptWeightSteals = 1.0;
const double kDisruptWeightBlocks = 0.5;
const double kDisruptWeightDreb = 0.5;

const int kDisruptActiveMin = 3;
const int kDisruptSolidMax = 5;
const int kDisruptGoodMin = 6;
const int kDisruptGoodMax = 12;
const int kDisruptEliteMin = 13;
