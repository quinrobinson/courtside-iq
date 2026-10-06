// Birth-date prompt gate — Phase 4.11d
//
// The 2.0 replacement for custom_code/widgets/birth_date_prompt_gate.dart,
// which is mounted ONLY on the v1 home_widget. That means the prompt has been
// dead on every build with kUseDashboardV2 on - a real feature silently lost
// to the rebuild, like the Games tab's event filter.
//
// Asks once per player per week, for the FIRST player missing a birth date.
// Not once per player per open, and not for every player at once: a parent
// with three uncalibrated players should not face three dialogs before they
// have seen the app.

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import 'birth_date_nudges.dart';
import 'birth_date_prompt_service.dart';
import 'birth_date_sheet.dart';

/// Checks for a player missing a birth date and offers to add one.
///
/// Silent on every failure. This is an unprompted nudge; if the query fails
/// the parent should see nothing at all rather than an error for something
/// they never asked for.
Future<void> maybePromptForBirthDate(BuildContext context) async {
  try {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;

    final rows = await SupaFlow.client
        .from('players')
        .select('id, first_name')
        .eq('user_id', userId)
        .filter('birth_date', 'is', null) as List;

    for (final row in rows) {
      final playerId = row['id'] as String?;
      if (playerId == null) continue;
      if (!await BirthDatePromptService.shouldShowModalForPlayer(playerId)) {
        continue;
      }
      if (!context.mounted) return;

      // Recorded BEFORE the dialog resolves, so a parent who declines is not
      // asked again on the next open. "Not now" has to mean not now.
      await BirthDatePromptService.markModalDismissed(playerId);

      if (!context.mounted) return;
      final wants = await showBirthDatePrompt(context);
      if (!wants || !context.mounted) return;

      final date = await presentBirthDateSheet(context);
      if (date == null) return;
      await writeBirthDate(playerId, date);
      return;
    }
  } catch (_) {
    // Deliberately silent. See the note above.
  }
}

/// Writes a month and year to a player. Day 1 stands in for the day the app
/// never asks about - the same rule as the add and edit forms.
Future<void> writeBirthDate(String playerId, DateTime date) async {
  final month = date.month.toString().padLeft(2, '0');
  await SupaFlow.client
      .from('players')
      .update({'birth_date': '${date.year}-$month-01'}).eq('id', playerId);
}
