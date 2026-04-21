import 'package:flutter/material.dart';

/// Shared picker model used by AddPlayerSheet and EditPlayerSheet.
///
/// A [PickerField] renders a tappable field card that looks identical to
/// the other gray field cards in the sheets; tapping it opens a
/// [PickerSheet] bottom modal with a hairline-divided list and brand-purple
/// selected state. Keeps both flows visually consistent and avoids the
/// stock Material dropdown menu that feels disconnected from our sheets.

const _fieldBg = Color(0xFFF0F0F0);
const _labelColor = Color(0xFF1A1A1A);
const _hintColor = Color(0xFFAAAAAA);
const _purple = Color(0xFF7936FF);
const _border = Color(0xFFE6E6E6);
const _handle = Color(0xFFC7C7C7);
const _fontIBMPlexSans = 'IBM Plex Sans';

/// Shows the picker sheet and returns the chosen option, or null on dismiss.
/// Drops keyboard focus first so the sheet doesn't get shoved up by
/// `viewInsets` when the caller has a focused TextField.
Future<T?> presentPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  T? current,
  PickerAddNew? addNew,
}) async {
  FocusScope.of(context).unfocus();
  await Future<void>.delayed(const Duration(milliseconds: 60));
  if (!context.mounted) return null;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PickerSheet<T>(
      title: title,
      options: options,
      labelOf: labelOf,
      current: current,
      addNew: addNew,
    ),
  );
}

/// Optional "+ Add new" row rendered at the top of a [PickerSheet]. The
/// [onTap] callback receives the sheet's context so the caller can pop the
/// picker before presenting a follow-on creation sheet.
class PickerAddNew {
  const PickerAddNew({required this.label, required this.onTap});
  final String label;
  final Future<void> Function(BuildContext sheetContext) onTap;
}

/// Tappable field card — drop-in replacement for `DropdownButton`. Matches
/// the gray rounded field style used in the add/edit player sheets.
class PickerField<T> extends StatelessWidget {
  const PickerField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.displayOf,
    required this.onTap,
  });

  final T? value;
  final String placeholder;
  final String Function(T) displayOf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? placeholder : displayOf(value as T);
    final isPlaceholder = value == null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _fontIBMPlexSans,
                      fontSize: 16,
                      color: isPlaceholder ? _hintColor : _labelColor,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: _hintColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet list of options. Current selection highlighted in brand
/// purple with a checkmark. Caps height at 60% of screen so long lists
/// (years) stay scrollable without covering the screen.
class PickerSheet<T> extends StatelessWidget {
  const PickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.labelOf,
    required this.current,
    this.addNew,
  });

  final String title;
  final List<T> options;
  final String Function(T) labelOf;
  final T? current;
  final PickerAddNew? addNew;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.6;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH + bottomInset + 80),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _labelColor,
              ),
            ),
          ),
          if (addNew != null)
            InkWell(
              onTap: () => addNew!.onTap(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 20, color: _purple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        addNew!.label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 12 + bottomInset),
              itemCount: options.length,
              itemBuilder: (context, i) {
                final opt = options[i];
                final selected = current != null && current == opt;
                final showTopBorder = i != 0 || addNew != null;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(opt),
                  child: Container(
                    decoration: showTopBorder
                        ? const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: _border, width: 1),
                            ),
                          )
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            labelOf(opt),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? _purple : _labelColor,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check, size: 22, color: _purple),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
