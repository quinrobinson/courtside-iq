import '../database.dart';

class PlayerGameStatsTable extends SupabaseTable<PlayerGameStatsRow> {
  @override
  String get tableName => 'player_game_stats';

  @override
  PlayerGameStatsRow createRow(Map<String, dynamic> data) =>
      PlayerGameStatsRow(data);
}

class PlayerGameStatsRow extends SupabaseDataRow {
  PlayerGameStatsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayerGameStatsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get gameId => getField<String>('game_id')!;
  set gameId(String value) => setField<String>('game_id', value);

  String get playerId => getField<String>('player_id')!;
  set playerId(String value) => setField<String>('player_id', value);

  int? get points => getField<int>('points');
  set points(int? value) => setField<int>('points', value);

  int? get fgMade => getField<int>('fg_made');
  set fgMade(int? value) => setField<int>('fg_made', value);

  int? get fgAttempt => getField<int>('fg_attempt');
  set fgAttempt(int? value) => setField<int>('fg_attempt', value);

  int? get twoMade => getField<int>('two_made');
  set twoMade(int? value) => setField<int>('two_made', value);

  int? get twoAttempt => getField<int>('two_attempt');
  set twoAttempt(int? value) => setField<int>('two_attempt', value);

  int? get threeMade => getField<int>('three_made');
  set threeMade(int? value) => setField<int>('three_made', value);

  int? get threeAttempt => getField<int>('three_attempt');
  set threeAttempt(int? value) => setField<int>('three_attempt', value);

  int? get ftMade => getField<int>('ft_made');
  set ftMade(int? value) => setField<int>('ft_made', value);

  int? get ftAttempt => getField<int>('ft_attempt');
  set ftAttempt(int? value) => setField<int>('ft_attempt', value);

  int? get offReb => getField<int>('off_reb');
  set offReb(int? value) => setField<int>('off_reb', value);

  int? get defReb => getField<int>('def_reb');
  set defReb(int? value) => setField<int>('def_reb', value);

  int? get assist => getField<int>('assist');
  set assist(int? value) => setField<int>('assist', value);

  int? get steal => getField<int>('steal');
  set steal(int? value) => setField<int>('steal', value);

  int? get turnover => getField<int>('turnover');
  set turnover(int? value) => setField<int>('turnover', value);

  int? get block => getField<int>('block');
  set block(int? value) => setField<int>('block', value);

  int? get offFoul => getField<int>('off_foul');
  set offFoul(int? value) => setField<int>('off_foul', value);

  int? get defFoul => getField<int>('def_foul');
  set defFoul(int? value) => setField<int>('def_foul', value);
}
