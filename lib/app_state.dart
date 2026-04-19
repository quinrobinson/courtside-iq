import 'package:flutter/material.dart';
import 'package:ff_commons/api_requests/api_manager.dart';
import 'backend/supabase/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _liveGameStatus =
          await secureStorage.getBool('ff_liveGameStatus') ?? _liveGameStatus;
    });
    await _safeInitAsync(() async {
      _liveGameID =
          await secureStorage.getString('ff_liveGameID') ?? _liveGameID;
    });
    await _safeInitAsync(() async {
      _livePlayerID =
          await secureStorage.getString('ff_livePlayerID') ?? _livePlayerID;
    });
    await _safeInitAsync(() async {
      _liveName = await secureStorage.getString('ff_liveName') ?? _liveName;
    });
    await _safeInitAsync(() async {
      _liveOppTeam =
          await secureStorage.getString('ff_liveOppTeam') ?? _liveOppTeam;
    });
    await _safeInitAsync(() async {
      _liveFgMade = await secureStorage.getInt('ff_liveFgMade') ?? _liveFgMade;
    });
    await _safeInitAsync(() async {
      _liveFgAttempt =
          await secureStorage.getInt('ff_liveFgAttempt') ?? _liveFgAttempt;
    });
    await _safeInitAsync(() async {
      _liveTwoMade =
          await secureStorage.getInt('ff_liveTwoMade') ?? _liveTwoMade;
    });
    await _safeInitAsync(() async {
      _liveTwoAttempt =
          await secureStorage.getInt('ff_liveTwoAttempt') ?? _liveTwoAttempt;
    });
    await _safeInitAsync(() async {
      _liveThreeMade =
          await secureStorage.getInt('ff_liveThreeMade') ?? _liveThreeMade;
    });
    await _safeInitAsync(() async {
      _liveThreeAttempt = await secureStorage.getInt('ff_liveThreeAttempt') ??
          _liveThreeAttempt;
    });
    await _safeInitAsync(() async {
      _liveFtMade = await secureStorage.getInt('ff_liveFtMade') ?? _liveFtMade;
    });
    await _safeInitAsync(() async {
      _liveFtAttempt =
          await secureStorage.getInt('ff_liveFtAttempt') ?? _liveFtAttempt;
    });
    await _safeInitAsync(() async {
      _liveMissedTwo =
          await secureStorage.getInt('ff_liveMissedTwo') ?? _liveMissedTwo;
    });
    await _safeInitAsync(() async {
      _liveMissedThree =
          await secureStorage.getInt('ff_liveMissedThree') ?? _liveMissedThree;
    });
    await _safeInitAsync(() async {
      _liveMissedOne =
          await secureStorage.getInt('ff_liveMissedOne') ?? _liveMissedOne;
    });
    await _safeInitAsync(() async {
      _livePoints = await secureStorage.getInt('ff_livePoints') ?? _livePoints;
    });
    await _safeInitAsync(() async {
      _liveOffReb = await secureStorage.getInt('ff_liveOffReb') ?? _liveOffReb;
    });
    await _safeInitAsync(() async {
      _liveDefReb = await secureStorage.getInt('ff_liveDefReb') ?? _liveDefReb;
    });
    await _safeInitAsync(() async {
      _liveAssist = await secureStorage.getInt('ff_liveAssist') ?? _liveAssist;
    });
    await _safeInitAsync(() async {
      _liveSteals = await secureStorage.getInt('ff_liveSteals') ?? _liveSteals;
    });
    await _safeInitAsync(() async {
      _liveBlocks = await secureStorage.getInt('ff_liveBlocks') ?? _liveBlocks;
    });
    await _safeInitAsync(() async {
      _liveOffFoul =
          await secureStorage.getInt('ff_liveOffFoul') ?? _liveOffFoul;
    });
    await _safeInitAsync(() async {
      _liveDefFoul =
          await secureStorage.getInt('ff_liveDefFoul') ?? _liveDefFoul;
    });
    await _safeInitAsync(() async {
      _liveTurnover =
          await secureStorage.getInt('ff_liveTurnover') ?? _liveTurnover;
    });
    await _safeInitAsync(() async {
      _ratingDone = await secureStorage.getBool('ff_ratingDone') ?? _ratingDone;
    });
    await _safeInitAsync(() async {
      _ratingDelayed =
          await secureStorage.getBool('ff_ratingDelayed') ?? _ratingDelayed;
    });
    await _safeInitAsync(() async {
      _ratingDate = await secureStorage.read(key: 'ff_ratingDate') != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (await secureStorage.getInt('ff_ratingDate'))!)
          : _ratingDate;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _userName = '';
  String get userName => _userName;
  set userName(String value) {
    _userName = value;
  }

  String _revenueCatUserId = '';
  String get revenueCatUserId => _revenueCatUserId;
  set revenueCatUserId(String value) {
    _revenueCatUserId = value;
  }

  bool _isUserPremium = false;
  bool get isUserPremium => _isUserPremium;
  set isUserPremium(bool value) {
    _isUserPremium = value;
  }

  String _msg = '';
  String get msg => _msg;
  set msg(String value) {
    _msg = value;
  }

  bool _showsnackbard = false;
  bool get showsnackbard => _showsnackbard;
  set showsnackbard(bool value) {
    _showsnackbard = value;
  }

  bool _msgtype = false;
  bool get msgtype => _msgtype;
  set msgtype(bool value) {
    _msgtype = value;
  }

  bool _liveGameStatus = false;
  bool get liveGameStatus => _liveGameStatus;
  set liveGameStatus(bool value) {
    _liveGameStatus = value;
    secureStorage.setBool('ff_liveGameStatus', value);
  }

  void deleteLiveGameStatus() {
    secureStorage.delete(key: 'ff_liveGameStatus');
  }

  String _liveGameID = '';
  String get liveGameID => _liveGameID;
  set liveGameID(String value) {
    _liveGameID = value;
    secureStorage.setString('ff_liveGameID', value);
  }

  void deleteLiveGameID() {
    secureStorage.delete(key: 'ff_liveGameID');
  }

  String _livePlayerID = '';
  String get livePlayerID => _livePlayerID;
  set livePlayerID(String value) {
    _livePlayerID = value;
    secureStorage.setString('ff_livePlayerID', value);
  }

  void deleteLivePlayerID() {
    secureStorage.delete(key: 'ff_livePlayerID');
  }

  String _liveName = '';
  String get liveName => _liveName;
  set liveName(String value) {
    _liveName = value;
    secureStorage.setString('ff_liveName', value);
  }

  void deleteLiveName() {
    secureStorage.delete(key: 'ff_liveName');
  }

  String _liveOppTeam = '';
  String get liveOppTeam => _liveOppTeam;
  set liveOppTeam(String value) {
    _liveOppTeam = value;
    secureStorage.setString('ff_liveOppTeam', value);
  }

  void deleteLiveOppTeam() {
    secureStorage.delete(key: 'ff_liveOppTeam');
  }

  int _liveFgMade = 0;
  int get liveFgMade => _liveFgMade;
  set liveFgMade(int value) {
    _liveFgMade = value;
    secureStorage.setInt('ff_liveFgMade', value);
  }

  void deleteLiveFgMade() {
    secureStorage.delete(key: 'ff_liveFgMade');
  }

  int _liveFgAttempt = 0;
  int get liveFgAttempt => _liveFgAttempt;
  set liveFgAttempt(int value) {
    _liveFgAttempt = value;
    secureStorage.setInt('ff_liveFgAttempt', value);
  }

  void deleteLiveFgAttempt() {
    secureStorage.delete(key: 'ff_liveFgAttempt');
  }

  int _liveTwoMade = 0;
  int get liveTwoMade => _liveTwoMade;
  set liveTwoMade(int value) {
    _liveTwoMade = value;
    secureStorage.setInt('ff_liveTwoMade', value);
  }

  void deleteLiveTwoMade() {
    secureStorage.delete(key: 'ff_liveTwoMade');
  }

  int _liveTwoAttempt = 0;
  int get liveTwoAttempt => _liveTwoAttempt;
  set liveTwoAttempt(int value) {
    _liveTwoAttempt = value;
    secureStorage.setInt('ff_liveTwoAttempt', value);
  }

  void deleteLiveTwoAttempt() {
    secureStorage.delete(key: 'ff_liveTwoAttempt');
  }

  int _liveThreeMade = 0;
  int get liveThreeMade => _liveThreeMade;
  set liveThreeMade(int value) {
    _liveThreeMade = value;
    secureStorage.setInt('ff_liveThreeMade', value);
  }

  void deleteLiveThreeMade() {
    secureStorage.delete(key: 'ff_liveThreeMade');
  }

  int _liveThreeAttempt = 0;
  int get liveThreeAttempt => _liveThreeAttempt;
  set liveThreeAttempt(int value) {
    _liveThreeAttempt = value;
    secureStorage.setInt('ff_liveThreeAttempt', value);
  }

  void deleteLiveThreeAttempt() {
    secureStorage.delete(key: 'ff_liveThreeAttempt');
  }

  int _liveFtMade = 0;
  int get liveFtMade => _liveFtMade;
  set liveFtMade(int value) {
    _liveFtMade = value;
    secureStorage.setInt('ff_liveFtMade', value);
  }

  void deleteLiveFtMade() {
    secureStorage.delete(key: 'ff_liveFtMade');
  }

  int _liveFtAttempt = 0;
  int get liveFtAttempt => _liveFtAttempt;
  set liveFtAttempt(int value) {
    _liveFtAttempt = value;
    secureStorage.setInt('ff_liveFtAttempt', value);
  }

  void deleteLiveFtAttempt() {
    secureStorage.delete(key: 'ff_liveFtAttempt');
  }

  int _liveMissedTwo = 0;
  int get liveMissedTwo => _liveMissedTwo;
  set liveMissedTwo(int value) {
    _liveMissedTwo = value;
    secureStorage.setInt('ff_liveMissedTwo', value);
  }

  void deleteLiveMissedTwo() {
    secureStorage.delete(key: 'ff_liveMissedTwo');
  }

  int _liveMissedThree = 0;
  int get liveMissedThree => _liveMissedThree;
  set liveMissedThree(int value) {
    _liveMissedThree = value;
    secureStorage.setInt('ff_liveMissedThree', value);
  }

  void deleteLiveMissedThree() {
    secureStorage.delete(key: 'ff_liveMissedThree');
  }

  int _liveMissedOne = 0;
  int get liveMissedOne => _liveMissedOne;
  set liveMissedOne(int value) {
    _liveMissedOne = value;
    secureStorage.setInt('ff_liveMissedOne', value);
  }

  void deleteLiveMissedOne() {
    secureStorage.delete(key: 'ff_liveMissedOne');
  }

  int _livePoints = 0;
  int get livePoints => _livePoints;
  set livePoints(int value) {
    _livePoints = value;
    secureStorage.setInt('ff_livePoints', value);
  }

  void deleteLivePoints() {
    secureStorage.delete(key: 'ff_livePoints');
  }

  int _liveOffReb = 0;
  int get liveOffReb => _liveOffReb;
  set liveOffReb(int value) {
    _liveOffReb = value;
    secureStorage.setInt('ff_liveOffReb', value);
  }

  void deleteLiveOffReb() {
    secureStorage.delete(key: 'ff_liveOffReb');
  }

  int _liveDefReb = 0;
  int get liveDefReb => _liveDefReb;
  set liveDefReb(int value) {
    _liveDefReb = value;
    secureStorage.setInt('ff_liveDefReb', value);
  }

  void deleteLiveDefReb() {
    secureStorage.delete(key: 'ff_liveDefReb');
  }

  int _liveAssist = 0;
  int get liveAssist => _liveAssist;
  set liveAssist(int value) {
    _liveAssist = value;
    secureStorage.setInt('ff_liveAssist', value);
  }

  void deleteLiveAssist() {
    secureStorage.delete(key: 'ff_liveAssist');
  }

  int _liveSteals = 0;
  int get liveSteals => _liveSteals;
  set liveSteals(int value) {
    _liveSteals = value;
    secureStorage.setInt('ff_liveSteals', value);
  }

  void deleteLiveSteals() {
    secureStorage.delete(key: 'ff_liveSteals');
  }

  int _liveBlocks = 0;
  int get liveBlocks => _liveBlocks;
  set liveBlocks(int value) {
    _liveBlocks = value;
    secureStorage.setInt('ff_liveBlocks', value);
  }

  void deleteLiveBlocks() {
    secureStorage.delete(key: 'ff_liveBlocks');
  }

  int _liveOffFoul = 0;
  int get liveOffFoul => _liveOffFoul;
  set liveOffFoul(int value) {
    _liveOffFoul = value;
    secureStorage.setInt('ff_liveOffFoul', value);
  }

  void deleteLiveOffFoul() {
    secureStorage.delete(key: 'ff_liveOffFoul');
  }

  int _liveDefFoul = 0;
  int get liveDefFoul => _liveDefFoul;
  set liveDefFoul(int value) {
    _liveDefFoul = value;
    secureStorage.setInt('ff_liveDefFoul', value);
  }

  void deleteLiveDefFoul() {
    secureStorage.delete(key: 'ff_liveDefFoul');
  }

  int _liveTurnover = 0;
  int get liveTurnover => _liveTurnover;
  set liveTurnover(int value) {
    _liveTurnover = value;
    secureStorage.setInt('ff_liveTurnover', value);
  }

  void deleteLiveTurnover() {
    secureStorage.delete(key: 'ff_liveTurnover');
  }

  bool _customAlertDialog = false;
  bool get customAlertDialog => _customAlertDialog;
  set customAlertDialog(bool value) {
    _customAlertDialog = value;
  }

  bool _gameInsights = false;
  bool get gameInsights => _gameInsights;
  set gameInsights(bool value) {
    _gameInsights = value;
  }

  String _gameCompleteStatus = '';
  String get gameCompleteStatus => _gameCompleteStatus;
  set gameCompleteStatus(String value) {
    _gameCompleteStatus = value;
  }

  bool _aiPerformanceSelection = false;
  bool get aiPerformanceSelection => _aiPerformanceSelection;
  set aiPerformanceSelection(bool value) {
    _aiPerformanceSelection = value;
  }

  int _playerCount = 0;
  int get playerCount => _playerCount;
  set playerCount(int value) {
    _playerCount = value;
  }

  bool _darkMode = false;
  bool get darkMode => _darkMode;
  set darkMode(bool value) {
    _darkMode = value;
  }

  bool _systemMode = false;
  bool get systemMode => _systemMode;
  set systemMode(bool value) {
    _systemMode = value;
  }

  bool _ratingDone = false;
  bool get ratingDone => _ratingDone;
  set ratingDone(bool value) {
    _ratingDone = value;
    secureStorage.setBool('ff_ratingDone', value);
  }

  void deleteRatingDone() {
    secureStorage.delete(key: 'ff_ratingDone');
  }

  bool _ratingDelayed = false;
  bool get ratingDelayed => _ratingDelayed;
  set ratingDelayed(bool value) {
    _ratingDelayed = value;
    secureStorage.setBool('ff_ratingDelayed', value);
  }

  void deleteRatingDelayed() {
    secureStorage.delete(key: 'ff_ratingDelayed');
  }

  DateTime? _ratingDate;
  DateTime? get ratingDate => _ratingDate;
  set ratingDate(DateTime? value) {
    _ratingDate = value;
    value != null
        ? secureStorage.setInt('ff_ratingDate', value.millisecondsSinceEpoch)
        : secureStorage.remove('ff_ratingDate');
  }

  void deleteRatingDate() {
    secureStorage.delete(key: 'ff_ratingDate');
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
