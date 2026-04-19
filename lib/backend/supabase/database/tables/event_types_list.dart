import '../database.dart';

class EventTypesListTable extends SupabaseTable<EventTypesListRow> {
  @override
  String get tableName => 'event_types_list';

  @override
  EventTypesListRow createRow(Map<String, dynamic> data) =>
      EventTypesListRow(data);
}

class EventTypesListRow extends SupabaseDataRow {
  EventTypesListRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventTypesListTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);
}
