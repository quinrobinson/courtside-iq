import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'edit_game_stat_widget.dart' show EditGameStatWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class EditGameStatModel extends FlutterFlowModel<EditGameStatWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for EditAnimation widget.
  late bool editAnimationStatus;

  @override
  void initState(BuildContext context) {
    editAnimationStatus = false;
  }

  @override
  void dispose() {}
}
