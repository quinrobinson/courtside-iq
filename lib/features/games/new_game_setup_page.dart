// New Game — Setup — Phase 4.13
//
// Measured from 286:1328:
//
//   hero   INK (#0f0f0f), 212 tall: back at 12/52, "New Game" SemiBold 17
//          centred, then the player tiles - avatar 54 over a name, 78 apart.
//          Every avatar is filled sunk ink; the RING is what changes - lime
//          2pt for the chosen player, a #2e2e2e hairline for the rest.
//   form   TEAM (with a "+"), OPPONENT, EVENT · OPTIONAL (with a "+")
//   cta    "Start Game", full width
//
// PLAYER, TEAM AND OPPONENT ARE ALL REQUIRED; only the event is optional.
// That is the frame's own convention - it marks exactly one field "OPTIONAL",
// which is the design saying the others are not - and it matches v1, whose
// Start button is disabled without all three. An earlier version here required
// only the player, on the reasoning that a parent at tip-off should not be
// blocked by a field. That was reasoning over reading.
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
    _playersFuture = _loadPlayers();
  }

  /// Loads the players and preselects a lone one. Kept separate from initState
  /// so the offline "Try again" can re-run it.
  Future<List<PlayerListEntry>> _loadPlayers() {
    final future = widget.repository.load();
    future.then((players) {
      // One player means there is nothing to choose. Preselecting saves a tap
      // that has only one possible answer.
      if (mounted && players.length == 1) {
        setState(() => _playerId = players.first.playerId);
      }
    }).catchError((_) {});
    return future;
  }

  void _retry() => setState(() => _playersFuture = _loadPlayers());

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

  /// Player, team and opponent. See the note at the top of the file.
  bool get _canStart =>
      _playerId != null &&
      (_team?.trim().isNotEmpty ?? false) &&
      _opponent.text.trim().isNotEmpty;

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
              final loading = snap.connectionState == ConnectionState.waiting;
              // OFFLINE IS NOT AN EMPTY SETUP. The load throws with no signal,
              // and the old `snap.data ?? []` swallowed that into a setup with
              // an empty player toggle and a permanently-disabled Start - a dead
              // screen with no explanation. Every entry point (the create sheet,
              // the games list, Today) funnels through here, so the offline
              // state belongs here, once.
              final failed = snap.hasError;
              final players = snap.data ?? const <PlayerListEntry>[];
              return Column(
                children: [
                  _Hero(
                    // Nobody to pick while the list is loading or unreachable;
                    // the hero still carries the back button.
                    players: loading || failed
                        ? const <PlayerListEntry>[]
                        : players,
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
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : failed
                            ? _OfflineNotice(onRetry: _retry)
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(
                                    CiSpace.screen,
                                    CiSpace.s6,
                                    CiSpace.screen,
                                    CiSpace.s6),
                                children: [
                                  // Team and Opponent stay disabled until a
                                  // player is chosen, which is not obvious - a
                                  // parent can tap a greyed picker and get
                                  // nothing. Say what to do first.
                                  if (_playerId == null) ...[
                                    Text(
                                      'Select a player above to set the team '
                                      'and opponent.',
                                      style: CiType.bodySm
                                          .copyWith(color: c.textMuted),
                                    ),
                                    const SizedBox(height: CiSpace.s5),
                                  ],
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
                                    // Start depends on this, so the button has
                                    // to re-evaluate as they type.
                                    onChanged: (_) => setState(() {}),
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
                  // No Start while loading or offline: there is no game to
                  // start until the players are in hand.
                  if (!loading && !failed)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(CiSpace.screen, 0,
                            CiSpace.screen, CiSpace.s6),
                        child: CiButton(
                          label: 'Start Game',
                          expand: true,
                          onPressed: _canStart ? () => _start(players) : null,
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

/// Shown in place of the setup when the players cannot be loaded - almost
/// always no connection. Persistent, not a toast: it explains why Start is not
/// available, which a message that vanishes cannot.
class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CiSpace.s7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: c.textMuted),
            const SizedBox(height: CiSpace.s4),
            Text("You're offline",
                textAlign: TextAlign.center,
                style: CiType.sectionTitle.copyWith(color: c.text)),
            const SizedBox(height: CiSpace.s2),
            Text(
              'Starting a game needs a connection to load your players. '
              'Reconnect and try again.',
              textAlign: TextAlign.center,
              style: CiType.bodySm.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: CiSpace.s5),
            CiButton(
              label: 'Try again',
              style: CiButtonStyle.secondary,
              size: CiButtonSize.sm,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
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
    // INK, and it claims the status bar. Built on light first - assumed, not
    // read - which is the same miss as the Full Breakdown hero.
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
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
          const SizedBox(height: CiSpace.s6),
        ],
      ),
        );
      }),
    );
  }
}

/// Avatar over a name, on the ink hero.
///
/// The RING carries the selection - lime at 2pt against a dark hairline - which
/// is what the frame specifies and is also the only signal that survives a
/// glance at a phone held at arm's length in a gym. The name weight follows,
/// but weight alone at 13pt does not carry.
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
              CiAvatar(
                name: player.displayName,
                imageUrl: player.profilePic,
                size: 54,
                ringColor: selected ? c.accentGood : c.border,
                ringWidth: selected ? 2 : 1.35,
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
