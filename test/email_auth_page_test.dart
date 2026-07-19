import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/auth/email_auth_page.dart';

// Screen behaviour only. The validation RULES are tested as pure Dart in
// auth_validation_test.dart.
//
// CAREFUL: _submit() with VALID inputs calls the real authManager and hits
// Supabase, which is not initialised in tests. Every submit here must leave at
// least one field invalid. Anything that needs a valid-input path belongs in
// the pure test or on device.

Future<void> _pump(WidgetTester tester,
        {AuthMode mode = AuthMode.signIn}) =>
    tester.pumpWidget(MaterialApp(home: EmailAuthPage(initialMode: mode)));

Finder _fieldNamed(String label) => find.ancestor(
      of: find.text(label.toUpperCase()),
      matching: find.byType(CiField),
    );

// "Sign in" is on screen twice - the mode chip and the CTA - so every finder
// here has to say WHICH control it means. find.text alone is ambiguous.
Finder _chip(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(CiChip),
    );

Finder get _cta => find.byType(CiButton);

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(_cta);
  await tester.pump();
}

Future<void> _tapChip(WidgetTester tester, String label) async {
  await tester.tap(_chip(label));
  await tester.pump();
}

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.enterText(
    find.descendant(of: _fieldNamed(label), matching: find.byType(TextField)),
    text,
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('validation timing', () {
    testWidgets('shows nothing before the first submit', (tester) async {
      await _pump(tester);
      await _type(tester, 'Email address', 'a');
      // Validating from empty would tell a parent their email is invalid while
      // they are still typing the first letter of it.
      expect(find.text('Enter a valid email address.'), findsNothing);
      expect(find.textContaining('at least'), findsNothing);
    });

    testWidgets('surfaces both field errors on submit', (tester) async {
      // Sign UP, because the length rule only applies to a password being
      // created. See the sign-in regression test below.
      await _pump(tester, mode: AuthMode.signUp);
      await _type(tester, 'Email address', 'alex.rivera@');
      await _type(tester, 'Password', 'short');
      await _submit(tester);

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
    });

    testWidgets('sign in never rejects a short existing password',
        (tester) async {
      // THE LOCKOUT, 2026-07-19: an 8-character minimum on sign in barred
      // every account created before the rule existed, in their own app, with
      // no recourse. The email stays invalid here so this never reaches the
      // network - the point is only that the PASSWORD draws no complaint.
      await _pump(tester);
      await _type(tester, 'Email address', 'alex.rivera@');
      await _type(tester, 'Password', 'abc');
      await _submit(tester);

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsNothing);
      expect(find.textContaining('at least'), findsNothing);
    });

    testWidgets('switching to sign up applies the minimum again',
        (tester) async {
      await _pump(tester);
      await _type(tester, 'Email address', 'alex.rivera@');
      await _type(tester, 'Password', 'abc');
      await _submit(tester);
      expect(find.textContaining('at least'), findsNothing);

      await _tapChip(tester, 'Sign up');
      await _submit(tester);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
    });

    testWidgets('clears an error as soon as the input becomes valid',
        (tester) async {
      await _pump(tester);
      await _type(tester, 'Email address', 'alex.rivera@');
      await _type(tester, 'Password', 'longenough');
      await _submit(tester);
      expect(find.text('Enter a valid email address.'), findsOneWidget);

      await _type(tester, 'Email address', 'alex.rivera@example.com');
      expect(find.text('Enter a valid email address.'), findsNothing);
    });

    testWidgets('empty fields report what is missing, not what is invalid',
        (tester) async {
      await _pump(tester);
      await _submit(tester);
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });
  });

  group('mode toggle', () {
    testWidgets('sign up adds confirm password and renames the CTA',
        (tester) async {
      await _pump(tester);
      expect(_fieldNamed('Confirm password'), findsNothing);
      expect(find.text('Forgot password?'), findsOneWidget);

      await _tapChip(tester, 'Sign up');

      expect(_fieldNamed('Confirm password'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      // No account exists yet, so there is nothing to recover.
      expect(find.text('Forgot password?'), findsNothing);
    });

    testWidgets('keeps what the parent already typed', (tester) async {
      await _pump(tester);
      await _type(tester, 'Email address', 'alex@example.com');
      await _tapChip(tester, 'Sign up');
      // Wiping the form on toggle would punish someone who tapped the wrong
      // chip first, which is the common case.
      expect(find.text('alex@example.com'), findsOneWidget);
    });

    testWidgets('toggling clears errors rather than carrying them over',
        (tester) async {
      await _pump(tester);
      await _submit(tester);
      expect(find.text('Enter your email address.'), findsOneWidget);

      await _tapChip(tester, 'Sign up');
      // Switching mode is not a failed attempt; sign up should not open with
      // red text the parent has not earned.
      expect(find.text('Enter your email address.'), findsNothing);
    });

    testWidgets('mismatched passwords block sign up', (tester) async {
      await _pump(tester, mode: AuthMode.signUp);
      await _type(tester, 'Email address', 'alex@example.com');
      await _type(tester, 'Password', 'longenough');
      await _type(tester, 'Confirm password', 'longenoughX');
      // Confirm stays invalid, so this never reaches authManager.
      await _submit(tester);
      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('a stale confirm error cannot survive a switch to sign in',
        (tester) async {
      await _pump(tester, mode: AuthMode.signUp);
      await _type(tester, 'Password', 'longenough');
      await _type(tester, 'Confirm password', 'different');
      await _submit(tester);
      expect(find.text('Passwords do not match.'), findsOneWidget);

      await _tapChip(tester, 'Sign in');
      expect(find.text('Passwords do not match.'), findsNothing);
    });
  });

  group('ground', () {
    testWidgets('renders on ink, so fields are black not sunk grey',
        (tester) async {
      await _pump(tester);
      final container = tester.widget<Container>(
        find
            .descendant(of: _fieldNamed('Email address'), matching: find.byType(Container))
            .first,
      );
      expect((container.decoration! as BoxDecoration).color,
          CiColors.onInk.fieldFill);
    });
  });

  group('password visibility', () {
    testWidgets('Show reveals only its own field', (tester) async {
      await _pump(tester, mode: AuthMode.signUp);
      TextField fieldIn(String label) => tester.widget<TextField>(
            find.descendant(
                of: _fieldNamed(label), matching: find.byType(TextField)),
          );

      expect(fieldIn('Password').obscureText, isTrue);
      expect(fieldIn('Confirm password').obscureText, isTrue);

      await tester.tap(find.text('Show').first);
      await tester.pump();

      expect(fieldIn('Password').obscureText, isFalse);
      // Revealing one must not reveal the other.
      expect(fieldIn('Confirm password').obscureText, isTrue);
    });
  });
}
