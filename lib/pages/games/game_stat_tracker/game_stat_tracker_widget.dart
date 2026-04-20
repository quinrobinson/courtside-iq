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
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'game_stat_tracker_model.dart';
export 'game_stat_tracker_model.dart';

class GameStatTrackerWidget extends StatefulWidget {
  const GameStatTrackerWidget({
    super.key,
    required this.playerName,
    required this.oppName,
    required this.playerID,
    this.eventSelected,
    this.playerTeam,
  });

  final String? playerName;
  final String? oppName;
  final String? playerID;
  final String? eventSelected;
  final String? playerTeam;

  static String routeName = 'GameStatTracker';
  static String routePath = '/gameStatTracker';

  @override
  State<GameStatTrackerWidget> createState() => _GameStatTrackerWidgetState();
}

class _GameStatTrackerWidgetState extends State<GameStatTrackerWidget>
    with TickerProviderStateMixin {
  late GameStatTrackerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasContainerTriggered9 = false;
  var hasContainerTriggered10 = false;
  var hasContainerTriggered11 = false;
  var hasContainerTriggered12 = false;
  var hasContainerTriggered13 = false;
  var hasContainerTriggered14 = false;
  var hasContainerTriggered15 = false;
  var hasContainerTriggered16 = false;
  var hasContainerTriggered17 = false;
  var hasContainerTriggered18 = false;
  var hasContainerTriggered19 = false;
  var hasContainerTriggered20 = false;
  var hasContainerTriggered21 = false;
  var hasContainerTriggered22 = false;
  var hasButtonTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GameStatTrackerModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().liveGameStatus = true;
      FFAppState().livePlayerID = widget!.playerID!;
      FFAppState().liveOppTeam = widget!.oppName!;
      FFAppState().liveFgMade = FFAppState().liveFgMade;
      FFAppState().liveFgAttempt = FFAppState().liveFgAttempt;
      FFAppState().liveTwoMade = FFAppState().liveTwoMade;
      FFAppState().liveTwoAttempt = FFAppState().liveTwoAttempt;
      FFAppState().liveThreeMade = FFAppState().liveThreeMade;
      FFAppState().liveThreeAttempt = FFAppState().liveThreeAttempt;
      FFAppState().liveFtMade = FFAppState().liveFtMade;
      FFAppState().liveFtAttempt = FFAppState().liveFtAttempt;
      FFAppState().liveMissedTwo = FFAppState().liveMissedTwo;
      FFAppState().liveMissedThree = FFAppState().liveMissedThree;
      FFAppState().liveMissedOne = FFAppState().liveMissedOne;
      FFAppState().livePoints = FFAppState().livePoints;
      FFAppState().liveOffReb = FFAppState().liveOffReb;
      FFAppState().liveDefReb = FFAppState().liveDefReb;
      FFAppState().liveAssist = FFAppState().liveAssist;
      FFAppState().liveSteals = FFAppState().liveSteals;
      FFAppState().liveBlocks = FFAppState().liveBlocks;
      FFAppState().liveOffFoul = FFAppState().liveOffFoul;
      FFAppState().liveDefFoul = FFAppState().liveDefFoul;
      FFAppState().liveTurnover = FFAppState().liveTurnover;
      FFAppState().liveName = widget!.playerName!;
      safeSetState(() {});
    });

    animationsMap.addAll({
      'textOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).gray1,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).gray1,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).gray1,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).gray1,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).gray1,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).secondary,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryText,
            begin: 0.0,
            end: 1.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 2000.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).globalBackground,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation9': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation10': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation11': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation12': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation13': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation14': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation15': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation16': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation17': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation18': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation19': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation20': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation21': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation22': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
          TintEffect(
            curve: Curves.easeOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).primaryBackground,
            begin: 0.3,
            end: 0.0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).globalBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 12.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueOrDefault<String>(
                                    widget!.playerName,
                                    'Player Name',
                                  ),
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.ibmPlexSans(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 22.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'vs. ${FFAppState().liveOppTeam}',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.ibmPlexSans(
                                            fontWeight: FontWeight.w300,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .gray1,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w300,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 6.0,
                              buttonSize: 42.0,
                              icon: Icon(
                                Icons.edit_note,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 26.0,
                              ),
                              onPressed: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: FlutterFlowTheme.of(context)
                                      .bottomSheetBg,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: Container(
                                          height: 598.0,
                                          child: EditGameStatWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                            ),
                          ),
                        ].divide(SizedBox(width: 3.0)),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .globalBackground,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: 1.0,
                                ),
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    6.0, 2.0, 6.0, 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF6F00),
                                            FlutterFlowTheme.of(context)
                                                .imperial
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(0.0, -1.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5.0, 0.0, 3.0, 0.0),
                                        child: Text(
                                          'LIVE',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).gray4,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                6.0, 12.0, 6.0, 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PTS',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  ((FFAppState().liveTwoMade *
                                                              2) +
                                                          (FFAppState()
                                                                  .liveThreeMade *
                                                              3) +
                                                          FFAppState()
                                                              .liveFtMade)
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation1']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation1']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'REB',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  (FFAppState().liveOffReb +
                                                          FFAppState()
                                                              .liveDefReb)
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation2']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation2']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AST',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 7.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  FFAppState()
                                                      .liveAssist
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation3']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation3']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BLK',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  FFAppState()
                                                      .liveBlocks
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation4']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation4']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'STL',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  FFAppState()
                                                      .liveSteals
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation5']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation5']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TOV',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  FFAppState()
                                                      .liveTurnover
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation6']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation6']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PF',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 11.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  (valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveOffFoul,
                                                            0,
                                                          ) +
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveDefFoul,
                                                            0,
                                                          ))
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation7']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation7']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EFF',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      6.0, 12.0, 6.0, 6.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  functions
                                                      .calculateEFF(
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .livePoints,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveOffReb,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveDefReb,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveAssist,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveSteals,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveBlocks,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            valueOrDefault<int>(
                                                                  FFAppState()
                                                                      .liveTwoAttempt,
                                                                  0,
                                                                ) +
                                                                valueOrDefault<
                                                                    int>(
                                                                  FFAppState()
                                                                      .liveThreeAttempt,
                                                                  0,
                                                                ),
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            valueOrDefault<int>(
                                                                  FFAppState()
                                                                      .liveTwoMade,
                                                                  0,
                                                                ) +
                                                                valueOrDefault<
                                                                    int>(
                                                                  FFAppState()
                                                                      .liveThreeMade,
                                                                  0,
                                                                ),
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveMissedOne,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveFtMade,
                                                            0,
                                                          ),
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                .liveTurnover,
                                                            0,
                                                          ))
                                                      .toString(),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'textOnActionTriggerAnimation8']!,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .globalBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap[
                                                    'containerOnActionTriggerAnimation8']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).gray4,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        'FG',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              '${valueOrDefault<String>(
                                                (valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveTwoMade,
                                                          0,
                                                        ) +
                                                        valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveThreeMade,
                                                          0,
                                                        ))
                                                    .toString(),
                                                '0',
                                              )}/${valueOrDefault<String>(
                                                (valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveTwoAttempt,
                                                          0,
                                                        ) +
                                                        valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveThreeAttempt,
                                                          0,
                                                        ))
                                                    .toString(),
                                                '0',
                                              )}',
                                              '0/0 (0%)',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.ibmPlexMono(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              '(${functions.calculatePlayerFGPercent(FFAppState().liveTwoMade + FFAppState().liveThreeMade, FFAppState().liveTwoAttempt + FFAppState().liveThreeAttempt).toString()}%)',
                                              '0/0 (0%)',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.ibmPlexMono(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 0.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).gray4,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        '3PT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              '${valueOrDefault<String>(
                                                FFAppState()
                                                    .liveThreeMade
                                                    .toString(),
                                                '0',
                                              )}/${valueOrDefault<String>(
                                                FFAppState()
                                                    .liveThreeAttempt
                                                    .toString(),
                                                '0',
                                              )}',
                                              '0/0 (0%)',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.ibmPlexMono(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              '(${valueOrDefault<String>(
                                                functions
                                                    .calculatePlayerThreePointPercent(
                                                        valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveThreeMade,
                                                          0,
                                                        ),
                                                        valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveThreeAttempt,
                                                          0,
                                                        ))
                                                    .toString(),
                                                '0',
                                              )}%)',
                                              '0/0 (0%)',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.ibmPlexMono(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 0.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).gray4,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        'FT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              '${valueOrDefault<String>(
                                                FFAppState()
                                                    .liveFtMade
                                                    .toString(),
                                                '0',
                                              )}/${valueOrDefault<String>(
                                                FFAppState()
                                                    .liveFtAttempt
                                                    .toString(),
                                                '0',
                                              )}',
                                              '0/0 (0%)',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.ibmPlexMono(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              '(${valueOrDefault<String>(
                                                functions
                                                    .calculatePlayerFTPercent(
                                                        valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveFtMade,
                                                          0,
                                                        ),
                                                        valueOrDefault<int>(
                                                          FFAppState()
                                                              .liveFtAttempt,
                                                          0,
                                                        ))
                                                    .toString(),
                                                '0',
                                              )}%)',
                                              '0/0 (0%)',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.ibmPlexMono(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 0.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: 6.0)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().liveTwoMade =
                                      FFAppState().liveTwoMade + 1;
                                  FFAppState().liveTwoAttempt =
                                      FFAppState().liveTwoAttempt + 1;
                                  FFAppState().livePoints =
                                      FFAppState().livePoints + 2;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation9'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered9 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation9']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation1'] !=
                                      null) {
                                    await animationsMap[
                                            'containerOnActionTriggerAnimation1']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                },
                                onLongPress: () async {
                                  if (FFAppState().liveTwoMade > 0) {
                                    FFAppState().liveTwoMade =
                                        FFAppState().liveTwoMade + -1;
                                    FFAppState().liveTwoAttempt =
                                        FFAppState().liveTwoAttempt + -1;
                                    FFAppState().livePoints =
                                        FFAppState().livePoints + -2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'textOnActionTriggerAnimation1'] !=
                                        null) {
                                      await animationsMap[
                                              'textOnActionTriggerAnimation1']!
                                          .controller
                                          .forward(from: 0.0);
                                    }
                                    return;
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).teal,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '2PT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'MADE',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 0.0)),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation9']!,
                                  hasBeenTriggered: hasContainerTriggered9),
                            ),
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().liveThreeMade =
                                      FFAppState().liveThreeMade + 1;
                                  FFAppState().liveThreeAttempt =
                                      FFAppState().liveThreeAttempt + 1;
                                  FFAppState().livePoints =
                                      FFAppState().livePoints + 3;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation10'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered10 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation10']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation1'] !=
                                      null) {
                                    await animationsMap[
                                            'containerOnActionTriggerAnimation1']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                },
                                onLongPress: () async {
                                  if (FFAppState().liveThreeMade > 0) {
                                    _model.points = _model.points! +
                                        (FFAppState().liveThreeMade != null
                                            ? -3
                                            : 0);
                                    _model.fgMade = _model.fgMade! +
                                        (FFAppState().liveThreeMade > 0
                                            ? -1
                                            : 0);
                                    _model.fgAttempt = _model.fgAttempt! +
                                        (FFAppState().liveThreeAttempt > 0
                                            ? -1
                                            : 0);
                                    _model.threeMade = _model.threeMade! +
                                        (FFAppState().liveThreeMade > 0
                                            ? -1
                                            : 0);
                                    _model.threeAttempt = _model.threeAttempt! +
                                        (FFAppState().liveThreeAttempt > 0
                                            ? -1
                                            : 0);
                                    safeSetState(() {});
                                    FFAppState().livePoints =
                                        FFAppState().livePoints +
                                            (FFAppState().liveThreeMade > 0
                                                ? -3
                                                : 0);
                                    FFAppState().liveFgMade =
                                        FFAppState().liveFgMade +
                                            (FFAppState().liveThreeMade > 0
                                                ? -1
                                                : 0);
                                    FFAppState().liveFgAttempt =
                                        FFAppState().liveFgAttempt +
                                            (FFAppState().liveThreeAttempt > 0
                                                ? -1
                                                : 0);
                                    FFAppState().liveThreeMade =
                                        FFAppState().liveThreeMade +
                                            (FFAppState().liveThreeMade > 0
                                                ? -1
                                                : 0);
                                    FFAppState().liveThreeAttempt =
                                        FFAppState().liveThreeAttempt +
                                            (FFAppState().liveThreeAttempt > 0
                                                ? -1
                                                : 0);
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'textOnActionTriggerAnimation1'] !=
                                        null) {
                                      await animationsMap[
                                              'textOnActionTriggerAnimation1']!
                                          .controller
                                          .forward(from: 0.0);
                                    }
                                    return;
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).teal,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '3PT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'MADE',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation10']!,
                                  hasBeenTriggered: hasContainerTriggered10),
                            ),
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().liveFtMade =
                                      FFAppState().liveFtMade + 1;
                                  FFAppState().liveFtAttempt =
                                      FFAppState().liveFtAttempt + 1;
                                  FFAppState().livePoints =
                                      FFAppState().livePoints + 1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation11'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered11 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation11']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation1'] !=
                                      null) {
                                    await animationsMap[
                                            'containerOnActionTriggerAnimation1']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                },
                                onLongPress: () async {
                                  if (FFAppState().liveFtMade > 0) {
                                    FFAppState().liveFtMade =
                                        FFAppState().liveFtMade + -1;
                                    FFAppState().liveFtAttempt =
                                        FFAppState().liveFtAttempt + -1;
                                    FFAppState().livePoints =
                                        FFAppState().livePoints + -1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'textOnActionTriggerAnimation1'] !=
                                        null) {
                                      await animationsMap[
                                              'textOnActionTriggerAnimation1']!
                                          .controller
                                          .forward(from: 0.0);
                                    }
                                    return;
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).teal,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '1FT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'MADE',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation11']!,
                                  hasBeenTriggered: hasContainerTriggered11),
                            ),
                          ].divide(SizedBox(width: 3.0)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().liveTwoAttempt =
                                      FFAppState().liveTwoAttempt + 1;
                                  FFAppState().liveMissedTwo =
                                      FFAppState().liveMissedTwo + 1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation12'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered12 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation12']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                },
                                onLongPress: () async {
                                  if (FFAppState().liveMissedTwo > 0) {
                                    FFAppState().liveTwoAttempt =
                                        FFAppState().liveTwoAttempt + -1;
                                    FFAppState().liveMissedTwo =
                                        FFAppState().liveMissedTwo + -1;
                                    safeSetState(() {});
                                    return;
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '2PT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'MISSED',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 0.0)),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation12']!,
                                  hasBeenTriggered: hasContainerTriggered12),
                            ),
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().liveThreeAttempt =
                                      FFAppState().liveThreeAttempt + 1;
                                  FFAppState().liveMissedThree =
                                      FFAppState().liveMissedThree + 1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation13'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered13 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation13']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                },
                                onLongPress: () async {
                                  if (FFAppState().liveMissedThree > 0) {
                                    FFAppState().liveThreeAttempt =
                                        FFAppState().liveThreeAttempt + -1;
                                    FFAppState().liveMissedThree =
                                        FFAppState().liveMissedThree + -1;
                                    safeSetState(() {});
                                    return;
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '3PT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'MISSED',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation13']!,
                                  hasBeenTriggered: hasContainerTriggered13),
                            ),
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().liveFtAttempt =
                                      FFAppState().liveFtAttempt + 1;
                                  FFAppState().liveMissedOne =
                                      FFAppState().liveMissedOne + 1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation14'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered14 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation14']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                },
                                onLongPress: () async {
                                  if (FFAppState().liveMissedOne > 0) {
                                    FFAppState().liveFtAttempt =
                                        FFAppState().liveFtAttempt + -1;
                                    FFAppState().liveMissedOne =
                                        FFAppState().liveMissedOne + -1;
                                    safeSetState(() {});
                                    return;
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '1FT',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'MISSED',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation14']!,
                                  hasBeenTriggered: hasContainerTriggered14),
                            ),
                          ].divide(SizedBox(width: 6.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveDefReb =
                                    FFAppState().liveDefReb + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation15'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered15 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation15']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation2'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation2']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveDefReb > 0) {
                                  FFAppState().liveDefReb =
                                      FFAppState().liveDefReb + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation2'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation2']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            6.0, 6.0, 6.0, 6.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.plus_one,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryButtonText,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'DEF. REB',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    font:
                                                        GoogleFonts.ibmPlexSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryButtonText,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(height: 0.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation15']!,
                                hasBeenTriggered: hasContainerTriggered15),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveBlocks =
                                    FFAppState().liveBlocks + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation16'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered16 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation16']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation4'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation4']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveBlocks > 0) {
                                  FFAppState().liveBlocks =
                                      FFAppState().liveBlocks + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation4'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation4']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'BLOCK',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation16']!,
                                hasBeenTriggered: hasContainerTriggered16),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveSteals =
                                    FFAppState().liveSteals + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation17'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered17 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation17']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation5'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation5']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveSteals > 0) {
                                  FFAppState().liveSteals =
                                      FFAppState().liveSteals + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation5'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation5']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'STEAL',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation17']!,
                                hasBeenTriggered: hasContainerTriggered17),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveDefFoul =
                                    FFAppState().liveDefFoul + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation18'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered18 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation18']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation7'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation7']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveDefFoul > 0) {
                                  FFAppState().liveDefFoul =
                                      FFAppState().liveDefFoul + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation7'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation7']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'DEF. FOUL',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation18']!,
                                hasBeenTriggered: hasContainerTriggered18),
                          ),
                        ].divide(SizedBox(width: 6.0)),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveOffReb =
                                    FFAppState().liveOffReb + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation19'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered19 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation19']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation2'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation2']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveOffReb > 0) {
                                  FFAppState().liveOffReb =
                                      FFAppState().liveOffReb + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation2'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation2']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'OFF. REB',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation19']!,
                                hasBeenTriggered: hasContainerTriggered19),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveAssist =
                                    FFAppState().liveAssist + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation20'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered20 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation20']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation3'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation3']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveAssist > 0) {
                                  FFAppState().liveAssist =
                                      FFAppState().liveAssist + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation3'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation3']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'ASSIST',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation20']!,
                                hasBeenTriggered: hasContainerTriggered20),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveTurnover =
                                    FFAppState().liveTurnover + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation21'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered21 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation21']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation6'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation6']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveTurnover > 0) {
                                  FFAppState().liveTurnover =
                                      FFAppState().liveTurnover + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation6'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation6']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'TURNOVER',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation21']!,
                                hasBeenTriggered: hasContainerTriggered21),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().liveOffFoul =
                                    FFAppState().liveOffFoul + 1;
                                safeSetState(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation22'] !=
                                    null) {
                                  safeSetState(
                                      () => hasContainerTriggered22 = true);
                                  SchedulerBinding.instance.addPostFrameCallback(
                                      (_) async => await animationsMap[
                                              'containerOnActionTriggerAnimation22']!
                                          .controller
                                          .forward(from: 0.0));
                                }
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation7'] !=
                                    null) {
                                  await animationsMap[
                                          'containerOnActionTriggerAnimation7']!
                                      .controller
                                      .forward(from: 0.0);
                                }
                              },
                              onLongPress: () async {
                                if (FFAppState().liveOffFoul > 0) {
                                  FFAppState().liveOffFoul =
                                      FFAppState().liveOffFoul + -1;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'textOnActionTriggerAnimation7'] !=
                                      null) {
                                    await animationsMap[
                                            'textOnActionTriggerAnimation7']!
                                        .controller
                                        .forward(from: 0.0);
                                  }
                                  return;
                                } else {
                                  return;
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: valueOrDefault<double>(
                                  isAndroid ? 70.0 : 80.0,
                                  80.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).gray3,
                                    width: 1.0,
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        3.0, 3.0, 3.0, 3.0),
                                    child: Container(
                                      width: 75.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.plus_one,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryButtonText,
                                            size: 22.0,
                                          ),
                                          Text(
                                            'OFF. FOUL',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.ibmPlexSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryButtonText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                                animationsMap[
                                    'containerOnActionTriggerAnimation22']!,
                                hasBeenTriggered: hasContainerTriggered22),
                          ),
                        ].divide(SizedBox(width: 6.0)),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) => FFButtonWidget(
                                onPressed: () async {
                                  var _shouldSetState = false;
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(dialogContext)
                                                .unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            child:
                                                AlertDialogGameCompleteWidget(
                                              title: 'All done?',
                                              message:
                                                  'Confirm if you\'re ready to close out this game and save the stats. ',
                                              confirmLabel: 'Finish Game',
                                              dismissLabel: 'Keep Playing',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  if (FFAppState().customAlertDialog) {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      barrierColor: Color(0xCD161616),
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: GameCompleteWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));

                                    FFAppState().gameCompleteStatus =
                                        'Saving game details...';
                                    FFAppState().update(() {});
                                    // Game Details
                                    _model.newGame = await GamesTable().insert({
                                      'opponent_team': widget!.oppName,
                                      'user_id': currentUserUid,
                                      'player_id': widget!.playerID,
                                      'player_team_name': widget!.playerTeam,
                                      'event_name': widget!.eventSelected,
                                    });
                                    _shouldSetState = true;
                                    FFAppState().gameCompleteStatus =
                                        'Saving player stats...';
                                    FFAppState().update(() {});
                                    // Game Stats
                                    _model.newStats =
                                        await PlayerGameStatsTable().insert({
                                      'game_id': _model.newGame?.id,
                                      'player_id': FFAppState().livePlayerID,
                                      'points': FFAppState().livePoints,
                                      'fg_made': FFAppState().liveTwoMade +
                                          FFAppState().liveThreeMade,
                                      'fg_attempt':
                                          FFAppState().liveTwoAttempt +
                                              FFAppState().liveThreeAttempt,
                                      'two_made': FFAppState().liveTwoMade,
                                      'two_attempt':
                                          FFAppState().liveTwoAttempt,
                                      'three_made': FFAppState().liveThreeMade,
                                      'three_attempt':
                                          FFAppState().liveThreeAttempt,
                                      'ft_made': FFAppState().liveFtMade,
                                      'ft_attempt': FFAppState().liveFtAttempt,
                                      'off_reb': FFAppState().liveOffReb,
                                      'def_reb': FFAppState().liveDefReb,
                                      'assist': FFAppState().liveAssist,
                                      'steal': FFAppState().liveSteals,
                                      'turnover': FFAppState().liveTurnover,
                                      'block': FFAppState().liveBlocks,
                                      'off_foul': FFAppState().liveOffFoul,
                                      'def_foul': FFAppState().liveDefFoul,
                                    });
                                    _shouldSetState = true;
                                    if ((valueOrDefault<int>(
                                              functions.calculateEFF(
                                                  valueOrDefault<int>(
                                                    FFAppState().livePoints,
                                                    0,
                                                  ),
                                                  valueOrDefault<int>(
                                                    FFAppState().liveOffReb,
                                                    0,
                                                  ),
                                                  valueOrDefault<int>(
                                                    FFAppState().liveDefReb,
                                                    0,
                                                  ),
                                                  valueOrDefault<int>(
                                                    FFAppState().liveAssist,
                                                    0,
                                                  ),
                                                  valueOrDefault<int>(
                                                    FFAppState().liveSteals,
                                                    0,
                                                  ),
                                                  valueOrDefault<int>(
                                                    FFAppState().liveBlocks,
                                                    0,
                                                  ),
                                                  FFAppState().liveFgAttempt,
                                                  FFAppState().liveFgMade,
                                                  FFAppState().liveFtAttempt,
                                                  valueOrDefault<int>(
                                                    FFAppState().liveFtMade,
                                                    0,
                                                  ),
                                                  valueOrDefault<int>(
                                                    FFAppState().liveTurnover,
                                                    0,
                                                  )),
                                              0,
                                            ) >=
                                            5) &&
                                        (FFAppState().aiPerformanceSelection ==
                                            true)) {
                                      FFAppState().gameCompleteStatus =
                                          ' Creating performance insights...';
                                      FFAppState().update(() {});
                                      // Phase 1.10: Buildship → Supabase Edge
                                      // Function. Stats are fetched server-side
                                      // from v_player_game_stats; we only pass
                                      // the game id. Insight jsonb is written
                                      // to player_game_stats.game_insights.
                                      final gameId = _model.newGame?.id;
                                      if (gameId != null) {
                                        await actions
                                            .generateGameInsight(gameId);
                                      }

                                      _shouldSetState = true;
                                    }
                                    // Clear State
                                    FFAppState().deleteLiveFgMade();
                                    FFAppState().liveFgMade = 0;

                                    FFAppState().deleteLiveFgAttempt();
                                    FFAppState().liveFgAttempt = 0;

                                    FFAppState().deleteLiveTwoMade();
                                    FFAppState().liveTwoMade = 0;

                                    FFAppState().deleteLiveTwoAttempt();
                                    FFAppState().liveTwoAttempt = 0;

                                    FFAppState().deleteLiveThreeMade();
                                    FFAppState().liveThreeMade = 0;

                                    FFAppState().deleteLiveThreeAttempt();
                                    FFAppState().liveThreeAttempt = 0;

                                    FFAppState().deleteLiveFtMade();
                                    FFAppState().liveFtMade = 0;

                                    FFAppState().deleteLiveFtAttempt();
                                    FFAppState().liveFtAttempt = 0;

                                    FFAppState().deleteLiveMissedTwo();
                                    FFAppState().liveMissedTwo = 0;

                                    FFAppState().deleteLiveMissedThree();
                                    FFAppState().liveMissedThree = 0;

                                    FFAppState().deleteLiveMissedOne();
                                    FFAppState().liveMissedOne = 0;

                                    FFAppState().deleteLivePoints();
                                    FFAppState().livePoints = 0;

                                    FFAppState().deleteLiveOffReb();
                                    FFAppState().liveOffReb = 0;

                                    FFAppState().deleteLiveDefReb();
                                    FFAppState().liveDefReb = 0;

                                    FFAppState().deleteLiveAssist();
                                    FFAppState().liveAssist = 0;

                                    FFAppState().deleteLiveSteals();
                                    FFAppState().liveSteals = 0;

                                    FFAppState().deleteLiveBlocks();
                                    FFAppState().liveBlocks = 0;

                                    FFAppState().deleteLiveOffFoul();
                                    FFAppState().liveOffFoul = 0;

                                    FFAppState().deleteLiveDefFoul();
                                    FFAppState().liveDefFoul = 0;

                                    FFAppState().deleteLiveTurnover();
                                    FFAppState().liveTurnover = 0;

                                    FFAppState().liveGameStatus = false;
                                    FFAppState().deleteLiveGameID();
                                    FFAppState().liveGameID = '';

                                    FFAppState().deleteLivePlayerID();
                                    FFAppState().livePlayerID = '';

                                    FFAppState().deleteLiveName();
                                    FFAppState().liveName = '';

                                    FFAppState().deleteLiveOppTeam();
                                    FFAppState().liveOppTeam = '';

                                    FFAppState().customAlertDialog = false;
                                    FFAppState().gameCompleteStatus = 'Done';
                                    FFAppState().update(() {});
                                    await Future.delayed(
                                      Duration(
                                        milliseconds: 300,
                                      ),
                                    );

                                    context.pushNamed(
                                      HomeWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                          duration: Duration(milliseconds: 400),
                                        ),
                                      },
                                    );
                                  } else {
                                    if (_shouldSetState) safeSetState(() {});
                                    return;
                                  }

                                  if (FFAppState().ratingDelayed) {
                                    if ((FFAppState().ratingDone == false) &&
                                        functions.checkDateThreshold(
                                            FFAppState().ratingDate, 30)!) {
                                      await showDialog(
                                        barrierColor:
                                            FlutterFlowTheme.of(context)
                                                .bottomSheetBg,
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            alignment: AlignmentDirectional(
                                                    0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                            child: GestureDetector(
                                              onTap: () {
                                                FocusScope.of(dialogContext)
                                                    .unfocus();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              child: AlertRateWidget(),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      if (_shouldSetState) safeSetState(() {});
                                      return;
                                    }
                                  } else {
                                    await showDialog(
                                      barrierColor: FlutterFlowTheme.of(context)
                                          .bottomSheetBg,
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          alignment: AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          child: GestureDetector(
                                            onTap: () {
                                              FocusScope.of(dialogContext)
                                                  .unfocus();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: AlertRateWidget(),
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  if (_shouldSetState) safeSetState(() {});
                                },
                                text: 'Game Complete',
                                icon: Icon(
                                  Icons.check,
                                  size: 28.0,
                                ),
                                options: FFButtonOptions(
                                  height: 60.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconAlignment: IconAlignment.start,
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.ibmPlexSans(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'buttonOnActionTriggerAnimation']!,
                                  hasBeenTriggered: hasButtonTriggered),
                            ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) => InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(dialogContext)
                                                .unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            child: AlertDialogWidget(
                                              title: 'Reset Game Stats?',
                                              message:
                                                  'Reset will clear all recorded stats for this game. Do you wish to continue?',
                                              confirmLabel: 'Yes, clear.',
                                              dismissLabel: 'No',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  if (FFAppState().customAlertDialog == true) {
                                    // Clear State
                                    FFAppState().deleteLiveFgMade();
                                    FFAppState().liveFgMade = 0;

                                    FFAppState().deleteLiveFgAttempt();
                                    FFAppState().liveFgAttempt = 0;

                                    FFAppState().deleteLiveTwoMade();
                                    FFAppState().liveTwoMade = 0;

                                    FFAppState().deleteLiveTwoAttempt();
                                    FFAppState().liveTwoAttempt = 0;

                                    FFAppState().deleteLiveThreeMade();
                                    FFAppState().liveThreeMade = 0;

                                    FFAppState().deleteLiveThreeAttempt();
                                    FFAppState().liveThreeAttempt = 0;

                                    FFAppState().deleteLiveFtMade();
                                    FFAppState().liveFtMade = 0;

                                    FFAppState().deleteLiveFtAttempt();
                                    FFAppState().liveFtAttempt = 0;

                                    FFAppState().deleteLiveMissedTwo();
                                    FFAppState().liveMissedTwo = 0;

                                    FFAppState().deleteLiveMissedThree();
                                    FFAppState().liveMissedThree = 0;

                                    FFAppState().deleteLiveMissedOne();
                                    FFAppState().liveMissedOne = 0;

                                    FFAppState().deleteLivePoints();
                                    FFAppState().livePoints = 0;

                                    FFAppState().deleteLiveOffReb();
                                    FFAppState().liveOffReb = 0;

                                    FFAppState().deleteLiveDefReb();
                                    FFAppState().liveDefReb = 0;

                                    FFAppState().deleteLiveAssist();
                                    FFAppState().liveAssist = 0;

                                    FFAppState().deleteLiveSteals();
                                    FFAppState().liveSteals = 0;

                                    FFAppState().deleteLiveBlocks();
                                    FFAppState().liveBlocks = 0;

                                    FFAppState().deleteLiveOffFoul();
                                    FFAppState().liveOffFoul = 0;

                                    FFAppState().deleteLiveDefFoul();
                                    FFAppState().liveDefFoul = 0;

                                    FFAppState().deleteLiveTurnover();
                                    FFAppState().liveTurnover = 0;

                                    FFAppState().customAlertDialog = false;
                                    safeSetState(() {});
                                    // Snack Bar
                                    FFAppState().msg =
                                        'Game stats have been reset.';
                                    FFAppState().showsnackbard = true;
                                    FFAppState().msgtype = true;
                                    FFAppState().update(() {});
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  height: 60.0,
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restart_alt_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 28.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 2.0, 0.0, 0.0),
                                        child: Text(
                                          'Reset',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .gray1,
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Color(0xCD161616),
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: GamePausedWidget(),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                              child: Container(
                                height: 60.0,
                                decoration: BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pause_sharp,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 28.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        'Pause',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.ibmPlexSans(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .gray1,
                                              fontSize: 13.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) => InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(dialogContext)
                                                .unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            child: AlertDialogWidget(
                                              title: 'Stop Current Game?',
                                              message:
                                                  'You\'ll lose any unfinished stats. Do you wish to proceed?',
                                              confirmLabel: 'Yes, proceed.',
                                              dismissLabel: 'No',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  if (FFAppState().customAlertDialog == true) {
                                    // Clear State
                                    FFAppState().deleteLiveFgMade();
                                    FFAppState().liveFgMade = 0;

                                    FFAppState().deleteLiveFgAttempt();
                                    FFAppState().liveFgAttempt = 0;

                                    FFAppState().deleteLiveTwoMade();
                                    FFAppState().liveTwoMade = 0;

                                    FFAppState().deleteLiveTwoAttempt();
                                    FFAppState().liveTwoAttempt = 0;

                                    FFAppState().deleteLiveThreeMade();
                                    FFAppState().liveThreeMade = 0;

                                    FFAppState().deleteLiveThreeAttempt();
                                    FFAppState().liveThreeAttempt = 0;

                                    FFAppState().deleteLiveFtMade();
                                    FFAppState().liveFtMade = 0;

                                    FFAppState().deleteLiveFtAttempt();
                                    FFAppState().liveFtAttempt = 0;

                                    FFAppState().deleteLiveMissedTwo();
                                    FFAppState().liveMissedTwo = 0;

                                    FFAppState().deleteLiveMissedThree();
                                    FFAppState().liveMissedThree = 0;

                                    FFAppState().deleteLiveMissedOne();
                                    FFAppState().liveMissedOne = 0;

                                    FFAppState().deleteLivePoints();
                                    FFAppState().livePoints = 0;

                                    FFAppState().deleteLiveOffReb();
                                    FFAppState().liveOffReb = 0;

                                    FFAppState().deleteLiveDefReb();
                                    FFAppState().liveDefReb = 0;

                                    FFAppState().deleteLiveAssist();
                                    FFAppState().liveAssist = 0;

                                    FFAppState().deleteLiveSteals();
                                    FFAppState().liveSteals = 0;

                                    FFAppState().deleteLiveBlocks();
                                    FFAppState().liveBlocks = 0;

                                    FFAppState().deleteLiveOffFoul();
                                    FFAppState().liveOffFoul = 0;

                                    FFAppState().deleteLiveDefFoul();
                                    FFAppState().liveDefFoul = 0;

                                    FFAppState().deleteLiveTurnover();
                                    FFAppState().liveTurnover = 0;

                                    FFAppState().liveGameStatus = false;
                                    FFAppState().deleteLiveGameID();
                                    FFAppState().liveGameID = '';

                                    FFAppState().deleteLivePlayerID();
                                    FFAppState().livePlayerID = '';

                                    FFAppState().deleteLiveName();
                                    FFAppState().liveName = '';

                                    FFAppState().deleteLiveOppTeam();
                                    FFAppState().liveOppTeam = '';

                                    safeSetState(() {});

                                    context.goNamed(
                                      HomeWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                          duration: Duration(milliseconds: 400),
                                        ),
                                      },
                                    );

                                    FFAppState().msg =
                                        'Game stats for live games deleted.';
                                    FFAppState().showsnackbard = true;
                                    FFAppState().msgtype = true;
                                    FFAppState().update(() {});
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  height: 60.0,
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_forever_sharp,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 28.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 2.0, 0.0, 0.0),
                                        child: Text(
                                          'Delete',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.ibmPlexSans(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .gray1,
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                  ].divide(SizedBox(height: 6.0)),
                ),
              ),
              if (FFAppState().showsnackbard == true)
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                    child: wrapWithModel(
                      model: _model.customSnackBarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: CustomSnackBarWidget(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
