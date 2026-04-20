import 'package:shared_preferences/shared_preferences.dart';

class BirthDatePromptService {
  static const _keyPrefix = 'birth_date_modal_dismissed_at:';
  static const Duration _repromptAfter = Duration(days: 7);

  static String _key(String playerId) => '$_keyPrefix$playerId';

  static Future<bool> shouldShowModalForPlayer(String playerId) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_key(playerId));
    if (millis == null) return true;
    final dismissedAt = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime.now().difference(dismissedAt) >= _repromptAfter;
  }

  static Future<void> markModalDismissed(String playerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(playerId), DateTime.now().millisecondsSinceEpoch);
  }

  static bool shouldShowBannerForPlayer(Map<String, dynamic> player) {
    return player['birth_date'] == null;
  }
}
