import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/design_tokens.dart';
import '/courtside_iq/skeleton_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/global/bottom_sheets/paywall/paywall_widget.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/global/empty_states/empty_players_list/empty_players_list_widget.dart';
import '/pages/global/informational_dialog/informational_dialog_widget.dart';
import '/features/players/add_player_sheet.dart';
import 'dart:ui';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'players_list_model.dart';
export 'players_list_model.dart';

class PlayersListWidget extends StatefulWidget {
  const PlayersListWidget({super.key});

  static String routeName = 'PlayersList';
  static String routePath = '/playerList';

  @override
  State<PlayersListWidget> createState() => _PlayersListWidgetState();
}

class _PlayersListWidgetState extends State<PlayersListWidget> {
  late PlayersListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlayersListModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.getActivePlayersCount = await PlayersTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'user_id',
          currentUserUid,
        ),
      );
      FFAppState().playerCount = _model.getActivePlayersCount!.length;
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
    context.watch<FFAppState>();

    return FutureBuilder<List<PlayerProfileViewRow>>(
      future: PlayerProfileViewTable().queryRows(
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
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: title stub + button stub
                    Row(
                      children: const [
                        SkeletonBox(width: 100, height: 28),
                        Spacer(),
                        SkeletonBox(width: 80, height: 36, radius: 8),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Player row 1
                    Row(
                      children: const [
                        SkeletonBox(width: 44, height: 44, radius: 22),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 130, height: 16),
                            SizedBox(height: 6),
                            SkeletonBox(width: 80, height: 12),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Player row 2
                    Row(
                      children: const [
                        SkeletonBox(width: 44, height: 44, radius: 22),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 130, height: 16),
                            SizedBox(height: 6),
                            SkeletonBox(width: 80, height: 12),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Player row 3
                    Row(
                      children: const [
                        SkeletonBox(width: 44, height: 44, radius: 22),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 130, height: 16),
                            SizedBox(height: 6),
                            SkeletonBox(width: 80, height: 12),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        List<PlayerProfileViewRow> playersListPlayerProfileViewRowList =
            snapshot.data!;

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
                        isAndroid ? 36.0 : 66.0,
                        66.0,
                      ),
                      0.0,
                      0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(),
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Players',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              font: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineSmall
                                                        .fontStyle,
                                              ),
                                              fontSize: 22.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall
                                                      .fontStyle,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 6.0)),
                                  ),
                                ),
                              ),
                            ),
                            if (!((playersListPlayerProfileViewRowList.length >=
                                    1) &&
                                (FFAppState().isUserPremium == false)))
                              Builder(
                                builder: (context) => FFButtonWidget(
                                  onPressed: () async {
                                    if (playersListPlayerProfileViewRowList
                                            .length >=
                                        3) {
                                      await showDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            alignment: AlignmentDirectional(
                                                    0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                            child: GestureDetector(
                                              onTap: () {
                                                FocusScope.of(dialogContext)
                                                    .unfocus();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              child: Container(
                                                height: double.infinity,
                                                width: double.infinity,
                                                child:
                                                    InformationalDialogWidget(
                                                  title: 'Limit Exceeded',
                                                  message:
                                                      'You\'re limited to 3 players. Remove one first to add a new player.',
                                                  confirmLabel: 'Ok',
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      await showAddPlayerSheet(context)
                                          .then((value) => safeSetState(() {}));
                                    }
                                  },
                                  text: 'Add Player',
                                  icon: Icon(
                                    Icons.add,
                                    size: 23.0,
                                  ),
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        9.0, 0.0, 14.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    color: Color(0x00F0F0F0),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                              ),
                          ].divide(SizedBox(width: 12.0)),
                        ),
                      ),
                      if (FFAppState().isUserPremium == false)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 12.0, 12.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: Container(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                1.0,
                                        child: PaywallWidget(),
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).teal,
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  image: Image.asset(
                                    'assets/images/gradient-bg-black-b.png',
                                  ).image,
                                ),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                              border: Border.all(
                                                color: Color(0x59FFFFFF),
                                              ),
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          6.0, 1.0, 6.0, 1.0),
                                                  child: Text(
                                                    'PRO',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .montserrat(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineSmall
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Upgrade to a Pro plan',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .ibmPlexSans(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Unlimited games and 3 players profiles.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .ibmPlexSans(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.2,
                                                        ),
                                                  ),
                                                ),
                                              ].divide(SizedBox(height: 3.0)),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_outward,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            size: 18.0,
                                          ),
                                        ].divide(SizedBox(width: 12.0)),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final playersVar =
                                                playersListPlayerProfileViewRowList
                                                    .toList();
                                            if (playersVar.isEmpty) {
                                              return Center(
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 380.0,
                                                  child:
                                                      EmptyPlayersListWidget(),
                                                ),
                                              );
                                            }

                                            return ListView.separated(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: playersVar.length,
                                              separatorBuilder: (_, __) =>
                                                  SizedBox(height: 8.0),
                                              itemBuilder:
                                                  (context, playersVarIndex) {
                                                final playersVarItem =
                                                    playersVar[playersVarIndex];
                                                // ── Compute per-game averages ──
                                                final int _games = (playersVarItem.totalGames ?? 0).toInt();
                                                final String _ptsStr = _games > 0
                                                    ? ((playersVarItem.totalPoints ?? 0) / _games).toStringAsFixed(1)
                                                    : '--';
                                                final String _rebStr = _games > 0
                                                    ? (((playersVarItem.totalOffReb ?? 0) + (playersVarItem.totalDefReb ?? 0)) / _games).toStringAsFixed(1)
                                                    : '--';
                                                final String _astStr = _games > 0
                                                    ? ((playersVarItem.totalAssist ?? 0) / _games).toStringAsFixed(1)
                                                    : '--';
                                                final String _fullName =
                                                    '${playersVarItem.playerFirstName ?? ''} ${playersVarItem.playerLastName ?? ''}'.trim();
                                                final String? _position = playersVarItem.playerPosition;
                                                final String? _ageBand = playersVarItem.ageBand;
                                                final String _picRaw = playersVarItem.playerProfilePic ?? '';
                                                final bool _hasPhoto = _picRaw.isNotEmpty;
                                                final List<String> _pillParts = [
                                                  if (_position != null && _position.isNotEmpty) _position,
                                                  if (_ageBand != null && _ageBand.isNotEmpty) _ageBand,
                                                ];
                                                final String? _pillText = _pillParts.isEmpty ? null : _pillParts.join(' · ');

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: CIColors.surface,
                                                    borderRadius: BorderRadius.circular(CIRadius.md),
                                                    border: Border.all(color: CIColors.hairline, width: 1.0),
                                                    boxShadow: CIElevation.card,
                                                  ),
                                                  child: InkWell(
                                                    splashColor: Colors.transparent,
                                                    focusColor: Colors.transparent,
                                                    hoverColor: Colors.transparent,
                                                    highlightColor: Colors.transparent,
                                                    borderRadius: BorderRadius.circular(CIRadius.md),
                                                    onTap: () async {
                                                      if (FFAppState().isUserPremium == true) {
                                                        context.pushNamed(
                                                          PlayersProfileWidget.routeName,
                                                          queryParameters: {
                                                            'playerID': serializeParam(
                                                              playersVarItem.playerId,
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                          extra: <String, dynamic>{
                                                            '__transition_info__': TransitionInfo(
                                                              hasTransition: true,
                                                              transitionType: PageTransitionType.fade,
                                                              duration: Duration(milliseconds: 0),
                                                            ),
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        // ── Header: avatar + name/meta (padded) ──
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 14.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              // 56px circular avatar
                                                              Container(
                                                                width: 56.0,
                                                                height: 56.0,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: CIColors.surfaceAlt,
                                                                  image: _hasPhoto
                                                                      ? DecorationImage(
                                                                          image: NetworkImage(_picRaw),
                                                                          fit: BoxFit.cover,
                                                                        )
                                                                      : null,
                                                                ),
                                                                child: _hasPhoto
                                                                    ? null
                                                                    : const Icon(
                                                                        Icons.person_rounded,
                                                                        size: 32.0,
                                                                        color: CIColors.ink4,
                                                                      ),
                                                              ),
                                                              const SizedBox(width: 12.0),
                                                              // Name + position pill + games count
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Expanded(
                                                                          child: Text(
                                                                            _fullName.isEmpty ? 'Player' : _fullName,
                                                                            style: const TextStyle(
                                                                              fontFamily: CIType.fontFamily,
                                                                              fontSize: 16.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: CIColors.ink,
                                                                              height: 1.25,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        if (_pillText != null) ...[
                                                                          const SizedBox(width: 8.0),
                                                                          Container(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              horizontal: 8.0,
                                                                              vertical: 3.0,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color: CIColors.canvasSunk,
                                                                              borderRadius: BorderRadius.circular(CIRadius.md),
                                                                            ),
                                                                            child: Text(
                                                                              _pillText,
                                                                              style: const TextStyle(
                                                                                fontFamily: CIType.fontFamily,
                                                                                fontSize: 11.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: CIColors.ink3,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ],
                                                                    ),
                                                                    const SizedBox(height: 4.0),
                                                                    Text(
                                                                      _games == 1 ? '1 game logged' : '$_games games logged',
                                                                      style: const TextStyle(
                                                                        fontFamily: CIType.fontFamily,
                                                                        fontSize: 12.0,
                                                                        fontWeight: FontWeight.w400,
                                                                        color: CIColors.ink3,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // ── Horizontal rule (edge-to-edge) ──
                                                        Container(height: 1.0, color: CIColors.hairline),
                                                        // ── Stats row: PTS AVG / REB AVG / AST AVG ──
                                                        // Vertical rules span full row height via IntrinsicHeight
                                                        IntrinsicHeight(
                                                          child: Row(
                                                            children: [
                                                              Expanded(child: Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                                child: _statCell('PTS AVG', _ptsStr),
                                                              )),
                                                              Container(width: 1.0, color: CIColors.hairline),
                                                              Expanded(child: Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                                child: _statCell('REB AVG', _rebStr),
                                                              )),
                                                              Container(width: 1.0, color: CIColors.hairline),
                                                              Expanded(child: Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                                child: _statCell('AST AVG', _astStr),
                                                              )),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 12.0),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(),
                                            child: Visibility(
                                              visible:
                                                  (playersListPlayerProfileViewRowList
                                                          .isNotEmpty) ==
                                                      true,
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        24.0, 12.0, 24.0, 0.0),
                                                child: Text(
                                                  'Manage up to 3 players profiles. Select a player to dive into their stats and performance history.',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .ibmPlexSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].addToEnd(SizedBox(height: 130.0)),
                                    ),
                                  ),
                                ),
                              ].addToEnd(SizedBox(height: 116.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.customNavBarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: CustomNavBarWidget(
                      page: 'Players',
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

  // ── Player card stat cell ──────────────────────────────────────────────────
  static Widget _statCell(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
            color: CIColors.ink,
            height: 1.1,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: const TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 9.0,
            fontWeight: FontWeight.w700,
            color: CIColors.ink3,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
