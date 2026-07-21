// Types for the games list — Phase 4.12
//
// Split from games_list_builder.dart so the pure logic can be tested without
// dragging in anything Flutter-shaped, and so the widget layer imports one
// thing rather than two.

/// One logged game, reduced to what the list needs.
class GameListRow {
  final String gameId;
  final String playerId;
  final String playerName;
  final String? playerPhotoUrl;

  final String? opponent;
  final DateTime? playedAt;

  final int points;
  final int rebounds;
  final int assists;
  final int steals;
  final int turnovers;

  const GameListRow({
    required this.gameId,
    required this.playerId,
    required this.playerName,
    this.playerPhotoUrl,
    this.opponent,
    this.playedAt,
    this.points = 0,
    this.rebounds = 0,
    this.assists = 0,
    this.steals = 0,
    this.turnovers = 0,
  });
}

/// A filter chip: what it shows, and what it selects.
class GameFilterOption {
  /// Empty means "all".
  final String id;
  final String label;

  const GameFilterOption({required this.id, required this.label});
}
