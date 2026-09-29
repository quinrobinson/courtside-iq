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

/// How the mark sits inside an app icon (Quin, 2026-09-28, placed by hand in
/// Figma section 1101:974, row 70%, dead-centre column).
///
/// The mark's box fills [fill] of the visible icon shape, and its centre sits
/// [dx] / [dy] away from the shape's centre, as fractions of that shape's
/// width (negative = left / up). The square and the circle differ because the
/// C is two concentric rings with an opening on the right: centring its BOX
/// leaves the rings visibly right of centre, most of all inside a circle mask,
/// where the rings should read concentric with the mask.
class IconPlacement {
  const IconPlacement({required this.fill, required this.dx, required this.dy});
  final double fill;
  final double dx;
  final double dy;
}

/// iOS, the Play Store listing icon, legacy Android and web: a square.
const kIconPlacementSquare = IconPlacement(fill: 0.70, dx: -0.0111, dy: -0.0040);

/// Android adaptive launcher icon: the launcher shows a circle (or squircle)
/// cut from the middle 72dp of a 108dp layer.
const kIconPlacementCircle = IconPlacement(fill: 0.70, dx: -0.0278, dy: -0.0040);

/// The dots placed in an icon: [canvas] is the layer's size and [shape] the
/// size of the visible shape centred in it (equal for iOS; 72/108 of the
/// canvas for an Android adaptive layer). Radii and opacities carry over.
List<MarkDot> iconDots(IconPlacement p, {required double canvas, double? shape}) {
  final visible = shape ?? canvas;
  final b = markBounds();
  final side = visible * p.fill;
  final k = side / b.side;
  final left = canvas / 2 + p.dx * visible - side / 2;
  final top = canvas / 2 + p.dy * visible - side / 2;
  return [
    for (final d in kMarkDots)
      MarkDot(
        left + (d.x - b.left) * k,
        top + (d.y - b.top) * k,
        d.r * k,
        d.opacity,
      ),
  ];
}
