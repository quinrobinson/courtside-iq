import '../database.dart';

class PlayerTeamsTable extends SupabaseTable<PlayerTeamsRow> {
  @override
  String get tableName => 'player_teams';

  @override
  PlayerTeamsRow createRow(Map<String, dynamic> data) => PlayerTeamsRow(data);
}

class PlayerTeamsRow extends SupabaseDataRow {
  PlayerTeamsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayerTeamsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get teamName => getField<String>('team_name');
  set teamName(String? value) => setField<String>('team_name', value);

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);
}
