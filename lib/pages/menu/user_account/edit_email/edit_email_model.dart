import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'edit_email_widget.dart' show EditEmailWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditEmailModel extends FlutterFlowModel<EditEmailWidget> {
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
  // State field(s) for userEmail widget.
  FocusNode? userEmailFocusNode;
  TextEditingController? userEmailTextController;
  String? Function(BuildContext, String?)? userEmailTextControllerValidator;

  @override
  void initState(BuildContext context) {
    subPgHeaderModel = createModel(context, () => SubPgHeaderModel());
  }

  @override
  void dispose() {
    subPgHeaderModel.dispose();
    userEmailFocusNode?.dispose();
    userEmailTextController?.dispose();
  }
}
