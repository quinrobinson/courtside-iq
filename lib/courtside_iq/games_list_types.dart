// Types for the games list — Phase 4.12
//
// Split from games_list_builder.dart so the pure logic can be tested without
// dragging in anything Flutter-shaped, and so the widget layer imports one
// thing rather than two.

import 'game_detail_builder.dart';
import 'metrics_config.dart';

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

  // What the row needs to say what the game meant (2026-09-29). See
  // game_row_meaning.dart.
  final int blocks;

  /// The offensive part of [rebounds].
  final int offRebounds;
  final int fgAttempt;
  final int ftAttempt;
  final GameInsight? insight;
  final AgeBand? ageBand;

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
    this.blocks = 0,
    this.offRebounds = 0,
    this.fgAttempt = 0,
    this.ftAttempt = 0,
    this.insight,
    this.ageBand,
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
