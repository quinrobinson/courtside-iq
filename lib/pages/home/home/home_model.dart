import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/bottom_sheets/new_live_game/new_live_game_widget.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/global/empty_states/no_games/no_games_widget.dart';
import '/pages/global/informational_dialog/informational_dialog_widget.dart';
import '/pages/players/player_components/new_player/new_player_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Home widget.
  List<PlayersRow>? getActivePlayers;
  // Stores action output result for [Backend Call - Query Rows] action in Home widget.
  List<GamesRow>? getActiveGames;
  // Stores action output result for [Backend Call - Query Rows] action in Home widget.
  List<UsersRow>? getUserName;
  // Stores action output result for [Custom Action - loginToRevenueCat] action in Home widget.
  bool? revenueCatLogin;
  // Models for NoGames dynamic component.
  late FlutterFlowDynamicModels<NoGamesModel> noGamesModels;
  // Model for CustomNavBar component.
  late CustomNavBarModel customNavBarModel;
  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    noGamesModels = FlutterFlowDynamicModels(() => NoGamesModel());
    customNavBarModel = createModel(context, () => CustomNavBarModel());
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    noGamesModels.dispose();
    customNavBarModel.dispose();
    customSnackBarModel.dispose();
  }
}
