// Builds the launcher-icon sources from the Figma export — Phase 4.19e.
//
// Figma's App Icon frame (923:3279) is 240pt, and the export tool caps at 4x,
// so the master arrives at 960 with an alpha channel. Two things have to
// happen before flutter_launcher_icons can use it:
//
//   1. iOS wants a 1024 App Store icon and REJECTS alpha. So the artwork is
//      flattened onto ink and taken to 1024.
//   2. Android adaptive icons crop BOTH layers to the inner ~66% of the
//      canvas. Handing the full-bleed artwork straight in would zoom the mask
//      into the middle of it and cut the burst off around the mark. So the
//      foreground is the artwork SCALED DOWN onto a transparent 1024 canvas,
//      which lets the launcher's mask land on the composition we designed.
//
// Run: dart run scripts/build_app_icon.dart <master.png>
// Then: dart run flutter_launcher_icons

import 'dart:io';

import 'package:image/image.dart' as img;

/// The ink ground, matching `adaptive_icon_background` in pubspec.yaml.
const _ink = 0x0F;

/// Canvas size for both outputs. 1024 is the iOS App Store requirement.
const _canvas = 1024;

/// How much of the adaptive canvas the artwork occupies.
///
/// The guaranteed-visible safe zone is 66.7%. This sits slightly above it so
/// that a rounder mask (or a launcher's parallax) does not reveal a rim of
/// flat background around the artwork; the only thing that trade costs is the
/// outermost ring of decorative burst dots, and the mark stays far inside.
const _foregroundFill = 0.75;

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run scripts/build_app_icon.dart <master.png>');
    exit(64);
  }

  final source = img.decodePng(File(args.first).readAsBytesSync());
  if (source == null) {
    stderr.writeln('could not decode ${args.first}');
    exit(65);
  }
  stdout.writeln('source: ${source.width}x${source.height}');

  // --- iOS / web master: flattened onto ink, no alpha, 1024 ----------------
  final flat = img.Image(width: source.width, height: source.height)
    ..clear(img.ColorRgb8(_ink, _ink, _ink));
  img.compositeImage(flat, source);
  final master = img.copyResize(
    flat,
    width: _canvas,
    height: _canvas,
    interpolation: img.Interpolation.cubic,
  );
  _write('assets/images/app_launcher_icon.png', master);

  // --- Android adaptive foreground: artwork inset on transparent ----------
  final inner = (_canvas * _foregroundFill).round();
  final scaled = img.copyResize(
    flat,
    width: inner,
    height: inner,
    interpolation: img.Interpolation.cubic,
  );
  final foreground = img.Image(width: _canvas, height: _canvas, numChannels: 4);
  final offset = ((_canvas - inner) / 2).round();
  img.compositeImage(foreground, scaled, dstX: offset, dstY: offset);
  _write('assets/images/app_launcher_icon_foreground.png', foreground);
}

void _write(String path, img.Image image) {
  File(path).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $path (${image.width}x${image.height})');
}
