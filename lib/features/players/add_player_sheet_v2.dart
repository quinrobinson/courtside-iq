// Add Player Sheet — Phase 4.11d
//
// Measured from 302:1402: four fields, a caption, and a lime "Add player".
//
// TWO PRODUCT CHANGES from v1, both from the frame rather than from me:
//
//   LAST NAME is new, and optional. v1 collected a first name only, so a
//   parent with two children sharing a first initial had no way to tell the
//   avatars apart.
//
//   BIRTH DATE is now OPTIONAL. v1 refused to save without a month and year.
//   That was already inconsistent with the rest of the app: the birth-date
//   prompt and the "birth date missing" caveat both exist precisely because
//   players CAN lack one, and Growth IQ has always had a locked state for it.
//
// FIVE BEHAVIOURS ARE CARRIED FROM v1, none of them visible in any frame and
// every one of them the result of something that went wrong on a device:
//
//   1. positions load with the failure SURFACED - an empty picker is
//      indistinguishable from one that never opened
//   2. the insert is guarded - the server's RLS policy can legitimately
//      refuse it, and unguarded that refusal spun the button forever
//   3. a refusal says what the PARENT can do, not what the database called it
//   4. the error renders INLINE - a SnackBar from inside a modal sheet draws
//      behind the sheet, so the parent sees nothing at all
//   5. birth_date is stored YYYY-MM-01 - the app asks for month and year, and
//      1 is the honest placeholder for a day it never asked about

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'birth_date_sheet.dart';
import 'present_picker.dart';

/// Opens the sheet. [onPlayerAdded] fires only on a successful insert.
Future<void> showAddPlayerSheetV2(
  BuildContext context, {
  VoidCallback? onPlayerAdded,
}) {
  return showCiSheet<void>(
    context,
    child: AddPlayerSheetV2(onPlayerAdded: onPlayerAdded),
  );
}

class AddPlayerSheetV2 extends StatefulWidget {
  const AddPlayerSheetV2({super.key, this.onPlayerAdded});

  final VoidCallback? onPlayerAdded;

  @override
  State<AddPlayerSheetV2> createState() => _AddPlayerSheetV2State();
}

class _AddPlayerSheetV2State extends State<AddPlayerSheetV2> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  List<String> _positions = const [];
  String? _position;
  DateTime? _birthDate;

  bool _saving = false;

  /// Shown INLINE, above the button. See note 4 in the header.
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstName.addListener(() => setState(() {}));
    _loadPositions();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    try {
      final rows = await SupaFlow.client
          .from('player_positions_list')
          .select('position_name')
          .order('id') as List;
      if (!mounted) return;
      setState(() {
        _positions =
            rows.map((r) => r['position_name'] as String).toList();
      });
    } catch (_) {
      if (!mounted) return;
      // Surfaced where the parent is looking, for the same reason the save
      // error is. Silence here presents as a picker that does nothing.
      setState(() => _error = 'Could not load positions. Check your '
          'connection and try again.');
    }
  }

  /// First name and position. Birth date is optional per the frame; a last
  /// name always was.
  bool get _canSave =>
      _firstName.text.trim().isNotEmpty && _position != null && !_saving;

  Future<void> _pickPosition() async {
    final picked = await presentCiPicker<String>(
      context,
      title: 'Position',
      options: _positions,
      labelOf: (p) => p,
      current: _position,
    );
    if (picked != null && mounted) setState(() => _position = picked);
  }

  Future<void> _pickBirthDate() async {
    final picked = await presentBirthDateSheet(context, current: _birthDate);
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _saving = false;
        _error = 'You are signed out. Sign in and try again.';
      });
      return;
    }

    final last = _lastName.text.trim();

    try {
      await SupaFlow.client.from('players').insert({
        'first_name': _firstName.text.trim(),
        if (last.isNotEmpty) 'last_name': last,
        'player_position': _position,
        'user_id': userId,
        if (_birthDate != null) 'birth_date': _formatBirthDate(_birthDate!),
      });
    } catch (e) {
      if (!mounted) return;
      final refused = e.toString().contains('row-level security');
      setState(() {
        _saving = false;
        _error = refused
            ? 'Your plan does not allow another player right now.'
            : 'Could not add player. Please try again.';
      });
      return;
    }

    widget.onPlayerAdded?.call();
    if (mounted) Navigator.of(context).pop();
  }

  /// YYYY-MM-01. The app collects a month and a year; day 1 stands in for the
  /// day it never asked about.
  static String _formatBirthDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-01';

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return CiSheet(
      title: 'Add player',
      cta: 'Add player',
      ctaBusy: _saving,
      onCta: _canSave ? _save : null,
      child: SingleChildScrollView(
        // The keyboard is up while the name is typed, so the form has to
        // scroll clear of it rather than be pushed off the top.
        padding: EdgeInsets.fromLTRB(
          CiSpace.screen,
          CiSpace.s5,
          CiSpace.screen,
          MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CiField(
              label: 'First name',
              controller: _firstName,
              placeholder: 'Maya',
            ),
            const SizedBox(height: CiSpace.s5),
            CiField(
              // The OPTIONAL is part of the label, not a hint below it: a
              // parent should know a field can be skipped before they start
              // wondering what to put in it.
              label: 'Last name  ·  Optional',
              controller: _lastName,
              placeholder: 'Chen',
            ),
            const SizedBox(height: CiSpace.s5),
            CiPickerField(
              label: 'Position',
              placeholder: 'Select position',
              value: _position,
              onTap: _pickPosition,
            ),
            const SizedBox(height: CiSpace.s5),
            CiPickerField(
              label: 'Birth date  ·  Optional',
              placeholder: 'Select birth date',
              value: _birthDate == null ? null : _monthYear(_birthDate!),
              onTap: _pickBirthDate,
            ),
            // s2, not s6. At 24 the line floated free of the field and read
            // as its own paragraph; helper text has to sit under the input it
            // explains to belong to it.
            const SizedBox(height: CiSpace.s2),
            Text(
              'We use this to compare your player to others their age.',
              style: CiType.caption.copyWith(color: c.textMuted),
            ),
            if (_error != null) ...[
              const SizedBox(height: CiSpace.s4),
              Text(_error!,
                  style: CiType.bodySm.copyWith(color: c.accentEnergy)),
            ],
          ],
        ),
      ),
    );
  }

  static const _months = [
    'January', 'February', 'March', 'April', //
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  static String _monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';
}
