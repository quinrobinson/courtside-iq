import '../database.dart';

class FeedbackTable extends SupabaseTable<FeedbackRow> {
  @override
  String get tableName => 'feedback';

  @override
  FeedbackRow createRow(Map<String, dynamic> data) => FeedbackRow(data);
}

class FeedbackRow extends SupabaseDataRow {
  FeedbackRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FeedbackTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get rating => getField<String>('rating');
  set rating(String? value) => setField<String>('rating', value);

  String? get feedback => getField<String>('feedback');
  set feedback(String? value) => setField<String>('feedback', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);
}
