import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import 'picker_sheet.dart';

const _sheetBg      = CIColors.surface;
const _fieldBg      = CIColors.surfaceAlt;
const _labelColor   = CIColors.ink;
const _hintColor    = CIColors.ink4;
const _saveDisabled = CIColors.canvasSunk;
const _saveEnabled  = CIColors.ink;
const _handleColor  = CIColors.ink4;


const _months = [
  'January', 'February', 'March', 'April',
  'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

Future<void> showAddPlayerSheet(
  BuildContext context, {
  VoidCallback? onPlayerAdded,
}) {
  return showModalBottomSheet(
    // Covers the nav bar: a sheet pushed on a shell BRANCH navigator
    // renders inside the branch, leaving the tabs sitting over it.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddPlayerSheet(onPlayerAdded: onPlayerAdded),
  );
}

class AddPlayerSheet extends StatefulWidget {
  const AddPlayerSheet({super.key, this.onPlayerAdded});
  final VoidCallback? onPlayerAdded;

  @override
  State<AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<AddPlayerSheet> {
  final _nameController = TextEditingController();
  String? _position;
  int?    _month;
  int?    _year;
  List<String> _positions = [];
  bool _saving = false;

  /// Shown INLINE, above the Save button.
  ///
  /// A SnackBar raised from inside a modal bottom sheet renders BEHIND the
  /// sheet, so the previous attempt caught the error, stopped the spinner and
  /// showed the parent nothing at all - which reads as "Save does nothing".
  /// The message has to live where the sheet is.
  String? _error;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(17, (i) => now - 3 - i);
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _position != null &&
      _month != null &&
      _year != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _loadPositions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    // Wrapped: an unhandled failure here left _positions empty, and an empty
    // picker is indistinguishable from a picker that never opened. The error
    // now surfaces instead of presenting as a dead control.
    try {
      final rows = await SupaFlow.client
          .from('player_positions_list')
          .select('position_name')
          .order('id');
      if (!mounted) return;
      setState(() {
        _positions = (rows as List)
            .map((r) => r['position_name'] as String)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      showCiToast(context, 'Could not load positions: $e',
          type: CiToastType.error);
    }
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) { setState(() => _saving = false); return; }

    final birthDate =
        '$_year-${_month!.toString().padLeft(2, '0')}-01';

    // GUARDED. This insert can legitimately be REFUSED by the server: the
    // players INSERT policy allows it only for a premium user or one under
    // the free allowance. Unguarded, that refusal threw, _saving stayed true,
    // and the button span forever with no explanation - which is how it
    // presented on device.
    try {
      await SupaFlow.client.from('players').insert({
        'first_name':       _nameController.text.trim(),
        'player_position':  _position!,
        'user_id':          userId,
        'birth_date':       birthDate,
      });
    } catch (e) {
      if (!mounted) return;
      final refused = e.toString().contains('row-level security');
      setState(() {
        _saving = false;
        _error = refused
            // Says what the parent can do, not what the database called it.
            ? 'Your plan does not allow another player right now.'
            : 'Could not add player. Please try again.';
      });
      return;
    }

    widget.onPlayerAdded?.call();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(CIRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 48 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 34, height: 6,
              decoration: BoxDecoration(
                color: _handleColor,
                borderRadius: BorderRadius.circular(CIRadius.xs),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Player',
                style: TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: _labelColor,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  '×',
                  style: TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 24,
                    color: _labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // NAME
          const _Label('NAME'),
          const SizedBox(height: 6),
          _FieldCard(
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontFamily: CIType.fontFamily,
                fontSize: 16,
                color: _labelColor,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter player name...',
                hintStyle: TextStyle(
                  fontFamily: CIType.fontFamily,
                  fontSize: 16,
                  color: _hintColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // PLAYER POSITION
          const _Label('PLAYER POSITION'),
          const SizedBox(height: 6),
          PickerField<String>(
            value: _position,
            placeholder: 'Select position',
            displayOf: (v) => v,
            onTap: () async {
              final picked = await presentPickerSheet<String>(
                context,
                title: 'Select position',
                options: _positions,
                labelOf: (v) => v,
                current: _position,
              );
              if (picked != null) setState(() => _position = picked);
            },
          ),
          const SizedBox(height: 16),

          // BIRTH MONTH & YEAR
          const _Label('BIRTH MONTH & YEAR'),
          const SizedBox(height: 6),
          Row(
            children: [
              // Month (~62%)
              Expanded(
                flex: 62,
                child: PickerField<int>(
                  value: _month,
                  placeholder: 'Month',
                  displayOf: (m) => _months[m - 1],
                  onTap: () async {
                    final picked = await presentPickerSheet<int>(
                      context,
                      title: 'Select month',
                      options: List.generate(12, (i) => i + 1),
                      labelOf: (m) => _months[m - 1],
                      current: _month,
                    );
                    if (picked != null) setState(() => _month = picked);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Year (~38%)
              Expanded(
                flex: 38,
                child: PickerField<int>(
                  value: _year,
                  placeholder: 'Year',
                  displayOf: (y) => '$y',
                  onTap: () async {
                    final picked = await presentPickerSheet<int>(
                      context,
                      title: 'Select year',
                      options: _years,
                      labelOf: (y) => '$y',
                      current: _year,
                    );
                    if (picked != null) setState(() => _year = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Helper text
          const Text(
            'Used to give your player age-appropriate ratings.',
            style: TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 13,
              color: _hintColor,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline,
                    size: 18, color: Color(0xFFFF4F00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFFFF4F00),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? _saveEnabled : _saveDisabled,
                disabledBackgroundColor: _saveDisabled,
                foregroundColor: CIColors.inkOnBrand,
                disabledForegroundColor: _hintColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CIRadius.lg),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CIColors.inkOnBrand,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: CIType.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: CIType.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: _labelColor,
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(CIRadius.lg),
      ),
      child: child,
    );
  }
}
