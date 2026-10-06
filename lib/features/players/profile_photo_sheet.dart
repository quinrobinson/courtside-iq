// Profile Photo Sheet — Phase 4.11d
//
// Measured from 646:2192: three rows, no CTA. "Remove photo" carries the
// energy accent.
//
// REPLACES FlutterFlow's selectMediaWithSourceBottomSheet, which asked the
// same question in its own Material sheet. Two source pickers in a row - ours
// then theirs - is what v1 did, so this calls selectMedia with the source
// already decided.
//
// THE SHEET DOES NOT UPLOAD. It returns an intent and the caller performs it,
// so the screen that owns the player row is the one that writes to it, and
// the sheet stays testable without storage.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_sheet.dart';
import '/flutter_flow/upload_data.dart';

enum PhotoAction { takePhoto, chooseFromLibrary, remove }

/// Opens the sheet. Returns null if dismissed.
///
/// [canRemove] hides the remove row when there is no photo to remove: an
/// action that cannot do anything should not be offered.
Future<PhotoAction?> presentProfilePhotoSheet(
  BuildContext context, {
  required bool canRemove,
}) {
  return showCiSheet<PhotoAction>(
    context,
    child: ProfilePhotoSheet(canRemove: canRemove),
  );
}

class ProfilePhotoSheet extends StatelessWidget {
  const ProfilePhotoSheet({super.key, required this.canRemove});

  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    return CiSheet(
      title: 'Profile photo',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CiSheetOptionRow(
            label: 'Take photo',
            onTap: () =>
                Navigator.of(context).pop(PhotoAction.takePhoto),
          ),
          CiSheetOptionRow(
            label: 'Choose from library',
            showDivider: canRemove,
            onTap: () =>
                Navigator.of(context).pop(PhotoAction.chooseFromLibrary),
          ),
          if (canRemove)
            CiSheetOptionRow(
              label: 'Remove photo',
              destructive: true,
              showDivider: false,
              onTap: () => Navigator.of(context).pop(PhotoAction.remove),
            ),
        ],
      ),
    );
  }
}

/// Picks an image for [action], or null if the parent backed out of the
/// system picker.
///
/// Separated from the sheet so the screen can show its own progress state
/// while this runs: an upload takes long enough that silence reads as a
/// failed tap.
Future<List<SelectedFile>?> pickPlayerPhoto(PhotoAction action) {
  return selectMedia(
    mediaSource: action == PhotoAction.takePhoto
        ? MediaSource.camera
        : MediaSource.photoGallery,
    // Downscaled before upload. A modern phone camera produces several
    // megabytes for something rendered at 88 points, and a parent in a gym on
    // bad signal pays for every one of them.
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
    multiImage: false,
  );
}
