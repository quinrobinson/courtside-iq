import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/skeleton_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/games/game_components/event_selection/event_selection_widget.dart';
import '/pages/games/game_components/new_event/new_event_widget.dart';
import '/pages/games/game_components/team_selection/team_selection_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/features/players/add_player_sheet.dart';
import '/features/players/picker_sheet.dart';
import '/pages/players/player_components/new_team/new_team_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'new_game_model.dart';
export 'new_game_model.dart';

class NewGameWidget extends StatefulWidget {
  const NewGameWidget({super.key});

  static String routeName = 'NewGame';
  static String routePath = '/newGame';

  @override
  State<NewGameWidget> createState() => _NewGameWidgetState();
}

class _NewGameWidgetState extends State<NewGameWidget> {
  late NewGameModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewGameModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.userPlayerList = await PlayerListViewTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'user_id',
          currentUserUid,
        ),
      );

      safeSetState(() {});
    });

    _model.opponentTeamTextController ??= TextEditingController();
    _model.opponentTeamFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<List<PlayersRow>>(
      future: PlayersTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'user_id',
          currentUserUid,
        ),
        limit: 3,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).globalBackground,
            body: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                24.0,
                valueOrDefault<double>(isAndroid ? 24.0 : 66.0, 66.0) + 12.0,
                24.0,
                0.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const SkeletonBox(width: 120, height: 28, radius: 8),
                  const SizedBox(height: 20),
                  // PLAYERS label
                  const SkeletonBox(width: 64, height: 11, radius: 4),
                  const SizedBox(height: 8),
                  // Player cards row
                  Row(children: [
                    const SkeletonBox(width: 81, height: 100),
                    const SizedBox(width: 6),
                    const SkeletonBox(width: 81, height: 100),
                    const SizedBox(width: 6),
                    const SkeletonBox(width: 81, height: 100),
                  ]),
                  const SizedBox(height: 20),
                  // OPPONENT label + field
                  const SkeletonBox(width: 80, height: 11, radius: 4),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: double.infinity, height: 56),
                  const SizedBox(height: 20),
                  // TEAMS label + field
                  const SkeletonBox(width: 52, height: 11, radius: 4),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: double.infinity, height: 56),
                  const SizedBox(height: 20),
                  // EVENTS label + field
                  const SkeletonBox(width: 60, height: 11, radius: 4),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: double.infinity, height: 56),
                ],
              ),
            ),
          );
        }
        List<PlayersRow> newGamePlayersRowList = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).globalBackground,
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      valueOrDefault<double>(
                        isAndroid ? 24.0 : 66.0,
                        66.0,
                      ),
                      0.0,
                      0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).globalBackground,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).globalBackground,
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 12.0, 24.0, 0.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'New Game',
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineSmall
                                              .override(
                                                font: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineSmall
                                                          .fontStyle,
                                                ),
                                                fontSize: 24.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 1.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 6.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  6.0),
                                                      child: Text(
                                                        'PLAYERS',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .montserrat(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .gray1,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      1.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 100.0,
                                              decoration: BoxDecoration(),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 0.0, 7.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Builder(
                                                        builder: (context) {
                                                          final newGameVar =
                                                              newGamePlayersRowList
                                                                  .toList();

                                                          return ListView
                                                              .separated(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                newGameVar
                                                                    .length,
                                                            separatorBuilder: (_,
                                                                    __) =>
                                                                SizedBox(
                                                                    width: 6.0),
                                                            itemBuilder: (context,
                                                                newGameVarIndex) {
                                                              final newGameVarItem =
                                                                  newGameVar[
                                                                      newGameVarIndex];
                                                              return InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  _model.selectedPlayerID =
                                                                      newGameVarItem
                                                                          .id;
                                                                  _model.selectedTeam =
                                                                      null;
                                                                  _model.selectedEvent =
                                                                      null;
                                                                  _model.selectedName =
                                                                      newGameVarItem
                                                                          .firstName;
                                                                  safeSetState(
                                                                      () {});
                                                                  _model
                                                                      .opponentTeamTextController
                                                                      ?.clear();
                                                                },
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    functions
                                                                        .playerTileWidth(
                                                                            newGamePlayersRowList.length)
                                                                        .toDouble(),
                                                                    81.0,
                                                                  ),
                                                                  height: 100.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                    borderRadius:
                                                                        BorderRadius.circular(6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        _model.selectedName ==
                                                                                newGameVarItem.firstName
                                                                            ? FlutterFlowTheme.of(context).primaryText
                                                                            : FlutterFlowTheme.of(context).secondaryBackground,
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                      ),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            8.0,
                                                                            12.0,
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children:
                                                                          [
                                                                        Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            if (newGameVarItem.playerProfilePic == null ||
                                                                                newGameVarItem.playerProfilePic == '')
                                                                              Container(
                                                                                width: 46.0,
                                                                                height: 46.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  borderRadius: BorderRadius.circular(9999.0),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.person,
                                                                                      color: FlutterFlowTheme.of(context).gray2,
                                                                                      size: 24.0,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            if (newGameVarItem.playerProfilePic != null &&
                                                                                newGameVarItem.playerProfilePic != '')
                                                                              Container(
                                                                                width: 46.0,
                                                                                height: 46.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  borderRadius: BorderRadius.circular(9999.0),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(9999.0),
                                                                                      child: Image.network(
                                                                                        newGameVarItem.playerProfilePic!,
                                                                                        width: 46.0,
                                                                                        height: 46.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  valueOrDefault<String>(
                                                                                    newGameVarItem.firstName,
                                                                                    'Name',
                                                                                  ).maybeHandleOverflow(
                                                                                    maxChars: 10,
                                                                                    replacement: '…',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.ibmPlexSans(
                                                                                          fontWeight: FontWeight.normal,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        fontSize: 14.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.normal,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 6.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if ((_model.userPlayerList
                                                            ?.length ??
                                                        0) <=
                                                    2)
                                                  Expanded(
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        await showAddPlayerSheet(
                                                                context)
                                                            .then((value) =>
                                                                safeSetState(
                                                                    () {}));
                                                      },
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 50.0,
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 110.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          borderRadius:
                                                              BorderRadius.circular(6.0),
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.add_circle,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Opacity(
                                            opacity: valueOrDefault<double>(
                                              _model.selectedName != null &&
                                                      _model.selectedName != ''
                                                  ? 1.0
                                                  : 0.5,
                                              1.0,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 1.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: const BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            12.0),
                                                                child: Text(
                                                                  'TEAMS',
                                                                  style: const TextStyle(
                                                                    fontFamily: 'IBM Plex Sans',
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.w600,
                                                                    letterSpacing: 1.2,
                                                                    color: Color(0xFF1A1A1A),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    if (_model.selectedName !=
                                                                            null &&
                                                                        _model.selectedName !=
                                                                            '') {
                                                                      final rows =
                                                                          await PlayerTeamsTable()
                                                                              .queryRows(
                                                                        queryFn: (q) => q
                                                                            .eqOrNull('player_id', _model.selectedPlayerID)
                                                                            .eqOrNull('user_id', currentUserUid),
                                                                      );
                                                                      final teams = rows
                                                                          .map((r) => r.teamName ?? '')
                                                                          .where((t) => t.isNotEmpty)
                                                                          .toList();
                                                                      if (!mounted) return;
                                                                      final picked =
                                                                          await presentPickerSheet<
                                                                              String>(
                                                                        context,
                                                                        title: 'Select team',
                                                                        options: teams,
                                                                        labelOf: (t) => t,
                                                                        current: _model.selectedTeam,
                                                                      );
                                                                      if (picked != null) {
                                                                        _model.selectedTeam = picked;
                                                                        safeSetState(() {});
                                                                      }
                                                                      return;
                                                                    } else {
                                                                      FFAppState()
                                                                              .msg =
                                                                          'Select a player first.';
                                                                      FFAppState()
                                                                              .showsnackbard =
                                                                          true;
                                                                      FFAppState()
                                                                              .msgtype =
                                                                          false;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                      return;
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 56.0,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                      border: Border.all(
                                                                        color: const Color(0xFFE0E1E5),
                                                                        width: 1.0,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 12.0, 0.0),
                                                                            child: Text(
                                                                              _model.selectedTeam != null && _model.selectedTeam != ''
                                                                                  ? _model.selectedTeam!
                                                                                  : 'Select a team',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                fontFamily: 'IBM Plex Sans',
                                                                                fontSize: 16.0,
                                                                                color: _model.selectedTeam != null && _model.selectedTeam != ''
                                                                                    ? const Color(0xFF1A1A1A)
                                                                                    : const Color(0xFFAAAAAA),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                                                          child: Icon(
                                                                            Icons.arrow_drop_down,
                                                                            color: Color(0xFF888888),
                                                                            size: 24.0,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(),
                                                                child:
                                                                    FlutterFlowIconButton(
                                                                  borderColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  borderRadius:
                                                                       8.0,
                                                                  buttonSize:
                                                                      56.0,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  disabledColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .gray4,
                                                                  disabledIconColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .add_circle,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  onPressed: (_model.selectedName ==
                                                                              null ||
                                                                          _model.selectedName ==
                                                                              '')
                                                                      ? null
                                                                      : () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            barrierColor:
                                                                                FlutterFlowTheme.of(context).bottomSheetBg,
                                                                            isDismissible:
                                                                                false,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return GestureDetector(
                                                                                onTap: () {
                                                                                  FocusScope.of(context).unfocus();
                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                },
                                                                                child: Padding(
                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                  child: Container(
                                                                                    height: 362.0,
                                                                                    child: NewTeamWidget(
                                                                                      playerID: _model.selectedPlayerID!,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 6.0)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Opacity(
                                            opacity: valueOrDefault<double>(
                                              _model.selectedName != null &&
                                                      _model.selectedName != ''
                                                  ? 1.0
                                                  : 0.5,
                                              1.0,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 1.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: const BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.zero,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            12.0),
                                                                child: Text(
                                                                  'EVENTS',
                                                                  style: const TextStyle(
                                                                    fontFamily: 'IBM Plex Sans',
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.w600,
                                                                    letterSpacing: 1.2,
                                                                    color: Color(0xFF1A1A1A),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            6.0,
                                                                            0.0,
                                                                            0.0,
                                                                            12.0),
                                                                child: Text(
                                                                  '(optional)',
                                                                  style: const TextStyle(
                                                                    fontFamily: 'IBM Plex Sans',
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.normal,
                                                                    letterSpacing: 0.4,
                                                                    color: Color(0xFFAAAAAA),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          -1.0,
                                                                          0.0),
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      if (_model.selectedName !=
                                                                              null &&
                                                                          _model.selectedName !=
                                                                              '') {
                                                                        final rows =
                                                                            await GameEventsTable()
                                                                                .queryRows(
                                                                          queryFn: (q) => q
                                                                              .eqOrNull('user_id', currentUserUid)
                                                                              .eqOrNull('player_id', _model.selectedPlayerID),
                                                                        );
                                                                        final events = rows
                                                                            .map((r) => r.eventName ?? '')
                                                                            .where((e) => e.isNotEmpty)
                                                                            .toList();
                                                                        if (!mounted) return;
                                                                        final picked =
                                                                            await presentPickerSheet<
                                                                                String>(
                                                                          context,
                                                                          title: 'Select event',
                                                                          options: events,
                                                                          labelOf: (e) => e,
                                                                          current: _model.selectedEvent,
                                                                        );
                                                                        if (picked != null) {
                                                                          _model.selectedEvent = picked;
                                                                          safeSetState(() {});
                                                                        }
                                                                        return;
                                                                      } else {
                                                                        FFAppState().msg =
                                                                            'Select a player first.';
                                                                        FFAppState().showsnackbard =
                                                                            true;
                                                                        FFAppState().msgtype =
                                                                            false;
                                                                        FFAppState()
                                                                            .update(() {});
                                                                        return;
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: 56.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                        border: Border.all(
                                                                          color: const Color(0xFFE0E1E5),
                                                                          width: 1.0,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 12.0, 0.0),
                                                                              child: Text(
                                                                                _model.selectedEvent != null && _model.selectedEvent != ''
                                                                                    ? _model.selectedEvent!
                                                                                    : 'Select an event',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'IBM Plex Sans',
                                                                                  fontSize: 16.0,
                                                                                  color: _model.selectedEvent != null && _model.selectedEvent != ''
                                                                                      ? const Color(0xFF1A1A1A)
                                                                                      : const Color(0xFFAAAAAA),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                                                            child: Icon(
                                                                              Icons.arrow_drop_down,
                                                                              color: Color(0xFF888888),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(),
                                                                child:
                                                                    FlutterFlowIconButton(
                                                                  borderColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  borderRadius:
                                                                       8.0,
                                                                  buttonSize:
                                                                      56.0,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  disabledColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .gray4,
                                                                  disabledIconColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .add_circle,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  onPressed: (_model.selectedName ==
                                                                              null ||
                                                                          _model.selectedName ==
                                                                              '')
                                                                      ? null
                                                                      : () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            barrierColor:
                                                                                FlutterFlowTheme.of(context).bottomSheetBg,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return GestureDetector(
                                                                                onTap: () {
                                                                                  FocusScope.of(context).unfocus();
                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                },
                                                                                child: Padding(
                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                  child: Container(
                                                                                    height: 510.0,
                                                                                    child: NewEventWidget(
                                                                                      playerID: _model.selectedPlayerID!,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) {
                                                                            // Auto-select the newly created event.
                                                                            if (value is String && value.isNotEmpty) {
                                                                              _model.selectedEvent = value;
                                                                            }
                                                                            safeSetState(() {});
                                                                          });
                                                                        },
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 6.0)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 12.0)),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 1.0),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      12.0),
                                                          child: Text(
                                                            'OPPENENT',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .montserrat(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .gray1,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      1.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .gray4,
                                                              borderRadius:
                                                                  BorderRadius.circular(6.0),
                                                            ),
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          3.0,
                                                                          3.0,
                                                                          3.0,
                                                                          3.0),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                      .opponentTeamTextController,
                                                                  focusNode: _model
                                                                      .opponentTeamFocusNode,
                                                                  onChanged: (_) =>
                                                                      EasyDebounce
                                                                          .debounce(
                                                                    '_model.opponentTeamTextController',
                                                                    Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    () => safeSetState(
                                                                        () {}),
                                                                  ),
                                                                  autofocus:
                                                                      false,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    isDense:
                                                                        false,
                                                                    labelStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.ibmPlexSans(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).gray1,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              1.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    alignLabelWithHint:
                                                                        false,
                                                                    hintText:
                                                                        'Enter opposing team',
                                                                    hintStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.ibmPlexSans(
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).gray2,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    enabledBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    focusedBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    errorBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    focusedErrorBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .gray4,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            5.0,
                                                                            12.0,
                                                                            12.0,
                                                                            12.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .ibmPlexSans(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                  validator: _model
                                                                      .opponentTeamTextControllerValidator
                                                                      .asValidator(
                                                                          context),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                height: 60.0,
                                                decoration: BoxDecoration(),
                                                child: FFButtonWidget(
                                                  onPressed: ((_model
                                                                      .selectedPlayerID ==
                                                                  null ||
                                                              _model.selectedPlayerID ==
                                                                  '') ||
                                                          (_model.selectedTeam ==
                                                                  null ||
                                                              _model.selectedTeam ==
                                                                  '') ||
                                                          (_model.opponentTeamTextController
                                                                      .text ==
                                                                  null ||
                                                              _model.opponentTeamTextController
                                                                      .text ==
                                                                  ''))
                                                      ? null
                                                      : () async {
                                                          Navigator.pop(
                                                              context);

                                                          context.pushNamed(
                                                            GameStatTrackerWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'playerName':
                                                                  serializeParam(
                                                                _model
                                                                    .selectedName,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                              'oppName':
                                                                  serializeParam(
                                                                _model
                                                                    .opponentTeamTextController
                                                                    .text,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                              'playerID':
                                                                  serializeParam(
                                                                _model
                                                                    .selectedPlayerID,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                              'eventSelected':
                                                                  serializeParam(
                                                                _model
                                                                    .selectedEvent,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                              'playerTeam':
                                                                  serializeParam(
                                                                _model
                                                                    .selectedTeam,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                            }.withoutNulls,
                                                            extra: <String,
                                                                dynamic>{
                                                              '__transition_info__':
                                                                  TransitionInfo(
                                                                hasTransition:
                                                                    true,
                                                                transitionType:
                                                                    PageTransitionType
                                                                        .fade,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        400),
                                                              ),
                                                            },
                                                          );
                                                        },
                                                  text: 'Start Game',
                                                  options: FFButtonOptions(
                                                    height: 60.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryButtonText,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(6.0),
                                                    disabledColor:
                                                        const Color(0xFFDADBDE),
                                                    disabledTextColor:
                                                        const Color(0xFF9A9BA8),
                                                  ),
                                                  showLoadingIndicator: false,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 0.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(),
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                    },
                                                    text: 'Cancel',
                                                    options: FFButtonOptions(
                                                      height: 60.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .globalBackground,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .ibmPlexSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 0.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    showLoadingIndicator: false,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 12.0)),
                                  ),
                                ),
                              ]
                                  .divide(SizedBox(height: 12.0))
                                  .addToEnd(SizedBox(
                                      height: valueOrDefault<double>(
                                    isAndroid ? 60.0 : 34.0,
                                    34.0,
                                  ))),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (FFAppState().showsnackbard == true)
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 60.0, 12.0, 0.0),
                      child: wrapWithModel(
                        model: _model.customSnackBarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: CustomSnackBarWidget(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
