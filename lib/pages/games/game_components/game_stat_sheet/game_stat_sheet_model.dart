import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/games/game_components/game_insights_info/game_insights_info_widget.dart';
import '/pages/global/alert_dialog/alert_dialog_widget.dart';
import '/pages/global/informational_dialog/informational_dialog_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'game_stat_sheet_widget.dart' show GameStatSheetWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class GameStatSheetModel extends FlutterFlowModel<GameStatSheetWidget> {
  ///  Local state fields for this component.

  double? pssa;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
