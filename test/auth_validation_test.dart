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

  group('validatePassword', () {
    test('accepts anything at or over the minimum', () {
      expect(validatePassword('a' * kMinPasswordLength), isNull);
      expect(validatePassword('a longer passphrase'), isNull);
    });

    test('rejects one character under, and names the number', () {
      expect(validatePassword('a' * (kMinPasswordLength - 1)),
          'Use at least $kMinPasswordLength characters.');
    });

    test('does not trim: spaces are legitimate password characters', () {
      final spaces = ' ' * kMinPasswordLength;
      expect(validatePassword(spaces), isNull);
    });

    test('says what is missing when empty', () {
      expect(validatePassword(''), 'Enter your password.');
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
        validatePassword('short'),
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
        validatePassword('short'),
        validateConfirmPassword('a', 'b'),
      ]) {
        expect(m!.endsWith('.'), isTrue, reason: m);
        expect(m[0], m[0].toUpperCase(), reason: m);
      }
    });
  });
}
