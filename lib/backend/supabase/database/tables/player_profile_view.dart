import '../database.dart';

class PlayerProfileViewTable extends SupabaseTable<PlayerProfileViewRow> {
  @override
  String get tableName => 'player_profile_view';

  @override
  PlayerProfileViewRow createRow(Map<String, dynamic> data) =>
      PlayerProfileViewRow(data);
}

class PlayerProfileViewRow extends SupabaseDataRow {
  PlayerProfileViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlayerProfileViewTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get playerId => getField<String>('player_id');
  set playerId(String? value) => setField<String>('player_id', value);

  String? get playerFirstName => getField<String>('player_first_name');
  set playerFirstName(String? value) =>
      setField<String>('player_first_name', value);

  String? get playerLastName => getField<String>('player_last_name');
  set playerLastName(String? value) =>
      setField<String>('player_last_name', value);

  String? get playerPosition => getField<String>('player_position');
  set playerPosition(String? value) =>
      setField<String>('player_position', value);

  String? get teamName => getField<String>('team_name');
  set teamName(String? value) => setField<String>('team_name', value);

  String? get playerProfilePic => getField<String>('player_profile_pic');
  set playerProfilePic(String? value) =>
      setField<String>('player_profile_pic', value);

  int? get totalPoints => getField<int>('total_points');
  set totalPoints(int? value) => setField<int>('total_points', value);

  int? get totalFgMade => getField<int>('total_fg_made');
  set totalFgMade(int? value) => setField<int>('total_fg_made', value);

  int? get totalFgAttempt => getField<int>('total_fg_attempt');
  set totalFgAttempt(int? value) => setField<int>('total_fg_attempt', value);

  int? get totalTwoMade => getField<int>('total_two_made');
  set totalTwoMade(int? value) => setField<int>('total_two_made', value);

  int? get totalTwoAttempt => getField<int>('total_two_attempt');
  set totalTwoAttempt(int? value) => setField<int>('total_two_attempt', value);

  int? get totalThreeMade => getField<int>('total_three_made');
  set totalThreeMade(int? value) => setField<int>('total_three_made', value);

  int? get totalThreeAttempt => getField<int>('total_three_attempt');
  set totalThreeAttempt(int? value) =>
      setField<int>('total_three_attempt', value);

  int? get totalFtMade => getField<int>('total_ft_made');
  set totalFtMade(int? value) => setField<int>('total_ft_made', value);

  int? get totalFtAttempt => getField<int>('total_ft_attempt');
  set totalFtAttempt(int? value) => setField<int>('total_ft_attempt', value);

  int? get totalOffReb => getField<int>('total_off_reb');
  set totalOffReb(int? value) => setField<int>('total_off_reb', value);

  int? get totalDefReb => getField<int>('total_def_reb');
  set totalDefReb(int? value) => setField<int>('total_def_reb', value);

  int? get totalAssist => getField<int>('total_assist');
  set totalAssist(int? value) => setField<int>('total_assist', value);

  int? get totalSteal => getField<int>('total_steal');
  set totalSteal(int? value) => setField<int>('total_steal', value);

  int? get totalTurnover => getField<int>('total_turnover');
  set totalTurnover(int? value) => setField<int>('total_turnover', value);

  int? get totalBlock => getField<int>('total_block');
  set totalBlock(int? value) => setField<int>('total_block', value);

  int? get totalOffFoul => getField<int>('total_off_foul');
  set totalOffFoul(int? value) => setField<int>('total_off_foul', value);

  int? get totalDefFoul => getField<int>('total_def_foul');
  set totalDefFoul(int? value) => setField<int>('total_def_foul', value);

  int? get totalGames => getField<int>('total_games');
  set totalGames(int? value) => setField<int>('total_games', value);

  DateTime? get birthDate => getField<DateTime>('birth_date');
  set birthDate(DateTime? value) => setField<DateTime>('birth_date', value);

  String? get ageBand => getField<String>('age_band');
  set ageBand(String? value) => setField<String>('age_band', value);
}
