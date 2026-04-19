import '../database.dart';

class PlayerListViewTable extends SupabaseTable<PlayerListViewRow> {
  @override
  String get tableName => 'player_list_view';

  @override
  PlayerListViewRow createRow(Map<String, dynamic> data) =>
      PlayerListViewRow(data);
}

class PlayerListViewRow extends SupabaseDataRow {
  PlayerListViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayerListViewTable();

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get playerName => getField<String>('player_name');
  set playerName(String? value) => setField<String>('player_name', value);

  String? get playerProfilePic => getField<String>('player_profile_pic');
  set playerProfilePic(String? value) =>
      setField<String>('player_profile_pic', value);
}
