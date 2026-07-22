// CiAvatar, CiPlayerSwitcher, CiIconButton — Phase 4.8
//
// Measured from Components / PlayerSwitcher and IconButton:
//   avatar      40x40 circle, ExtraBold 14 initials
//               selected: filled surface, ink initials
//               unselected: transparent with a 1px ring, light initials
//   switcher    row of avatars, 10px gap, trailing "+" in a ringed circle
//   IconButton  40x40, radius 6, 1px border
//               Light: surface fill, ink glyph
//               Dark:  transparent fill, dark border, white glyph
//
// Identity here is INITIALS, not a jersey number. JerseyTile exists in the
// Figma file but jersey numbers were dropped as a product decision - there is
// no field capturing one, and the rule is that the UI never displays a player
// attribute it cannot collect. It is deliberately not ported.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

/// A player avatar is a circle; the header profile is a rounded square.
///
/// The header one deliberately matches the icon buttons beside it (40x40,
/// radius 6) so the bell and the profile read as one pair, rather than a
/// circle floating next to a square.
enum CiAvatarShape { circle, rounded }

class CiAvatar extends StatelessWidget {
  const CiAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.selected = true,
    this.ringColor,
    this.ringWidth = 1,
    this.shape = CiAvatarShape.circle,
    this.onTap,
  });

  /// Full name; initials are derived. Passing "Jada White" yields "JW".
  final String name;

  /// Shown instead of initials when present.
  final String? imageUrl;

  final double size;

  /// An explicit ring, overriding the selected/unselected treatment.
  ///
  /// The New Game player tiles (286:1328) work the other way round from the
  /// switcher: EVERY avatar is filled the same sunk ink, and the RING is what
  /// changes - lime at 2pt for the chosen player, a dark grey hairline for the
  /// rest. Passing a ring switches to that treatment.
  final Color? ringColor;
  final double ringWidth;

  /// Filled when selected, ringed outline when not. In a switcher this is
  /// which player is active.
  final bool selected;

  /// Circle for a player, rounded square for the header profile.
  final CiAvatarShape shape;

  final VoidCallback? onTap;

  /// First letter of the first two words. Falls back to a single letter, and
  /// to '?' for an empty name rather than rendering an empty circle.
  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    final rounded = shape == CiAvatarShape.rounded;
    final radius = rounded ? CiRadius.chipR : null;

    final photo = imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(
            imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            // A broken photo URL must never blank the avatar - fall back to
            // initials, which always work.
            errorBuilder: (_, __, ___) => _initials(c),
          )
        : null;

    final child = photo == null
        ? _initials(c)
        : rounded
            ? ClipRRect(borderRadius: CiRadius.chipR, child: photo)
            : ClipOval(child: photo);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ringColor != null
            ? c.surfaceSunk
            : selected
                ? c.surfaceInvert
                : Colors.transparent,
        shape: rounded ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: radius,
        border: ringColor != null
            ? Border.all(color: ringColor!, width: ringWidth)
            : selected
                ? null
                : Border.all(color: c.borderStrong),
      ),
      child: child,
    );

    if (onTap == null) return avatar;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: avatar,
    );
  }

  Widget _initials(CiColors c) => Center(
        child: Text(
          initialsOf(name),
          style: CiType.rowLabel.copyWith(
            color: selected ? c.textInvert : c.text,
            fontWeight: CiWeight.extraBold,
            fontSize: size * 0.35,
            height: 1,
          ),
        ),
      );
}

/// Row of player avatars with a trailing add button.
class CiPlayerSwitcher extends StatelessWidget {
  const CiPlayerSwitcher({
    super.key,
    required this.names,
    required this.index,
    required this.onSelected,
    this.imageUrls = const [],
    this.onAdd,
  });

  final List<String> names;
  final int index;
  final ValueChanged<int> onSelected;
  final List<String?> imageUrls;

  /// Null hides the add slot entirely.
  ///
  /// Callers decide when that is - see runAddPlayerFlow. It is NOT hidden at
  /// the cap: the slot routes through the same gate as every other add
  /// entry point, which explains why rather than leaving a parent guessing.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < names.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          CiAvatar(
            name: names[i],
            imageUrl: i < imageUrls.length ? imageUrls[i] : null,
            selected: i == index,
            onTap: () => onSelected(i),
          ),
        ],
        if (onAdd != null) ...[
          if (names.isNotEmpty) const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Add player',
            child: GestureDetector(
              onTap: onAdd,
              behavior: HitTestBehavior.opaque,
              // DASHED, per the component (72:170). A solid ring reads as a
              // player who has not loaded; a dashed one reads as a space
              // waiting to be filled, which is what it is.
              child: CustomPaint(
                painter: _DashedRing(color: c.text.withValues(alpha: 0.18)),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.add,
                      size: 16, color: c.text.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CiIconButton extends StatelessWidget {
  const CiIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.onDark = false,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Transparent fill with a dark border, for use on ink backgrounds.
  final bool onDark;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final disabled = onPressed == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Material(
          color: onDark ? Colors.transparent : c.surface,
          borderRadius: CiRadius.chipR,
          child: InkWell(
            onTap: onPressed,
            borderRadius: CiRadius.chipR,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: CiRadius.chipR,
                border: Border.all(
                    color: onDark ? CiPalette.darkBorder : c.border),
              ),
              child: Icon(
                icon,
                size: 20,
                color: onDark ? CiPalette.white : c.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dashed ring around the add-player slot.
///
/// Painted because Flutter's Border draws solid only, and the alternative -
/// an image asset - would not take the ground's colour. Measured from 72:170:
/// a 1px stroke at 18% of the foreground.
class _DashedRing extends CustomPainter {
  const _DashedRing({required this.color});

  final Color color;

  /// Dash and gap in logical pixels. Close enough to the frame's rhythm that
  /// the ring reads as dashed rather than dotted at 40pt.
  static const double _dash = 3.5;
  static const double _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final centre = Offset(radius, radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Whole number of dash+gap pairs, so the ring closes cleanly instead of
    // leaving a long or clipped final dash at the twelve o'clock seam.
    final circumference = 2 * math.pi * (radius - 0.5);
    final pairs = (circumference / (_dash + _gap)).round().clamp(6, 60);
    final sweep = 2 * math.pi / pairs;
    final dashSweep = sweep * (_dash / (_dash + _gap));

    for (var i = 0; i < pairs; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius - 0.5),
        i * sweep,
        dashSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => old.color != color;
}
