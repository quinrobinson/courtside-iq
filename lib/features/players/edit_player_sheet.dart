import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import 'picker_sheet.dart';

// Design tokens — mirror AddPlayerSheet so the two sheets feel like siblings.
const _sheetBg      = Color(0xFFFFFFFF);
const _fieldBg      = Color(0xFFF0F0F0);
const _labelColor   = Color(0xFF1A1A1A);
const _hintColor    = Color(0xFFAAAAAA);
const _saveDisabled = Color(0xFFE8E8E8);
const _saveEnabled  = Color(0xFF1A1A1A);
const _handleColor  = Color(0xFFC7C7C7);

const _fontMontserrat  = 'Montserrat';
const _fontIBMPlexSans = 'IBM Plex Sans';

const _months = [
  'January', 'February', 'March', 'April',
  'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

/// Opens the Edit Player sheet pre-filled with the player's current values.
/// Returns `true` if the player was updated (so the caller can refresh).
Future<bool?> showEditPlayerSheet(
  BuildContext context, {
  required String playerId,
  required String firstName,
  required String? position,
  required DateTime? birthDate,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditPlayerSheet(
      playerId: playerId,
      initialFirstName: firstName,
      initialPosition: position,
      initialBirthDate: birthDate,
    ),
  );
}

class EditPlayerSheet extends StatefulWidget {
  const EditPlayerSheet({
    super.key,
    required this.playerId,
    required this.initialFirstName,
    required this.initialPosition,
    required this.initialBirthDate,
  });

  final String playerId;
  final String initialFirstName;
  final String? initialPosition;
  final DateTime? initialBirthDate;

  @override
  State<EditPlayerSheet> createState() => _EditPlayerSheetState();
}

class _EditPlayerSheetState extends State<EditPlayerSheet> {
  late final TextEditingController _nameController;
  String? _position;
  int? _month;
  int? _year;
  List<String> _positions = [];
  bool _saving = false;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(17, (i) => now - 3 - i);
  }

  bool get _valid =>
      _nameController.text.trim().isNotEmpty &&
      _position != null &&
      _month != null &&
      _year != null;

  bool get _dirty {
    if (_nameController.text.trim() != widget.initialFirstName.trim()) {
      return true;
    }
    if (_position != widget.initialPosition) return true;
    final bd = widget.initialBirthDate;
    if (bd?.month != _month || bd?.year != _year) return true;
    return false;
  }

  bool get _canSave => _valid && _dirty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFirstName);
    _nameController.addListener(() => setState(() {}));
    _position = widget.initialPosition;
    _month = widget.initialBirthDate?.month;
    _year = widget.initialBirthDate?.year;
    _loadPositions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    final rows = await SupaFlow.client
        .from('player_positions_list')
        .select('position_name')
        .order('id');
    if (!mounted) return;
    setState(() {
      _positions = (rows as List)
          .map((r) => r['position_name'] as String)
          .toList();
      // Ensure the currently-set position is present in the options even if
      // it's been deprecated from the catalog.
      if (_position != null && !_positions.contains(_position)) {
        _positions = [_position!, ..._positions];
      }
    });
  }

  Future<void> _pick<T>({
    required String title,
    required List<T> options,
    required String Function(T) labelOf,
    required T? current,
    required ValueChanged<T> onPicked,
  }) async {
    final picked = await presentPickerSheet<T>(
      context,
      title: title,
      options: options,
      labelOf: labelOf,
      current: current,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final birthDate =
        '$_year-${_month!.toString().padLeft(2, '0')}-01';

    try {
      await SupaFlow.client.from('players').update({
        'first_name': _nameController.text.trim(),
        'player_position': _position!,
        'birth_date': birthDate,
      }).eq('id', widget.playerId);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 48 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 34,
              height: 6,
              decoration: BoxDecoration(
                color: _handleColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Player',
                style: TextStyle(
                  fontFamily: _fontMontserrat,
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
                    fontFamily: _fontMontserrat,
                    fontSize: 24,
                    color: _labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _Label('NAME'),
          const SizedBox(height: 6),
          _FieldCard(
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontFamily: _fontIBMPlexSans,
                fontSize: 16,
                color: _labelColor,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter player name...',
                hintStyle: TextStyle(
                  fontFamily: _fontIBMPlexSans,
                  fontSize: 16,
                  color: _hintColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const _Label('PLAYER POSITION'),
          const SizedBox(height: 6),
          PickerField<String>(
            value: _position,
            placeholder: 'Select position',
            displayOf: (v) => v,
            onTap: () => _pick<String>(
              title: 'Select position',
              options: _positions,
              labelOf: (v) => v,
              current: _position,
              onPicked: (v) => setState(() => _position = v),
            ),
          ),
          const SizedBox(height: 16),

          const _Label('BIRTH MONTH & YEAR'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 62,
                child: PickerField<int>(
                  value: _month,
                  placeholder: 'Month',
                  displayOf: (m) => _months[m - 1],
                  onTap: () => _pick<int>(
                    title: 'Select month',
                    options: List.generate(12, (i) => i + 1),
                    labelOf: (m) => _months[m - 1],
                    current: _month,
                    onPicked: (v) => setState(() => _month = v),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 38,
                child: PickerField<int>(
                  value: _year,
                  placeholder: 'Year',
                  displayOf: (y) => '$y',
                  onTap: () => _pick<int>(
                    title: 'Select year',
                    options: _years,
                    labelOf: (y) => '$y',
                    current: _year,
                    onPicked: (v) => setState(() => _year = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Text(
            'Used to give your player age-appropriate ratings.',
            style: TextStyle(
              fontFamily: _fontIBMPlexSans,
              fontSize: 13,
              color: _hintColor,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? _saveEnabled : _saveDisabled,
                disabledBackgroundColor: _saveDisabled,
                foregroundColor: Colors.white,
                disabledForegroundColor: _hintColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: _fontIBMPlexSans,
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
        fontFamily: _fontIBMPlexSans,
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

