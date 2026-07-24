// Guided First-Run gate — Phase 4.9
//
// Decides, on the authenticated landing, whether to run the guided first-run
// (Welcome -> Add first player) or drop straight to Today. Shown ONCE per user,
// and only for a user who has no players yet.
//
// It sits at _homeScreen() in nav.dart, the ONE seam every landing passes
// through: a cold start, a fresh sign-in, AND the email-confirmation deep link,
// which re-enters the app WITHOUT going back through the sign-up screen. A gate
// on the sign-up path would miss that confirm landing - which is the whole
// point, now that email confirmation is on.
//
// The policy is injected so the gate is testable without Supabase or storage.

import 'package:flutter/material.dart';

import '/app_state.dart';
import '/backend/supabase/supabase.dart';
import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import 'first_run_flow.dart';

/// Whether to show the guided first-run, and how to remember it was shown.
abstract class FirstRunPolicy {
  Future<bool> shouldShow();
  Future<void> markSeen();
}

/// The real policy: seen-state from [FFAppState], player count from Supabase.
class SupabaseFirstRunPolicy implements FirstRunPolicy {
  const SupabaseFirstRunPolicy();

  /// Null when there is no signed-in user OR when Supabase cannot be reached
  /// at all.
  ///
  /// DEFENSIVE ON PURPOSE. This gate sits on the landing path, so a throw here
  /// does not fail politely - it takes out the screen every session starts on.
  /// `SupaFlow.client` asserts that Supabase was initialised, and that assert
  /// was outside the try below, so the one thing this gate must never do was
  /// exactly what it did. Declining is always a safe answer; throwing is not.
  String? get _uid {
    try {
      return SupaFlow.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> shouldShow() async {
    final uid = _uid;
    if (uid == null) return false;
    // Already welcomed on this device? Never query, never repeat.
    if (FFAppState().firstRunSeen(uid)) return false;
    try {
      final rows =
          await SupaFlow.client.from('players').select('id').eq('user_id', uid)
              as List;
      // Only a brand-new, player-less account is welcomed. Anyone with a
      // player already knows the app; Today's empty state covers the rest.
      final isNew = rows.isEmpty;
      // A user welcomed here is new to 2.0, so the "What's new in 2.0" upgrade
      // sheet - which is for v1 upgraders - must never reach them. Marking it
      // seen the moment we know they are new keeps the two landing gates
      // mutually exclusive: without it, a new parent who adds a player in
      // first-run would then have a player and trip the upgrade gate on the
      // same landing. Done in the real policy (not the gate widget) so it stays
      // out of the injected-fake path the tests use.
      if (isNew) await FFAppState().markWhatsNew2Seen(uid);
      return isNew;
    } catch (_) {
      // A failed count must not trap the parent in a welcome they can't leave.
      return false;
    }
  }

  @override
  Future<void> markSeen() async {
    final uid = _uid;
    if (uid != null) await FFAppState().markFirstRunSeen(uid);
  }
}

class FirstRunGate extends StatefulWidget {
  const FirstRunGate({
    super.key,
    required this.child,
    this.policy = const SupabaseFirstRunPolicy(),
  });

  /// Where the gate lands when first-run is not needed (Today).
  final Widget child;
  final FirstRunPolicy policy;

  @override
  State<FirstRunGate> createState() => _FirstRunGateState();
}

class _FirstRunGateState extends State<FirstRunGate> {
  /// null while deciding, true = run first-run, false = show [child].
  bool? _showFirstRun;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final show = await widget.policy.shouldShow();
    // Not showing it means this user is settled: record that so we never query
    // again (idempotent if they were already marked seen).
    if (!show) await widget.policy.markSeen();
    if (mounted) setState(() => _showFirstRun = show);
  }

  Future<void> _finish() async {
    await widget.policy.markSeen();
    if (mounted) setState(() => _showFirstRun = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showFirstRun == null) {
      // A brief ink hold while the one count query resolves. A seen user
      // resolves in a microtask, so this is a single frame at most.
      return CiSurface.ink(
        statusBar: true,
        child: Builder(
          builder: (context) =>
              Scaffold(backgroundColor: CiColors.of(context).bg),
        ),
      );
    }
    if (_showFirstRun!) return FirstRunFlow(onFinished: _finish);
    return widget.child;
  }
}
