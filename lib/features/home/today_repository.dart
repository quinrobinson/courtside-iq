// Today repository — Phase 4.10a
//
// Fetch and map. Every derived number lives in lib/courtside_iq/ so it can be
// tested without a network; this file exists only to get rows out of Supabase
// and into those pure functions.
//
// TWO QUERIES FOR THE WHOLE SCREEN, and no per-player fan-out. Growth IQ needs
// each player's games in order, but `v_player_game_stats` already carries
// every player's games for the user, so one query serves all three players and
// the recent-games list at once.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/today_builder.dart';
import '/courtside_iq/today_snapshot.dart';
import 'widgets/game_feed_row.dart';

/// How many recent games Today lists, across all players.
///
/// Five, raised from production's three on 2026-07-20. A deliberate product
/// change, not an accident of the redesign.
const int kTodayRecentGamesLimit = 5;

class TodayData {
  const TodayData({
    required this.headerPlayers,
    required this.recentGames,
    required this.playerCount,
  });

  /// Already filtered to players with a Growth IQ, and ordered. **May be
  /// empty** even when [playerCount] is not: a player with too few games has
  /// no score to show.
  final List<TodaySnapshot> headerPlayers;

  final List<GameFeedEntry> recentGames;

  /// Every player the user has, including those absent from the header. This
  /// is what distinguishes "no players yet" from "players, but no games yet",
  /// which are different screens.
  final int playerCount;

  bool get hasNoPlayers => playerCount == 0;
}

class TodayRepository {
  const TodayRepository();

  Future<TodayData> load() async {
    final uid = currentUserUid;
    if (uid.isEmpty) {
      return const TodayData(
        headerPlayers: [],
        recentGames: [],
        playerCount: 0,
      );
    }

    final profileRows = await SupaFlow.client
        .from('player_profile_view')
        .select(
          'player_id, player_first_name, player_last_name, player_profile_pic, '
          'total_games, total_points, age_band',
        )
        .eq('user_id', uid) as List;

    if (profileRows.isEmpty) {
      return const TodayData(
        headerPlayers: [],
        recentGames: [],
        playerCount: 0,
      );
    }

    final gameRows = await SupaFlow.client
        .from('v_player_game_stats')
        .select(
          'player_id, game_id, created_at, first_name, last_name, '
          'player_profile_pic, opponent_team, points, fg_attempt, ft_attempt, '
          'off_reb, def_reb, assist, steal, turnover, block',
        )
        .eq('user_id', uid)
        .order('created_at', ascending: false) as List;

    final headlines = await _loadHeadlines(profileRows);

    final players = profileRows.map((r) {
      final pid = r['player_id'] as String? ?? '';
      return TodayPlayerRow(
        playerId: pid,
        firstName: r['player_first_name'] as String? ?? '',
        lastName: r['player_last_name'] as String?,
        profilePic: r['player_profile_pic'] as String?,
        totalGames: _int(r['total_games']),
        totalPoints: _int(r['total_points']),
        ageBand: r['age_band'] as String?,
        headline: headlines[pid],
      );
    }).toList();

    final games = gameRows.map(_toGameRow).toList();

    return TodayData(
      headerPlayers: headerSnapshots(
        buildTodaySnapshots(players: players, games: games),
      ),
      // Already newest-first from the query.
      recentGames:
          gameRows.take(kTodayRecentGamesLimit).map(_toFeedEntry).toList(),
      playerCount: players.length,
    );
  }

  Future<Map<String, String>> _loadHeadlines(List profileRows) async {
    final ids = profileRows
        .map<String>((r) => r['player_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) return const {};

    final rows = await SupaFlow.client
        .from('player_development_insights')
        .select('player_id, insight_json')
        .inFilter('player_id', ids)
        .order('created_at', ascending: false) as List;

    final out = <String, String>{};
    for (final r in rows) {
      final pid = r['player_id'] as String?;
      // Newest first, so the first row per player wins.
      if (pid == null || out.containsKey(pid)) continue;
      final raw = r['insight_json'];
      if (raw is Map) {
        final headline = raw['headline'];
        if (headline is String && headline.trim().isNotEmpty) {
          out[pid] = headline.trim();
        }
      }
    }
    return out;
  }

  static TodayGameRow _toGameRow(dynamic r) => TodayGameRow(
        playerId: r['player_id'] as String? ?? '',
        gameId: r['game_id'] as String? ?? '',
        createdAt: _date(r['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
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

  static GameFeedEntry _toFeedEntry(dynamic r) {
    final first = (r['first_name'] as String? ?? '').trim();
    final last = (r['last_name'] as String? ?? '').trim();
    return GameFeedEntry(
      gameId: r['game_id'] as String? ?? '',
      playerId: r['player_id'] as String? ?? '',
      playerName: [first, last].where((s) => s.isNotEmpty).join(' '),
      playerPhotoUrl: r['player_profile_pic'] as String?,
      opponent: r['opponent_team'] as String?,
      playedAt: _date(r['created_at']),
      points: _int(r['points']),
      // The frame shows one REB column; the data stores two.
      rebounds: _int(r['off_reb']) + _int(r['def_reb']),
      assists: _int(r['assist']),
      steals: _int(r['steal']),
      turnovers: _int(r['turnover']),
    );
  }

  /// Supabase returns bigint as int, but a view can hand back num or a string.
  /// A null here must read as zero rather than crash the screen.
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
