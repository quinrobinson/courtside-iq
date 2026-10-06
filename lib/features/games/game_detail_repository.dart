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
import '/courtside_iq/stat_event.dart';

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
    final events = await _events(gameId);

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
      insight: parseGameInsight(r['game_insights_json']),
      events: events,
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

  /// The game's plays, in order. Empty for any game logged before stat_events
  /// shipped, which is most of them.
  ///
  /// NEVER THROWS. The timeline is additive - the aggregates above are what
  /// this screen is actually for - so a failure here costs the timeline and
  /// nothing else. Letting it propagate would turn a missing extra into a
  /// screen that will not open.
  ///
  /// Voided rows are fetched rather than filtered in SQL, because the widget
  /// needs them to renumber correctly: the display index counts confirmed
  /// plays, and it can only do that if it knows which were voided.
  Future<List<StatEvent>> _events(String gameId) async {
    try {
      final rows = await SupaFlow.client
          .from('stat_events')
          .select('event_type, sequence_no, recorded_at, status')
          .eq('game_id', gameId)
          .order('sequence_no') as List;

      return [
        for (final raw in rows)
          if (raw is Map<String, dynamic>) ?_event(raw),
      ];
    } catch (_) {
      return const [];
    }
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

/// Null for a row this build cannot read.
///
/// Video may eventually write event types with no stat equivalent. Those carry
/// no stat weight, so skipping them is correct rather than defensive.
StatEvent? _event(Map<String, dynamic> r) {
  final stat = kStatFromEventType[r['event_type'] as String? ?? ''];
  final seq = (r['sequence_no'] as num?)?.toInt();
  final at = DateTime.tryParse(r['recorded_at'] as String? ?? '');
  if (stat == null || seq == null || at == null) return null;
  return StatEvent(
    sequenceNo: seq,
    stat: stat,
    recordedAt: at.toLocal(),
    // Anything that is not explicitly confirmed is treated as not counting.
    // 'suggested' and 'dismissed' are video states no tracker tap produces,
    // and neither should reach a rollup or the screen.
    status: r['status'] == 'confirmed'
        ? StatEventStatus.confirmed
        : StatEventStatus.voided,
  );
}
