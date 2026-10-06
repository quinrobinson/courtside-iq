// The live game flow — Phase 4.13
//
// Setup hands over here, and this owns the sequence: track, pause, end, save.
// Each screen stays a pure renderer; the ordering and the side effects live in
// one place so no screen has to know what comes after it.
//
// THE SNAPSHOT IS THE UNIT OF TRUTH. It is written to the store on every tap
// by the tracker, so a crash mid-game loses nothing, and it is what the save
// path turns into rows.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_confirm_dialog.dart';
import '/courtside_iq/design/components/ci_toast.dart';

import 'game_complete_page.dart';
import 'game_paused_dialog.dart';
import '/courtside_iq/live_game.dart';
import 'games_revision.dart';
import 'live_game_store.dart';
import 'live_tracker_page.dart';
import 'new_game_setup_page.dart';
import 'save_game.dart';
import '/features/player_insight/data/player_insight_service.dart';

class LiveGameFlow extends StatefulWidget {
  /// A game starting now, from the setup screen.
  const LiveGameFlow({
    super.key,
    required NewGameSetup setup,
    this.store = const LiveGameStore(),
    this.saver = const GameSaver(),
    this.onFinished,
  })  : _setup = setup,
        _resuming = null;

  /// A game already in progress, read back off disk.
  ///
  /// Resuming REPLAYS THE STORED SNAPSHOT rather than rebuilding one from a
  /// setup, so the stats and the original start time come back intact. Losing
  /// startedAt would date the game to whenever the parent happened to reopen
  /// the app, which for a game tracked last night is the wrong day.
  const LiveGameFlow.resume({
    super.key,
    required LiveGameSnapshot snapshot,
    this.store = const LiveGameStore(),
    this.saver = const GameSaver(),
    this.onFinished,
  })  : _setup = null,
        _resuming = snapshot;

  final NewGameSetup? _setup;
  final LiveGameSnapshot? _resuming;
  final LiveGameStore store;
  final GameSaver saver;

  /// Called once the game is saved or discarded, so the caller can leave.
  final VoidCallback? onFinished;

  @override
  State<LiveGameFlow> createState() => _LiveGameFlowState();
}

enum _Stage { tracking, complete }

class _LiveGameFlowState extends State<LiveGameFlow> {
  late LiveGameSnapshot _snapshot = widget._resuming ??
      LiveGameSnapshot(
        playerId: widget._setup!.playerId,
        playerName: widget._setup!.playerName,
        opponent: widget._setup!.opponent,
        team: widget._setup!.team,
        event: widget._setup!.event,
        stats: const LiveGameStats(),
        startedAt: DateTime.now(),
      );

  _Stage _stage = _Stage.tracking;
  bool _saving = false;
  bool _offline = false;
  StreamSubscription<List<ConnectivityResult>>? _conn;

  @override
  void initState() {
    super.initState();
    _watchConnectivity();
  }

  @override
  void dispose() {
    _conn?.cancel();
    super.dispose();
  }

  /// Display only. The queue keeps the game safe either way; this just lets
  /// the tracker say so, which is the difference between a parent trusting
  /// the app in a gym and force-quitting it.
  Future<void> _watchConnectivity() async {
    final conn = Connectivity();
    void apply(List<ConnectivityResult> r) {
      final off = r.every((x) => x == ConnectivityResult.none);
      if (mounted && off != _offline) setState(() => _offline = off);
    }

    try {
      apply(await conn.checkConnectivity());
      _conn = conn.onConnectivityChanged.listen(apply);
    } catch (_) {
      // No connectivity plugin on this platform is not a reason to block a
      // game. Assume online and let the queue sort it out.
    }
  }

  Future<void> _pause() async {
    final choice =
        await showGamePausedDialog(context, snapshot: _snapshot);
    if (!mounted) return;
    if (choice == PausedChoice.end) setState(() => _stage = _Stage.complete);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final outcome = await widget.saver.save(_snapshot);
    // Tell the game-showing screens to reload. A synced game is on the server
    // now, but the Games list and Today feed are kept alive by the shell and
    // would otherwise still show the list from before this game existed. (An
    // offline-queued game is not on the server yet; the queue bumps this again
    // when it actually syncs.)
    notifyGamesChanged();
    // Warm the development narrative in the background so the Development tab is
    // instant when the parent looks, right after the game. ONLY on a synced
    // save: an offline-queued game is not on the server yet, so generating now
    // would produce a story that omits the game just saved.
    if (outcome == SaveOutcome.synced) {
      unawaited(PlayerInsightService().warm(_snapshot.playerId));
    }
    // The game is durable either way, so the in-progress copy goes now. Left
    // behind, the next launch would offer to resume a game already saved.
    await widget.store.clear();
    if (!mounted) return;

    // Success either way. Not "failed" on the offline branch: the game is on
    // disk and will go up by itself.
    showCiToast(
      context,
      outcome == SaveOutcome.synced
          ? 'Game saved.'
          : 'Game saved. It will sync when you are back online.',
      type: CiToastType.success,
    );
    _finish();
  }

  Future<void> _discard() async {
    final confirmed = await showCiConfirmDialog(
      context,
      title: 'Discard this game?',
      message: 'The stats you tracked will be deleted. This cannot be undone.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep it',
    );
    if (!confirmed || !mounted) return;
    await widget.store.clear();
    if (mounted) _finish();
  }

  /// Leave the flow.
  ///
  /// Falls back to popping this route when the caller named no destination,
  /// which is exactly how the RESUME path arrives here. Without it a parent
  /// who resumed a game, saved it and watched "Game saved." appear was left
  /// sitting on the Game Complete screen with no way forward - and Discard
  /// looked like it did nothing at all.
  void _finish() {
    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _Stage.complete) {
      return GameCompletePage(
        snapshot: _snapshot,
        saving: _saving,
        onSave: _save,
        onDiscard: _discard,
      );
    }

    return LiveTrackerPage(
      snapshot: _snapshot,
      store: widget.store,
      offline: _offline,
      onPause: (s) {
        _snapshot = s;
        _pause();
      },
      onEnd: (s) {
        _snapshot = s;
        setState(() => _stage = _Stage.complete);
      },
    );
  }
}
