import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import '/pages/menu/menu_components/custom_accordion/custom_accordion_widget.dart';
import 'dart:ui';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'help_center_model.dart';
export 'help_center_model.dart';

class HelpCenterWidget extends StatefulWidget {
  const HelpCenterWidget({super.key});

  static String routeName = 'HelpCenter';
  static String routePath = '/helpCenter';

  @override
  State<HelpCenterWidget> createState() => _HelpCenterWidgetState();
}

class _HelpCenterWidgetState extends State<HelpCenterWidget> {
  late HelpCenterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HelpCenterModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).globalBackground,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                  child: wrapWithModel(
                    model: _model.subPgHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SubPgHeaderWidget(
                      pageTitle: 'Help Center',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 6.0, 0.0, 6.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'GETTING STARTED',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 14.0,
                                                    letterSpacing: 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'What stats can I track?',
                                      body:
                                          'CourtSide IQ lets you track the essentials: points, rebounds, assists, steals, blocks, and turnovers.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'How do I track a game?',
                                      body:
                                          'Open the app, tap “+” in the bottom navigation and select New Game. Complete player selection and game details. Now you are ready to log points, rebounds, assists, steals, and more.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'How many players can I add?',
                                      body:
                                          'You can create up to 3 player profiles per account. This is perfect for parents with multiple kids or trainers working with one or two athletes.',
                                    ),
                                  ),
                                ].divide(SizedBox(height: 6.0)),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 6.0, 0.0, 6.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'SUBSCRIPTION & PAYMENTS',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 14.0,
                                                    letterSpacing: 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header:
                                          'What does the subscription include?',
                                      body:
                                          'Both the weekly and monthly plans include full access to all features: live stat tracking, unlimited game history, up to 3 player profiles, season averages, and AI performance insights per game.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'How much does it cost?',
                                      body:
                                          'You can choose between \$1.99 per week or \$5.99 per month. The monthly plan is the best value if you will be using the app all season.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel6,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'Is there a free trial?',
                                      body:
                                          'Yes! Every new Courtside IQ subscriber gets a 7-day free trial. No charge until your trial ends, and if you cancel before then, you won\'t be billed. The free trial is available for first-time subscribers on the monthly plan.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel7,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header:
                                          'How do I manage or cancel my subscription?',
                                      body:
                                          'You can manage your subscription directly in the app by going to Menu and tapping Manage Your Subscription. To cancel on an Apple device, go to your Apple Account settings and select Subscriptions. On Android, open Google Play, go to Subscriptions, and select Courtside IQ. If you need help, contact us and we\'ll walk you through it.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel8,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'Can I get a refund?',
                                      body:
                                          'Yes. Refunds are handled by the app store where you originally subscribed.',
                                    ),
                                  ),
                                ].divide(SizedBox(height: 6.0)),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 6.0, 0.0, 6.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'FEATURES & USAGE',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 14.0,
                                                    letterSpacing: 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel9,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'When should I use Courtside IQ?',
                                      body:
                                          'Courtside IQ is designed to be used during live games, and that\'s where you\'ll get the most out of it. Just tap as the action happens and the app takes care of the rest. ',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel10,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header:
                                          'What features are included in the app?',
                                      body:
                                          '- Create and manage up to 3 player profiles\n- Log unlimited games\n- Track key stats like points, rebounds, etc.\n- View averages and game history\n- AI performance insights for games\n- Keep everything organized in one simple app',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel11,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header:
                                          'Can I track more than one player?',
                                      body:
                                          'Yes. You can manage up to 3 player profiles in your account. Each player has their own history and averages so you can keep progress separate.',
                                    ),
                                  ),
                                ].divide(SizedBox(height: 6.0)),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 6.0, 0.0, 6.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'PRIVACY & SECURITY',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 16.0,
                                                    letterSpacing: 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel12,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header: 'Is my data safe?',
                                      body:
                                          'Yes. Your stats and player information are stored securely and never sold or shared. You stay in control of your data at all times.',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.customAccordionModel13,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CustomAccordionWidget(
                                      header:
                                          'What happens if I delete my account?',
                                      body:
                                          'If you delete your account, all of your data will be permanently removed from our system. You can request deletion from your Account profile page. Please note that deleting your account does not cancel your subscription. To avoid future charges, make sure to cancel your subscription through your app store before deleting your account.',
                                    ),
                                  ),
                                ].divide(SizedBox(height: 6.0)),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 12.0)).addToEnd(SizedBox(
                                height: valueOrDefault<double>(
                              isAndroid ? 60.0 : 34.0,
                              34.0,
                            ))),
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 2.0)).addToEnd(SizedBox(height: 12.0)),
            ),
          ),
        ),
      ),
    );
  }
}
