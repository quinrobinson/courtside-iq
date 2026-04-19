import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/games/game_components/event_selection/event_selection_widget.dart';
import '/pages/games/game_components/new_event/new_event_widget.dart';
import '/pages/games/game_components/team_selection/team_selection_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/players/player_components/new_player/new_player_widget.dart';
import '/pages/players/player_components/new_team/new_team_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'new_game_widget.dart' show NewGameWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewGameModel extends FlutterFlowModel<NewGameWidget> {
  ///  Local state fields for this page.

  String? selectedPlayerID = ' All Players';

  String? selectedTeam;

  String? selectedEvent;

  String? selectedName;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in NewGame widget.
  List<PlayerListViewRow>? userPlayerList;
  // State field(s) for opponentTeam widget.
  FocusNode? opponentTeamFocusNode;
  TextEditingController? opponentTeamTextController;
  String? Function(BuildContext, String?)? opponentTeamTextControllerValidator;
  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    opponentTeamFocusNode?.dispose();
    opponentTeamTextController?.dispose();

    customSnackBarModel.dispose();
  }
}
