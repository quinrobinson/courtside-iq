import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/menu_list_empty_state/menu_list_empty_state_widget.dart';
import '/pages/players/player_components/new_team/new_team_widget.dart';
import 'dart:ui';
import 'team_selection_widget.dart' show TeamSelectionWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TeamSelectionModel extends FlutterFlowModel<TeamSelectionWidget> {
  ///  Local state fields for this component.

  String? teamSelection;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
