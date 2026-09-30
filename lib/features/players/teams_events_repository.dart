// Teams and events — Phase 4.11d
//
// The pick-lists behind logging a game. `player_teams` fills
// `games.player_team_name`, `game_events` fills `games.event_name`.
//
// BOTH OF THOSE COLUMNS ARE DENORMALISED TEXT. Removing a team here changes
// what a parent can PICK next time and nothing else - every past game keeps
// the label it was logged with. That is why there is no rename: it would look
// like it rewrote history and it would not.
//
// Both tables carry user_id as well as player_id. It is written on insert so
// the rows match the ownership pattern the rest of the schema uses.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/event_types.dart';

class PlayerTeam {
  final int id;
  final String name;

  const PlayerTeam({required this.id, required this.name});
}

class PlayerEvent {
  final int id;
  final String name;

  /// Null when the stored value is absent or unrecognised. The row still
  /// renders; it just shows no type rather than a guessed one.
  final EventType? type;

  const PlayerEvent({required this.id, required this.name, this.type});
}

class TeamsEventsRepository {
  const TeamsEventsRepository();

  Future<List<PlayerTeam>> loadTeams(String playerId) async {
    final rows = await SupaFlow.client
        .from('player_teams')
        .select('id, team_name')
        .eq('player_id', playerId)
        .order('team_name') as List;

    return rows
        .map((r) => PlayerTeam(
              id: (r['id'] as num).toInt(),
              name: (r['team_name'] as String?)?.trim() ?? '',
            ))
        .where((t) => t.name.isNotEmpty)
        .toList();
  }

  Future<void> addTeam(String playerId, String name) async {
    await SupaFlow.client.from('player_teams').insert({
      'player_id': playerId,
      'user_id': currentUserUid,
      'team_name': name.trim(),
    });
  }

  Future<void> removeTeam(int id) async {
    await SupaFlow.client.from('player_teams').delete().eq('id', id);
  }

  Future<List<PlayerEvent>> loadEvents(String playerId) async {
    final rows = await SupaFlow.client
        .from('game_events')
        .select('id, event_name, event_type')
        .eq('player_id', playerId)
        .order('event_name') as List;

    return rows
        .map((r) => PlayerEvent(
              id: (r['id'] as num).toInt(),
              name: (r['event_name'] as String?)?.trim() ?? '',
              type: eventTypeFromStored(r['event_type'] as String?),
            ))
        .where((e) => e.name.isNotEmpty)
        .toList();
  }

  Future<void> addEvent(String playerId, String name, EventType type) async {
    await SupaFlow.client.from('game_events').insert({
      'player_id': playerId,
      'user_id': currentUserUid,
      'event_name': name.trim(),
      // The STORED vocabulary, not the label. See event_types.dart.
      'event_type': type.stored,
    });
  }

  Future<void> removeEvent(int id) async {
    await SupaFlow.client.from('game_events').delete().eq('id', id);
  }
}
