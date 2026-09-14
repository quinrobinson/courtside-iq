// Player photo storage — Phase 4.26a
//
// Owns where a player's photo LIVES, which FlutterFlow's uploader did badly in
// two separate ways.
//
// 1. THE PATH WAS ENUMERABLE. `_getStoragePath` names files by
//    `DateTime.now().microsecondsSinceEpoch`, so objects landed at
//    `pics/1776050991034336.jpg`. The bucket is public, so a photo of a child
//    was fetchable by anyone who guessed a nearby timestamp, with no
//    authentication. Timestamps are not secrets: they cluster, and a real
//    upload time narrows the search enormously.
//
// 2. THE FOLDER WAS THE STRING "null". `pickPlayerPhoto` never passed
//    `storageFolderPath`, and `_getStoragePath` interpolates the null straight
//    into the path, so every 2.0 upload landed in a literal `null/` directory.
//    Only the v1.5 sheet passed 'pics', and that sheet is unreachable.
//
// Paths are now `players/<playerId>/<uuid v4>.<ext>`. The player id is itself
// a uuid, so the prefix leaks nothing, and it gives the future RLS policy on
// storage.objects a natural thing to scope by: the owner of the player owns
// the folder.
//
// STILL RETURNS A PUBLIC URL, deliberately. The private-bucket-plus-signed-url
// fix is the real one, and it is NOT done here, because v1.4.0 clients read
// the same `players.player_profile_pic` column and render whatever string is
// in it. Storing a path, or making the bucket private, breaks every avatar on
// every phone still on v1 - and 2.0 is a phased rollout, so that is a live
// population. Unguessable names remove the enumeration attack now; the bucket
// flips once v1 has drained. Tracked as 4.26b.
//
// REPLACING A PHOTO DELETES THE OLD OBJECT. The previous uploader never did,
// and neither did "remove photo", which only nulled the column. Prod carries
// 107 objects for 31 referenced photos: 76 orphans nobody can see and nobody
// can reach, still sitting in a public bucket.

import 'package:uuid/uuid.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/upload_data.dart';

const String kPlayerPhotoBucket = 'playerprofiles';

const _uuid = Uuid();

/// Extensions we are willing to put in a path, and the type each is served as.
///
/// An allow-list rather than "whatever the filename ended with": the extension
/// reaches the path, and a path segment assembled from unchecked user input is
/// how a traversal gets in. Anything unrecognised is stored as `.jpg`, which
/// is what the picker produces in practice.
const Map<String, String> _kContentTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'heic': 'image/heic',
  'webp': 'image/webp',
};

/// `players/<playerId>/<random>.<ext>`.
///
/// Visible for testing: the whole point of this change is the shape of this
/// string, so it is asserted directly rather than through a live upload.
String buildPlayerPhotoPath(String playerId, String? originalFilename) {
  final ext = _extensionOf(originalFilename);
  return 'players/$playerId/${_uuid.v4()}.$ext';
}

String _extensionOf(String? filename) {
  final raw = (filename ?? '').split('.').last.toLowerCase();
  return _kContentTypes.containsKey(raw) ? raw : 'jpg';
}

/// Uploads [file] for [playerId] and returns its public URL.
///
/// The caller writes that URL to `players.player_profile_pic`; this function
/// does not touch the row, so the screen that owns the player is still the one
/// that writes to it.
Future<String> uploadPlayerPhoto({
  required String playerId,
  required SelectedFile file,
}) async {
  final path = buildPlayerPhotoPath(playerId, file.originalFilename);
  final bucket = SupaFlow.client.storage.from(kPlayerPhotoBucket);
  await bucket.uploadBinary(
    path,
    file.bytes,
    // The old uploader passed `contentType: null`, which leaves the object
    // served as application/octet-stream and makes some clients download it
    // rather than render it.
    fileOptions: FileOptions(
      contentType: _kContentTypes[_extensionOf(file.originalFilename)],
    ),
  );
  return bucket.getPublicUrl(path);
}

/// Best-effort delete of the object behind a stored public URL.
///
/// NEVER THROWS. This runs after the row has already been pointed somewhere
/// else, so a failure here leaves an orphan - untidy, and exactly what the
/// bucket is already full of - but the parent's photo change has succeeded and
/// must not be reported as failed. An orphan is a cleanup job; a false error
/// is a parent retrying something that worked.
Future<void> deletePlayerPhotoAt(String? publicUrl) async {
  final path = playerPhotoPathFromUrl(publicUrl);
  if (path == null) return;
  try {
    await SupaFlow.client.storage.from(kPlayerPhotoBucket).remove([path]);
  } catch (_) {
    // Intentionally swallowed. See above.
  }
}

/// The in-bucket path for a stored public URL, or null if it is not one of
/// ours.
///
/// Handles both shapes in prod today: the old `pics/<timestamp>.jpg` and
/// `null/<timestamp>.png`, and the new `players/<id>/<uuid>.jpg`.
String? playerPhotoPathFromUrl(String? publicUrl) {
  if (publicUrl == null || publicUrl.isEmpty) return null;
  const marker = '/object/public/$kPlayerPhotoBucket/';
  final i = publicUrl.indexOf(marker);
  if (i < 0) return null;
  final path = publicUrl.substring(i + marker.length);
  // Strip any query string a signed or cache-busted url might carry.
  final clean = path.split('?').first;
  return clean.isEmpty ? null : clean;
}
