// CiStepper — Phase 4.8
//
// Live stat entry. Measured from Components / Stepper:
//   192x83 overall, label Medium 13 muted, 10px gap
//   row: 56x56 minus, 16px gap, value Light 32, 16px gap, 56x56 plus
//   buttons radius 6 (chip), 1px border, glyphs Light 30
//
// The 56px buttons matter. A parent taps these one-handed, standing, watching
// their kid rather than the screen - the design review specifically raised
// button height here. 56 is well above the 44px minimum and that headroom is
// the point, not slack to trim.
//
// Decrement stops at zero and never goes negative: there is no such thing as
// minus one rebound, and a parent who over-taps should not have to fix a
// nonsense number mid-game.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

class CiStepper extends StatelessWidget {
  const CiStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.enabled = true,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool enabled;

  void _bump(int delta) {
    final next = (value + delta).clamp(min, max);
    if (next == value) return;
    // Live entry is eyes-off. Haptics are the only confirmation a parent gets
    // that a tap registered, so they are functional here, not decoration.
    HapticFeedback.selectionClick();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: CiType.labelTight.copyWith(color: c.textMuted)),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StepButton(
              glyph: '−', // true minus sign, not a hyphen
              onTap: enabled && value > min ? () => _bump(-1) : null,
              semanticLabel: 'Decrease $label',
            ),
            const SizedBox(width: CiSpace.s4),
            SizedBox(
              width: 48,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: CiType.statSm.copyWith(color: c.text),
              ),
            ),
            const SizedBox(width: CiSpace.s4),
            _StepButton(
              glyph: '+',
              onTap: enabled && value < max ? () => _bump(1) : null,
              semanticLabel: 'Increase $label',
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.glyph,
    required this.onTap,
    required this.semanticLabel,
  });

  final String glyph;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final disabled = onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel,
      child: Opacity(
        opacity: disabled ? 0.35 : 1,
        child: Material(
          color: c.surface,
          borderRadius: CiRadius.chipR,
          child: InkWell(
            onTap: onTap,
            borderRadius: CiRadius.chipR,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: CiRadius.chipR,
                border: Border.all(color: c.border),
              ),
              alignment: Alignment.center,
              child: Text(
                glyph,
                style: CiType.statSm.copyWith(
                  color: c.text,
                  fontWeight: CiWeight.light,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
