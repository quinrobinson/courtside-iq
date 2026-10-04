// Held-game reminder — roadmap 3.8
//
// A free parent who tracked a 4th game with no signal: the server refused it
// at sync, and the queue is holding it on the phone (heldForLimit). This tells
// them, with the approved "Your game is safe on this phone" sheet (Figma
// 1182:5370), and offers Premium to add it to their games.
//
// WHEN: once per app launch, the first time a held game is seen - at start and
// whenever the queue changes (which is what a reconnect flush does). Once per
// launch, not on every queue change, so it reminds without nagging; the game
// itself waits indefinitely.
//
// ONLY WHEN THE CLIENT AGREES. A held game could in theory come from another
// refusal (an expired session also arrives as 42501). The sheet shows only for
// a free parent at the allowance, so a premium parent is never told they have
// run out.

import 'dart:async';

import 'package:flutter/material.dart';

import '/courtside_iq/game_sync/game_sync_queue.dart';
import '/courtside_iq/game_sync/pending_game.dart';
import '/courtside_iq/game_sync/supabase_game_uploader.dart';
import '/courtside_iq/player_gating.dart';
import '/features/players/widgets/player_gates.dart';
import '/features/premium/paywall_launcher.dart';
import 'game_allowance.dart';

/// What the gate needs, injectable so the nav shell's tests never reach the
/// queue's storage, RevenueCat or Supabase.
abstract class HeldGamePolicy {
  Future<List<PendingGame>> held();
  Future<GameAllowance> allowance();
  Stream<int> get changes;
  Future<void> syncNow();
}

class QueueHeldGamePolicy implements HeldGamePolicy {
  const QueueHeldGamePolicy();

  GameSyncQueue get _q => gameSyncQueue;

  @override
  Future<List<PendingGame>> held() => _q.heldForLimit();

  @override
  Future<GameAllowance> allowance() => loadGameAllowance();

  @override
  Stream<int> get changes => _q.pendingCount;

  @override
  Future<void> syncNow() => _q.flush();
}

/// Shown once per launch. Static so a rebuilt shell does not reset it.
bool _shownThisLaunch = false;

class HeldGameGate extends StatefulWidget {
  const HeldGameGate({
    super.key,
    required this.child,
    this.policy = const QueueHeldGamePolicy(),
  });

  final Widget child;
  final HeldGamePolicy policy;

  @override
  State<HeldGameGate> createState() => _HeldGameGateState();
}

class _HeldGameGateState extends State<HeldGameGate> {
  StreamSubscription<int>? _sub;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
    try {
      _sub = widget.policy.changes.listen((_) => _maybeShow());
    } catch (_) {
      // No queue (tests, or storage unavailable): nothing to remind about.
    }
  }

  Future<void> _maybeShow() async {
    if (_shownThisLaunch || _checking || !mounted) return;
    _checking = true;
    try {
      final held = await widget.policy.held();
      if (held.isEmpty || !mounted) return;
      final a = await widget.policy.allowance();
      if (canStartGame(isPremium: a.isPremium, gameCount: a.gameCount) ||
          !mounted) {
        // Premium, or not actually at the allowance: not a limit hold, so no
        // limit sheet. The queue keeps retrying it on every flush.
        return;
      }
      _shownThisLaunch = true;
      final opponent = held.first.gameRow['opponent_team'] as String?;
      final wantsPlans = await showOfflineGameHeldGate(
        context,
        opponent: opponent,
        playerFirstName: a.playerFirstName,
      );
      if (!wantsPlans || !mounted) return;
      await showPaywall(context);
      // Bought or not, try now: a new subscriber's game should appear without
      // waiting for the next launch. If the webhook has not landed yet the
      // game simply stays held and syncs on the next flush.
      await widget.policy.syncNow();
    } catch (_) {
      // A reminder is never worth an error on screen.
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Test hook: lets a test start from a fresh launch.
@visibleForTesting
void resetHeldGameGateForTest() => _shownThisLaunch = false;
