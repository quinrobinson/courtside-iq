import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/auth_validation.dart';

void main() {
  group('validateEmail', () {
    test('accepts ordinary addresses', () {
      expect(validateEmail('alex@example.com'), isNull);
      expect(validateEmail('a@b.co'), isNull);
    });

    test('accepts plus tags, dots, and subdomains', () {
      // Parents use plus tags for kid-specific mail. An over-strict regex that
      // rejects these locks someone out with no way to argue with it.
      expect(validateEmail('alex.rivera+kids@mail.example.co.uk'), isNull);
      expect(validateEmail("o'brien@example.com"), isNull);
    });

    test('rejects a half-typed address', () {
      expect(validateEmail('alex.rivera@'), 'Enter a valid email address.');
      expect(validateEmail('alex.rivera'), 'Enter a valid email address.');
      expect(validateEmail('@example.com'), 'Enter a valid email address.');
      expect(validateEmail('alex@example'), 'Enter a valid email address.');
    });

    test('rejects embedded whitespace', () {
      expect(validateEmail('alex rivera@example.com'),
          'Enter a valid email address.');
    });

    test('trims surrounding whitespace rather than rejecting it', () {
      // Autofill and paste routinely add a trailing space. Failing on that
      // would be blaming the parent for the keyboard.
      expect(validateEmail('  alex@example.com  '), isNull);
    });

    test('says what is missing when empty, not what is invalid', () {
      expect(validateEmail(''), 'Enter your email address.');
      expect(validateEmail('   '), 'Enter your email address.');
    });
  });

  group('validatePassword (SIGN IN)', () {
    test('accepts a short existing password', () {
      // THE REGRESSION, 2026-07-19: a client-side 8-character minimum on sign
      // in locked out every account created before that rule existed. The
      // password already exists; only the server may judge it.
      expect(validatePassword('abc'), isNull);
      expect(validatePassword('1'), isNull);
    });

    test('accepts anything non-empty, whatever its shape', () {
      expect(validatePassword('a' * 200), isNull);
      expect(validatePassword('   '), isNull);
      expect(validatePassword('!@#'), isNull);
    });

    test('never mentions a length requirement', () {
      // Any message about length here means the minimum has crept back in.
      for (final p in ['a', 'abc', 'short', '']) {
        final message = validatePassword(p);
        if (message != null) {
          expect(message, isNot(contains('at least')));
          expect(message, isNot(contains('characters')));
        }
      }
    });

    test('still catches an empty field', () {
      expect(validatePassword(''), 'Enter your password.');
    });
  });

  group('validateNewPassword (SIGN UP)', () {
    test('enforces the minimum, because the password is being created', () {
      expect(validateNewPassword('a' * (kMinPasswordLength - 1)),
          'Use at least $kMinPasswordLength characters.');
      expect(validateNewPassword('a' * kMinPasswordLength), isNull);
    });

    test('does not trim: spaces are legitimate password characters', () {
      expect(validateNewPassword(' ' * kMinPasswordLength), isNull);
    });

    test('says what is missing when empty', () {
      expect(validateNewPassword(''), 'Enter your password.');
    });
  });

  group('validateConfirmPassword', () {
    test('accepts an exact match', () {
      expect(validateConfirmPassword('longenough', 'longenough'), isNull);
    });

    test('rejects a mismatch, including case', () {
      expect(validateConfirmPassword('longenough', 'longenougH'),
          'Passwords do not match.');
    });

    test('reports the empty case as missing, not as a mismatch', () {
      expect(validateConfirmPassword('longenough', ''),
          'Re-enter your password.');
    });
  });

  group('copy rules', () {
    test('no message uses an em dash', () {
      final messages = <String?>[
        validateEmail(''),
        validateEmail('nope'),
        validatePassword(''),
        validateNewPassword('short'),
        validateConfirmPassword('a', ''),
        validateConfirmPassword('a', 'b'),
      ];
      for (final m in messages) {
        expect(m, isNotNull);
        expect(m, isNot(contains('—')), reason: 'em dash in user-facing copy');
      }
    });

    test('every message ends in a period and starts capitalised', () {
      for (final m in <String?>[
        validateEmail(''),
        validateEmail('nope'),
        validateNewPassword('short'),
        validateConfirmPassword('a', 'b'),
      ]) {
        expect(m!.endsWith('.'), isTrue, reason: m);
        expect(m[0], m[0].toUpperCase(), reason: m);
      }
    });
  });
}
