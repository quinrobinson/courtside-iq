// "What's new in 2.0" gate — Phase 4.19c
//
// Decides, on the authenticated landing, whether to show the upgrade sheet over
// Today. Unlike the first-run gate this does NOT replace the screen: it renders
// Today immediately and, once it is up, presents the sheet as a modal - a
// one-time celebration, not a wall in front of the app.
//
// WHO SEES IT. Existing v1 users, once. The test is "has at least one player"
// (they were here before 2.0) AND "not seen on this device". New users are
// excluded upstream: the first-run gate marks THIS sheet seen the moment it
// shows a brand-new parent the welcome, so the two are mutually exclusive and a
// new parent never gets an upgrade sheet for an app they've never used.
//
// It nests INSIDE FirstRunGate at _homeScreen(), the one seam every landing
// passes through - a cold start, a fresh sign-in, and the email-confirmation
// deep link. The policy is injected so the gate is testable without Supabase.

import 'package:flutter/material.dart';

import '/app_state.dart';
import '/backend/supabase/supabase.dart';
import 'whats_new_sheet.dart';

/// Whether to show the upgrade sheet, and how to remember it was shown.
abstract class WhatsNew2Policy {
  Future<bool> shouldShow();
  Future<void> markSeen();
}

/// The real policy: seen-state from [FFAppState], player count from Supabase.
class SupabaseWhatsNew2Policy implements WhatsNew2Policy {
  const SupabaseWhatsNew2Policy();

  /// Null when there is no signed-in user OR when Supabase cannot be reached.
  /// Defensive for the same reason as the first-run gate: this sits on the
  /// landing path, where a throw takes out the screen every session starts on.
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
    // Already shown on this device? Never query, never repeat.
    if (FFAppState().whatsNew2Seen(uid)) return false;
    try {
      final rows =
          await SupaFlow.client.from('players').select('id').eq('user_id', uid)
              as List;
      // Existing users only. A player means they used the app before 2.0 and
      // have something to be reassured about. A player-less account is brand
      // new (first-run handles it) with nothing to reassure.
      return rows.isNotEmpty;
    } catch (_) {
      // A failed count just defers: no sheet now, try again next landing.
      return false;
    }
  }

  @override
  Future<void> markSeen() async {
    final uid = _uid;
    if (uid != null) await FFAppState().markWhatsNew2Seen(uid);
  }
}

class WhatsNewGate extends StatefulWidget {
  const WhatsNewGate({
    super.key,
    required this.child,
    this.policy = const SupabaseWhatsNew2Policy(),
  });

  /// Today, rendered underneath. The sheet floats over it.
  final Widget child;
  final WhatsNew2Policy policy;

  @override
  State<WhatsNewGate> createState() => _WhatsNewGateState();
}

class _WhatsNewGateState extends State<WhatsNewGate> {
  @override
  void initState() {
    super.initState();
    // After Today is on screen, so the sheet rises over a real background
    // rather than a blank frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    final show = await widget.policy.shouldShow();
    if (!show || !mounted) return;
    // Marked before it opens, so killing the app mid-read does not bring it
    // back: a one-time sheet shown twice is worse than shown once and quit.
    await widget.policy.markSeen();
    if (!mounted) return;
    await showWhatsNew2(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
