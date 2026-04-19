import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/bottom_sheets/new_live_game/new_live_game_widget.dart';
import '/pages/players/player_components/new_player/new_player_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'create_new_widget.dart' show CreateNewWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateNewModel extends FlutterFlowModel<CreateNewWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Query Rows] action in CreateNew widget.
  List<PlayersRow>? getActivePlayersCount;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
