import '../database.dart';

class PlayerPositionsListTable extends SupabaseTable<PlayerPositionsListRow> {
  @override
  String get tableName => 'player_positions_list';

  @override
  PlayerPositionsListRow createRow(Map<String, dynamic> data) =>
      PlayerPositionsListRow(data);
}

class PlayerPositionsListRow extends SupabaseDataRow {
  PlayerPositionsListRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayerPositionsListTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get positionName => getField<String>('position_name');
  set positionName(String? value) => setField<String>('position_name', value);
}
