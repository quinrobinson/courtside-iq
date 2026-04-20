import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';

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

Future<void> showSetBirthDateSheet(
  BuildContext context, {
  required String playerId,
  required String playerFirstName,
  VoidCallback? onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SetBirthDateSheet(
      playerId: playerId,
      playerFirstName: playerFirstName,
      onSaved: onSaved,
    ),
  );
}

class SetBirthDateSheet extends StatefulWidget {
  const SetBirthDateSheet({
    super.key,
    required this.playerId,
    required this.playerFirstName,
    this.onSaved,
  });

  final String playerId;
  final String playerFirstName;
  final VoidCallback? onSaved;

  @override
  State<SetBirthDateSheet> createState() => _SetBirthDateSheetState();
}

class _SetBirthDateSheetState extends State<SetBirthDateSheet> {
  int? _month;
  int? _year;
  bool _saving = false;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(17, (i) => now - 3 - i);
  }

  bool get _canSave => _month != null && _year != null;

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final birthDate = '$_year-${_month!.toString().padLeft(2, '0')}-01';

    try {
      await SupaFlow.client
          .from('players')
          .update({'birth_date': birthDate})
          .eq('id', widget.playerId)
          .timeout(const Duration(seconds: 10));

      widget.onSaved?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
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
              width: 34, height: 6,
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
                'Set birth year',
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
          const SizedBox(height: 8),
          Text(
            "Add ${widget.playerFirstName}'s birth month and year so Courtside IQ can give age-appropriate ratings.",
            style: const TextStyle(
              fontFamily: _fontIBMPlexSans,
              fontSize: 14,
              color: _hintColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'BIRTH MONTH & YEAR',
            style: TextStyle(
              fontFamily: _fontIBMPlexSans,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
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
                        child: Icon(Icons.keyboard_arrow_down, color: _hintColor),
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
                        child: Icon(Icons.keyboard_arrow_down, color: _hintColor),
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
