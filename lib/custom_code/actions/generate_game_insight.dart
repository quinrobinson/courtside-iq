// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Calls the `generate-game-insight` Supabase Edge Function.
///
/// Returns the insight text on success, or null on any failure (missing
/// auth, below-threshold game, Claude failure, network error). The full
/// structured insight jsonb is written server-side to
/// `player_game_stats.game_insights` — the client reads it from the view
/// on the next refresh.
Future<String?> generateGameInsight(String gameId) async {
  try {
    final response = await SupaFlow.client.functions.invoke(
      'generate-game-insight',
      body: {'game_id': gameId},
    );

    final data = response.data;
    if (data is! Map) return null;

    final insight = data['insight'];
    if (insight is! Map) return null;

    if (insight['below_threshold'] == true) return null;

    final text = insight['text'];
    return text is String && text.isNotEmpty ? text : null;
  } catch (e) {
    debugPrint('generateGameInsight error: $e');
    return null;
  }
}
