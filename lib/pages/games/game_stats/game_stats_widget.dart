import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/design_tokens.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/games/game_components/game_insights_info/game_insights_info_widget.dart';
import '/pages/global/alert_dialog/alert_dialog_widget.dart';
import '/pages/global/informational_dialog/informational_dialog_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'game_stats_model.dart';
export 'game_stats_model.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;

class GameStatsWidget extends StatefulWidget {
  const GameStatsWidget({
    super.key,
    required this.playerID,
    required this.gameID,
  });

  final String? playerID;
  final String? gameID;

  static String routeName = 'GameStats';
  static String routePath = '/gameStats';

  @override
  State<GameStatsWidget> createState() => _GameStatsWidgetState();
}

class _GameStatsWidgetState extends State<GameStatsWidget> {
  late GameStatsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GameStatsModel());
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).globalBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: FlutterFlowTheme.of(context).primaryText,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.west, size: 20),
          ),
        ),
        body: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
              0, 0, 0, isAndroid ? 66.0 : 30.0),
          child: FutureBuilder<List<VPlayerGameStatsRow>>(
            future: VPlayerGameStatsTable().querySingleRow(
              queryFn: (q) => q
                  .eqOrNull('player_id', widget.playerID)
                  .eqOrNull('game_id', widget.gameID),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: SpinKitFadingFour(
                      color: FlutterFlowTheme.of(context).teal,
                      size: 30,
                    ),
                  ),
                );
              }
              final rows = snapshot.data!;
              final row = rows.isNotEmpty ? rows.first : null;
              if (row == null) return const SizedBox.shrink();
              return _buildBody(context, row);
            },
          ),
        ),
      ),
    );
  }

  // ── Body: scrollable content + floating share button ─────────────────────

  Widget _buildBody(BuildContext context, VPlayerGameStatsRow row) {
    final hasPpsa = functions.ppsaActive(
        functions.ppsa(row.fgAttempt!, row.ftAttempt!, row.points),
        row.fgAttempt);
    final hasAst2tov =
        functions.ast2tovActive(row.assist, row.turnover);
    final hasDisrupt = functions.disruptActive(
        row.steal, row.block, row.offReb, row.defReb);

    return Stack(
      children: [
        // ── Scrollable content ──────────────────────────────────────────
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: isAndroid ? 120.0 : 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Matchup header
              _matchupHeader(context, row),
              const SizedBox(height: 12),

              // Royal Glow insight card (Tier 3) — only when insight exists
              if ((row.gameInsights ?? '').trim().isNotEmpty) ...[
                _insightCard(context, row.gameInsights!.trim()),
              ],

              // ── DEVELOPMENT METRICS section (only when ≥1 metric active)
              if (hasPpsa || hasAst2tov || hasDisrupt) ...[
                const SizedBox(height: 16),
                _sectionHeader('Development'),
              ],

              // Metric cards (conditional on data thresholds)
              if (hasPpsa) ...[
                const SizedBox(height: 8),
                _metricCard(
                  context: context,
                  label: 'Scoring Efficiency',
                  sublabel: 'Points per shot attempt',
                  value: valueOrDefault<String>(
                    formatNumber(
                      functions.ppsa(
                          row.fgAttempt!, row.ftAttempt!, row.points),
                      formatType: FormatType.custom,
                      format: '0.0#',
                      locale: '',
                    ),
                    '#.#',
                  ),
                  isElite: functions.ppsaElite(functions.ppsa(
                      row.fgAttempt!, row.ftAttempt!, row.points)),
                  isGood: functions.ppsaGood(functions.ppsa(
                      row.fgAttempt!, row.ftAttempt!, row.points)),
                  isSolid: functions.ppsaSolid(functions.ppsa(
                      row.fgAttempt!, row.ftAttempt!, row.points)),
                ),
              ],

              if (hasAst2tov) ...[
                const SizedBox(height: 8),
                _metricCard(
                  context: context,
                  label: 'Playmaking + Ball Security',
                  sublabel: 'Assists for every turnover',
                  value: valueOrDefault<String>(
                    functions.ast2tov(row.assist, row.turnover),
                    '#:#',
                  ),
                  isElite:
                      functions.ast2tovElite(row.assist, row.turnover),
                  isGood: functions.ast2tovGood(row.assist, row.turnover),
                  isSolid:
                      functions.ast2tovSolid(row.assist, row.turnover),
                ),
              ],

              if (hasDisrupt) ...[
                const SizedBox(height: 8),
                _metricCard(
                  context: context,
                  label: 'Effort + Disruption',
                  sublabel: 'Extra possessions created',
                  value: valueOrDefault<String>(
                    functions
                        .disrupt(row.steal, row.block, row.offReb, row.defReb)
                        .toString(),
                    '#',
                  ),
                  isElite: functions.disruptElite(functions.disrupt(
                      row.steal, row.block, row.offReb, row.defReb)),
                  isGood: functions.disruptGood(functions.disrupt(
                      row.steal, row.block, row.offReb, row.defReb)),
                  isSolid: functions.disruptSolid(functions.disrupt(
                      row.steal, row.block, row.offReb, row.defReb)),
                  onTap: () async {
                    await showDialog(
                      barrierColor:
                          FlutterFlowTheme.of(context).bottomSheetBg,
                      context: context,
                      builder: (dialogContext) => Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0, 0)
                            .resolve(Directionality.of(context)),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(dialogContext).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: const SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: InformationalDialogWidget(
                              title: 'Effort + Disruption',
                              message:
                                  'Tracks the hustle plays that don\'t always show up in highlights but matter most to winning, a true sign of effort and defensive development.',
                              confirmLabel: 'Close',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // ── STATS section ─────────────────────────────────────────
              const SizedBox(height: 16),
              _sectionHeader('Stats'),
              const SizedBox(height: 8),
              _statsGrid(context, row),
              const SizedBox(height: 8),
              _shootingCard(context, row),

              const SizedBox(height: 32),

              // Remove game button — subscribers only (hidden for free users)
              if (revenue_cat.activeEntitlementIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Builder(
                  builder: (context) => FFButtonWidget(
                    onPressed: () async {
                      await showDialog(
                        barrierColor:
                            FlutterFlowTheme.of(context).bottomSheetBg,
                        context: context,
                        builder: (dialogContext) => Dialog(
                          elevation: 0,
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: const AlignmentDirectional(0, 0)
                              .resolve(Directionality.of(context)),
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(dialogContext).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: const SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: AlertDialogWidget(
                                title: 'Before you delete...',
                                message:
                                    'One rough game doesn\'t define a player, it develops one. No one else sees this data. It\'s here to help identify what to work on next.',
                                confirmLabel: 'Yes, delete',
                                dismissLabel: 'Keep It',
                              ),
                            ),
                          ),
                        ),
                      );
                      if (FFAppState().customAlertDialog == true) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        await GamesTable().delete(
                          matchingRows: (rows) => rows
                              .eqOrNull('user_id', currentUserUid)
                              .eqOrNull('id', row.gameId),
                        );
                        FFAppState().msg = 'Game stats have been removed.';
                        FFAppState().showsnackbard = true;
                        FFAppState().msgtype = true;
                        FFAppState().update(() {});
                      }
                    },
                    text: 'Remove Game',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24, 0, 24, 0),
                      iconPadding: EdgeInsetsDirectional.zero,
                      color: FlutterFlowTheme.of(context).globalBackground,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w500),
                                color:
                                    FlutterFlowTheme.of(context).imperial,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w500,
                              ),
                      elevation: 0,
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground),
                      borderRadius: BorderRadius.circular(CIRadius.md),
                    ),
                    showLoadingIndicator: false,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Floating share button (bottom-center) ─────────────────────
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 126,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).globalBackground.withValues(alpha: 0),
                  FlutterFlowTheme.of(context).globalBackground,
                ],
                stops: const [0, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: isAndroid ? 46 : 30),
              child: Builder(
                builder: (context) => FlutterFlowIconButton(
                  borderColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: CIRadius.full,
                  borderWidth: 1,
                  buttonSize: 60,
                  fillColor:
                      FlutterFlowTheme.of(context).primaryBackground,
                  icon: Icon(
                    Icons.ios_share_outlined,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24,
                  ),
                  onPressed: () async {
                    await Share.share(
                      functions.stat2text(
                        row.points!,
                        row.offReb!,
                        row.defReb!,
                        row.assist!,
                        row.steal!,
                        row.block!,
                        row.fgAttempt!,
                        row.fgMade!,
                        row.ftAttempt!,
                        row.ftMade!,
                        row.turnover!,
                        row.gameInsights,
                        row.createdAt!,
                        row.opponentTeam!,
                        row.threeAttempt!,
                        row.threeMade!,
                        row.firstName ?? '',
                      )!,
                      sharePositionOrigin: getWidgetBoundingBox(context),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Matchup header ────────────────────────────────────────────────────────

  Widget _matchupHeader(BuildContext context, VPlayerGameStatsRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Avatar + name columns, VS divider
          Row(
            children: [
              // ── Player side ───────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    _playerAvatar(row.playerProfilePic, 64),
                    const SizedBox(height: 8),
                    Text(
                      row.firstName ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: CIType.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CIColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              // ── VS divider ────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CIColors.ink3,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              // ── Opponent side ─────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: CIColors.canvasSunk,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: CIColors.ink3,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      valueOrDefault<String>(row.opponentTeam, 'Opponent'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: CIType.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CIColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Metadata pills: date · optional event name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _metaPill(
                label: dateTimeFormat(
                  'yMMMd',
                  row.createdAt!,
                  locale: FFLocalizations.of(context).languageCode,
                ),
                outlined: true,
              ),
              if ((row.eventName ?? '').isNotEmpty) ...[
                const SizedBox(width: 6),
                _metaPill(
                  label: row.eventName!.maybeHandleOverflow(
                      maxChars: 24, replacement: '…'),
                  filled: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: CIType.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: CIColors.ink3,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _playerAvatar(String? profilePic, double size) {
    if (profilePic != null && profilePic.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          profilePic,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarPlaceholder(size),
        ),
      );
    }
    return _avatarPlaceholder(size);
  }

  Widget _avatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: CIColors.canvasSunk,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: CIColors.ink3,
        size: size * 0.44,
      ),
    );
  }

  Widget _metaPill({
    required String label,
    bool outlined = false,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? CIColors.canvasSunk : Colors.transparent,
        borderRadius: BorderRadius.circular(CIRadius.md),
        border: outlined ? Border.all(color: CIColors.hairline) : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: CIType.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: CIColors.ink2,
        ),
      ),
    );
  }

  // ── Royal Glow insight card — Tier 3 ─────────────────────────────────────

  Widget _insightCard(BuildContext context, String insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: CIColors.surface,
          borderRadius: BorderRadius.circular(CIRadius.md),
          border: Border.all(color: CIColors.royal500.withValues(alpha: 0.18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Royal radial glow — focal point at top-right corner
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.4,
                    colors: [
                      CIColors.royal500.withValues(alpha: 0.22),
                      CIColors.royal500.withValues(alpha: 0.07),
                      CIColors.royal500.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.40, 0.85],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eyebrow row: dot · GAME INSIGHT · ⓘ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: CIColors.royal500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'GAME INSIGHT',
                          style: TextStyle(
                            fontFamily: CIType.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: CIColors.royal600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final ctx = context;
                          await showDialog(
                            barrierColor:
                                FlutterFlowTheme.of(ctx).bottomSheetBg,
                            context: ctx,
                            builder: (dialogContext) => Dialog(
                              elevation: 0,
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              alignment: const AlignmentDirectional(0, 0)
                                  .resolve(Directionality.of(ctx)),
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(dialogContext).unfocus();
                                  FocusManager.instance.primaryFocus
                                      ?.unfocus();
                                },
                                child: const SizedBox(
                                  height: double.infinity,
                                  width: double.infinity,
                                  child: GameInsightsInfoWidget(),
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: CIColors.ink3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Insight body text
                  Text(
                    insight,
                    style: const TextStyle(
                      fontFamily: CIType.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: CIColors.ink2,
                      height: 1.52,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats grid (3×2): PTS / REB / AST / TO / STL / BLK ──────────────────

  Widget _statsGrid(BuildContext context, VPlayerGameStatsRow row) {
    final totalReb = (row.defReb ?? 0) + (row.offReb ?? 0);
    final items = [
      _StatItem('PTS', '${row.points ?? 0}'),
      _StatItem('REB', '$totalReb'),
      _StatItem('AST', '${row.assist ?? 0}'),
      _StatItem('TO', '${row.turnover ?? 0}'),
      _StatItem('STL', '${row.steal ?? 0}'),
      _StatItem('BLK', '${row.block ?? 0}'),
    ];

    Widget cell(_StatItem s,
        {bool rightBorder = false, bool bottomBorder = false}) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: rightBorder
                  ? const BorderSide(color: CIColors.hairline)
                  : BorderSide.none,
              bottom: bottomBorder
                  ? const BorderSide(color: CIColors.hairline)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.value,
                style: const TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: CIColors.ink,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.label,
                style: const TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CIColors.ink3,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: CIColors.surface,
          borderRadius: BorderRadius.circular(CIRadius.md),
          border: Border.all(color: CIColors.hairline),
        ),
        child: Column(
          children: [
            Row(children: [
              cell(items[0], rightBorder: true, bottomBorder: true),
              cell(items[1], rightBorder: true, bottomBorder: true),
              cell(items[2], bottomBorder: true),
            ]),
            Row(children: [
              cell(items[3], rightBorder: true),
              cell(items[4], rightBorder: true),
              cell(items[5]),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Shooting card: FG / FT / 3PT ─────────────────────────────────────────

  Widget _shootingCard(BuildContext context, VPlayerGameStatsRow row) {
    Widget cell({
      required String label,
      required int made,
      required int attempted,
      required double? pct,
      bool rightBorder = false,
    }) {
      final pctStr = pct != null
          ? formatNumber(pct,
              formatType: FormatType.custom, format: '##0', locale: '')
          : '0';
      return Expanded(
        child: Container(
          decoration: rightBorder
              ? const BoxDecoration(
                  border: Border(
                      right: BorderSide(color: CIColors.hairline)))
              : null,
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$made/$attempted',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CIColors.ink,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$pctStr%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: CIColors.ink3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CIColors.canvasSunk,
                  borderRadius: BorderRadius.circular(CIRadius.md),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CIColors.ink3,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: CIColors.surface,
          borderRadius: BorderRadius.circular(CIRadius.md),
          border: Border.all(color: CIColors.hairline),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cell(
                label: 'FG',
                made: row.fgMade ?? 0,
                attempted: row.fgAttempt ?? 0,
                pct: functions.calculatePlayerFGPercent(
                    row.fgMade, row.fgAttempt),
                rightBorder: true,
              ),
              cell(
                label: 'FT',
                made: row.ftMade ?? 0,
                attempted: row.ftAttempt ?? 0,
                pct: functions.calculatePlayerFTPercent(
                    row.ftMade, row.ftAttempt),
                rightBorder: true,
              ),
              cell(
                label: '3PT',
                made: row.threeMade ?? 0,
                attempted: row.threeAttempt ?? 0,
                pct: functions.calculatePlayerThreePointPercent(
                    row.threeMade, row.threeAttempt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Metric card with tier badge ──────────────────────────────────────────

  Widget _metricCard({
    required BuildContext context,
    required String label,
    required String sublabel,
    required String value,
    required bool isElite,
    required bool isGood,
    required bool isSolid,
    VoidCallback? onTap,
  }) {
    Widget badge() {
      if (isElite) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: CIColors.steel50,
            borderRadius: BorderRadius.circular(CIRadius.md),
          ),
          child: const Text(
            'Elite',
            style: TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CIColors.steel500,
            ),
          ),
        );
      }
      if (isGood) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: CIColors.jade50,
            borderRadius: BorderRadius.circular(CIRadius.md),
          ),
          child: const Text(
            'Good',
            style: TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CIColors.jade500,
            ),
          ),
        );
      }
      if (isSolid) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: CIColors.spark50,
            borderRadius: BorderRadius.circular(CIRadius.md),
          ),
          child: const Text(
            'Active',
            style: TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CIColors.spark500,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Tier accent: Active→spark, Good→jade, Elite→steel, none→null
    final Color? accent = isElite
        ? CIColors.steel500
        : isGood
            ? CIColors.jade500
            : isSolid
                ? CIColors.spark500
                : null;

    final Widget cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: CIColors.ink3,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: CIColors.ink,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: CIColors.ink3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          badge(),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: accent != null
              ? BoxDecoration(
                  color: CIColors.surface,
                  borderRadius: BorderRadius.circular(CIRadius.md),
                  border: Border.all(color: accent.withValues(alpha: 0.20)),
                )
              : BoxDecoration(
                  color: CIColors.surface,
                  borderRadius: BorderRadius.circular(CIRadius.md),
                  border: Border.all(color: CIColors.hairline),
                ),
          child: accent != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.4,
                            colors: [
                              accent.withValues(alpha: 0.22),
                              accent.withValues(alpha: 0.07),
                              accent.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.40, 0.85],
                          ),
                        ),
                      ),
                    ),
                    cardContent,
                  ],
                )
              : cardContent,
        ),
      ),
    );
  }
}

// ── Private data class ───────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);
}
