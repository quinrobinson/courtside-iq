import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/games/game_components/new_event/new_event_widget.dart';
import '/pages/global/alert_dialog/alert_dialog_widget.dart';
import '/pages/global/custom_snack_bar/custom_snack_bar_widget.dart';
import '/pages/global/sub_pg_header/sub_pg_header_widget.dart';
import '/pages/players/player_components/new_team/new_team_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'edit_player_widget.dart' show EditPlayerWidget;
import 'package:expandable/expandable.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class EditPlayerModel extends FlutterFlowModel<EditPlayerWidget> {
  ///  Local state fields for this page.

  String? profilePic;

  ///  State fields for stateful widgets in this page.

  // Model for SubPgHeader component.
  late SubPgHeaderModel subPgHeaderModel;
  // Stores action output result for [Backend Call - Update Row(s)] action in IconButton widget.
  List<PlayersRow>? removeIMG;
  bool isDataUploading_uploadDataNto = false;
  FFUploadedFile uploadedLocalFile_uploadDataNto =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataNto = '';

  // Stores action output result for [Backend Call - Update Row(s)] action in IconButton widget.
  List<PlayersRow>? updatedIMG;
  // State field(s) for firstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController1;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController2;

  // Model for CustomSnackBar component.
  late CustomSnackBarModel customSnackBarModel;

  @override
  void initState(BuildContext context) {
    subPgHeaderModel = createModel(context, () => SubPgHeaderModel());
    customSnackBarModel = createModel(context, () => CustomSnackBarModel());
  }

  @override
  void dispose() {
    subPgHeaderModel.dispose();
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    expandableExpandableController1.dispose();
    expandableExpandableController2.dispose();
    customSnackBarModel.dispose();
  }
}
