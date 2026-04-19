import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/global/empty_states/empty_players_list/empty_players_list_widget.dart';
import '/pages/global/informational_dialog/informational_dialog_widget.dart';
import '/pages/players/player_components/new_player/new_player_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'players_list_widget.dart' show PlayersListWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class PlayersListModel extends FlutterFlowModel<PlayersListWidget> {
  ///  Local state fields for this page.

  int? playerCount;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in PlayersList widget.
  List<PlayersRow>? getActivePlayersCount;
  // Model for CustomNavBar component.
  late CustomNavBarModel customNavBarModel;
  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    customNavBarModel = createModel(context, () => CustomNavBarModel());
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    customNavBarModel.dispose();
    customSnackBarModel.dispose();
  }
}
