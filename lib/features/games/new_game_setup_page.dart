// New Game — Setup — Phase 4.13
//
// Measured from 286:1328:
//
//   hero   212: back at 12/52, "New Game" SemiBold 17 centred, then the
//          player tiles - avatar 54 over a name, 78 apart, the chosen one
//          SemiBold and the rest Medium
//   form   TEAM (with a "+"), OPPONENT, EVENT · OPTIONAL (with a "+")
//   cta    "Start Game", full width
//
// EVERYTHING BUT THE PLAYER IS OPTIONAL TO FILL IN, but only the event says so
// on its label. Team and opponent are asked for plainly because a game without
// them is harder to recognise later in a list; neither blocks the start.
//
// The "+" beside team and event adds one INLINE. A parent standing courtside
// should not have to leave for the profile to add the team their kid just
// joined - which is what the 4.11d pick-lists were built to make possible.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/players_list_builder.dart';
import '/features/players/players_repository.dart';
import 'game_setup_pickers.dart';

/// What the setup screen produces. The tracker takes it from here.
class NewGameSetup {
  final String playerId;
  final String playerName;
  final String? team;
  final String? opponent;
  final String? event;

  const NewGameSetup({
    required this.playerId,
    required this.playerName,
    this.team,
    this.opponent,
    this.event,
  });
}

class NewGameSetupPage extends StatefulWidget {
  const NewGameSetupPage({
    super.key,
    this.repository = const PlayersRepository(),
    this.onStart,
  });

  final PlayersRepository repository;

  /// Called with the setup once the parent taps Start Game.
  ///
  /// Injected rather than navigating from here: the tracker is 4.13's next
  /// piece, and this screen should not need editing when it lands.
  final ValueChanged<NewGameSetup>? onStart;

  @override
  State<NewGameSetupPage> createState() => _NewGameSetupPageState();
}

class _NewGameSetupPageState extends State<NewGameSetupPage> {
  final _opponent = TextEditingController();

  Future<List<PlayerListEntry>>? _playersFuture;
  String? _playerId;
  String? _team;
  String? _event;

  @override
  void initState() {
    super.initState();
    _playersFuture = widget.repository.load();
    _playersFuture!.then((players) {
      // One player means there is nothing to choose. Preselecting saves a tap
      // that has only one possible answer.
      if (mounted && players.length == 1) {
        setState(() => _playerId = players.first.playerId);
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _opponent.dispose();
    super.dispose();
  }

  Future<void> _pickTeam() async {
    final id = _playerId;
    if (id == null) return;
    final picked =
        await presentTeamSelection(context, playerId: id, current: _team);
    if (picked != null && mounted) setState(() => _team = picked);
  }

  Future<void> _pickEvent() async {
    final id = _playerId;
    if (id == null) return;
    final picked =
        await presentEventSelection(context, playerId: id, current: _event);
    if (picked != null && mounted) setState(() => _event = picked);
  }

  void _start(List<PlayerListEntry> players) {
    final id = _playerId;
    if (id == null) return;
    final player = players.firstWhere((p) => p.playerId == id);
    widget.onStart?.call(NewGameSetup(
      playerId: id,
      playerName: player.firstName,
      team: _team,
      opponent: _opponent.text.trim().isEmpty ? null : _opponent.text.trim(),
      event: _event,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: FutureBuilder<List<PlayerListEntry>>(
            future: _playersFuture,
            builder: (context, snap) {
              final players = snap.data ?? const <PlayerListEntry>[];
              return Column(
                children: [
                  _Hero(
                    players: players,
                    selectedId: _playerId,
                    onSelect: (id) => setState(() {
                      _playerId = id;
                      // Teams and events belong to ONE player, so a selection
                      // made for someone else is not theirs to carry over.
                      _team = null;
                      _event = null;
                    }),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(CiSpace.screen,
                          CiSpace.s6, CiSpace.screen, CiSpace.s6),
                      children: [
                        _PickerRow(
                          label: 'Team',
                          value: _team,
                          placeholder: 'Select team',
                          enabled: _playerId != null,
                          onTap: _pickTeam,
                          onAdd: _pickTeam,
                        ),
                        const SizedBox(height: CiSpace.s5),
                        CiField(
                          label: 'Opponent',
                          controller: _opponent,
                          placeholder: 'Enter opponent name',
                        ),
                        const SizedBox(height: CiSpace.s5),
                        _PickerRow(
                          label: 'Event  ·  Optional',
                          value: _event,
                          placeholder: 'Select event',
                          enabled: _playerId != null,
                          onTap: _pickEvent,
                          onAdd: _pickEvent,
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(CiSpace.screen, 0,
                          CiSpace.screen, CiSpace.s6),
                      child: CiButton(
                        label: 'Start Game',
                        expand: true,
                        // Only the player is required. A game with no team or
                        // opponent is still a game worth tracking, and a
                        // parent at tip-off should not be blocked by a field.
                        onPressed: _playerId == null
                            ? null
                            : () => _start(players),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.players,
    required this.selectedId,
    required this.onSelect,
  });

  final List<PlayerListEntry> players;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                Center(
                  child: Text('New Game',
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
          const SizedBox(height: CiSpace.s5),
          // 78 apart in the frame, which is the 54 tile plus a 24 gap.
          Wrap(
            spacing: 24,
            runSpacing: CiSpace.s4,
            alignment: WrapAlignment.center,
            children: [
              for (final p in players)
                _PlayerTile(
                  player: p,
                  selected: p.playerId == selectedId,
                  onTap: () => onSelect(p.playerId),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Avatar over a name. The chosen one is SemiBold ink; the rest are Medium
/// muted, and dimmed - selection has to survive a glance, and weight alone at
/// 13pt does not carry across a phone held at arm's length in a gym.
class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final PlayerListEntry player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: player.firstName,
      container: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: selected ? 1 : 0.45,
                child: CiAvatar(
                  name: player.displayName,
                  imageUrl: player.profilePic,
                  size: 54,
                  selected: selected,
                ),
              ),
              const SizedBox(height: CiSpace.s2),
              Text(
                player.firstName,
                style: CiType.labelTight.copyWith(
                  color: selected ? c.text : c.textMuted,
                  fontWeight:
                      selected ? CiWeight.semiBold : CiWeight.medium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A picker field with a trailing "+" that adds a new one inline.
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.enabled,
    required this.onTap,
    required this.onAdd,
  });

  final String label;
  final String? value;
  final String placeholder;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: CiPickerField(
            label: label,
            placeholder: placeholder,
            value: value,
            enabled: enabled,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: CiSpace.s3),
        Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Semantics(
            button: true,
            label: 'Add ${label.split('  ·  ').first.toLowerCase()}',
            container: true,
            excludeSemantics: true,
            child: InkWell(
              onTap: enabled ? onAdd : null,
              borderRadius: CiRadius.chipR,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.fieldFill,
                  borderRadius: CiRadius.chipR,
                  border: Border.all(color: c.border),
                ),
                child: Icon(Icons.add, size: 20, color: c.text),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
