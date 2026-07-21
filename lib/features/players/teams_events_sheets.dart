// Teams and Events sheets — Phase 4.11d
//
// Designed 2026-07-21 and approved. Four surfaces, two of them near-identical
// on purpose:
//
//   Teams / Events  the list, each row removable, an add row at the bottom
//   Add team        a name
//   Add event       a name and a type
//
// EACH LIST SAYS WHAT REMOVING DOES. "Past games keep the team they were
// logged with" is the whole reason there is no rename here, and a parent
// tidying a list deserves to know it is not touching their history.
//
// No confirmation on remove: nothing is lost, and a dialog for an action with
// no consequence is friction that teaches parents to dismiss dialogs.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/event_types.dart';
import 'teams_events_repository.dart';

/// Opens the teams list. Returns true if anything changed, so the caller can
/// refresh its count without refetching on every dismissal.
Future<bool> presentTeamsSheet(
  BuildContext context, {
  required String playerId,
  TeamsEventsRepository repository = const TeamsEventsRepository(),
}) async {
  final changed = await showCiSheet<bool>(
    context,
    child: _TeamsSheet(playerId: playerId, repository: repository),
  );
  return changed ?? false;
}

Future<bool> presentEventsSheet(
  BuildContext context, {
  required String playerId,
  TeamsEventsRepository repository = const TeamsEventsRepository(),
}) async {
  final changed = await showCiSheet<bool>(
    context,
    child: _EventsSheet(playerId: playerId, repository: repository),
  );
  return changed ?? false;
}

// --- Teams -------------------------------------------------------------------

class _TeamsSheet extends StatefulWidget {
  const _TeamsSheet({required this.playerId, required this.repository});

  final String playerId;
  final TeamsEventsRepository repository;

  @override
  State<_TeamsSheet> createState() => _TeamsSheetState();
}

class _TeamsSheetState extends State<_TeamsSheet> {
  List<PlayerTeam>? _teams;
  bool _changed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final teams = await widget.repository.loadTeams(widget.playerId);
      if (mounted) setState(() => _teams = teams);
    } catch (_) {
      if (mounted) {
        setState(() {
          _teams = const [];
          _error = 'Could not load teams. Check your connection.';
        });
      }
    }
  }

  Future<void> _add() async {
    final name = await _presentNameSheet(
      context,
      title: 'Add team',
      label: 'Team name',
      placeholder: 'Northside Hawks',
      cta: 'Add team',
    );
    if (name == null || !mounted) return;
    try {
      await widget.repository.addTeam(widget.playerId, name);
      _changed = true;
      await _load();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not add that team.');
    }
  }

  Future<void> _remove(PlayerTeam team) async {
    try {
      await widget.repository.removeTeam(team.id);
      _changed = true;
      await _load();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not remove that team.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ListSheetShell(
      title: 'Teams',
      caption: 'Teams you can pick when logging a game. Past games keep the '
          'team they were logged with.',
      error: _error,
      loading: _teams == null,
      addLabel: 'Add team',
      onAdd: _add,
      onClose: () => Navigator.of(context).pop(_changed),
      rows: [
        for (final t in _teams ?? const <PlayerTeam>[])
          _ManagedRow(title: t.name, onRemove: () => _remove(t)),
      ],
    );
  }
}

// --- Events ------------------------------------------------------------------

class _EventsSheet extends StatefulWidget {
  const _EventsSheet({required this.playerId, required this.repository});

  final String playerId;
  final TeamsEventsRepository repository;

  @override
  State<_EventsSheet> createState() => _EventsSheetState();
}

class _EventsSheetState extends State<_EventsSheet> {
  List<PlayerEvent>? _events;
  bool _changed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final events = await widget.repository.loadEvents(widget.playerId);
      if (mounted) setState(() => _events = events);
    } catch (_) {
      if (mounted) {
        setState(() {
          _events = const [];
          _error = 'Could not load events. Check your connection.';
        });
      }
    }
  }

  Future<void> _add() async {
    final result = await showCiSheet<_NewEvent>(
      context,
      child: const _AddEventSheet(),
    );
    if (result == null || !mounted) return;
    try {
      await widget.repository
          .addEvent(widget.playerId, result.name, result.type);
      _changed = true;
      await _load();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not add that event.');
    }
  }

  Future<void> _remove(PlayerEvent event) async {
    try {
      await widget.repository.removeEvent(event.id);
      _changed = true;
      await _load();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not remove that event.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ListSheetShell(
      title: 'Events',
      caption: 'Tournaments and leagues you can pick when logging a game. '
          'Past games keep the event they were logged with.',
      error: _error,
      loading: _events == null,
      addLabel: 'Add event',
      onAdd: _add,
      onClose: () => Navigator.of(context).pop(_changed),
      rows: [
        for (final e in _events ?? const <PlayerEvent>[])
          _ManagedRow(
            title: e.name,
            // The LABEL, never the stored value. See event_types.dart.
            subtitle: e.type?.label,
            onRemove: () => _remove(e),
          ),
      ],
    );
  }
}

// --- Shared pieces -----------------------------------------------------------

class _ListSheetShell extends StatelessWidget {
  const _ListSheetShell({
    required this.title,
    required this.caption,
    required this.rows,
    required this.addLabel,
    required this.onAdd,
    required this.onClose,
    required this.loading,
    this.error,
  });

  final String title;
  final String caption;
  final List<Widget> rows;
  final String addLabel;
  final VoidCallback onAdd;
  final VoidCallback onClose;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return CiSheet(
      title: title,
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s3, CiSpace.screen, CiSpace.s5),
            child: Text(caption,
                style: CiType.bodySm.copyWith(color: c.textMuted, height: 1.4)),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  CiSpace.screen, 0, CiSpace.screen, CiSpace.s4),
              child: Text(error!,
                  style: CiType.bodySm.copyWith(color: c.accentEnergy)),
            ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CiSpace.s7),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4),
              child: ListView(shrinkWrap: true, children: rows),
            ),
            CiSheetOptionRow(
              label: '+   $addLabel',
              showDivider: false,
              onTap: onAdd,
            ),
          ],
        ],
      ),
    );
  }
}

/// A list row with a remove action.
///
/// "Remove" as a word rather than an X: an unlabelled glyph beside a team name
/// could just as easily mean edit or close, and this one deletes a row.
class _ManagedRow extends StatelessWidget {
  const _ManagedRow({required this.title, required this.onRemove, this.subtitle});

  final String title;
  final String? subtitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: CiType.body.copyWith(
                              color: c.text, fontWeight: CiWeight.medium),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (subtitle != null)
                        Text(subtitle!,
                            style:
                                CiType.caption.copyWith(color: c.textMuted)),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Remove $title',
                  // container + exclude, or the inner "Remove" merges over the
                  // label and a screen reader announces a row of identical
                  // "Remove" buttons with nothing to tell them apart.
                  container: true,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onRemove,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: CiSpace.s2, vertical: CiSpace.s3),
                      child: Text('Remove',
                          style: CiType.rowLabel
                              .copyWith(color: c.accentEnergy)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
          child: Container(height: CiSpace.hairline, color: c.hairline),
        ),
      ],
    );
  }
}

/// A one-field sheet. Used for Add team.
Future<String?> _presentNameSheet(
  BuildContext context, {
  required String title,
  required String label,
  required String placeholder,
  required String cta,
}) {
  return showCiSheet<String>(
    context,
    child: _NameSheet(
        title: title, label: label, placeholder: placeholder, cta: cta),
  );
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({
    required this.title,
    required this.label,
    required this.placeholder,
    required this.cta,
  });

  final String title;
  final String label;
  final String placeholder;
  final String cta;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _controller.text.trim().isNotEmpty;
    return CiSheet(
      title: widget.title,
      cta: widget.cta,
      onCta: valid
          ? () => Navigator.of(context).pop(_controller.text.trim())
          : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CiSpace.screen,
          CiSpace.s5,
          CiSpace.screen,
          MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CiField(
          label: widget.label,
          controller: _controller,
          placeholder: widget.placeholder,
        ),
      ),
    );
  }
}

class _NewEvent {
  final String name;
  final EventType type;
  const _NewEvent(this.name, this.type);
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet();

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _controller = TextEditingController();

  /// Defaults to Tournament: short events outnumber seasons in the data, and
  /// a default that is usually right beats no default at all.
  EventType _type = EventType.tournament;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final valid = _controller.text.trim().isNotEmpty;

    return CiSheet(
      title: 'Add event',
      cta: 'Add event',
      onCta: valid
          ? () => Navigator.of(context)
              .pop(_NewEvent(_controller.text.trim(), _type))
          : null,
      child: Padding(
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
              label: 'Event name',
              controller: _controller,
              placeholder: 'Spring Classic',
            ),
            const SizedBox(height: CiSpace.s5),
            Text('TYPE', style: CiType.caption.copyWith(color: c.textMuted)),
            const SizedBox(height: CiSpace.s2),
            // Two options, so both stay visible. A dropdown to choose between
            // two hides half the answer behind a tap.
            Row(
              children: [
                for (final t in EventType.values) ...[
                  if (t != EventType.values.first)
                    const SizedBox(width: CiSpace.s2),
                  Expanded(
                    child: _TypeChip(
                      label: t.label,
                      selected: _type == t,
                      onTap: () => setState(() => _type = t),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: CiRadius.chipR,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.surfaceInvert : c.surface,
            borderRadius: CiRadius.chipR,
            border: selected ? null : Border.all(color: c.border),
          ),
          child: Text(
            label,
            style: CiType.rowTitle.copyWith(
              color: selected ? c.textInvert : c.text,
              fontWeight: CiWeight.medium,
            ),
          ),
        ),
      ),
    );
  }
}
