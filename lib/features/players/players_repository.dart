// Players repository — Phase 4.11a
//
// Fetch and map. Every derived number - averages, Growth IQ - lives in
// lib/courtside_iq/ where it is tested without a network; this file only pulls
// rows and hands them to buildPlayerList.
//
// Two queries, the same pair Today uses: the profile view for identity and
// totals, and v_player_game_stats for the per-game rows Growth IQ needs.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/players_list_builder.dart';
import '/courtside_iq/today_builder.dart' show TodayGameRow;

class PlayersRepository {
  const PlayersRepository();

  Future<List<PlayerListEntry>> load() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return const [];

    final profileRows = await SupaFlow.client
        .from('player_profile_view')
        .select(
          'player_id, player_first_name, player_last_name, player_profile_pic, '
          'player_position, age_band, total_games, total_points, '
          'total_off_reb, total_def_reb, total_assist',
        )
        .eq('user_id', uid) as List;

    if (profileRows.isEmpty) return const [];

    final gameRows = await SupaFlow.client
        .from('v_player_game_stats')
        .select(
          'player_id, game_id, created_at, points, fg_attempt, ft_attempt, '
          'off_reb, def_reb, assist, steal, turnover, block',
        )
        .eq('user_id', uid)
        .order('created_at', ascending: false) as List;

    final players = profileRows.map((r) {
      return PlayerListPlayerRow(
        playerId: r['player_id'] as String? ?? '',
        firstName: r['player_first_name'] as String? ?? '',
        lastName: r['player_last_name'] as String?,
        profilePic: r['player_profile_pic'] as String?,
        position: r['player_position'] as String?,
        ageBand: r['age_band'] as String?,
        totalGames: _int(r['total_games']),
        totalPoints: _int(r['total_points']),
        totalRebounds: _int(r['total_off_reb']) + _int(r['total_def_reb']),
        totalAssists: _int(r['total_assist']),
      );
    }).toList();

    final games = gameRows.map(_toGameRow).toList();

    final entries = buildPlayerList(players: players, games: games);
    // Players with a Growth IQ first, then most games - so the parent lands on
    // their most-developed player rather than on whoever sorts first.
    entries.sort((a, b) {
      final byGrowth = (b.hasGrowthIq ? 1 : 0) - (a.hasGrowthIq ? 1 : 0);
      if (byGrowth != 0) return byGrowth;
      return b.totalGames.compareTo(a.totalGames);
    });
    return entries;
  }

  static TodayGameRow _toGameRow(dynamic r) => TodayGameRow(
        playerId: r['player_id'] as String? ?? '',
        gameId: r['game_id'] as String? ?? '',
        createdAt:
            _date(r['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        points: _int(r['points']),
        fgAttempt: _int(r['fg_attempt']),
        ftAttempt: _int(r['ft_attempt']),
        offReb: _int(r['off_reb']),
        defReb: _int(r['def_reb']),
        assist: _int(r['assist']),
        steal: _int(r['steal']),
        turnover: _int(r['turnover']),
        block: _int(r['block']),
      );

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
