// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/features/player_insight/player_profile_page.dart';

Future openPlayerProfileV2(BuildContext context, String playerId) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PlayerProfilePageV2(playerId: playerId)),
  );
}
