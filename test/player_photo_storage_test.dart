// Player photo storage — Phase 4.26a
//
// These tests are about ONE STRING: the path an uploaded photo lands at. The
// bucket is public, so the path is the only thing standing between a child's
// photo and anyone who wants to guess at it, and the two defects this replaces
// were both defects in that string.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/players/player_photo_storage.dart';

const _playerId = '3f9c2a10-1b4d-4f2e-9c77-5a1e8d0b6c34';

void main() {
  group('buildPlayerPhotoPath', () {
    test('never lands in a literal "null" folder', () {
      // The shipped 2.0 bug: pickPlayerPhoto passed no storageFolderPath, and
      // _getStoragePath interpolated the null straight into the path.
      final path = buildPlayerPhotoPath(_playerId, 'IMG_0042.jpg');
      expect(path.startsWith('null/'), isFalse);
      expect(path.contains('/null/'), isFalse);
      expect(path.startsWith('players/$_playerId/'), isTrue);
    });

    test('is not enumerable: two uploads never collide', () {
      // The old scheme named files by microsecondsSinceEpoch, which clusters
      // and is guessable from a known upload time.
      final paths = {
        for (var i = 0; i < 200; i++)
          buildPlayerPhotoPath(_playerId, 'photo.jpg'),
      };
      expect(paths.length, 200);
    });

    test('carries no timestamp', () {
      final path = buildPlayerPhotoPath(_playerId, 'photo.jpg');
      final filename = path.split('/').last.split('.').first;
      // A microsecond epoch is 16 digits. A uuid v4 has hyphens and letters
      // and is never all digits.
      expect(RegExp(r'^\d+$').hasMatch(filename), isFalse);
      expect(filename.length, 36, reason: 'uuid v4');
    });

    test('scopes by player, so a future RLS policy has something to match', () {
      final a = buildPlayerPhotoPath(_playerId, 'photo.jpg');
      final b = buildPlayerPhotoPath('other-player', 'photo.jpg');
      expect(a.split('/')[1], _playerId);
      expect(b.split('/')[1], 'other-player');
    });

    group('extension handling', () {
      test('keeps a recognised extension', () {
        for (final ext in ['jpg', 'jpeg', 'png', 'heic', 'webp']) {
          expect(buildPlayerPhotoPath(_playerId, 'a.$ext').endsWith('.$ext'),
              isTrue);
        }
      });

      test('is case insensitive', () {
        expect(buildPlayerPhotoPath(_playerId, 'A.PNG').endsWith('.png'), isTrue);
      });

      test('falls back to jpg for anything unrecognised or missing', () {
        for (final name in [null, '', 'noextension', 'a.tiff']) {
          expect(buildPlayerPhotoPath(_playerId, name).endsWith('.jpg'), isTrue,
              reason: 'input: $name');
        }
      });

      test('cannot be used to escape the folder', () {
        // The extension reaches the path. An allow-list is what stops a
        // filename from contributing path separators or traversal.
        final path = buildPlayerPhotoPath(_playerId, 'evil.jpg/../../secret');
        expect(path.split('/').length, 3);
        expect(path.contains('..'), isFalse);
        expect(path.endsWith('.jpg'), isTrue);
      });
    });
  });

  group('playerPhotoPathFromUrl', () {
    const base =
        'https://ejwgxsszmfabujdqxxdz.supabase.co/storage/v1/object/public/playerprofiles/';

    test('reads back a path this module wrote', () {
      final path = buildPlayerPhotoPath(_playerId, 'photo.png');
      expect(playerPhotoPathFromUrl('$base$path'), path);
    });

    test('handles both legacy shapes still in prod', () {
      // 30 rows point at pics/, 1 at null/.
      expect(playerPhotoPathFromUrl('${base}pics/1776050991034336.jpg'),
          'pics/1776050991034336.jpg');
      expect(playerPhotoPathFromUrl('${base}null/1785362760133418.png'),
          'null/1785362760133418.png');
    });

    test('strips a query string', () {
      expect(playerPhotoPathFromUrl('${base}pics/a.jpg?t=123'), 'pics/a.jpg');
    });

    test('returns null for anything that is not ours', () {
      for (final url in [
        null,
        '',
        'https://example.com/photo.jpg',
        'https://ejwgxsszmfabujdqxxdz.supabase.co/storage/v1/object/public/otherbucket/a.jpg',
      ]) {
        expect(playerPhotoPathFromUrl(url), isNull, reason: 'input: $url');
      }
    });
  });
}
