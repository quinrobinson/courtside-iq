// Sending feedback — Phase 4.15c
//
// One insert into `public.feedback`, which is INSERT-ONLY for authenticated
// and anon roles. Nobody can read the table from the client, including the
// person who wrote the row, which is why the confirmation has to carry the
// reassurance rather than a sent-items list doing it.
//
// THE CATEGORY GOES IN THE `rating` COLUMN. v1's feedback screen asked for a
// rating and stored Solid / Good / Elite there; 508:1972 replaces that with
// Bug / Idea / Question / Other. Reusing the column avoids a migration for a
// rename, at the cost of a column called `rating` holding "Bug". Worth
// tidying with a migration eventually - flagged rather than done, because
// renaming a live column to improve one word is not free.
//
// THE EMAIL IS TAKEN FROM THE SESSION, not asked for. v1 had a field for it,
// which meant a typo made a reply impossible and an honest answer was one
// more thing to type. The signed-in address is already the right one.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';

/// What kind of note this is (508:1972).
enum FeedbackCategory { bug, idea, question, other }

extension FeedbackCategoryLabel on FeedbackCategory {
  String get label => switch (this) {
        FeedbackCategory.bug => 'Bug',
        FeedbackCategory.idea => 'Idea',
        FeedbackCategory.question => 'Question',
        FeedbackCategory.other => 'Other',
      };
}

class FeedbackRepository {
  const FeedbackRepository();

  /// Returns false if it could not be stored, so the screen can keep the
  /// message rather than swallowing something a parent took time to write.
  Future<bool> send({
    required FeedbackCategory category,
    required String message,
  }) async {
    try {
      await SupaFlow.client.from('feedback').insert({
        'rating': category.label,
        'feedback': message.trim(),
        'email': currentUserEmail,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
