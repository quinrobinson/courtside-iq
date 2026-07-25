// Edit Player — Phase 4.11d
//
// Measured from 387:1901: light ground, a centred title over a hairline, an
// 88 avatar with a camera badge, the same four fields as Add Player, then
// "Save changes" and a plain orange "Delete player".
//
// TEAMS AND EVENTS are two rows that open sheets, rather than v1's inline
// accordions. They are the pick-lists behind logging a game, not the subject
// of this screen, and keeping them behind a row is what stops identity being
// buried. Designed and approved 2026-07-21.
//
// DELETE IS ONE STATEMENT, and that is a deliberate change. v1 deleted
// player_game_stats and players CONCURRENTLY with Future.wait, which is a
// race: if the player row went first and the stats delete failed, the stats
// were orphaned against a player that no longer existed. Every child table
// (games, player_game_stats, player_teams, player_development_insights,
// player_trend_snapshots) is ON DELETE CASCADE - verified against the test
// schema - so deleting the player row does all of it atomically.

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_toast.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'birth_date_sheet.dart';
import 'delete_player_dialog.dart';
import 'present_picker.dart';
import 'profile_photo_sheet.dart';
import 'teams_events_repository.dart';
import 'teams_events_sheets.dart';

class EditPlayerPage extends StatefulWidget {
  const EditPlayerPage({
    super.key,
    required this.playerId,
    this.onSaved,
    this.onDeleted,
    this.teamsEvents = const TeamsEventsRepository(),
  });

  final String playerId;
  final TeamsEventsRepository teamsEvents;

  /// Fired after a successful update, so the screen behind can refetch. The
  /// same rule the create sheet needed: a save nothing reflects reads as a
  /// save that failed.
  final VoidCallback? onSaved;

  final VoidCallback? onDeleted;

  @override
  State<EditPlayerPage> createState() => _EditPlayerPageState();
}

class _EditPlayerPageState extends State<EditPlayerPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  List<String> _positions = const [];
  String? _position;
  DateTime? _birthDate;
  String? _photoUrl;

  /// Counts only. The rows show them; the sheets own the lists.
  int? _teamCount;
  int? _eventCount;

  bool _loading = true;
  bool _saving = false;

  /// Separate from [_saving]: an upload runs while the form stays usable, and
  /// blocking Save behind it would be wrong. The well shows its own spinner.
  bool _uploading = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _firstName.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      // CONCURRENT. These four are independent, and run one after another
      // they stacked four round trips behind a bare spinner - which on a slow
      // connection reads as a screen that failed to open.
      final playerFuture = SupaFlow.client
          .from('players')
          .select('first_name, last_name, player_position, birth_date, '
              'player_profile_pic')
          .eq('id', widget.playerId)
          .maybeSingle();
      final positionsFuture = SupaFlow.client
          .from('player_positions_list')
          .select('position_name')
          .order('id');
      final teamsFuture = widget.teamsEvents.loadTeams(widget.playerId);
      final eventsFuture = widget.teamsEvents.loadEvents(widget.playerId);

      final player = await playerFuture;
      final positions = await positionsFuture as List;
      final teams = await teamsFuture;
      final events = await eventsFuture;

      if (!mounted) return;
      setState(() {
        _firstName.text = player?['first_name'] as String? ?? '';
        _lastName.text = player?['last_name'] as String? ?? '';
        _position = player?['player_position'] as String?;
        _birthDate = DateTime.tryParse(
            player?['birth_date']?.toString() ?? '');
        _photoUrl = player?['player_profile_pic'] as String?;
        _positions =
            positions.map((r) => r['position_name'] as String).toList();
        _teamCount = teams.length;
        _eventCount = events.length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this player. Check your connection.';
      });
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

  Future<void> _changePhoto() async {
    final action = await presentProfilePhotoSheet(
      context,
      // Nothing to remove when there is no photo.
      canRemove: _photoUrl != null && _photoUrl!.isNotEmpty,
    );
    if (action == null || !mounted) return;

    if (action == PhotoAction.remove) {
      await _writePhotoUrl(null);
      return;
    }

    final files = await pickPlayerPhoto(action);
    // Null means the parent backed out of the system picker, which is not an
    // error and must not surface as one.
    if (files == null || files.isEmpty || !mounted) return;

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      final urls = await uploadSupabaseStorageFiles(
        bucketName: 'playerprofiles',
        selectedFiles: files,
      );
      if (urls.isEmpty) throw StateError('upload returned no url');
      await _writePhotoUrl(urls.first);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = 'Could not upload that photo. Please try again.';
      });
      return;
    }
    if (mounted) setState(() => _uploading = false);
  }

  /// Writes the photo straight to the row rather than waiting for Save.
  ///
  /// The photo is chosen in a sheet and applied immediately, so a parent who
  /// picks one and then backs out of the screen keeps it. Making it depend on
  /// Save would silently discard a photo they watched upload.
  Future<void> _writePhotoUrl(String? url) async {
    try {
      await SupaFlow.client
          .from('players')
          .update({'player_profile_pic': url}).eq('id', widget.playerId);
      if (!mounted) return;
      setState(() => _photoUrl = url);
      widget.onSaved?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not update the photo. Please try again.');
    }
  }

  /// Only the counts. Reloading the whole form would throw away anything the
  /// parent had typed and not yet saved.
  Future<void> _reloadCounts() async {
    try {
      final teams = await widget.teamsEvents.loadTeams(widget.playerId);
      final events = await widget.teamsEvents.loadEvents(widget.playerId);
      if (!mounted) return;
      setState(() {
        _teamCount = teams.length;
        _eventCount = events.length;
      });
    } catch (_) {
      // The sheet already reported anything that failed inside it.
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final last = _lastName.text.trim();

    try {
      await SupaFlow.client.from('players').update({
        'first_name': _firstName.text.trim(),
        // Written even when empty, unlike the insert: clearing a last name is
        // a thing a parent may deliberately do, and omitting the key would
        // silently keep the old one.
        'last_name': last.isEmpty ? null : last,
        'player_position': _position,
        if (_birthDate != null) 'birth_date': _formatBirthDate(_birthDate!),
      }).eq('id', widget.playerId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save changes. Please try again.';
      });
      return;
    }

    widget.onSaved?.call();
    if (!mounted) return;
    // Confirm the save, like the account edit screens do. Shown before the pop
    // so it attaches to the root messenger and floats over the profile the
    // parent lands back on - editing a player was the one save with no receipt.
    showCiToast(context, 'Player updated.', type: CiToastType.success);
    Navigator.of(context).maybePop();
  }

  Future<void> _delete() async {
    final name = _firstName.text.trim();
    final confirmed = await showDeletePlayerDialog(context, firstName: name);
    if (!confirmed || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      // ONE STATEMENT. Every child table cascades; see the header.
      await SupaFlow.client
          .from('players')
          .delete()
          .eq('id', widget.playerId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not delete this player. Please try again.';
      });
      return;
    }

    widget.onDeleted?.call();
    if (mounted) Navigator.of(context).maybePop();
  }

  static String _formatBirthDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-01';

  static const _months = [
    'January', 'February', 'March', 'April', //
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  static String _monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(
              children: [
                _Header(),
                if (_loading)
                  const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                else
                  Expanded(child: _form(c)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _form(CiColors c) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s7, CiSpace.screen, CiSpace.s8),
      children: [
        Center(
          child: _PhotoWell(
            name: _firstName.text,
            imageUrl: _photoUrl,
            busy: _uploading,
            onTap: _uploading ? null : _changePhoto,
          ),
        ),
        const SizedBox(height: CiSpace.s6),
        CiField(
          label: 'First name',
          controller: _firstName,
          placeholder: 'Maya',
        ),
        const SizedBox(height: 22),
        CiField(
          label: 'Last name  ·  Optional',
          controller: _lastName,
          placeholder: 'Chen',
        ),
        const SizedBox(height: 22),
        CiPickerField(
          label: 'Position',
          placeholder: 'Select position',
          value: _position,
          onTap: _pickPosition,
        ),
        const SizedBox(height: 22),
        CiPickerField(
          label: 'Birth date  ·  Optional',
          placeholder: 'Select birth date',
          value: _birthDate == null ? null : _monthYear(_birthDate!),
          onTap: _pickBirthDate,
        ),
        const SizedBox(height: CiSpace.s6),
        Text(
          'We use this to compare your player to others their age.',
          style: CiType.bodySm.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: CiSpace.s6),
        const CiHairline(),
        _ListRow(
          label: 'Teams',
          count: _teamCount,
          noun: 'team',
          onTap: () async {
            final changed = await presentTeamsSheet(context,
                playerId: widget.playerId, repository: widget.teamsEvents);
            if (changed && mounted) _reloadCounts();
          },
        ),
        _ListRow(
          label: 'Events',
          count: _eventCount,
          noun: 'event',
          onTap: () async {
            final changed = await presentEventsSheet(context,
                playerId: widget.playerId, repository: widget.teamsEvents);
            if (changed && mounted) _reloadCounts();
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: CiSpace.s4),
          Text(_error!, style: CiType.bodySm.copyWith(color: c.accentEnergy)),
        ],
        const SizedBox(height: CiSpace.s7),
        CiButton(
          label: 'Save changes',
          style: CiButtonStyle.lime,
          expand: true,
          busy: _saving,
          onPressed: _canSave ? _save : null,
        ),
        const SizedBox(height: CiSpace.s8),
        Center(
          child: Semantics(
            button: true,
            child: InkWell(
              onTap: _saving ? null : _delete,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: CiSpace.s3),
                child: Text(
                  'Delete player',
                  // Orange and unchromed, per the frame. A destructive action
                  // should be findable, not prominent: giving it a filled
                  // button would put it in the same visual class as Save.
                  style: CiType.h4.copyWith(color: c.accentEnergy),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: Stack(
            children: [
              Center(
                child: Text('Edit Player',
                    style: CiType.h4.copyWith(color: c.text)),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: CiSpace.s3),
                  child: CiIconButton(
                    icon: Icons.chevron_left,
                    semanticLabel: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const CiHairline(),
      ],
    );
  }
}

/// The 88 avatar with its camera badge.
class _PhotoWell extends StatelessWidget {
  const _PhotoWell({
    required this.name,
    this.imageUrl,
    this.onTap,
    this.busy = false,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: onTap != null,
      label: 'Change photo',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CiAvatar(name: name, imageUrl: imageUrl, size: 88),
              if (busy)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              Positioned(
                right: -2,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c.surfaceInvert,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.bg, width: 2),
                  ),
                  child: Icon(Icons.photo_camera_outlined,
                      size: 16, color: c.textInvert),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row that opens a list sheet, with the count it holds.
///
/// The hairlines here are FULL BLEED. Inset rules are the in-sheet
/// convention; on a screen they run edge to edge.
class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.label,
    required this.count,
    required this.noun,
    required this.onTap,
  });

  final String label;

  /// Null while loading, so the row shows its name without claiming a number
  /// it does not have yet.
  final int? count;

  final String noun;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final n = count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  Expanded(
                    child: Text(label,
                        style: CiType.h4.copyWith(color: c.text)),
                  ),
                  if (n != null)
                    Text(
                      n == 0 ? 'None yet' : '$n ${n == 1 ? noun : '${noun}s'}',
                      style: CiType.bodySm.copyWith(color: c.textMuted),
                    ),
                  const SizedBox(width: CiSpace.s2),
                  Icon(Icons.chevron_right, size: 18, color: c.textMuted),
                ],
              ),
            ),
          ),
        ),
        const CiHairline(),
      ],
    );
  }
}
