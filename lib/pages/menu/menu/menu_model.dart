import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/alert_rate/alert_rate_widget.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'menu_widget.dart' show MenuWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MenuModel extends FlutterFlowModel<MenuWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Menu widget.
  List<PlayersRow>? getActivePlayers;
  // Stores action output result for [Custom Action - logoutOfRevenueCat] action in Container widget.
  bool? loginToRevenueCat;
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
