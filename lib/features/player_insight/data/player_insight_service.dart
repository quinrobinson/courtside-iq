import '/backend/supabase/supabase.dart';
import '../models/player_insight.dart';

class PlayerInsightService {
  // ---------------------------------------------------------------------------
  // Request de-duplication.
  //
  // The profile page swaps tab widgets by type, so returning to the Development
  // tab destroys and rebuilds it — a fresh State, a fresh initState, and another
  // Edge Function call. Each of those is a paid Sonnet generation, because the
  // server's cache check is a read-then-write: a second request that lands
  // inside the first one's latency window also misses and calls Claude again.
  //
  // Telemetry caught exactly this: two generations 5s apart on one profile open.
  //
  // These are static so they survive widget remounts (the service itself is
  // instantiated per-tab, so instance state would not help).
  // ---------------------------------------------------------------------------

  /// In-flight calls, keyed by player id. Concurrent callers share one future.
  static final Map<String, Future<PlayerInsightResponse>> _inFlight = {};

  /// Recently completed results, so a remount moments later reuses the answer
  /// instead of paying for it again.
  static final Map<String, _CachedResponse> _recent = {};

  /// How long a completed result stays reusable.
  ///
  /// Deliberately short. This window only needs to cover the gap between a tab
  /// switch destroying the Development tab and the user switching back — that
  /// is seconds. Anything longer risks masking a freshly logged game behind a
  /// stale narrative, which trades a cost bug for a correctness bug. Game
  /// completion currently runs through the legacy action flows, so there is no
  /// Dart call site to hang invalidate() off yet; a short TTL is the safe
  /// default until 4C rebuilds that path.
  static const Duration _recentTtl = Duration(seconds: 30);

  /// Drop all memoized state. Call after logging a game so the next read
  /// regenerates rather than serving a stale narrative.
  static void invalidate([String? playerId]) {
    if (playerId == null) {
      _recent.clear();
      _inFlight.clear();
    } else {
      _recent.remove(playerId);
      _inFlight.remove(playerId);
    }
  }

  /// Fire the Edge Function. This is cache-aware server-side — if the cache
  /// matches the latest game id, it returns `cached: true` without calling
  /// Claude. If cache is stale or missing, it generates and writes a new row.
  ///
  /// De-duplicated: concurrent and closely-spaced calls for the same player
  /// share a single invocation.
  Future<PlayerInsightResponse> fetch(String playerId) {
    final cached = _recent[playerId];
    if (cached != null && !cached.isExpired) {
      return Future.value(cached.response);
    }

    final existing = _inFlight[playerId];
    if (existing != null) return existing;

    final future = _invoke(playerId);
    _inFlight[playerId] = future;

    return future.then((resp) {
      _recent[playerId] = _CachedResponse(resp, DateTime.now());
      return resp;
    }).whenComplete(() {
      // Failures are not memoized — a retry should genuinely retry.
      _inFlight.remove(playerId);
    });
  }

  Future<PlayerInsightResponse> _invoke(String playerId) async {
    final res = await SupaFlow.client.functions.invoke(
      'generate-player-insight',
      body: {'player_id': playerId},
    );
    final data = res.data;
    if (data is! Map) {
      throw StateError('Unexpected response shape');
    }
    final map = Map<String, dynamic>.from(data);
    if (map['error'] != null) {
      throw StateError(map['error'].toString());
    }
    return PlayerInsightResponse.fromJson(map);
  }

  /// Read the most recent cached insight row directly from the table (RLS
  /// scopes to the caller's players). Used to render the card instantly on
  /// tab open while the Edge Function refresh runs in parallel. Returns null
  /// if no cache row exists yet.
  /// The cached narrative, but ONLY if it describes the player's current
  /// latest game.
  ///
  /// This used to take whichever insight was newest for the player, with no
  /// game filter at all. A narrative generated three games ago rendered
  /// instantly while the current one loaded - so a parent could read a
  /// paragraph about games they have long since moved past, presented as if
  /// it were about last night. Returning null instead means the tab shows its
  /// loading state and then the real story. A visible load is a fair price for
  /// never telling a parent something untrue about their child.
  ///
  /// `generated_at_game_id` is what makes this checkable; it is NOT NULL on
  /// every insight row.
  Future<PlayerInsight?> readCached(String playerId) async {
    final latest = await SupaFlow.client
        .from('v_player_game_stats')
        .select('game_id')
        .eq('player_id', playerId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final latestGameId = latest?['game_id'] as String?;
    // No games means nothing could have been generated yet.
    if (latestGameId == null) return null;

    final row = await SupaFlow.client
        .from('player_development_insights')
        .select('insight_json')
        .eq('player_id', playerId)
        .eq('generated_at_game_id', latestGameId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;

    // A claim row carries a null insight_json: generation is in flight, not
    // finished. Rendering it would be rendering nothing.
    final raw = row['insight_json'];
    if (raw is! Map) return null;
    return PlayerInsight.fromJson(Map<String, dynamic>.from(raw));
  }
}

/// A completed response plus when it landed, for the short-lived reuse window.
class _CachedResponse {
  const _CachedResponse(this.response, this.at);

  final PlayerInsightResponse response;
  final DateTime at;

  bool get isExpired =>
      DateTime.now().difference(at) > PlayerInsightService._recentTtl;
}
