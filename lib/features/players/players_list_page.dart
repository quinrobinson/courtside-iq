// Players — Phase 4.11a
//
// Built from Players — List (272:1557) and Players — Empty (206:806).
//
// The same hybrid ground as Today: an ink header block over a light list. The
// header carries "Players" and the add button; the rows are the light body.
//
// Gating (free add-gate, 3-player cap, premium-lapsed lock) is 4.11a.2 and not
// wired here yet. The add button opens the existing AddPlayerSheet.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/players_list_builder.dart';
import '/features/flags.dart';
import '/features/nav/ci_nav_bar.dart';
import '/features/players/add_player_sheet.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import 'players_repository.dart';
import 'widgets/player_list_row.dart';

class PlayersListPage extends StatefulWidget {
  const PlayersListPage({super.key, this.repository = const PlayersRepository()});

  final PlayersRepository repository;

  @override
  State<PlayersListPage> createState() => _PlayersListPageState();
}

class _PlayersListPageState extends State<PlayersListPage> {
  late Future<List<PlayerListEntry>> _future = widget.repository.load();

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _addPlayer() async {
    // Gating (free limit, 3-player cap) lands in 4.11a.2. For now the sheet
    // opens directly, matching a premium user under the cap.
    await showAddPlayerSheet(context, onPlayerAdded: _refresh);
  }

  void _openProfile(PlayerListEntry e) {
    context.pushNamed(
      PlayersProfileWidget.routeName,
      queryParameters: {'playerID': e.playerId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: FutureBuilder<List<PlayerListEntry>>(
            future: _future,
            builder: (context, snap) {
              final players = snap.data;
              return Column(
                children: [
                  _Header(onAdd: _addPlayer),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: c.text,
                      child: _body(context, snap, players),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: kUseNavBar2
              ? const CiNavBar(active: CiNavTab.players)
              : const CustomNavBarWidget(page: 'Players'),
        );
      }),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncSnapshot<List<PlayerListEntry>> snap,
    List<PlayerListEntry>? players,
  ) {
    if (snap.connectionState == ConnectionState.waiting && players == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snap.hasError) {
      return _Message(
        title: 'Could not load your players',
        body: 'Pull down to try again.',
      );
    }
    if (players == null || players.isEmpty) {
      return _EmptyState(onAdd: _addPlayer);
    }

    final c = CiColors.of(context);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: players.length,
      separatorBuilder: (_, __) =>
          Container(height: CiSpace.hairline, color: c.hairline),
      itemBuilder: (context, i) => PlayerListRow(
        entry: players[i],
        onTap: () => _openProfile(players[i]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s6),
            child: Row(
              children: [
                Expanded(
                  child: Text('Players',
                      style: CiType.h2.copyWith(
                          color: c.text, fontWeight: CiWeight.extraBold)),
                ),
                CiIconButton(
                  icon: Icons.add,
                  onDark: true,
                  semanticLabel: 'Add player',
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    // Scrollable so pull-to-refresh still works with no content.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(color: c.surfaceSunk, shape: BoxShape.circle),
            child: Icon(Icons.people_outline, color: c.textMuted, size: 28),
          ),
        ),
        const SizedBox(height: CiSpace.s5),
        Text('No players yet',
            textAlign: TextAlign.center,
            style: CiType.h3.copyWith(color: c.text)),
        const SizedBox(height: CiSpace.s2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.s8),
          child: Text(
            'Add your player to start tracking how they grow game by game.',
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted),
          ),
        ),
        const SizedBox(height: CiSpace.s6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
          child: CiButton(
            label: 'Add player',
            style: CiButtonStyle.lime,
            expand: true,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
        Text(title,
            textAlign: TextAlign.center,
            style: CiType.h3.copyWith(color: c.text)),
        const SizedBox(height: CiSpace.s2),
        Text(body,
            textAlign: TextAlign.center,
            style: CiType.body.copyWith(color: c.textMuted)),
      ],
    );
  }
}
