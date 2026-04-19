import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/games/game_components/alert_dialog_game_complete/alert_dialog_game_complete_widget.dart';
import '/pages/games/game_components/edit_game_stat/edit_game_stat_widget.dart';
import '/pages/games/game_components/game_complete/game_complete_widget.dart';
import '/pages/games/game_components/game_paused/game_paused_widget.dart';
import '/pages/global/alert_dialog/alert_dialog_widget.dart';
import '/pages/global/alert_rate/alert_rate_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'game_stat_tracker_widget.dart' show GameStatTrackerWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GameStatTrackerModel extends FlutterFlowModel<GameStatTrackerWidget> {
  ///  Local state fields for this page.

  int? points = 0;

  int? fgMade = 0;

  int? fgAttempt = 0;

  int? twoMade = 0;

  int? twoAttempt = 0;

  int? threeMade = 0;

  int? threeAttempt = 0;

  int? ftMade = 0;

  int? ftAttempt = 0;

  int? offReb = 0;

  int? defReb = 0;

  int? assist = 0;

  int? steal = 0;

  int? block = 0;

  int? offFoul = 0;

  int? defFoul = 0;

  int? turnover = 0;

  String? gameId;

  int? missedTwo = 0;

  int? missedThree = 0;

  int? missedOne = 0;

  double? alertDialog;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Insert Row] action in GameCompleteButton widget.
  GamesRow? newGame;
  // Stores action output result for [Backend Call - Insert Row] action in GameCompleteButton widget.
  PlayerGameStatsRow? newStats;
  // Stores action output result for [Backend Call - API (GetGameInsights)] action in GameCompleteButton widget.
  ApiCallResponse? getGameInsights;
  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    customSnackBarModel.dispose();
  }
}
