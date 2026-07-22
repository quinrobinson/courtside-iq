// One game, for Game Detail — Phase 4.14
//
// Two reads, not one. `v_player_game_stats` has everything about the game and
// nothing about the player's age, and scoring efficiency is age-relative, so
// the band comes from `player_profile_view` alongside it.
//
// Adding age_band to v_player_game_stats would be the tidier query and the
// worse change: that view is read by Today, the profile and the Averages tab,
// so a column added to serve one screen is a change to all of them. The
// second read is by primary key and returns one row.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/game_detail_builder.dart';
import '/courtside_iq/metrics_config.dart';

class GameDetailRepository {
  const GameDetailRepository();

  /// Null when the game does not exist, or is not this user's.
  ///
  /// The user filter is belt and braces over RLS: a game id is guessable in a
  /// way a row is not, and this screen is reached by id from three places.
  Future<GameDetailRow?> load(String gameId) async {
    final uid = currentUserUid;
    if (uid.isEmpty || gameId.isEmpty) return null;

    final rows = await SupaFlow.client
        .from('v_player_game_stats')
        .select(
          'game_id, player_id, first_name, player_profile_pic, created_at, '
          'opponent_team, event_name, points, fg_made, fg_attempt, two_made, '
          'three_made, three_attempt, ft_made, ft_attempt, off_reb, def_reb, '
          'assist, steal, block, turnover, game_insights_json',
        )
        .eq('game_id', gameId)
        .eq('user_id', uid)
        .limit(1) as List;

    if (rows.isEmpty) return null;
    final r = rows.first as Map<String, dynamic>;

    final playerId = r['player_id'] as String? ?? '';
    final band = await _ageBand(playerId, uid);

    return GameDetailRow(
      gameId: r['game_id'] as String? ?? gameId,
      playerId: playerId,
      playerName: (r['first_name'] as String? ?? '').trim(),
      playerPhotoUrl: r['player_profile_pic'] as String?,
      opponent: r['opponent_team'] as String?,
      playedAt: DateTime.tryParse(r['created_at'] as String? ?? '')?.toLocal(),
      eventName: r['event_name'] as String?,
      ageBand: band,
      points: _int(r['points']),
      fgMade: _int(r['fg_made']),
      fgAttempt: _int(r['fg_attempt']),
      twoMade: _int(r['two_made']),
      threeMade: _int(r['three_made']),
      threeAttempt: _int(r['three_attempt']),
      ftMade: _int(r['ft_made']),
      ftAttempt: _int(r['ft_attempt']),
      offReb: _int(r['off_reb']),
      defReb: _int(r['def_reb']),
      assists: _int(r['assist']),
      steals: _int(r['steal']),
      blocks: _int(r['block']),
      turnovers: _int(r['turnover']),
      insight: _insight(r['game_insights_json']),
    );
  }

  /// Deletes the game. The stats row goes with it via ON DELETE CASCADE.
  Future<void> remove(String gameId) async {
    final uid = currentUserUid;
    if (uid.isEmpty || gameId.isEmpty) return;
    await SupaFlow.client
        .from('games')
        .delete()
        .eq('id', gameId)
        .eq('user_id', uid);
  }

  Future<AgeBand?> _ageBand(String playerId, String uid) async {
    if (playerId.isEmpty) return null;
    final rows = await SupaFlow.client
        .from('player_profile_view')
        .select('age_band')
        .eq('player_id', playerId)
        .eq('user_id', uid)
        .limit(1) as List;
    if (rows.isEmpty) return null;
    // Null for an unknown band since migration 20260721000000. Scoring
    // efficiency simply does not rate rather than being scored against an
    // assumed band.
    return ageBandFromString(rows.first['age_band'] as String?);
  }
}

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

GameInsight? _insight(Object? raw) {
  if (raw is! Map) return null;
  final text = raw['text'] as String?;
  final metric = raw['highlight_metric'] as String?;
  final tier = raw['tier_context'] as String?;
  if (text == null && metric == null) return null;
  return GameInsight(
    text: text,
    highlightMetric: metric,
    storedTier: tier,
  );
}
