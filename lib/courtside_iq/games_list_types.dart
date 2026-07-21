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

  /// Still being tracked. At most one game is live at a time.
  final bool isLive;

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
    this.isLive = false,
  });
}

/// A filter chip: what it shows, and what it selects.
class GameFilterOption {
  /// Empty means "all".
  final String id;
  final String label;

  const GameFilterOption({required this.id, required this.label});
}

/// A player who can be filtered to, whether or not they have games.
///
/// Kept separate from [GameListRow] because the chips come from the roster
/// and the rows come from the games - conflating them is what hid a player
/// with no games from their own filter.
class GameRosterEntry {
  final String playerId;
  final String firstName;

  const GameRosterEntry({required this.playerId, required this.firstName});
}
