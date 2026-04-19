import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/global/empty_states/no_games/no_games_widget.dart';
import '/pages/global/header_player_profile/header_player_profile_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'players_profile_widget.dart' show PlayersProfileWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class PlayersProfileModel extends FlutterFlowModel<PlayersProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in PlayersProfile widget.
  List<PlayerProfileViewRow>? playerProfile;
  // Stores action output result for [Backend Call - Query Rows] action in PlayersProfile widget.
  List<VPlayerGameStatsRow>? playerGameStats;
  // Model for HeaderPlayerProfile component.
  late HeaderPlayerProfileModel headerPlayerProfileModel;
  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;
  // Model for CustomNavBar component.
  late CustomNavBarModel customNavBarModel;

  @override
  void initState(BuildContext context) {
    headerPlayerProfileModel =
        createModel(context, () => HeaderPlayerProfileModel());
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
    customNavBarModel = createModel(context, () => CustomNavBarModel());
  }

  @override
  void dispose() {
    headerPlayerProfileModel.dispose();
    customSnackBarModel.dispose();
    customNavBarModel.dispose();
  }
}
