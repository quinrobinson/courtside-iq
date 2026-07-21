// Team and Event selection — Phase 4.13
//
// Measured from Team Selection (454:1932) and Event Selection (456:2010).
// Both pick one value while setting up a game, and both offer to add a new one
// inline - because a parent standing courtside about to tap Start Game should
// not have to leave for the profile to add the team their kid just joined.
//
// COMMITS ON TAP, no Save button. That is what those frames show, and it is
// right here: this is a picker inside a flow, not a settings screen. Edit
// Position keeps its Save because a mis-tap there changes stored data; a
// mis-tap here is undone by tapping again.
//
// Rendered with the CiSheet shell rather than the "✕" treatment in those two
// frames. They predate the shell - six sheets use it now - and one sheet
// vocabulary is worth more than matching two older drawings. THE FRAMES
// SHOULD BE UPDATED, not the code.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/features/players/teams_events_repository.dart';
import '/features/players/teams_events_sheets.dart';

/// Picks a team for the game. Returns the chosen name, or null.
Future<String?> presentTeamSelection(
  BuildContext context, {
  required String playerId,
  String? current,
  TeamsEventsRepository repository = const TeamsEventsRepository(),
}) {
  return showCiSheet<String>(
    context,
    child: _SelectionSheet(
      title: 'Select team',
      addLabel: 'Add a team',
      emptyLabel: 'No teams yet',
      current: current,
      load: () async {
        final teams = await repository.loadTeams(playerId);
        return [for (final t in teams) t.name];
      },
      add: (context) async {
        final name = await presentAddTeamSheet(context);
        if (name == null) return null;
        await repository.addTeam(playerId, name);
        return name;
      },
    ),
  );
}

/// Picks an event. Returns the chosen name, or null.
Future<String?> presentEventSelection(
  BuildContext context, {
  required String playerId,
  String? current,
  TeamsEventsRepository repository = const TeamsEventsRepository(),
}) {
  return showCiSheet<String>(
    context,
    child: _SelectionSheet(
      title: 'Select event',
      addLabel: 'New event',
      emptyLabel: 'No events yet',
      current: current,
      load: () async {
        final events = await repository.loadEvents(playerId);
        return [for (final e in events) e.name];
      },
      add: (context) async {
        final created = await presentAddEventSheet(context);
        if (created == null) return null;
        await repository.addEvent(playerId, created.name, created.type);
        return created.name;
      },
    ),
  );
}

class _SelectionSheet extends StatefulWidget {
  const _SelectionSheet({
    required this.title,
    required this.addLabel,
    required this.emptyLabel,
    required this.load,
    required this.add,
    this.current,
  });

  final String title;
  final String addLabel;
  final String emptyLabel;
  final String? current;

  final Future<List<String>> Function() load;

  /// Returns the newly created name, or null if the parent backed out.
  final Future<String?> Function(BuildContext) add;

  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  List<String>? _options;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final options = await widget.load();
      if (mounted) setState(() => _options = options);
    } catch (_) {
      if (mounted) {
        setState(() {
          _options = const [];
          _error = 'Could not load these. Check your connection.';
        });
      }
    }
  }

  Future<void> _add() async {
    try {
      final created = await widget.add(context);
      if (created == null || !mounted) return;
      // Created AND chosen. A parent who just typed a team name has already
      // told us which one they want; making them tap it again is a step that
      // exists only because the code was easier that way.
      Navigator.of(context).pop(created);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not add that. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final options = _options;

    return CiSheet(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  CiSpace.screen, CiSpace.s3, CiSpace.screen, 0),
              child: Text(_error!,
                  style: CiType.bodySm.copyWith(color: c.accentEnergy)),
            ),
          if (options == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CiSpace.s7),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(CiSpace.screen, CiSpace.s5,
                    CiSpace.screen, CiSpace.s3),
                child: Text(widget.emptyLabel,
                    style: CiType.body.copyWith(color: c.textMuted)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final o in options)
                      CiSheetOptionRow(
                        label: o,
                        selected: o == widget.current,
                        onTap: () => Navigator.of(context).pop(o),
                      ),
                  ],
                ),
              ),
            CiSheetOptionRow(
              label: '+   ${widget.addLabel}',
              showDivider: false,
              onTap: _add,
            ),
          ],
        ],
      ),
    );
  }
}
