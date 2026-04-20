import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';

// Light mode design tokens
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

Future<void> showAddPlayerSheet(
  BuildContext context, {
  VoidCallback? onPlayerAdded,
}) {
  return showModalBottomSheet(
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
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) { setState(() => _saving = false); return; }

    final birthDate =
        '$_year-${_month!.toString().padLeft(2, '0')}-01';

    await SupaFlow.client.from('players').insert({
      'first_name':       _nameController.text.trim(),
      'player_position':  _position!,
      'user_id':          userId,
      'birth_date':       birthDate,
    });

    widget.onPlayerAdded?.call();
    if (mounted) Navigator.of(context).pop();
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
          // Drag handle
          Center(
            child: Container(
              width: 34, height: 6,
              decoration: BoxDecoration(
                color: _handleColor,
                borderRadius: BorderRadius.circular(3),
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

          // NAME
          _Label('NAME'),
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
                  horizontal: 16, vertical: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // PLAYER POSITION
          _Label('PLAYER POSITION'),
          const SizedBox(height: 6),
          _FieldCard(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _position,
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select position',
                    style: TextStyle(
                      fontFamily: _fontIBMPlexSans,
                      fontSize: 16,
                      color: _hintColor,
                    ),
                  ),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: _hintColor),
                ),
                style: const TextStyle(
                  fontFamily: _fontIBMPlexSans,
                  fontSize: 16,
                  color: _labelColor,
                ),
                items: _positions.map((p) => DropdownMenuItem(
                  value: p,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(p),
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _position = v),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // BIRTH MONTH & YEAR
          _Label('BIRTH MONTH & YEAR'),
          const SizedBox(height: 6),
          Row(
            children: [
              // Month (~62%)
              Expanded(
                flex: 62,
                child: _FieldCard(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _month,
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Month',
                          style: TextStyle(
                            fontFamily: _fontIBMPlexSans,
                            fontSize: 16,
                            color: _hintColor,
                          ),
                        ),
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.keyboard_arrow_down,
                            color: _hintColor),
                      ),
                      style: const TextStyle(
                        fontFamily: _fontIBMPlexSans,
                        fontSize: 16,
                        color: _labelColor,
                      ),
                      items: List.generate(12, (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(_months[i]),
                        ),
                      )),
                      onChanged: (v) => setState(() => _month = v),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Year (~38%)
              Expanded(
                flex: 38,
                child: _FieldCard(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _year,
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Year',
                          style: TextStyle(
                            fontFamily: _fontIBMPlexSans,
                            fontSize: 16,
                            color: _hintColor,
                          ),
                        ),
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.keyboard_arrow_down,
                            color: _hintColor),
                      ),
                      style: const TextStyle(
                        fontFamily: _fontIBMPlexSans,
                        fontSize: 16,
                        color: _labelColor,
                      ),
                      items: _years.map((y) => DropdownMenuItem(
                        value: y,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$y'),
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _year = v),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Helper text
          const Text(
            'Used to give your player age-appropriate ratings.',
            style: TextStyle(
              fontFamily: _fontIBMPlexSans,
              fontSize: 13,
              color: _hintColor,
            ),
          ),
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
                foregroundColor: Colors.white,
                disabledForegroundColor: _hintColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
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
