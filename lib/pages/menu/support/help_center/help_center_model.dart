import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import '/pages/menu/menu_components/custom_accordion/custom_accordion_widget.dart';
import 'dart:ui';
import 'help_center_widget.dart' show HelpCenterWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HelpCenterModel extends FlutterFlowModel<HelpCenterWidget> {
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
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel1;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel2;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel3;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel4;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel5;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel6;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel7;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel8;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel9;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel10;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel11;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel12;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel13;

  @override
  void initState(BuildContext context) {
    subPgHeaderModel = createModel(context, () => SubPgHeaderModel());
    customAccordionModel1 = createModel(context, () => CustomAccordionModel());
    customAccordionModel2 = createModel(context, () => CustomAccordionModel());
    customAccordionModel3 = createModel(context, () => CustomAccordionModel());
    customAccordionModel4 = createModel(context, () => CustomAccordionModel());
    customAccordionModel5 = createModel(context, () => CustomAccordionModel());
    customAccordionModel6 = createModel(context, () => CustomAccordionModel());
    customAccordionModel7 = createModel(context, () => CustomAccordionModel());
    customAccordionModel8 = createModel(context, () => CustomAccordionModel());
    customAccordionModel9 = createModel(context, () => CustomAccordionModel());
    customAccordionModel10 = createModel(context, () => CustomAccordionModel());
    customAccordionModel11 = createModel(context, () => CustomAccordionModel());
    customAccordionModel12 = createModel(context, () => CustomAccordionModel());
    customAccordionModel13 = createModel(context, () => CustomAccordionModel());
  }

  @override
  void dispose() {
    subPgHeaderModel.dispose();
    customAccordionModel1.dispose();
    customAccordionModel2.dispose();
    customAccordionModel3.dispose();
    customAccordionModel4.dispose();
    customAccordionModel5.dispose();
    customAccordionModel6.dispose();
    customAccordionModel7.dispose();
    customAccordionModel8.dispose();
    customAccordionModel9.dispose();
    customAccordionModel10.dispose();
    customAccordionModel11.dispose();
    customAccordionModel12.dispose();
    customAccordionModel13.dispose();
  }
}
