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

/// The screen's whole data set: the roster the chips come from, and the games
/// the rows come from.
///
/// Both, because they are not the same thing. A player with no games still
/// gets a chip - see playerOptions.
class GamesData {
  final List<GameRosterEntry> roster;
  final List<GameListRow> games;

  const GamesData({required this.roster, required this.games});
}

class GamesRepository {
  const GamesRepository();

  Future<GamesData> load() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return const GamesData(roster: [], games: []);

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

    // Live games, by id. A SEPARATE query rather than altering
    // v_player_game_stats: that view is read by Today, the profile and the
    // Averages tab, and adding a column to serve one screen is a change to
    // all of them. There is at most one live game, so this is a tiny read.
    final liveRows = await SupaFlow.client
        .from('games')
        .select('id')
        .eq('user_id', uid)
        .eq('game_live', true) as List;
    final liveIds = {
      for (final r in liveRows) r['id'] as String?,
    }..removeWhere((id) => id == null);

    final names = <String, String>{};
    final photos = <String, String?>{};
    final roster = <GameRosterEntry>[];
    for (final r in profileRows) {
      final id = r['player_id'] as String?;
      if (id == null) continue;
      final name = r['player_first_name'] as String? ?? '';
      names[id] = name;
      photos[id] = r['player_profile_pic'] as String?;
      roster.add(GameRosterEntry(playerId: id, firstName: name));
    }

    final games = gameRows.map((r) {
      final playerId = r['player_id'] as String? ?? '';
      final gameId = r['game_id'] as String? ?? '';
      return GameListRow(
        gameId: gameId,
        playerId: playerId,
        isLive: liveIds.contains(gameId),
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

    return GamesData(roster: roster, games: games);
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
