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
import '/courtside_iq/player_averages.dart';
import '/courtside_iq/players_list_builder.dart';
import '/courtside_iq/today_builder.dart' show TodayGameRow;
import '/features/home/widgets/game_feed_row.dart' show GameFeedEntry;

class PlayersRepository {
  const PlayersRepository();

  Future<List<PlayerListEntry>> load() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return const [];

    final profileRows = await SupaFlow.client
        .from('player_profile_view')
        .select(
          'player_id, player_first_name, player_last_name, player_profile_pic, '
          'player_position, age_band, birth_date, total_games, total_points, '
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
        // The BAND is never null - get_age_band assumes 11U-13U for a missing
        // birth date - so this is the only way to tell a known age from an
        // assumed one.
        hasBirthDate: r['birth_date'] != null,
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

  /// Per-game rows for ONE player, newest first.
  ///
  /// Returns the ROWS, not the folded averages: the Averages tab and Full
  /// Breakdown are two arrangements of exactly these numbers, and the profile
  /// folds them once rather than querying twice.
  ///
  /// A separate query rather than a wider [load]: the list needs six columns
  /// for every player, this needs thirteen for one. Widening the list query to
  /// serve a screen the parent may never open makes every Players load slower.
  Future<List<AveragesGameRow>> loadGameRows(String playerId) async {
    final rows = await SupaFlow.client
        .from('v_player_game_stats')
        .select(
          'points, off_reb, def_reb, assist, steal, block, turnover, '
          'fg_made, fg_attempt, three_made, three_attempt, ft_made, ft_attempt',
        )
        .eq('player_id', playerId)
        .order('created_at', ascending: false) as List;

    return rows
        .map((r) => AveragesGameRow(
              points: _int(r['points']),
              offReb: _int(r['off_reb']),
              defReb: _int(r['def_reb']),
              assist: _int(r['assist']),
              steal: _int(r['steal']),
              block: _int(r['block']),
              turnover: _int(r['turnover']),
              fgMade: _int(r['fg_made']),
              fgAttempt: _int(r['fg_attempt']),
              threeMade: _int(r['three_made']),
              threeAttempt: _int(r['three_attempt']),
              ftMade: _int(r['ft_made']),
              ftAttempt: _int(r['ft_attempt']),
            ))
        .toList();
  }

  /// The player's games, newest first, as feed rows.
  Future<List<GameFeedEntry>> loadGames(String playerId) async {
    final rows = await SupaFlow.client
        .from('v_player_game_stats')
        .select(
          'game_id, created_at, opponent_team, event_name, '
          'points, off_reb, def_reb, assist, steal, turnover',
        )
        .eq('player_id', playerId)
        .order('created_at', ascending: false) as List;

    return rows
        .map((r) => GameFeedEntry(
              gameId: r['game_id'] as String? ?? '',
              // Unused on this tab: showPlayer is false, so the row never
              // renders a name or an avatar.
              playerName: '',
              opponent: r['opponent_team'] as String?,
              playedAt: _date(r['created_at']),
              eventName: r['event_name'] as String?,
              points: _int(r['points']),
              rebounds: _int(r['off_reb']) + _int(r['def_reb']),
              assists: _int(r['assist']),
              steals: _int(r['steal']),
              turnovers: _int(r['turnover']),
            ))
        .toList();
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
