// Signup confirmation link classification — Phase 4.18
//
// The listener signs the parent OUT when it sees a confirm link, to land them
// on sign-in. So the one thing that must not go wrong is which links it claims:
// matching the RECOVERY link would sign a parent out in the middle of a
// password reset. The navigation itself is deep-link + auth timing and needs a
// device; this pins the pure decision that guards it.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/auth/signup_confirmation_listener.dart';

void main() {
  test('matches the signup confirm link', () {
    expect(isSignupConfirmLink(Uri.parse('courtsideiq://login-callback')), isTrue);
    expect(
      isSignupConfirmLink(
          Uri.parse('courtsideiq://login-callback#access_token=x&type=signup')),
      isTrue,
    );
  });

  test('does NOT match the password-recovery link', () {
    // The critical negative: claiming this would sign a parent out mid-reset.
    expect(
      isSignupConfirmLink(Uri.parse('courtsideiq://reset-password')),
      isFalse,
    );
    expect(
      isSignupConfirmLink(
          Uri.parse('courtsideiq://reset-password#access_token=x')),
      isFalse,
    );
  });

  test('does not match other schemes or unrelated links', () {
    expect(isSignupConfirmLink(Uri.parse('https://login-callback.example.com')),
        isFalse);
    expect(isSignupConfirmLink(Uri.parse('webapp://courtsideiq.app')), isFalse);
    expect(isSignupConfirmLink(Uri.parse('courtsideiq://something-else')),
        isFalse);
  });
}
