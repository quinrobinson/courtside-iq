import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import 'dart:ui';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edit_player_position_model.dart';
export 'edit_player_position_model.dart';

class EditPlayerPositionWidget extends StatefulWidget {
  const EditPlayerPositionWidget({
    super.key,
    required this.playerID,
    required this.playerPosition,
  });

  final String? playerID;
  final String? playerPosition;

  static String routeName = 'EditPlayerPosition';
  static String routePath = '/editPlayerPosition';

  @override
  State<EditPlayerPositionWidget> createState() =>
      _EditPlayerPositionWidgetState();
}

class _EditPlayerPositionWidgetState extends State<EditPlayerPositionWidget> {
  late EditPlayerPositionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditPlayerPositionModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.newPlayerPosition = widget!.playerPosition;
      safeSetState(() {});
    });

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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                wrapWithModel(
                  model: _model.subPgHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: SubPgHeaderWidget(
                    pageTitle: 'Edit Position',
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).gray4,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 12.0, 12.0, 12.0),
                            child: Container(
                              height: 318.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).gray4,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Container(
                                height: 318.0,
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 0.0, 8.0, 0.0),
                                      child: FutureBuilder<
                                          List<PlayerPositionsListRow>>(
                                        future: PlayerPositionsListTable()
                                            .queryRows(
                                          queryFn: (q) => q,
                                        ),
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child: SpinKitFadingFour(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .teal,
                                                  size: 30.0,
                                                ),
                                              ),
                                            );
                                          }
                                          List<PlayerPositionsListRow>
                                              listViewPlayerPositionsListRowList =
                                              snapshot.data!;

                                          return ListView.separated(
                                            padding: EdgeInsets.fromLTRB(
                                              0,
                                              12.0,
                                              0,
                                              12.0,
                                            ),
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount:
                                                listViewPlayerPositionsListRowList
                                                    .length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 0.0),
                                            itemBuilder:
                                                (context, listViewIndex) {
                                              final listViewPlayerPositionsListRow =
                                                  listViewPlayerPositionsListRowList[
                                                      listViewIndex];
                                              return InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  _model.newPlayerPosition =
                                                      listViewPlayerPositionsListRow
                                                          .positionName;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  height: 42.0,
                                                  decoration: BoxDecoration(
                                                    color: _model
                                                                .newPlayerPosition ==
                                                            listViewPlayerPositionsListRow
                                                                .positionName
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .teal
                                                        : Color(0x00000000),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(9.0, 0.0,
                                                                9.0, 0.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        listViewPlayerPositionsListRow
                                                            .positionName,
                                                        '[position name]',
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .ibmPlexSans(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 1.0)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FFButtonWidget(
                              onPressed: (_model.newPlayerPosition ==
                                      widget!.playerPosition)
                                  ? null
                                  : () async {
                                      await PlayersTable().update(
                                        data: {
                                          'player_position':
                                              _model.newPlayerPosition,
                                        },
                                        matchingRows: (rows) => rows.eqOrNull(
                                          'id',
                                          widget!.playerID,
                                        ),
                                      );
                                      context.safePop();
                                      FFAppState().msg =
                                          'Player position has been updated!';
                                      FFAppState().showsnackbard = true;
                                      FFAppState().msgtype = true;
                                      FFAppState().update(() {});
                                    },
                              text: 'Update',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primaryText,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.ibmPlexSans(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(12.0),
                                disabledColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                disabledTextColor:
                                    FlutterFlowTheme.of(context).gray3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 1.0)),
            ),
          ),
        ),
      ),
    );
  }
}
