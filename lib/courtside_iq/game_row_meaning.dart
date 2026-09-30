// Game row meaning — Release 2.2 design review (Quin, 2026-09-29)
//
// What ONE saved game meant, reduced to what a list row can carry: a lead
// number on the right, and one line under the opponent and date.
//
// The row used to be a five-stat box score (PTS REB AST STL TO). That is the
// stat tracker this app says it is not. A parent scanning Today or the Games
// list wants "how did it go", so the row now leads with the one number that
// best stands for the game and says in words what was notable about it.
//
// THE MEANING LINE, first match wins:
//
//   1. insight   a one-line SUMMARY of the stored AI insight, never the
//                insight cut short (Quin, 2026-09-30): at most 52 characters
//                so it fits two lines unclipped, and no player name, which
//                was redundant on every stacked row. The model writes it
//                (`summary`, prompt v3); older insights get one derived from
//                the text by [deriveSummary]. The full insight lives on Game
//                Detail. When neither fits, the row falls through to 2.
//   2. tier      the best rating Game Detail gives this game, with its skill
//                name. Computed by buildGameDetail itself, not recomputed
//                here: the row and the screen it opens must never disagree,
//                which is the two-classifier bug this codebase has already
//                had twice. Ties go to Game Detail's own order.
//   3. stats     the top two non-zero counts among rebounds, assists, steals
//                and blocks, in words ("7 rebounds, 3 steals").
//   4. none      nothing is drawn.
//
// ZERO-PERFORMANCE GAMES SAY NOTHING. No lead, no line. CLAUDE.md: a game
// with no performance shows no rating and displays nothing, never a zero.
// [isZeroPerformance] is where that rule is enforced for game rows.
//
// Pure Dart: no Flutter, no Supabase.

import 'game_detail_builder.dart';
import 'game_metrics.dart';
import 'metrics_config.dart';

/// The number on the right of the row, and its unit label.
class GameRowLead {
  const GameRowLead(this.value, this.label);

  final String value;

  /// 'PTS', 'REB', 'AST', 'STL' or 'BLK'.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is GameRowLead && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(value, label);

  @override
  String toString() => 'GameRowLead($value $label)';
}

enum GameRowMeaningKind { insight, tier, stats, none }

/// What the row says about the game.
class GameRowMeaning {
  const GameRowMeaning({
    required this.lead,
    required this.kind,
    this.text,
    this.tier,
  });

  static const empty =
      GameRowMeaning(lead: null, kind: GameRowMeaningKind.none);

  /// Null when there is no number worth leading with.
  final GameRowLead? lead;

  final GameRowMeaningKind kind;

  /// The line itself: the insight sentence, the skill name for a tier, or
  /// the counts in words. Null for [GameRowMeaningKind.none].
  final String? text;

  /// Set only for [GameRowMeaningKind.tier].
  final GameTier? tier;
}

/// True when the game recorded nothing at all: no points, rebounds, assists,
/// steals, blocks or turnovers, and no shot attempts.
///
/// Such a game shows NO lead and NO meaning. CLAUDE.md's rule: zero
/// performance returns no rating and displays nothing, not a "zero" rating.
bool isZeroPerformance({
  required int points,
  required int offReb,
  required int defReb,
  required int assists,
  required int steals,
  required int blocks,
  required int turnovers,
  required int fgAttempt,
  required int ftAttempt,
}) =>
    points == 0 &&
    offReb + defReb == 0 &&
    assists == 0 &&
    steals == 0 &&
    blocks == 0 &&
    turnovers == 0 &&
    fgAttempt == 0 &&
    ftAttempt == 0;

/// The first sentence of [text]: up to and including the first . ! or ?
/// that is followed by whitespace. The whole trimmed text when there is none.
String firstSentence(String text) {
  final t = text.trim();
  final m = RegExp(r'[.!?](?=\s)').firstMatch(t);
  return m == null ? t : t.substring(0, m.end).trim();
}

/// The longest summary a game row shows. MEASURED, not guessed
/// (test/game_row_summary_fit_test.dart): on a 360pt phone with the avatar
/// showing, the text column is 179pt and wide 55-character lines only just
/// make two lines; 390pt phones take about 60. The model is asked for 50.
/// Mirrors SUMMARY_MAX_CHARS in supabase/functions/_shared/insight_summary.ts.
const int kSummaryMaxChars = 52;

/// Tidies a summary line: no leading player name ("Maya's", "Maya"), no
/// closing period, sentence case. Null when nothing is left or it is over
/// [kSummaryMaxChars]. Mirrors cleanSummary in insight_summary.ts.
String? cleanSummary(String? raw, {String? firstName}) {
  if (raw == null) return null;
  var s = raw.trim().replaceAll(RegExp(r'\s*—\s*'), ', ');
  final name = firstName?.trim() ?? '';
  if (name.isNotEmpty) {
    s = s.replaceFirst(
        RegExp('^${RegExp.escape(name)}(?:[\'’]s)?\\s+', caseSensitive: false),
        '');
  }
  s = s.replaceFirst(RegExp(r'[.!\s]+$'), '').trim();
  if (s.isEmpty) return null;
  s = s[0].toUpperCase() + s.substring(1);
  return s.length <= kSummaryMaxChars ? s : null;
}

/// Where a long insight clause can be shortened, tried from the right: each
/// cut drops a trailing qualifier ("... as a combo guard") and keeps the
/// headline in front of it.
const _cutBefore = [
  ' as a ', ' as an ', ' as the ', ' when ', ' which ', ' while ', ' and ',
  ' showing ', ' shows ', ' including ', ' with ', ' for ',
];

/// A summary for an insight written before the model wrote one: the first
/// clause of the first sentence, without the name, shortened at a natural
/// break until it fits. Null when no break gets it under the limit, so the
/// row shows its tier instead of a clipped sentence.
String? deriveSummary(String text, {String? firstName}) {
  var s = firstSentence(text).replaceAll(RegExp(r'\s*\([^)]*\)'), '');
  final comma = s.indexOf(', ');
  if (comma >= 20) s = s.substring(0, comma);
  s = s.replaceFirst(RegExp(r'[.!?\s]+$'), '');
  var cleaned = cleanSummary(s, firstName: firstName);
  if (cleaned != null) return cleaned;
  // Over the limit: strip the name first so the cuts measure the real line.
  final name = firstName?.trim() ?? '';
  if (name.isNotEmpty) {
    s = s.replaceFirst(
        RegExp('^${RegExp.escape(name)}(?:[\'’]s)?\\s+', caseSensitive: false),
        '');
  }
  while (s.length > kSummaryMaxChars) {
    var at = -1;
    for (final cut in _cutBefore) {
      final i = s.lastIndexOf(cut);
      if (i >= 20 && i > at) at = i;
    }
    if (at < 0) return null;
    s = s.substring(0, at).replaceFirst(RegExp(r'[,\s]+$'), '');
  }
  return cleanSummary(s, firstName: firstName);
}

/// Builds the row's lead and meaning for one saved game.
///
/// [ageBand] is needed for the scoring-efficiency tier, which is age
/// relative; without it that tier simply does not exist, as on Game Detail.
GameRowMeaning buildGameRowMeaning({
  required int points,
  required int offReb,
  required int defReb,
  required int assists,
  required int steals,
  required int blocks,
  required int turnovers,
  required int fgAttempt,
  required int ftAttempt,
  GameInsight? insight,
  AgeBand? ageBand,
  String? playerFirstName,
}) {
  if (isZeroPerformance(
    points: points,
    offReb: offReb,
    defReb: defReb,
    assists: assists,
    steals: steals,
    blocks: blocks,
    turnovers: turnovers,
    fgAttempt: fgAttempt,
    ftAttempt: ftAttempt,
  )) {
    return GameRowMeaning.empty;
  }

  final rebounds = offReb + defReb;
  // In tie order: the first listed wins an equal count.
  final counts = <(int, String, String, String)>[
    (rebounds, 'REB', 'rebound', 'rebounds'),
    (assists, 'AST', 'assist', 'assists'),
    (steals, 'STL', 'steal', 'steals'),
    (blocks, 'BLK', 'block', 'blocks'),
  ];
  // Stable sort, so ties keep the order above.
  final ranked = counts.where((c) => c.$1 > 0).toList()
    ..sort((a, b) => b.$1.compareTo(a.$1));

  final GameRowLead? lead = points > 0
      ? GameRowLead('$points', 'PTS')
      : ranked.isEmpty
          ? null
          : GameRowLead('${ranked.first.$1}', ranked.first.$2);

  // 1. The insight's one-line summary: the model's, else one derived from
  // the text. Neither fitting falls through to the tier, never to a clip.
  if (insight != null && insight.hasText) {
    final summary =
        cleanSummary(insight.summary, firstName: playerFirstName) ??
            deriveSummary(insight.text!, firstName: playerFirstName);
    if (summary != null) {
      return GameRowMeaning(
        lead: lead,
        kind: GameRowMeaningKind.insight,
        text: summary,
      );
    }
  }

  // 2. The best tier, exactly as Game Detail rates this game. Only the
  // fields the ratings read are filled; buildGameDetail is used rather than
  // the tier functions directly so the gates (PPSA attempts, AST/TOV assists,
  // disruption minimum) and the skill names cannot drift from that screen.
  final rated = buildGameDetail(GameDetailRow(
    gameId: '',
    playerId: '',
    playerName: '',
    ageBand: ageBand,
    points: points,
    fgMade: 0,
    fgAttempt: fgAttempt,
    twoMade: 0,
    threeMade: 0,
    threeAttempt: 0,
    ftMade: 0,
    ftAttempt: ftAttempt,
    offReb: offReb,
    defReb: defReb,
    assists: assists,
    steals: steals,
    blocks: blocks,
    turnovers: turnovers,
  )).development;
  if (rated.isNotEmpty) {
    // Highest tier wins; on a tie the earlier row (Game Detail's order,
    // ppsa -> ast_tov -> disrupt) is kept because only a strictly higher
    // tier replaces it.
    var best = rated.first;
    for (final r in rated.skip(1)) {
      if (r.tier.index > best.tier.index) best = r;
    }
    return GameRowMeaning(
      lead: lead,
      kind: GameRowMeaningKind.tier,
      text: best.title,
      tier: best.tier,
    );
  }

  // 3. The standout counts.
  if (ranked.isNotEmpty) {
    return GameRowMeaning(
      lead: lead,
      kind: GameRowMeaningKind.stats,
      text: ranked
          .take(2)
          .map((c) => '${c.$1} ${c.$1 == 1 ? c.$3 : c.$4}')
          .join(', '),
    );
  }

  return GameRowMeaning(lead: lead, kind: GameRowMeaningKind.none);
}
