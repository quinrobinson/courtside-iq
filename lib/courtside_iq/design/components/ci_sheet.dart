// CiSheet — Phase 4.11d
//
// The shell every bottom sheet in 2.0 shares. Measured from About Story
// (648:2195), About Growth IQ (691:2845), Edit Position (641:2183) and Set
// Birth Date (643:2188), which are the same frame with different middles:
//
//   grabber  36x4, radius 2, centred, 12 from the top
//   title    Bold 20 at 24/34
//   close    IconButton 40 at right 24 / top 24
//   body     caller's content
//   CTA      full-width lime pill, 48 tall, 24 inset
//
// SQUARE TOP CORNERS. None of those four frames carries a radius. The system
// HAS a sheet radius, which is exactly why this is written down: the first
// info sheet got CiRadius.sheetTopR applied on reflex and had to be undone.
//
// Extracted once four sheets wanted it rather than up front. Three of them
// would have been a guess about what varies; four showed that only the middle
// and the CTA label do.

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';
import 'ci_avatar.dart';
import 'ci_button.dart';

/// Presents [child] with the app's standard modal treatment.
///
/// [useRootNavigator] defaults TRUE because these sheets are opened from
/// inside other sheets - the position picker from Add Player, for one - and a
/// nested sheet on the same navigator can land BEHIND its parent instead of
/// above it.
Future<T?> showCiSheet<T>(
  BuildContext context, {
  required Widget child,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}

class CiSheet extends StatelessWidget {
  const CiSheet({
    super.key,
    required this.title,
    required this.child,
    this.cta,
    this.onCta,
    this.ctaBusy = false,
    this.onClose,
  });

  final String title;

  /// The sheet's middle. Sized by its own content: these sheets differ in
  /// height only by what goes here.
  final Widget child;

  /// Null renders no button at all. An explainer that only needs dismissing
  /// passes "Got it"; a picker passes "Save".
  final String? cta;

  /// Null with a non-null [cta] renders the button disabled, which is how a
  /// picker says "nothing chosen yet".
  final VoidCallback? onCta;

  final bool ctaBusy;

  /// Defaults to popping the sheet.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return ColoredBox(
      color: c.bg,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(CiSpace.screen, 18, CiSpace.s4, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      // Aligns the title's optical centre with the close
                      // button, which is 40 tall against a 24 cap height.
                      padding: const EdgeInsets.only(top: CiSpace.s2),
                      child: Text(title,
                          style: CiType.h3.copyWith(color: c.text)),
                    ),
                  ),
                  const SizedBox(width: CiSpace.s3),
                  CiIconButton(
                    icon: Icons.close,
                    semanticLabel: 'Close',
                    onPressed:
                        onClose ?? () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Flexible(child: child),
            if (cta != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s6),
                child: CiButton(
                  label: cta!,
                  // Lime on every sheet in the set. These buttons complete a
                  // small friendly task; none of them is destructive.
                  style: CiButtonStyle.lime,
                  expand: true,
                  busy: ctaBusy,
                  onPressed: onCta,
                ),
              )
            else
              const SizedBox(height: CiSpace.s6),
          ],
        ),
      ),
    );
  }
}

/// A row inside a sheet: a label, and a check when it is the chosen one.
///
/// Measured from Edit Position (641:2214): 56 tall, label Medium 16 at 24,
/// check 22 at the right. Its divider is INSET to the 24 gutter, unlike every
/// hairline on a screen - inside a sheet the rule follows the content rather
/// than the edge.
class CiSheetOptionRow extends StatelessWidget {
  const CiSheetOptionRow({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.showDivider = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: CiSpace.screen),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: CiType.body.copyWith(
                            color: c.text, fontWeight: CiWeight.medium),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check, size: 22, color: c.text),
                  ],
                ),
              ),
            ),
            if (showDivider)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: CiSpace.screen),
                child: Container(
                  height: CiSpace.hairline,
                  color: c.hairline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A sheet that picks one option from a list.
///
/// Measured from Edit Position (641:2183). Note the interaction CHANGED from
/// v1: that sheet popped the moment a row was tapped, this one holds the
/// choice and commits on Save. Slower by one tap, and recoverable from a
/// mis-tap on a list where the rows are 56pt apart.
class CiOptionSheet<T> extends StatefulWidget {
  const CiOptionSheet({
    super.key,
    required this.title,
    required this.options,
    required this.labelOf,
    this.current,
    this.cta = 'Save',
  });

  final String title;
  final List<T> options;
  final String Function(T) labelOf;
  final T? current;
  final String cta;

  @override
  State<CiOptionSheet<T>> createState() => _CiOptionSheetState<T>();
}

class _CiOptionSheetState<T> extends State<CiOptionSheet<T>> {
  late T? _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    // Capped so a long list - years, in the birth-date flow - stays
    // scrollable instead of growing past the top of the screen. Carried from
    // the v1 picker, which learned it the same way.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    return CiSheet(
      title: widget.title,
      cta: widget.cta,
      // Disabled until something is chosen: a Save that commits nothing is a
      // button that lies about what it does.
      onCta: _selected == null
          ? null
          : () => Navigator.of(context).pop(_selected),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.options.length,
          itemBuilder: (context, i) {
            final option = widget.options[i];
            return CiSheetOptionRow(
              label: widget.labelOf(option),
              selected: _selected == option,
              onTap: () => setState(() => _selected = option),
            );
          },
        ),
      ),
    );
  }
}
