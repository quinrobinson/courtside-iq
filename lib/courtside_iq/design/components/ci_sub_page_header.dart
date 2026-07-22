// Sub-page header — Phase 4.15
//
// Measured from Your Profile (295:1385): a 40pt back button at x12, the title
// SemiBold 17 CENTRED ACROSS THE FULL WIDTH, and a full-bleed rule at 104.
//
// LIGHT, NOT INK. The list screens (Players, Games, Menu) wear an ink header
// because they are destinations; these are pages you are passing through, and
// an ink bar on each would make a two-tap detour feel like leaving the app.
//
// THE TITLE CENTRES ON THE SCREEN, not in the space left over beside the back
// button. The frame draws it at x0 across all 390, so it stays put whether or
// not a trailing action is present - otherwise a title shifts as you move
// between screens that happen to have one.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

class CiSubPageHeader extends StatelessWidget {
  const CiSubPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;

  /// Defaults to popping the route. Passed explicitly only where leaving
  /// needs to do something first, such as discarding an edit.
  final VoidCallback? onBack;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: Stack(
            children: [
              // Centred first, so it sits under the controls rather than
              // being pushed by them.
              Center(
                child: Text(
                  title,
                  style: CiType.rowTitle
                      .copyWith(color: c.text, fontWeight: CiWeight.semiBold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 12,
                top: 6,
                child: Semantics(
                  button: true,
                  label: 'Back',
                  container: true,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 18, color: c.text),
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                Positioned(
                  right: 12,
                  top: 6,
                  child: SizedBox(height: 40, child: Center(child: trailing)),
                ),
            ],
          ),
        ),
        Container(height: CiSpace.hairline, color: c.hairline),
      ],
    );
  }
}
