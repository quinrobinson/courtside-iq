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
    this.shape = CiAvatarShape.circle,
    this.onTap,
  });

  /// Full name; initials are derived. Passing "Jada White" yields "JW".
  final String name;

  /// Shown instead of initials when present.
  final String? imageUrl;

  final double size;

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
        color: selected ? c.surfaceInvert : Colors.transparent,
        shape: rounded ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: radius,
        border: selected ? null : Border.all(color: c.borderStrong),
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

  /// Null hides the add button, e.g. when a free user is at their limit.
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
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.borderStrong),
                ),
                child: Icon(Icons.add, size: 16, color: c.text),
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
