import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/menu/menu_components/custom_accordion/custom_accordion_widget.dart';
import 'dart:ui';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/index.dart';
import 'paywall_widget.dart' show PaywallWidget;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaywallModel extends FlutterFlowModel<PaywallWidget> {
  ///  Local state fields for this component.

  String selectedPlan = 'monthly';

  ///  State fields for stateful widgets in this component.

  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel1;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel2;
  // Model for CustomAccordion component.
  late CustomAccordionModel customAccordionModel3;
  // Stores action output result for [RevenueCat - Purchase] action in Button widget.
  bool? iosMonthlyPurchaseSuccessful;
  // Stores action output result for [RevenueCat - Purchase] action in Button widget.
  bool? androidMonthlyPurchaseSuccessful;
  // Stores action output result for [RevenueCat - Purchase] action in Button widget.
  bool? iosWeeklyPurchaseSuccessful;
  // Stores action output result for [RevenueCat - Purchase] action in Button widget.
  bool? androidWeeklyPurchaseSuccessful;
  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    customAccordionModel1 = createModel(context, () => CustomAccordionModel());
    customAccordionModel2 = createModel(context, () => CustomAccordionModel());
    customAccordionModel3 = createModel(context, () => CustomAccordionModel());
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    customAccordionModel1.dispose();
    customAccordionModel2.dispose();
    customAccordionModel3.dispose();
    customSnackBarModel.dispose();
  }
}
