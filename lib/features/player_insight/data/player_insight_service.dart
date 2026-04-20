import '/backend/supabase/supabase.dart';
import '../models/player_insight.dart';

class PlayerInsightService {
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
}
