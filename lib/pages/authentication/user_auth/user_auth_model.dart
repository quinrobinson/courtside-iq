import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'user_auth_widget.dart' show UserAuthWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserAuthModel extends FlutterFlowModel<UserAuthWidget> {
  ///  Local state fields for this page.

  bool staterSelected = true;

  bool gameChangerSelected = true;

  ///  State fields for stateful widgets in this page.

  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    customSnackBarModel.dispose();
  }
}
