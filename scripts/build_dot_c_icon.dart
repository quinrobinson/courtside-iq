// Writes the app icon's vector sources from the mark geometry (Release 2.1).
//
// The Dot-burst C is 26 circles; lib/courtside_iq/brand/dot_c_mark_geometry.dart
// is the only copy. This script turns it into:
//
//   1. ios/Runner/courtside-iq.icon/Assets/Mark.svg - the Icon Composer layer.
//      1024 canvas = the icon canvas, so the layer sits at scale 1, no offset.
//      Lime with each dot's fade as fill-opacity; the layer in icon.json has
//      NO fill override, because a layer fill would repaint every dot the same
//      and flatten the fade.
//   2. build/app_icon_master.svg - the full square icon (ink ground + dots),
//      the source for Android and web. Rasterise it, then hand the PNG to
//      scripts/build_app_icon.dart:
//
//   dart run scripts/build_dot_c_icon.dart
//   rsvg-convert -w 1024 -h 1024 build/app_icon_master.svg -o build/app_icon_master.png
//   dart run scripts/build_app_icon.dart build/app_icon_master.png
//   dart run flutter_launcher_icons
//
// test/ci_logo_mark_test.dart checks Mark.svg against the geometry, so a
// geometry change without re-running this fails the suite.

import 'dart:io';

import 'package:courtside_i_q/courtside_iq/brand/dot_c_mark_geometry.dart';

/// Icon Composer and the store both want 1024.
const _canvas = 1024.0;

/// Primitives accent/lime and ink/default.
const _lime = '#9DFF00';
const _ink = '#0F0F0F';

String _dots() {
  const k = _canvas / kMarkIconBox;
  final b = StringBuffer();
  for (final d in kMarkDots) {
    b.writeln(
      '<circle cx="${(d.x * k).toStringAsFixed(2)}" '
      'cy="${(d.y * k).toStringAsFixed(2)}" '
      'r="${(d.r * k).toStringAsFixed(2)}" '
      'fill="$_lime" fill-opacity="${d.opacity.toStringAsFixed(3)}"/>',
    );
  }
  return b.toString();
}

String _svg(String body) =>
    '<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" '
    'xmlns="http://www.w3.org/2000/svg">\n$body</svg>\n';

void main() {
  _write('ios/Runner/courtside-iq.icon/Assets/Mark.svg', _svg(_dots()));
  _write(
    'build/app_icon_master.svg',
    _svg('<rect width="1024" height="1024" fill="$_ink"/>\n${_dots()}'),
  );
}

void _write(String path, String contents) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(contents);
  stdout.writeln('wrote $path');
}
