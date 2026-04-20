import '../database.dart';

class VPlayerGameStatsTable extends SupabaseTable<VPlayerGameStatsRow> {
  @override
  String get tableName => 'v_player_game_stats';

  @override
  VPlayerGameStatsRow createRow(Map<String, dynamic> data) =>
      VPlayerGameStatsRow(data);
}

class VPlayerGameStatsRow extends SupabaseDataRow {
  VPlayerGameStatsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VPlayerGameStatsTable();

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String? get playerProfilePic => getField<String>('player_profile_pic');
  set playerProfilePic(String? value) =>
      setField<String>('player_profile_pic', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get gameId => getField<String>('game_id');
  set gameId(String? value) => setField<String>('game_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get opponentTeam => getField<String>('opponent_team');
  set opponentTeam(String? value) => setField<String>('opponent_team', value);

  String? get playerTeamName => getField<String>('player_team_name');
  set playerTeamName(String? value) =>
      setField<String>('player_team_name', value);

  String? get eventName => getField<String>('event_name');
  set eventName(String? value) => setField<String>('event_name', value);

  String? get eventType => getField<String>('event_type');
  set eventType(String? value) => setField<String>('event_type', value);

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

  String? get gameInsights {
    final raw = data['game_insights'];
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map) return raw['text']?.toString();
    return raw.toString();
  }
  set gameInsights(String? value) => setField<String>('game_insights', value);

  Map<String, dynamic>? get gameInsightsJson {
    final raw = data['game_insights'];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}
