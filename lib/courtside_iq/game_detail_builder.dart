// Game Detail view model — Phase 4.14
//
// One game's stored row in, everything 145:610 renders out. Pure Dart: no
// Flutter, no Supabase, so the rules below are testable without either.
//
// THREE RULES DECIDE WHAT THE SCREEN SHOWS, all of them from the same product
// principle - a rating the data cannot support is worse than no rating:
//
//   1. A metric below its data threshold gets NO ROW. Not a zero, not a
//      greyed-out badge. Under 5 shot attempts a single lucky basket reads as
//      elite efficiency; under 3 assists a 2-and-0 game is a perfect ratio
//      that means nothing.
//   2. When NO metric qualifies, the whole Development section goes. Three
//      unrated rows would be a section that says nothing at length.
//   3. Points, the shooting percentages and the scoring mix ALWAYS show.
//      Those are counts, not judgements - they are true regardless of sample
//      size, and they are why a parent opened the game.
//
// The tiers come from game_metrics.dart, INCLUDING the one on the insight
// card. The stored insight carries its own `tier_context`, and using it for
// the card while computing the rows would let the card say ELITE above a row
// saying Good. That is the two-classifier bug from Growth IQ, one screen
// further down.

import 'game_metrics.dart';
import 'metrics_config.dart';

/// One game as stored, before any judgement is applied.
class GameDetailRow {
  const GameDetailRow({
    required this.gameId,
    required this.playerId,
    required this.playerName,
    this.playerPhotoUrl,
    this.opponent,
    this.playedAt,
    this.eventName,
    this.ageBand,
    required this.points,
    required this.fgMade,
    required this.fgAttempt,
    required this.twoMade,
    required this.threeMade,
    required this.threeAttempt,
    required this.ftMade,
    required this.ftAttempt,
    required this.offReb,
    required this.defReb,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.turnovers,
    this.insight,
  });

  final String gameId;
  final String playerId;
  final String playerName;
  final String? playerPhotoUrl;
  final String? opponent;
  final DateTime? playedAt;
  final String? eventName;

  /// Null when the player has no birth date. Scoring efficiency is age
  /// relative, so this being null costs that row - see [development].
  final AgeBand? ageBand;

  final int points;
  final int fgMade;
  final int fgAttempt;
  final int twoMade;
  final int threeMade;
  final int threeAttempt;
  final int ftMade;
  final int ftAttempt;
  final int offReb;
  final int defReb;
  final int assists;
  final int steals;
  final int blocks;
  final int turnovers;

  final GameInsight? insight;

  int get rebounds => offReb + defReb;

  /// Twos are what is left after threes. The tracker records them separately,
  /// but older rows only have fg_made, so deriving keeps both eras working.
  int get twoMadeDerived => twoMade > 0 ? twoMade : (fgMade - threeMade);
}

/// The stored AI insight.
class GameInsight {
  const GameInsight({this.text, this.highlightMetric, this.storedTier});

  final String? text;

  /// 'ppsa' | 'ast_tov' | 'disrupt' | 'effort', or null on legacy rows.
  final String? highlightMetric;

  /// `tier_context` as written by the Edge Function.
  ///
  /// NOT what the card displays. Kept only as a fallback for a highlighted
  /// metric this client cannot compute - notably 'effort', which the v0
  /// prompt emitted and no current formula covers.
  final String? storedTier;

  bool get hasText => (text ?? '').trim().isNotEmpty;
}

/// One rated row in the Development section.
class DevelopmentRow {
  const DevelopmentRow({
    required this.metric,
    required this.title,
    required this.detail,
    required this.tier,
  });

  /// Matches `highlight_metric` in the stored insight, so the card and the
  /// row can be tied together.
  final String metric;
  final String title;

  /// The counts behind the rating: "22 points on 14 shots".
  final String detail;
  final GameTier tier;
}

/// One band of the scoring mix bar.
class ScoringSegment {
  const ScoringSegment({required this.label, required this.points});
  final String label;
  final int points;
}

class GameDetailView {
  const GameDetailView({
    required this.row,
    required this.development,
    required this.scoringMix,
    required this.insightLabel,
  });

  final GameDetailRow row;

  /// Only the metrics that qualified. Empty means the section is hidden.
  final List<DevelopmentRow> development;

  /// Only the sources that actually scored. A segment worth nothing would be
  /// an invisible sliver with a legend entry explaining it.
  final List<ScoringSegment> scoringMix;

  /// "SCORING EFFICIENCY · ELITE" for the insight card, or null when the
  /// highlighted metric did not qualify and nothing was stored either.
  final String? insightLabel;

  bool get showDevelopment => development.isNotEmpty;

  /// The card is hidden entirely without text. An empty lime block promising
  /// an insight that is not there is worse than no block.
  bool get showInsight => row.insight?.hasText ?? false;
}

/// Percentage, or null when nothing was attempted.
///
/// A shot never taken has no percentage. "0%" would report a miss that never
/// happened.
double? shootingPct({required int made, required int attempted}) =>
    attempted == 0 ? null : made / attempted * 100;

const _metricTitles = {
  'ppsa': 'Scoring Efficiency',
  'ast_tov': 'Playmaking',
  'disrupt': 'Disruption',
  'effort': 'Effort',
};

GameDetailView buildGameDetail(GameDetailRow row) {
  final development = <DevelopmentRow>[];

  // FIELD GOAL ATTEMPTS, not the PPSA denominator. The frame reads "22 points
  // on 14 shots" beside a 57% field goal figure of 8/14, so "shots" here is
  // what a parent counts as a shot. PPSA's own gate and denominator still
  // include free throws - this line explains the rating, it does not restate
  // the formula.
  final shotsTaken = row.fgAttempt;
  if (ppsaQualifies(fgAttempted: row.fgAttempt, ftAttempted: row.ftAttempt)) {
    final value = ppsa(
      fgAttempted: row.fgAttempt,
      ftAttempted: row.ftAttempt,
      points: row.points,
    );
    final tier = ppsaTier(value, row.ageBand);
    if (tier != null) {
      development.add(DevelopmentRow(
        metric: 'ppsa',
        title: _metricTitles['ppsa']!,
        detail: '${row.points} points on $shotsTaken shots',
        tier: tier,
      ));
    }
  }

  final playmaking =
      astTovTier(assists: row.assists, turnovers: row.turnovers);
  if (playmaking != null) {
    development.add(DevelopmentRow(
      metric: 'ast_tov',
      title: _metricTitles['ast_tov']!,
      detail: '${_plural(row.assists, 'assist')}, '
          '${_plural(row.turnovers, 'turnover')}',
      tier: playmaking,
    ));
  }

  final disrupt = disruptTier(disruptScore(
    steals: row.steals,
    blocks: row.blocks,
    oreb: row.offReb,
    dreb: row.defReb,
  ));
  if (disrupt != null) {
    development.add(DevelopmentRow(
      metric: 'disrupt',
      title: _metricTitles['disrupt']!,
      detail: '${_plural(row.steals, 'steal')}, '
          '${_plural(row.rebounds, 'rebound')}',
      tier: disrupt,
    ));
  }

  final mix = <ScoringSegment>[
    ScoringSegment(label: '2PT', points: row.twoMadeDerived * 2),
    ScoringSegment(label: '3PT', points: row.threeMade * 3),
    ScoringSegment(label: 'FT', points: row.ftMade),
  ].where((s) => s.points > 0).toList();

  return GameDetailView(
    row: row,
    development: development,
    scoringMix: mix,
    insightLabel: _insightLabel(row, development),
  );
}

/// The card's eyebrow, preferring the tier this client computed.
String? _insightLabel(GameDetailRow row, List<DevelopmentRow> development) {
  final metric = row.insight?.highlightMetric;
  if (metric == null) return null;

  final title = _metricTitles[metric];
  if (title == null) return null;

  // The computed tier wins wherever there is one, so the card and the row
  // beneath it cannot disagree about the same metric in the same game.
  final computed =
      development.where((d) => d.metric == metric).map((d) => d.tier.label);
  final tier = computed.isNotEmpty ? computed.first : row.insight?.storedTier;
  if (tier == null || tier.isEmpty) return null;

  return '${title.toUpperCase()} · ${tier.toUpperCase()}';
}

String _plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
