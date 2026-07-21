// Age-band transition notice — Phase 4.11b
//
// A player's age band is DERIVED from their birth date, so nothing in the
// database records the moment they cross into a new one. The app finds out
// the same way a parent would: the band it sees today is not the band it saw
// last time.
//
// That means remembering, per player, the last band we showed. The decision
// itself is a pure function so it can be tested without prefs.

import 'package:shared_preferences/shared_preferences.dart';

class AgeBandService {
  static const _keyPrefix = 'age_band_last_seen:';

  static String _key(String playerId) => '$_keyPrefix$playerId';

  /// Whether the player has visibly moved up since we last looked.
  ///
  /// FALSE on the first sighting. With nothing stored, every player would
  /// otherwise be announced as having "moved up to" the band they have always
  /// been in - which is wrong for a new player and wrong for every existing
  /// player the first time they open this build.
  static bool movedUp({String? current, String? lastSeen}) {
    final c = current?.trim();
    final l = lastSeen?.trim();
    if (c == null || c.isEmpty) return false;
    if (l == null || l.isEmpty) return false;
    return c != l;
  }

  static Future<String?> lastSeenBand(String playerId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(playerId));
  }

  static Future<void> recordBand(String playerId, String? band) async {
    final b = band?.trim();
    if (b == null || b.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(playerId), b);
  }
}
