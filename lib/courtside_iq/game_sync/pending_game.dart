// A game that finished but has not yet reached Supabase — Phase 4.5.
//
// Live tracking itself is already safe: every stat tap writes through to
// FlutterSecureStorage, so a crash or dead battery mid-game loses nothing.
// The gap is the SAVE at the end, which fires two inserts back to back with
// no retry. In a gym with no signal that is the whole game, gone.
//
// Pure Dart. No Flutter, no Supabase imports — so it is testable and survives
// the 2.0 rebuild that deletes the FlutterFlow tracker screen.

import 'dart:convert';

/// One completed game awaiting upload: the game row and its stats row.
///
/// Both carry client-generated ids. That is what makes retrying safe — the
/// upload upserts by primary key, so the same PendingGame can be sent five
/// times and still produce exactly one game and one stats row. Without
/// client ids, a retry after a timeout that actually succeeded would create a
/// duplicate game, which is worse than the failure it was retrying.
class PendingGame {
  /// Client-generated uuid for public.games.id
  final String gameId;

  /// Client-generated uuid for public.player_game_stats.id
  final String statsId;

  /// Column/value map for public.games
  final Map<String, dynamic> gameRow;

  /// Column/value map for public.player_game_stats (game_id already set)
  final Map<String, dynamic> statsRow;

  /// When the parent tapped save, not when we managed to upload.
  final DateTime queuedAt;

  /// Upload attempts so far. Used for backoff and to surface a stuck game
  /// rather than retrying invisibly forever.
  final int attempts;

  /// Last failure, kept for diagnosis. Never shown raw to a parent.
  final String? lastError;

  const PendingGame({
    required this.gameId,
    required this.statsId,
    required this.gameRow,
    required this.statsRow,
    required this.queuedAt,
    this.attempts = 0,
    this.lastError,
  });

  PendingGame copyWith({int? attempts, String? lastError}) => PendingGame(
        gameId: gameId,
        statsId: statsId,
        gameRow: gameRow,
        statsRow: statsRow,
        queuedAt: queuedAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError ?? this.lastError,
      );

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'statsId': statsId,
        'gameRow': gameRow,
        'statsRow': statsRow,
        'queuedAt': queuedAt.toIso8601String(),
        'attempts': attempts,
        'lastError': lastError,
      };

  static PendingGame fromJson(Map<String, dynamic> j) => PendingGame(
        gameId: j['gameId'] as String,
        statsId: j['statsId'] as String,
        gameRow: Map<String, dynamic>.from(j['gameRow'] as Map),
        statsRow: Map<String, dynamic>.from(j['statsRow'] as Map),
        queuedAt:
            DateTime.tryParse(j['queuedAt'] as String? ?? '') ?? DateTime.now(),
        attempts: (j['attempts'] as num?)?.toInt() ?? 0,
        lastError: j['lastError'] as String?,
      );

  static String encodeList(List<PendingGame> games) =>
      jsonEncode(games.map((g) => g.toJson()).toList());

  /// Decodes defensively: a single corrupt entry must not take the whole queue
  /// down with it, because the queue is the only copy of that game.
  static List<PendingGame> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <PendingGame>[];
      for (final entry in decoded) {
        try {
          if (entry is Map) {
            out.add(PendingGame.fromJson(Map<String, dynamic>.from(entry)));
          }
        } catch (_) {
          // Skip the bad entry, keep the rest.
        }
      }
      return out;
    } catch (_) {
      return const [];
    }
  }
}
