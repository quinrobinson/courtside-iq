import '../database.dart';

class PlayersTable extends SupabaseTable<PlayersRow> {
  @override
  String get tableName => 'players';

  @override
  PlayersRow createRow(Map<String, dynamic> data) => PlayersRow(data);
}

class PlayersRow extends SupabaseDataRow {
  PlayersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayersTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get firstName => getField<String>('first_name')!;
  set firstName(String value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String get playerPosition => getField<String>('player_position')!;
  set playerPosition(String value) =>
      setField<String>('player_position', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get teamName => getField<String>('team_name');
  set teamName(String? value) => setField<String>('team_name', value);

  String? get playerProfilePic => getField<String>('player_profile_pic');
  set playerProfilePic(String? value) =>
      setField<String>('player_profile_pic', value);
}
