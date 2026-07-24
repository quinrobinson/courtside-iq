// Guided First-Run — Phase 4.9
//
// Built from Guided First-Run (Step 1 · Welcome) 321:1451 and (Step 2 · First
// Player) 323:1462. A two-step welcome shown ONCE, right after a new parent
// confirms their email:
//
//   Step 1 · Welcome    optional first name, so insights can address the parent
//   Step 2 · First Player   the same four fields as the Add Player sheet
//
// SKIPPABLE. "Skip for now" on step 1 lands them straight on Today (which has
// its own "add your first player" empty state), because onboarding is a welcome,
// not a gate. Adding a player on step 2 finishes the same way.
//
// The gate that decides WHEN this shows (first login, zero players, not seen
// before) lives at the auth-landing seam, not here - this widget only runs the
// flow and calls [onFinished] when it is done, whichever way it ends.
//
// Step 2 mirrors AddPlayerSheetV2's fields and insert deliberately. The save is
// kept here rather than shared for now; if a third caller appears, lift the
// four-field form and the insert into one place (noted, not done).

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/features/players/birth_date_sheet.dart';
import '/features/players/present_picker.dart';

class FirstRunFlow extends StatefulWidget {
  const FirstRunFlow({super.key, this.onFinished});

  /// Called once the flow ends, whether the parent skipped on step 1 or added
  /// a player on step 2. The caller marks first-run seen and routes to Today.
  final VoidCallback? onFinished;

  @override
  State<FirstRunFlow> createState() => _FirstRunFlowState();
}

class _FirstRunFlowState extends State<FirstRunFlow> {
  int _step = 0;
  final _firstName = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    super.dispose();
  }

  String get _parentName => _firstName.text.trim();

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          return Scaffold(
            backgroundColor: c.bg,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CiSpace.screen,
                      CiSpace.s4,
                      CiSpace.screen,
                      CiSpace.s2,
                    ),
                    child: _StepProgress(step: _step, total: 2),
                  ),
                  Expanded(
                    child: _step == 0
                        ? _WelcomeStep(
                            firstName: _firstName,
                            onContinue: () => setState(() => _step = 1),
                            onSkip: () => widget.onFinished?.call(),
                          )
                        : _FirstPlayerStep(
                            parentName: _parentName,
                            onAdded: () => widget.onFinished?.call(),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The two-segment bar at the top. A segment is filled once its step is reached.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: CiSpace.s2),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? c.text : c.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.firstName,
    required this.onContinue,
    required this.onSkip,
  });

  final TextEditingController firstName;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
      child: Column(
        children: [
          const Spacer(flex: 2),
          DotBurst(
            size: 200,
            markSize: 50,
            child: CiLogoMark(size: 50, color: c.text),
          ),
          const SizedBox(height: CiSpace.s7),
          Text(
            "Let's get set up",
            textAlign: TextAlign.center,
            style: CiType.h1.copyWith(color: c.text),
          ),
          const SizedBox(height: CiSpace.s3),
          Text(
            'Tell us your name so insights stay personal to your player.',
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: CiSpace.s7),
          CiField(
            label: 'Your name  ·  Optional',
            controller: firstName,
            placeholder: 'First name',
          ),
          const Spacer(flex: 3),
          CiButton(
            label: 'Continue',
            style: CiButtonStyle.lime,
            expand: true,
            onPressed: onContinue,
          ),
          const SizedBox(height: CiSpace.s2),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
              style: CiType.body.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(height: CiSpace.s4),
        ],
      ),
    );
  }
}

class _FirstPlayerStep extends StatefulWidget {
  const _FirstPlayerStep({
    required this.parentName,
    required this.onAdded,
  });

  final String parentName;
  final VoidCallback onAdded;

  @override
  State<_FirstPlayerStep> createState() => _FirstPlayerStepState();
}

class _FirstPlayerStepState extends State<_FirstPlayerStep> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  List<String> _positions = const [];
  String? _position;
  DateTime? _birthDate;

  bool _saving = false;
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
      final rows =
          await SupaFlow.client
                  .from('player_positions_list')
                  .select('position_name')
                  .order('id')
              as List;
      if (!mounted) return;
      setState(() {
        _positions = rows.map((r) => r['position_name'] as String).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'Could not load positions. Check your '
            'connection and try again.',
      );
    }
  }

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

    widget.onAdded();
  }

  static String _formatBirthDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-01';

  /// "Nice to meet you, Marcus." when a name was given, "Nice to meet you."
  /// when it was skipped - never a dangling comma.
  String get _greeting {
    final name = widget.parentName;
    final hello = name.isEmpty
        ? 'Nice to meet you.'
        : 'Nice to meet you, $name.';
    return '$hello Now add the player you\'ll be following.';
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              CiSpace.screen,
              CiSpace.s4,
              CiSpace.screen,
              CiSpace.s4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add your first player',
                  style: CiType.h1.copyWith(color: c.text),
                ),
                const SizedBox(height: CiSpace.s3),
                Text(
                  _greeting,
                  style: CiType.body.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: CiSpace.s6),
                CiField(
                  label: 'First name',
                  controller: _firstName,
                  placeholder: 'Maya',
                ),
                const SizedBox(height: CiSpace.s5),
                CiField(
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
                const SizedBox(height: CiSpace.s2),
                Text(
                  'We use this to compare your player to others their age.',
                  style: CiType.caption.copyWith(color: c.textMuted),
                ),
                if (_error != null) ...[
                  const SizedBox(height: CiSpace.s4),
                  Text(
                    _error!,
                    style: CiType.bodySm.copyWith(color: c.accentEnergy),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CiSpace.screen,
            0,
            CiSpace.screen,
            CiSpace.s4,
          ),
          child: CiButton(
            label: 'Add player',
            style: CiButtonStyle.lime,
            expand: true,
            busy: _saving,
            onPressed: _canSave ? _save : null,
          ),
        ),
      ],
    );
  }

  static const _months = [
    'January', 'February', 'March', 'April', //
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  static String _monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';
}
