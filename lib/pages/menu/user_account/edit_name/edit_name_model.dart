import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import 'dart:ui';
import 'edit_name_widget.dart' show EditNameWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditNameModel extends FlutterFlowModel<EditNameWidget> {
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
  // State field(s) for userName widget.
  FocusNode? userNameFocusNode1;
  TextEditingController? userNameTextController1;
  String? Function(BuildContext, String?)? userNameTextController1Validator;
  // State field(s) for userName widget.
  FocusNode? userNameFocusNode2;
  TextEditingController? userNameTextController2;
  String? Function(BuildContext, String?)? userNameTextController2Validator;

  @override
  void initState(BuildContext context) {
    subPgHeaderModel = createModel(context, () => SubPgHeaderModel());
  }

  @override
  void dispose() {
    subPgHeaderModel.dispose();
    userNameFocusNode1?.dispose();
    userNameTextController1?.dispose();

    userNameFocusNode2?.dispose();
    userNameTextController2?.dispose();
  }
}
