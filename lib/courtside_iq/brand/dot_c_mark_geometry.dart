// The Courtside IQ mark, Dot-burst C - geometry (Quin, 2026-09-28).
//
// Two rings of dots forming a C that opens right. Along each ring, from the
// bottom tip to the top tip, the dots GROW (45% to 100% of the ring's base
// size) and FADE IN (30% to 100% opacity): development read in one sweep.
// Neighbouring dots sit an equal 7 units apart, and the composition is
// optically centred in its 256 box (a touch right for the open mouth, a touch
// above centre).
//
// THIS FILE IS THE ONLY COPY OF THE SHAPE. CiLogoMark paints it, and
// scripts/build_dot_c_icon.dart generates the app icon's layer and master
// from it; a test holds the icon to it. Figma: LogoMark 1066:364 and
// AppIcon (Dot C) 1084:7034 on the Branding page. Change the shape there
// first, then here - never adjust a number here on its own.
//
// Pure Dart on purpose (no Flutter imports), so scripts can use it.

/// One dot: centre and radius in the 256 icon box, and its opacity.
class MarkDot {
  const MarkDot(this.x, this.y, this.r, this.opacity);
  final double x;
  final double y;
  final double r;
  final double opacity;
}

/// The icon composition's box. The app icon places the dots on this box as-is
/// (scaled to 1024), padding included.
const double kMarkIconBox = 256;

/// Inner ring first (11 dots), then the outer ring (15).
const List<MarkDot> kMarkDots = [
  // Inner ring, bottom tip to top tip.
  MarkDot(181.37, 165.70, 5.40, 0.300),
  MarkDot(164.61, 179.23, 5.92, 0.370),
  MarkDot(142.89, 185.53, 6.47, 0.440),
  MarkDot(119.37, 182.35, 7.05, 0.510),
  MarkDot(98.42, 168.85, 7.65, 0.580),
  MarkDot(85.01, 146.38, 8.29, 0.650),
  MarkDot(83.52, 118.95, 8.96, 0.720),
  MarkDot(96.16, 93.02, 9.66, 0.790),
  MarkDot(121.45, 76.36, 10.40, 0.860),
  MarkDot(153.25, 75.69, 11.18, 0.930),
  MarkDot(181.37, 93.71, 12.00, 1.000),
  // Outer ring, bottom tip to top tip.
  MarkDot(207.42, 187.56, 6.75, 0.300),
  MarkDot(189.53, 203.82, 7.20, 0.350),
  MarkDot(167.07, 215.04, 7.68, 0.400),
  MarkDot(141.42, 219.66, 8.17, 0.450),
  MarkDot(114.54, 216.47, 8.68, 0.500),
  MarkDot(88.94, 204.85, 9.21, 0.550),
  MarkDot(67.50, 185.05, 9.76, 0.600),
  MarkDot(53.15, 158.36, 10.33, 0.650),
  MarkDot(48.51, 127.23, 10.92, 0.700),
  MarkDot(55.32, 95.27, 11.54, 0.750),
  MarkDot(73.99, 66.92, 12.18, 0.800),
  MarkDot(103.04, 46.97, 12.84, 0.850),
  MarkDot(138.91, 39.71, 13.54, 0.900),
  MarkDot(176.03, 47.92, 14.25, 0.950),
  MarkDot(207.42, 71.86, 15.00, 1.000),
];

/// The square that tightly holds the dots, in icon-box units: the in-app mark
/// fills its box edge to edge, like the Figma LogoMark component.
({double left, double top, double side}) markBounds() {
  var l = double.infinity, t = double.infinity;
  var r = double.negativeInfinity, b = double.negativeInfinity;
  for (final d in kMarkDots) {
    if (d.x - d.r < l) l = d.x - d.r;
    if (d.y - d.r < t) t = d.y - d.r;
    if (d.x + d.r > r) r = d.x + d.r;
    if (d.y + d.r > b) b = d.y + d.r;
  }
  final side = (r - l) > (b - t) ? r - l : b - t;
  return (
    left: l - (side - (r - l)) / 2,
    top: t - (side - (b - t)) / 2,
    side: side,
  );
}
