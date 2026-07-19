// CiButton — Phase 4.8
//
// Measured from Components / Button (Style x Size):
//   Md  h48, horizontal padding 24, SemiBold 15
//   Sm  h40, horizontal padding 16, SemiBold 13
//   radius 999 (pill) on every variant, icon gap 8
//
//   Primary    ink fill,    white label
//   Secondary  surface fill, 1px border, ink label
//   Lime       lime fill,   INK label
//   Orange     orange fill, INK label
//
// Lime and orange labels are ink, never white. That is the locked on-accent
// rule and it is why those two styles read `c.onAccent` rather than a
// per-style color.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

enum CiButtonStyle { primary, secondary, lime, orange }

enum CiButtonSize { md, sm }

class CiButton extends StatelessWidget {
  const CiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = CiButtonStyle.primary,
    this.size = CiButtonSize.md,
    this.icon,
    this.expand = false,
    this.busy = false,
  });

  final String label;

  /// Null disables the button. There is no separate `enabled` flag - one way
  /// to express one state.
  final VoidCallback? onPressed;

  final CiButtonStyle style;
  final CiButtonSize size;
  final IconData? icon;

  /// Stretch to the available width. Off by default: buttons hug their label
  /// in the designs except where a screen explicitly wants full width.
  final bool expand;

  /// Shows a spinner and blocks taps. Keeps the button's width so the layout
  /// does not jump while a save is in flight.
  final bool busy;

  bool get _disabled => onPressed == null || busy;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final md = size == CiButtonSize.md;

    final (Color bg, Color fg, Color? border) = switch (style) {
      CiButtonStyle.primary => (c.surfaceInvert, c.textInvert, null),
      CiButtonStyle.secondary => (c.surface, c.text, c.border),
      CiButtonStyle.lime => (c.accentGood, c.onAccent, null),
      CiButtonStyle.orange => (c.accentEnergy, c.onAccent, null),
    };

    final textStyle = (md ? CiType.rowTitle : CiType.buttonSm).copyWith(color: fg);

    final content = busy
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: md ? 18 : 16, color: fg),
                const SizedBox(width: CiSpace.s2),
              ],
              Flexible(
                child: Text(label,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    return Opacity(
      // Disabled reads as recessive, not as a different color. Keeps one
      // visual language instead of inventing a disabled palette per style.
      opacity: _disabled ? 0.4 : 1,
      child: Semantics(
        button: true,
        enabled: !_disabled,
        label: label,
        child: Material(
          color: bg,
          borderRadius: CiRadius.pillR,
          child: InkWell(
            onTap: _disabled ? null : onPressed,
            borderRadius: CiRadius.pillR,
            child: Container(
              height: md ? 48 : 40,
              padding: EdgeInsets.symmetric(
                  horizontal: md ? CiSpace.s6 : CiSpace.s4),
              decoration: BoxDecoration(
                borderRadius: CiRadius.pillR,
                border: border == null ? null : Border.all(color: border),
              ),
              // Align ONLY when expanding. A Container with an alignment and
              // no explicit width fills its constraints rather than hugging
              // its child, which silently made every button full width.
              alignment: expand ? Alignment.center : null,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
