import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'reset_password_widget.dart' show ResetPasswordWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ResetPasswordModel extends FlutterFlowModel<ResetPasswordWidget> {
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

  final formKey = GlobalKey<FormState>();
  // State field(s) for newPW widget.
  FocusNode? newPWFocusNode;
  TextEditingController? newPWTextController;
  late bool newPWVisibility;
  String? Function(BuildContext, String?)? newPWTextControllerValidator;
  String? _newPWTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'NEW PASSWORD is required';
    }

    if (val.length < 6) {
      return 'Requires at least 6 characters.';
    }

    return null;
  }

  // State field(s) for confirmNewPW widget.
  FocusNode? confirmNewPWFocusNode;
  TextEditingController? confirmNewPWTextController;
  late bool confirmNewPWVisibility;
  String? Function(BuildContext, String?)? confirmNewPWTextControllerValidator;
  String? _confirmNewPWTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'CONFIRM NEW PASSWORD is required';
    }

    if (val.length < 6) {
      return 'Requires at least 6 characters.';
    }

    return null;
  }

  // Stores action output result for [Custom Action - updatePassword] action in Button widget.
  String? error;

  @override
  void initState(BuildContext context) {
    newPWVisibility = false;
    newPWTextControllerValidator = _newPWTextControllerValidator;
    confirmNewPWVisibility = false;
    confirmNewPWTextControllerValidator = _confirmNewPWTextControllerValidator;
  }

  @override
  void dispose() {
    newPWFocusNode?.dispose();
    newPWTextController?.dispose();

    confirmNewPWFocusNode?.dispose();
    confirmNewPWTextController?.dispose();
  }
}
