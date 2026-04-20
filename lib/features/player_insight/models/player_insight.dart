class PlayerInsight {
  PlayerInsight({
    required this.headline,
    required this.text,
    required this.growthEdge,
    required this.trendDirection,
    required this.strengthFocus,
    required this.belowThreshold,
  });

  final String? headline;
  final String? text;
  final String? growthEdge;
  final String? trendDirection;
  final String? strengthFocus;
  final bool belowThreshold;

  static PlayerInsight fromJson(Map<String, dynamic> json) {
    return PlayerInsight(
      headline: json['headline'] as String?,
      text: json['text'] as String?,
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
