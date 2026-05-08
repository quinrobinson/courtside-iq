import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/games/game_components/create_new/create_new_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'custom_nav_bar_model.dart';
export 'custom_nav_bar_model.dart';

class CustomNavBarWidget extends StatefulWidget {
  const CustomNavBarWidget({
    super.key,
    required this.page,
  });

  final String? page;

  @override
  State<CustomNavBarWidget> createState() => _CustomNavBarWidgetState();
}

class _CustomNavBarWidgetState extends State<CustomNavBarWidget> {
  late CustomNavBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomNavBarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          24.0,
          0.0,
          24.0,
          valueOrDefault<double>(
            isAndroid ? 60.0 : 34.0,
            34.0,
          )),
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  // Outer container carries the shadow (can't be inside ClipRRect)
                  child: Container(
                    width: 330.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16.0,
                          offset: Offset(0.0, 4.0),
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: Color(0xFFE0E1E5),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(7.0, 6.0, 7.0, 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  HomeWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 0),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: widget!.page == 'Home'
                                      ? const Color(0xFF0F0F0F)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      color: widget!.page == 'Home'
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context)
                                              .disableText,
                                      size: 26.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  PlayersListWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 0),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: widget!.page == 'Players'
                                      ? const Color(0xFF0F0F0F)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      color: widget!.page == 'Players'
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context)
                                              .disableText,
                                      size: 26.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (FFAppState().isUserPremium)
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 6.0,
                              borderWidth: 0.0,
                              buttonSize: 40.0,
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF0F0F0F),
                                size: 24.0,
                              ),
                              onPressed: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: FlutterFlowTheme.of(context)
                                      .bottomSheetBg,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: Container(
                                        height: 248.0,
                                        child: CreateNewWidget(),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                            ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  AllGamesWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 0),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: widget!.page == 'Games'
                                      ? const Color(0xFF0F0F0F)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.scoreboard_rounded,
                                      color: widget!.page == 'Games'
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context)
                                              .disableText,
                                      size: 26.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  MenuWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 0),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: widget!.page == 'Menu'
                                      ? const Color(0xFF0F0F0F)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.menu_rounded,
                                      color: widget!.page == 'Menu'
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context)
                                              .disableText,
                                      size: 26.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 6.0)),
                      ),
                    ),
                  ),        // frosted Container
                ),          // BackdropFilter
              ),            // ClipRRect
            ),              // outer Container (shadow)
              ),            // Align
            ].divide(SizedBox(width: 12.0)),
            ),
          ],
        ),
      ),
    );
  }
}
