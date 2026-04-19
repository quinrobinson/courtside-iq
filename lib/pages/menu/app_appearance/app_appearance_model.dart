import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'app_appearance_widget.dart' show AppAppearanceWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppAppearanceModel extends FlutterFlowModel<AppAppearanceWidget> {
  ///  Local state fields for this page.

  String? selectedPlayerID = ' All Players';

  bool? allPlayers = true;

  bool? playerOne = true;

  bool? playerTwo = true;

  bool? playerThree = true;

  bool? playerOneSet;

  bool? playerTwoSet;

  bool? playerThreeSet;

  ///  State fields for stateful widgets in this page.

  // Model for SubPgHeader component.
  late SubPgHeaderModel subPgHeaderModel;

  @override
  void initState(BuildContext context) {
    subPgHeaderModel = createModel(context, () => SubPgHeaderModel());
  }

  @override
  void dispose() {
    subPgHeaderModel.dispose();
  }
}
