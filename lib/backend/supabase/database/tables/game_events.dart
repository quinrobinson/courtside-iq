import '../database.dart';

class GameEventsTable extends SupabaseTable<GameEventsRow> {
  @override
  String get tableName => 'game_events';

  @override
  GameEventsRow createRow(Map<String, dynamic> data) => GameEventsRow(data);
}

class GameEventsRow extends SupabaseDataRow {
  GameEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GameEventsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get eventName => getField<String>('event_name');
  set eventName(String? value) => setField<String>('event_name', value);

  String? get eventType => getField<String>('event_type');
  set eventType(String? value) => setField<String>('event_type', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);
}
