// Live game persistence — Phase 4.13
//
// WRITE-THROUGH ON EVERY TAP. This is the property that made v1's tracking
// safe, and it is not optional: a parent tracks a whole game on a phone that
// can be dropped, killed by iOS, or run flat, and a game cannot be tracked
// twice. 4.5 confirmed the v1 behaviour was already right here - the gap was
// only the final save - so the rebuild keeps it.
//
// SharedPreferences, not secure storage. v1 used FlutterSecureStorage through
// FFAppState, which is for secrets; a child's rebound count is not one, and
// the encrypted store is slower on a path that runs on every single tap.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '/courtside_iq/live_game.dart';

/// A game in progress, as stored.
class LiveGameSnapshot {
  final String playerId;
  final String playerName;
  final String? team;
  final String? opponent;
  final String? event;
  final LiveGameStats stats;
  final DateTime startedAt;

  const LiveGameSnapshot({
    required this.playerId,
    required this.playerName,
    required this.stats,
    required this.startedAt,
    this.team,
    this.opponent,
    this.event,
  });

  LiveGameSnapshot withStats(LiveGameStats next) => LiveGameSnapshot(
        playerId: playerId,
        playerName: playerName,
        team: team,
        opponent: opponent,
        event: event,
        stats: next,
        startedAt: startedAt,
      );

  Map<String, dynamic> toJson() => {
        'player_id': playerId,
        'player_name': playerName,
        'team': team,
        'opponent': opponent,
        'event': event,
        'started_at': startedAt.toIso8601String(),
        'stats': stats.toJson(),
      };

  static LiveGameSnapshot? fromJson(Map<String, dynamic> json) {
    final playerId = json['player_id'] as String?;
    if (playerId == null || playerId.isEmpty) return null;
    final rawStats = json['stats'];
    return LiveGameSnapshot(
      playerId: playerId,
      playerName: json['player_name'] as String? ?? '',
      team: json['team'] as String?,
      opponent: json['opponent'] as String?,
      event: json['event'] as String?,
      startedAt:
          DateTime.tryParse(json['started_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      stats: rawStats is Map
          ? LiveGameStats.fromJson(Map<String, dynamic>.from(rawStats))
          : const LiveGameStats(),
    );
  }
}

class LiveGameStore {
  const LiveGameStore();

  static const _key = 'live_game_v2';

  /// Saves the whole snapshot. Called after EVERY tap.
  Future<void> save(LiveGameSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }

  /// The game in progress, or null.
  ///
  /// A corrupt value returns null rather than throwing: a parent opening the
  /// app should get a working screen, not a crash, and the worst case is one
  /// lost game rather than an app that cannot start.
  Future<LiveGameSnapshot?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return LiveGameSnapshot.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Cleared only once the game has been saved or deliberately discarded.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
