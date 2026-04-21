import '/backend/supabase/supabase.dart';
import '../models/player_insight.dart';

class PlayerInsightService {
  /// Fire the Edge Function. This is cache-aware server-side — if the cache
  /// matches the latest game id, it returns `cached: true` without calling
  /// Claude. If cache is stale or missing, it generates and writes a new row.
  Future<PlayerInsightResponse> fetch(String playerId) async {
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
  Future<PlayerInsight?> readCached(String playerId) async {
    final row = await SupaFlow.client
        .from('player_development_insights')
        .select('insight_json')
        .eq('player_id', playerId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    final raw = row['insight_json'];
    if (raw is! Map) return null;
    return PlayerInsight.fromJson(Map<String, dynamic>.from(raw));
  }
}
