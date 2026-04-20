class PlayerInsight {
  PlayerInsight({
    required this.headline,
    required this.text,
    required this.whatsWorking,
    required this.needsDevelopment,
    required this.growthEdge,
    required this.trendDirection,
    required this.strengthFocus,
    required this.belowThreshold,
  });

  final String? headline;
  // Legacy v2 field. Kept so stale cache rows render gracefully during
  // the v2 → v3 transition. Preferred path is whatsWorking + needsDevelopment.
  final String? text;
  final String? whatsWorking;
  final String? needsDevelopment;
  final String? growthEdge;
  final String? trendDirection;
  final String? strengthFocus;
  final bool belowThreshold;

  bool get hasSplitNarrative =>
      (whatsWorking != null && whatsWorking!.trim().isNotEmpty) ||
      (needsDevelopment != null && needsDevelopment!.trim().isNotEmpty);

  static PlayerInsight fromJson(Map<String, dynamic> json) {
    return PlayerInsight(
      headline: json['headline'] as String?,
      text: json['text'] as String?,
      whatsWorking: json['whats_working'] as String?,
      needsDevelopment: json['needs_development'] as String?,
      growthEdge: json['growth_edge'] as String?,
      trendDirection: json['trend_direction'] as String?,
      strengthFocus: json['strength_focus'] as String?,
      belowThreshold: json['below_threshold'] == true,
    );
  }
}

class PlayerInsightResponse {
  PlayerInsightResponse({
    required this.insight,
    required this.cached,
    required this.gamesUntilUnlock,
  });

  final PlayerInsight insight;
  final bool cached;
  final int? gamesUntilUnlock;

  static PlayerInsightResponse fromJson(Map<String, dynamic> json) {
    final insightJson = Map<String, dynamic>.from(json['insight'] as Map);
    return PlayerInsightResponse(
      insight: PlayerInsight.fromJson(insightJson),
      cached: json['cached'] == true,
      gamesUntilUnlock: json['games_until_unlock'] as int?,
    );
  }
}
