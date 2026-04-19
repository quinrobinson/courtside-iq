import '../database.dart';

class PlayerGameInsightsTable extends SupabaseTable<PlayerGameInsightsRow> {
  @override
  String get tableName => 'player_game_insights';

  @override
  PlayerGameInsightsRow createRow(Map<String, dynamic> data) =>
      PlayerGameInsightsRow(data);
}

class PlayerGameInsightsRow extends SupabaseDataRow {
  PlayerGameInsightsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayerGameInsightsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get gameId => getField<String>('game_id')!;
  set gameId(String value) => setField<String>('game_id', value);

  String? get gameInsights => getField<String>('game_insights');
  set gameInsights(String? value) => setField<String>('game_insights', value);

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);
}
