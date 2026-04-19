import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sub_pg_header_model.dart';
export 'sub_pg_header_model.dart';

class SubPgHeaderWidget extends StatefulWidget {
  const SubPgHeaderWidget({
    super.key,
    required this.pageTitle,
  });

  final String? pageTitle;

  @override
  State<SubPgHeaderWidget> createState() => _SubPgHeaderWidgetState();
}

class _SubPgHeaderWidgetState extends State<SubPgHeaderWidget> {
  late SubPgHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubPgHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(18.0, 12.0, 0.0, 12.0),
          child: FlutterFlowIconButton(
            borderRadius: 6.0,
            buttonSize: 42.0,
            icon: Icon(
              Icons.west,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 20.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 66.0, 12.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              child: Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget!.pageTitle,
                        'Page Title',
                      ),
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                    ),
                  ].divide(SizedBox(width: 6.0)),
                ),
              ),
            ),
          ),
        ),
      ].divide(SizedBox(width: 6.0)),
    );
  }
}
