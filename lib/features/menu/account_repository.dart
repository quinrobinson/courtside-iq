// The signed-in account — Phase 4.15
//
// THE NAME IS NOT IN AUTH. `AuthUserInfo` never populates displayName in this
// app, so `currentUserDisplayName` is permanently the empty string. The name
// lives in `public.users` as first_name / last_name, which is where v1 writes
// it. Menu and Your Profile read from here instead, or they show "Your
// account" to everyone forever.
//
// The EMAIL is the opposite: auth owns it, and `public.users.user_email` is a
// copy kept for joins. Changing an email has to move both, and the auth side
// is the one that gates signing in.

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';

class AccountProfile {
  const AccountProfile({this.firstName = '', this.lastName = '', this.email = ''});

  final String firstName;
  final String lastName;
  final String email;

  /// "Alex Rivera", or whichever half exists.
  String get fullName =>
      [firstName.trim(), lastName.trim()].where((s) => s.isNotEmpty).join(' ');
}

/// What an email change did, so the screen can say the right thing.
enum EmailChangeOutcome {
  /// Supabase sent a confirmation link to the NEW address. The change is not
  /// live until it is clicked.
  confirmationSent,

  /// Rejected - already in use, or malformed.
  failed,
}

class AccountRepository {
  const AccountRepository();

  Future<AccountProfile> load() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return const AccountProfile();

    final rows = await SupaFlow.client
        .from('users')
        .select('first_name, last_name, user_email')
        .eq('id', uid)
        .limit(1) as List;

    if (rows.isEmpty) return AccountProfile(email: currentUserEmail);
    final r = rows.first as Map<String, dynamic>;
    return AccountProfile(
      firstName: r['first_name'] as String? ?? '',
      lastName: r['last_name'] as String? ?? '',
      // AUTH WINS on email. The users copy can lag a confirmed change, and
      // the address you actually sign in with is the one to show.
      email: currentUserEmail.isNotEmpty
          ? currentUserEmail
          : (r['user_email'] as String? ?? ''),
    );
  }

  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {
    final uid = currentUserUid;
    if (uid.isEmpty) return;
    await SupaFlow.client.from('users').update({
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
    }).eq('id', uid);
  }

  /// Starts an email change. NOTHING CHANGES UNTIL THE LINK IS CLICKED.
  ///
  /// Supabase mails a confirmation to the NEW address, and the account keeps
  /// signing in with the old one until then. A screen that says "Email
  /// updated" here would be lying, and the parent would be locked out of
  /// nothing while believing they had moved.
  ///
  /// `public.users.user_email` is deliberately NOT written here. It would
  /// record an address the account cannot yet sign in with; it is reconciled
  /// once auth confirms.
  Future<EmailChangeOutcome> requestEmailChange(String email) async {
    try {
      await SupaFlow.client.auth
          .updateUser(UserAttributes(email: email.trim()));
      return EmailChangeOutcome.confirmationSent;
    } catch (_) {
      return EmailChangeOutcome.failed;
    }
  }

  /// Verifies the current password, then sets the new one.
  ///
  /// SUPABASE DOES NOT CHECK THE OLD PASSWORD on updateUser - it trusts the
  /// session. So anyone holding an unlocked phone could change the password
  /// and lock the owner out. Signing in with the current password first is
  /// what makes the "Current password" field on the frame mean anything
  /// rather than being decoration.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = currentUserEmail;
    if (email.isEmpty) return false;
    try {
      await SupaFlow.client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } catch (_) {
      return false;
    }
    try {
      await SupaFlow.client.auth
          .updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (_) {
      return false;
    }
  }
}
