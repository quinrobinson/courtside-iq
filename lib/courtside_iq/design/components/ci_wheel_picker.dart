// CiWheelPicker — Phase 4.11d
//
// Measured from Set Birth Date (643:2188):
//
//   rows      38 apart, selected SemiBold 20, neighbours Regular 18
//   fade      42% opacity one row out, 18% two rows out, nothing beyond
//   band      the selection highlight is drawn ONCE behind both wheels, not
//             per wheel - see CiWheelBand
//
// Rolled rather than reached for CupertinoPicker: that control brings iOS
// chrome (its own magnifier, overlay and dividers) that fights this system's
// flat treatment, and it cannot express the two-step opacity falloff the
// frame specifies.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

/// Height of one row, and therefore of the selection band.
const double kCiWheelItemExtent = 38;

/// Rows visible above and below the selection. Three each way fills the
/// frame's 38*5 window without drawing rows the fade has taken to nothing.
const int _kVisibleEachSide = 3;

class CiWheelPicker<T> extends StatefulWidget {
  const CiWheelPicker({
    super.key,
    required this.items,
    required this.labelOf,
    required this.index,
    required this.onChanged,
    this.semanticLabel,
  });

  final List<T> items;
  final String Function(T) labelOf;

  final int index;
  final ValueChanged<int> onChanged;

  final String? semanticLabel;

  @override
  State<CiWheelPicker<T>> createState() => _CiWheelPickerState<T>();
}

class _CiWheelPickerState<T> extends State<CiWheelPicker<T>> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.index);

  @override
  void didUpdateWidget(CiWheelPicker<T> old) {
    super.didUpdateWidget(old);
    // Only drive the wheel when the value changed from OUTSIDE. Jumping in
    // response to the wheel's own scroll would fight the user's finger.
    if (widget.index != old.index &&
        _controller.hasClients &&
        _controller.selectedItem != widget.index) {
      _controller.jumpToItem(widget.index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Semantics(
      label: widget.semanticLabel,
      value: widget.items.isEmpty
          ? null
          : widget.labelOf(widget.items[widget.index]),
      child: SizedBox(
        height: kCiWheelItemExtent * (_kVisibleEachSide * 2 + 1),
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: kCiWheelItemExtent,
          // Flat, not a barrel. A high diameter ratio and no perspective keep
          // the rows reading as a list; the fade is what conveys depth.
          diameterRatio: 100,
          perspective: 0.0001,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: widget.onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.items.length,
            builder: (context, i) {
              final distance = (i - widget.index).abs();
              final selected = distance == 0;
              // 100 / 42 / 18, straight from the frame. Beyond two rows the
              // text is gone rather than faintly present.
              final opacity = switch (distance) {
                0 => 1.0,
                1 => 0.42,
                2 => 0.18,
                _ => 0.0,
              };

              return Center(
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    widget.labelOf(widget.items[i]),
                    style: selected
                        ? CiType.h4.copyWith(
                            color: c.text, fontWeight: CiWeight.semiBold)
                        : CiType.unit.copyWith(color: c.text),
                    maxLines: 1,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The selection highlight behind a row of wheels.
///
/// Drawn once, spanning every wheel, because the frame's band runs the full
/// 342 content width rather than boxing each column. A band per wheel would
/// put a seam down the middle of what is one selection.
class CiWheelBand extends StatelessWidget {
  const CiWheelBand({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Center(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: c.surfaceSunk,
                borderRadius: CiRadius.chipR,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
