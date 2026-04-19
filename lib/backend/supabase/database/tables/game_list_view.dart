import '../database.dart';

class GameListViewTable extends SupabaseTable<GameListViewRow> {
  @override
  String get tableName => 'game_list_view';

  @override
  GameListViewRow createRow(Map<String, dynamic> data) => GameListViewRow(data);
}

class GameListViewRow extends SupabaseDataRow {
  GameListViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GameListViewTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get opponentTeam => getField<String>('opponent_team');
  set opponentTeam(String? value) => setField<String>('opponent_team', value);

  bool? get gameLive => getField<bool>('game_live');
  set gameLive(bool? value) => setField<bool>('game_live', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);

  String? get playerTeamName => getField<String>('player_team_name');
  set playerTeamName(String? value) =>
      setField<String>('player_team_name', value);

  String? get eventName => getField<String>('event_name');
  set eventName(String? value) => setField<String>('event_name', value);
}
