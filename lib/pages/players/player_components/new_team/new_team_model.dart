import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'new_team_widget.dart' show NewTeamWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewTeamModel extends FlutterFlowModel<NewTeamWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for teamName widget.
  FocusNode? teamNameFocusNode;
  TextEditingController? teamNameTextController;
  String? Function(BuildContext, String?)? teamNameTextControllerValidator;
  String? _teamNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Team name is required';
    }

    return null;
  }

  // Stores action output result for [Backend Call - Insert Row] action in SaveTeamButton widget.
  PlayerTeamsRow? addTeam;

  @override
  void initState(BuildContext context) {
    teamNameTextControllerValidator = _teamNameTextControllerValidator;
  }

  @override
  void dispose() {
    teamNameFocusNode?.dispose();
    teamNameTextController?.dispose();
  }
}
