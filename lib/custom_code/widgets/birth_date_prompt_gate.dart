// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/features/players/birth_date_prompt_modal.dart';
import '/features/players/birth_date_prompt_service.dart';

/// Drop this invisible widget once on the home screen (or any post-auth
/// screen that renders after the player list is available). On first frame
/// it checks the current user's players for any missing a birth date, and
/// shows the first-launch modal for one of them (respecting a 7-day
/// per-player dismissal window).
class BirthDatePromptGate extends StatefulWidget {
  const BirthDatePromptGate({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<BirthDatePromptGate> createState() => _BirthDatePromptGateState();
}

class _BirthDatePromptGateState extends State<BirthDatePromptGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (_checked || !mounted) return;
    _checked = true;

    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      debugPrint('[BirthDateGate] userId=$userId');
      if (userId == null) return;

      final rows = await SupaFlow.client
          .from('players')
          .select('id, first_name')
          .eq('user_id', userId)
          .filter('birth_date', 'is', null);
      debugPrint('[BirthDateGate] rows=${(rows as List).length}');

      for (final row in rows) {
        final playerId = row['id'] as String;
        final firstName = (row['first_name'] as String?) ?? 'your player';
        final shouldShow =
            await BirthDatePromptService.shouldShowModalForPlayer(playerId);
        debugPrint(
            '[BirthDateGate] player=$playerId shouldShow=$shouldShow mounted=$mounted');
        if (shouldShow && mounted) {
          await showBirthDatePromptModal(
            context,
            playerId: playerId,
            playerFirstName: firstName,
          );
          return;
        }
      }
    } catch (e, st) {
      debugPrint('[BirthDateGate] ERROR: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 0,
      height: widget.height ?? 0,
    );
  }
}
