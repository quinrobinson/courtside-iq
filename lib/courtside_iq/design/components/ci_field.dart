// CiField + CiChip — Phase 4.8
//
// Measured from Screens / Email Auth (Sign In):
//   Field   350x72, label ABOVE the input with an 8px gap
//   LABEL   Medium 12, uppercase, muted
//   input   h48, radius 6, 16px horizontal padding, 1px border
//           on ink ground the fill is #000000, sitting DEEPER than the
//           #0F0F0F background; on light ground it is the sunk grey
//   chip    h32, pill radius, 14px padding, Regular 14
//           active white + ink, inactive sunk + muted
//
// LABEL ABOVE THE INPUT, ALWAYS. Never placeholder-as-label: the moment a
// parent starts typing, a placeholder label disappears and they lose the only
// clue about what the field wanted. The placeholder here is an example value,
// not a name.
//
// CHIPS ARE FILTERS AND TOGGLES. Tabs are navigation. The pill shape is that
// distinction made visible - see CiSegmentedTabs for the other half.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

class CiField extends StatefulWidget {
  const CiField({
    super.key,
    required this.label,
    this.controller,
    this.placeholder,
    this.obscure = false,
    this.trailing,
    this.onTrailingTap,
    this.keyboardType,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  /// Rendered above the input, uppercased. Required - a field without a
  /// visible name is the thing this component exists to prevent.
  final String label;

  final TextEditingController? controller;

  /// An EXAMPLE value, not a restatement of the label.
  final String? placeholder;

  final bool obscure;

  /// Inline action text, e.g. "Show" on a password field.
  final String? trailing;
  final VoidCallback? onTrailingTap;

  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<CiField> createState() => _CiFieldState();
}

class _CiFieldState extends State<CiField> {
  late final FocusNode _focus = FocusNode()..addListener(_onFocusChange);
  bool _focused = false;

  void _onFocusChange() {
    if (_focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final w = widget;
    final hasError = w.errorText != null && w.errorText!.isNotEmpty;

    // Error wins over focus: a field that is both must show the problem.
    // Otherwise focus reads as the strong border - white on ink, ink on
    // light - so the active field is unmistakable while typing.
    final borderColor = hasError
        ? c.accentEnergy
        : _focused
            ? c.focusRing
            : c.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          w.label.toUpperCase(),
          style: CiType.caption.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: CiSpace.s2),
        Opacity(
          opacity: w.enabled ? 1 : 0.5,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: CiSpace.s4),
            decoration: BoxDecoration(
              // The ground decides the fill, and the palette already knows
              // which ground it is on, so nothing is derived here. See
              // CiColors.fieldFill for why this had to become a token.
              color: c.fieldFill,
              borderRadius: CiRadius.chipR,
              border: Border.all(
                color: borderColor,
                // Focus thickens the ring as well as recolouring it, so the
                // state survives a glance and does not rely on colour alone.
                width: _focused && !hasError ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focus,
                    controller: w.controller,
                    obscureText: w.obscure,
                    enabled: w.enabled,
                    keyboardType: w.keyboardType,
                    onChanged: w.onChanged,
                    style: CiType.rowTitle
                        .copyWith(color: c.text, fontWeight: CiWeight.regular),
                    cursorColor: c.accentGood,
                    decoration: InputDecoration(
                      // The app theme sets `filled: true` with its own fill.
                      // Left on, the TextField paints a second box INSIDE this
                      // container - visible as a grey rectangle around the
                      // text on the ink auth fields.
                      filled: false,
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: w.placeholder,
                      hintStyle: CiType.rowTitle.copyWith(
                          color: c.textFaint, fontWeight: CiWeight.regular),
                    ),
                  ),
                ),
                if (w.trailing != null) ...[
                  const SizedBox(width: CiSpace.s2),
                  GestureDetector(
                    onTap: w.onTrailingTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(w.trailing!,
                        style: CiType.rowLabel.copyWith(
                            color: c.textFaint,
                            fontWeight: CiWeight.medium)),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: CiSpace.s1),
          Text(w.errorText!,
              style: CiType.bodyXs.copyWith(color: c.accentEnergy)),
        ],
      ],
    );
  }
}

/// Filter and toggle chip. h32, pill, Regular 14.
class CiChip extends StatelessWidget {
  const CiChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? c.surfaceInvert : c.surfaceSunk,
            borderRadius: CiRadius.pillR,
          ),
          // No alignment: a Container with one and no explicit width fills its
          // constraints instead of hugging. Chips must hug their label.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: CiType.bodySm.copyWith(
                  color: selected ? c.textInvert : c.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of chips with single selection.
class CiChipBar extends StatelessWidget {
  const CiChipBar({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CiSpace.s2,
      runSpacing: CiSpace.s2,
      children: [
        for (var i = 0; i < labels.length; i++)
          CiChip(
            label: labels[i],
            selected: i == index,
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}
