// Auth form validation — Phase 4.9
//
// Pure Dart on purpose. Validation used to live inside EmailAuthPage, which
// meant testing "is this address accepted" required pumping a widget, and any
// VALID input then fell through to the real authManager and hit Supabase. The
// rules are the thing worth testing; the screen is not.
//
// No Flutter, no Supabase imports here. See CLAUDE.md.

/// Minimum password length. Supabase enforces its own minimum server-side;
/// this exists so a parent finds out before a round trip, not after.
const int kMinPasswordLength = 8;

/// Deliberately permissive: something, an @, something, a dot, something.
///
/// Strict RFC validation rejects addresses that genuinely work, and this is a
/// typo check, not an authority on deliverability. The confirmation email is
/// the real check, and a parent locked out by an over-strict regex has no way
/// to argue with it.
final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Null when valid. The returned string is shown to a parent, so it says what
/// to do rather than what went wrong.
String? validateEmail(String raw) {
  final email = raw.trim();
  if (email.isEmpty) return 'Enter your email address.';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
  return null;
}

/// SIGN IN. Checks only that something was typed.
///
/// It must NEVER enforce a length or complexity rule. The password already
/// exists, and the server is the only thing entitled to say whether it is
/// correct. A client-side minimum here locks out every account created before
/// that minimum existed, using their own app, with no way to argue with it -
/// which is exactly what shipped and had to be reverted on 2026-07-19.
///
/// Rules about what a password may BE belong to [validateNewPassword].
String? validatePassword(String password) {
  if (password.isEmpty) return 'Enter your password.';
  return null;
}

/// SIGN UP. The password is being created, so the minimum applies.
String? validateNewPassword(String password) {
  if (password.isEmpty) return 'Enter your password.';
  if (password.length < kMinPasswordLength) {
    return 'Use at least $kMinPasswordLength characters.';
  }
  return null;
}

/// Sign up only. [confirm] must match [password].
String? validateConfirmPassword(String password, String confirm) {
  if (confirm.isEmpty) return 'Re-enter your password.';
  if (confirm != password) return 'Passwords do not match.';
  return null;
}
