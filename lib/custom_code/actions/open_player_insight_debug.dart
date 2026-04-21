// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/features/dev/player_insight_debug_page.dart';

/// Dev-only: pushes the Player Insight debug page. Wire this to any temporary
/// button in FlutterFlow to smoke test the generate-player-insight Edge
/// Function from a real user session. Remove the button once Phase 2 UI ships.
Future openPlayerInsightDebug(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const PlayerInsightDebugPage()),
  );
}
