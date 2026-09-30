// Writes the app icon's vector sources from the mark geometry (Release 2.1).
//
// The Dot-burst C is 26 circles; lib/courtside_iq/brand/dot_c_mark_geometry.dart
// is the only copy, including where the mark sits in an icon (fill 70%,
// placed by hand in Figma, differently for the square and the circle). This
// script turns it into:
//
//   1. ios/Runner/courtside-iq.icon/Assets/Mark.svg - the Icon Composer layer
//      (SQUARE placement). 1024 canvas = the icon canvas, so the layer sits at
//      scale 1, no offset. Lime with each dot's fade as fill-opacity; the
//      layer in icon.json has NO fill override, because a layer fill would
//      repaint every dot the same and flatten the fade.
//   2. build/app_icon_master.svg - the full square icon (ink ground + dots,
//      SQUARE placement): legacy Android, web, and the Play Store listing
//      icon.
//   3. build/app_icon_foreground.svg - the Android adaptive foreground
//      (CIRCLE placement), transparent, on the 108dp layer whose middle 72dp
//      the launcher shows.
//
//   dart run scripts/build_dot_c_icon.dart
//   rsvg-convert -w 1024 -h 1024 build/app_icon_master.svg -o assets/images/app_launcher_icon.png
//   rsvg-convert -w 1024 -h 1024 build/app_icon_foreground.svg -o assets/images/app_launcher_icon_foreground.png
//   rsvg-convert -w 512 -h 512 build/app_icon_master.svg -o store-assets/2-1/play-store-icon-512.png
//   dart run flutter_launcher_icons
//
// (scripts/build_app_icon.dart is no longer in this path: it derived the
// Android foreground by shrinking the square master, which cannot give the
// circle its own placement.)
//
// test/ci_logo_mark_test.dart checks Mark.svg against the geometry, so a
// geometry change without re-running this fails the suite.

import 'dart:io';

import 'package:courtside_i_q/courtside_iq/brand/dot_c_mark_geometry.dart';

/// Icon Composer, the store and the adaptive layer all use a 1024 canvas.
const _canvas = 1024.0;

/// An adaptive icon layer is 108dp; launchers show its middle 72dp.
const _adaptiveVisible = _canvas * 72 / 108;

/// Primitives accent/lime and ink/default.
const _lime = '#9DFF00';
const _ink = '#0F0F0F';

String _dots(List<MarkDot> dots) {
  final b = StringBuffer();
  for (final d in dots) {
    b.writeln(
      '<circle cx="${d.x.toStringAsFixed(2)}" '
      'cy="${d.y.toStringAsFixed(2)}" '
      'r="${d.r.toStringAsFixed(2)}" '
      'fill="$_lime" fill-opacity="${d.opacity.toStringAsFixed(3)}"/>',
    );
  }
  return b.toString();
}

String _svg(String body) =>
    '<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" '
    'xmlns="http://www.w3.org/2000/svg">\n$body</svg>\n';

void main() {
  final square = iconDots(kIconPlacementSquare, canvas: _canvas);
  final circle = iconDots(
    kIconPlacementCircle,
    canvas: _canvas,
    shape: _adaptiveVisible,
  );
  _write('ios/Runner/courtside-iq.icon/Assets/Mark.svg', _svg(_dots(square)));
  _write(
    'build/app_icon_master.svg',
    _svg('<rect width="1024" height="1024" fill="$_ink"/>\n${_dots(square)}'),
  );
  _write('build/app_icon_foreground.svg', _svg(_dots(circle)));
}

void _write(String path, String contents) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(contents);
  stdout.writeln('wrote $path');
}
