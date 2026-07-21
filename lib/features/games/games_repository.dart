// Games repository — Phase 4.12
//
// Every game the signed-in parent has logged, across all their players,
// NEWEST FIRST.
//
// The v1 list ordered created_at ASCENDING, so it opened on the oldest game
// ever logged and a parent had to scroll to reach last night's. That is fixed
// here rather than carried over.
//
// Two queries, the same shape the Players list uses: the profile view for
// names and photos, and v_player_game_stats for the games. The view does not
// carry a player name, so the join happens here.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/games_list_builder.dart';

class GamesRepository {
  const GamesRepository();

  Future<List<GameListRow>> load() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return const [];

    final profileRows = await SupaFlow.client
        .from('player_profile_view')
        .select('player_id, player_first_name, player_profile_pic')
        .eq('user_id', uid) as List;

    final gameRows = await SupaFlow.client
        .from('v_player_game_stats')
        .select(
          'game_id, player_id, created_at, opponent_team, '
          'points, off_reb, def_reb, assist, steal, turnover',
        )
        .eq('user_id', uid)
        .order('created_at', ascending: false) as List;

    final names = <String, String>{};
    final photos = <String, String?>{};
    for (final r in profileRows) {
      final id = r['player_id'] as String?;
      if (id == null) continue;
      names[id] = r['player_first_name'] as String? ?? '';
      photos[id] = r['player_profile_pic'] as String?;
    }

    return gameRows.map((r) {
      final playerId = r['player_id'] as String? ?? '';
      return GameListRow(
        gameId: r['game_id'] as String? ?? '',
        playerId: playerId,
        // Falls back to empty rather than a placeholder like "Unknown": the
        // row renders an avatar and a name, and inventing one would put a
        // word on screen that names no real child.
        playerName: names[playerId] ?? '',
        playerPhotoUrl: photos[playerId],
        opponent: r['opponent_team'] as String?,
        playedAt: _date(r['created_at']),
        points: _int(r['points']),
        rebounds: _int(r['off_reb']) + _int(r['def_reb']),
        assists: _int(r['assist']),
        steals: _int(r['steal']),
        turnovers: _int(r['turnover']),
      );
    }).toList();
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _date(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
