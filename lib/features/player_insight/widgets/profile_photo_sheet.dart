import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/upload_data.dart';

/// Result of [ProfilePhotoEditor.present].
class ProfilePhotoResult {
  const ProfilePhotoResult({this.newUrl, this.removed = false});
  final String? newUrl;
  final bool removed;
}

enum _SheetAction { camera, library, remove }

/// Bottom-sheet driven profile photo editor. Matches Figma 1615:2.
///
/// Flow:
///   1. Show the action sheet.
///   2. On camera/library → pick with [selectMedia], upload to the
///      `playerprofiles` bucket under `pics/`, update the player row.
///   3. On remove → null out `player_profile_pic`.
///
/// Returns [ProfilePhotoResult] when the row changed, or null on cancel.
class ProfilePhotoEditor {
  static const _purpleBubble = CIColors.surfaceAlt;
  static const _purpleIcon = CIColors.ink3;
  static const _destructiveBubble = CIColors.rose50;
  static const _destructive = CIColors.rose500;
  static const _text = CIColors.ink;
  static const _muted = CIColors.ink3;
  static const _border = CIColors.hairline;

  static Future<ProfilePhotoResult?> present(
    BuildContext context, {
    required String playerId,
    required bool hasPhoto,
  }) async {
    final action = await showModalBottomSheet<_SheetAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _Sheet(hasPhoto: hasPhoto),
    );
    if (action == null) return null;
    if (!context.mounted) return null;

    switch (action) {
      case _SheetAction.camera:
      case _SheetAction.library:
        final url = await _pickAndUpload(
          context,
          playerId: playerId,
          source: action == _SheetAction.camera
              ? MediaSource.camera
              : MediaSource.photoGallery,
        );
        if (url == null) return null;
        return ProfilePhotoResult(newUrl: url);
      case _SheetAction.remove:
        await _removePhoto(playerId);
        return const ProfilePhotoResult(removed: true);
    }
  }

  static Future<String?> _pickAndUpload(
    BuildContext context, {
    required String playerId,
    required MediaSource source,
  }) async {
    final selected = await selectMedia(
      storageFolderPath: 'pics',
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 75,
      mediaSource: source,
    );
    if (selected == null || selected.isEmpty) return null;

    final urls = await uploadSupabaseStorageFiles(
      bucketName: 'playerprofiles',
      selectedFiles: selected,
    );
    if (urls.isEmpty) return null;
    final url = urls.first;

    await SupaFlow.client
        .from('players')
        .update({'player_profile_pic': url}).eq('id', playerId);
    return url;
  }

  static Future<void> _removePhoto(String playerId) async {
    await SupaFlow.client
        .from('players')
        .update({'player_profile_pic': null}).eq('id', playerId);
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.hasPhoto});
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: CIColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(CIRadius.xl)),
      ),
      padding: EdgeInsets.only(bottom: 12 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ProfilePhotoEditor._border,
                borderRadius: BorderRadius.circular(CIRadius.xs),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              'Profile photo',
              style: TextStyle(
                fontFamily: CIType.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ProfilePhotoEditor._text,
              ),
            ),
          ),
          _Row(
            icon: Icons.photo_camera,
            label: 'Take photo',
            topDivider: false,
            onTap: () => Navigator.of(context).pop(_SheetAction.camera),
          ),
          _Row(
            icon: Icons.photo_library,
            label: 'Choose from library',
            topDivider: true,
            onTap: () => Navigator.of(context).pop(_SheetAction.library),
          ),
          if (hasPhoto)
            _Row(
              icon: Icons.delete,
              label: 'Remove photo',
              topDivider: true,
              destructive: true,
              showChevron: false,
              onTap: () => Navigator.of(context).pop(_SheetAction.remove),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.topDivider = false,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool topDivider;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final fg = destructive
        ? ProfilePhotoEditor._destructive
        : ProfilePhotoEditor._text;
    final bubbleBg = destructive
        ? ProfilePhotoEditor._destructiveBubble
        : ProfilePhotoEditor._purpleBubble;
    final iconColor = destructive
        ? ProfilePhotoEditor._destructive
        : ProfilePhotoEditor._purpleIcon;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: topDivider
              ? const Border(
                  top: BorderSide(color: ProfilePhotoEditor._border, width: 1),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: BorderRadius.circular(CIRadius.lg),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: ProfilePhotoEditor._muted,
              ),
          ],
        ),
      ),
    );
  }
}
