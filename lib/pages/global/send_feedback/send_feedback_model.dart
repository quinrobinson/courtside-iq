import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import 'dart:ui';
import 'send_feedback_widget.dart' show SendFeedbackWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SendFeedbackModel extends FlutterFlowModel<SendFeedbackWidget> {
  ///  Local state fields for this page.

  String? rateStatus;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for SubPgHeader component.
  late SubPgHeaderModel subPgHeaderModel;
  // State field(s) for userFeedback widget.
  FocusNode? userFeedbackFocusNode;
  TextEditingController? userFeedbackTextController;
  String? Function(BuildContext, String?)? userFeedbackTextControllerValidator;
  String? _userFeedbackTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Detailed feedback is required';
    }

    return null;
  }

  // State field(s) for userEmail widget.
  FocusNode? userEmailFocusNode;
  TextEditingController? userEmailTextController;
  String? Function(BuildContext, String?)? userEmailTextControllerValidator;

  @override
  void initState(BuildContext context) {
    subPgHeaderModel = createModel(context, () => SubPgHeaderModel());
    userFeedbackTextControllerValidator = _userFeedbackTextControllerValidator;
  }

  @override
  void dispose() {
    subPgHeaderModel.dispose();
    userFeedbackFocusNode?.dispose();
    userFeedbackTextController?.dispose();

    userEmailFocusNode?.dispose();
    userEmailTextController?.dispose();
  }
}
