// Game allowance — roadmap 3.8
//
// What the game gate needs to decide: is the parent premium, and how many
// games does the account have. Read fresh when possible, CACHED so the gate
// still works with no signal - the place this app is used most is a gym.
//
// THE COUNT INCLUDES QUEUED GAMES. A game saved offline sits in the sync queue,
// not in the database, so a server count alone would let a parent with three
// unsynced games start a fourth. Adding the queue keeps the client honest; the
// server policy is the backstop if it ever is not.
//
// FAILING OPEN, deliberately. If nothing is known at all (first launch, no
// signal), the gate allows: the server refuses a fourth game at save and the
// queue holds it (step 6), which is recoverable. Stopping a paying parent from
// tracking a game in the stands is not.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/game_sync/supabase_game_uploader.dart';
import '/features/home/entitlement_status.dart';

class GameAllowance {
  const GameAllowance({
    required this.isPremium,
    required this.gameCount,
    this.playerFirstName,
  });

  /// Active entitlement only. Lapsed counts as free, as in the player gate.
  final bool isPremium;

  /// Saved games on the account plus games waiting in the sync queue.
  final int gameCount;

  /// The only player's first name when the account has exactly one, for the
  /// gate's "Maya's games stay..." line. Null otherwise, and the copy falls
  /// back to a name-free version.
  final String? playerFirstName;
}

const _cacheKeyPrefix = 'ciq_game_allowance_v1_';

/// Reads entitlement and the game count, falling back to the cache for either
/// one that fails, and refreshes the cache with whatever was read.
Future<GameAllowance> loadGameAllowance() async {
  final uid = currentUserUid;
  final prefs = await SharedPreferences.getInstance();
  final cached = _readCache(prefs, uid);

  final status = await tryFetchEntitlementStatus();
  final isPremium = status == null
      ? cached?.isPremium ?? false
      : status == EntitlementStatus.premium;

  int? serverCount;
  String? firstName = cached?.playerFirstName;
  if (uid.isNotEmpty) {
    try {
      final rows = await SupaFlow.client
          .from('games')
          .select('id')
          .eq('user_id', uid) as List;
      serverCount = rows.length;
      final players = await SupaFlow.client
          .from('players')
          .select('first_name')
          .eq('user_id', uid) as List;
      firstName =
          players.length == 1 ? players.first['first_name'] as String? : null;
    } catch (_) {
      // Offline or a blip: the cached count stands in.
    }
  }

  final savedCount = serverCount ?? cached?.savedCount ?? 0;
  final queued = await gameSyncQueue.pending();

  if (uid.isNotEmpty) {
    await prefs.setString(
      '$_cacheKeyPrefix$uid',
      jsonEncode({
        'premium': isPremium,
        'saved': savedCount,
        'name': firstName,
      }),
    );
  }

  return GameAllowance(
    isPremium: isPremium,
    gameCount: savedCount + queued,
    playerFirstName: firstName,
  );
}

class _Cached {
  const _Cached(this.isPremium, this.savedCount, this.playerFirstName);
  final bool isPremium;
  final int savedCount;
  final String? playerFirstName;
}

_Cached? _readCache(SharedPreferences prefs, String uid) {
  if (uid.isEmpty) return null;
  final raw = prefs.getString('$_cacheKeyPrefix$uid');
  if (raw == null) return null;
  try {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return _Cached(
      m['premium'] as bool? ?? false,
      (m['saved'] as num?)?.toInt() ?? 0,
      m['name'] as String?,
    );
  } catch (_) {
    return null;
  }
}
