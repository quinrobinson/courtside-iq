import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/auth/forgot_password_page.dart';
import 'package:courtside_i_q/features/auth/reset_password_page.dart';

// Screen behaviour only. Neither page is submitted with valid input: both call
// custom actions that reach Supabase, which is not initialised in tests.

Finder _fieldNamed(String label) => find.ancestor(
      of: find.text(label.toUpperCase()),
      matching: find.byType(CiField),
    );

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.enterText(
    find.descendant(of: _fieldNamed(label), matching: find.byType(TextField)),
    text,
  );
  await tester.pump();
}

CiButton _cta(WidgetTester tester) =>
    tester.widget<CiButton>(find.byType(CiButton));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ForgotPasswordPage', () {
    testWidgets('the action is disabled until an email is typed',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(_cta(tester).onPressed, isNull);

      await _type(tester, 'Email address', 'alex@example.com');
      expect(_cta(tester).onPressed, isNotNull);
    });

    testWidgets('whitespace alone does not enable it', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      await _type(tester, 'Email address', '   ');
      expect(_cta(tester).onPressed, isNull);
    });

    testWidgets('renders the frame copy and the sign-in link', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);
      expect(find.text('Back to sign in'), findsOneWidget);
    });

    test('the recovery redirect is the deep link, not the hosted page', () {
      // Where this points decides whether a parent can get back into their
      // account. It must be the custom scheme registered in Info.plist and
      // AndroidManifest, or the link opens a browser and recovery dead-ends.
      expect(kPasswordResetRedirect, 'courtsideiq://reset-password');
      expect(kPasswordResetRedirect, startsWith('courtsideiq://'));
    });

    test('the retired URL is recorded, since it must stay alive a while', () {
      // Emails already sent still point here, and older installs still send
      // it. The page cannot be switched off the day the deep link ships.
      expect(kLegacyPasswordResetRedirect,
          'https://courtside-iq.flutterflow.app/resetPassword');
    });
  });

  group('ResetPasswordPage', () {
    Finder _helperUnder(String label) => find.descendant(
          of: _fieldNamed(label),
          matching: find.text('Use at least 8 characters.'),
        );

    testWidgets('states the length rule under the field it governs',
        (tester) async {
      // The frame puts this under CONFIRM PASSWORD, but the rule is enforced
      // on NEW PASSWORD. Split across two fields, a parent reads the rule in
      // one place and sees it violated in another.
      await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));
      expect(_helperUnder('New password'), findsOneWidget);
      expect(_helperUnder('Confirm password'), findsNothing);
    });

    testWidgets('an error replaces the helper rather than stacking under it',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));
      await _type(tester, 'New password', 'short');
      await _type(tester, 'Confirm password', 'different');
      await tester.tap(find.byType(CiButton));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      // The helper's slot now holds the error for that same field, not both.
      final newPasswordTexts = find.descendant(
        of: _fieldNamed('New password'),
        matching: find.text('Use at least 8 characters.'),
      );
      expect(newPasswordTexts, findsOneWidget,
          reason: 'shown as the ERROR, having replaced the helper');
    });

    testWidgets('enforces the minimum, because this password is being created',
        (tester) async {
      // The mirror of the sign-in rule: sign in must NOT enforce a length,
      // this screen must.
      await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));
      await _type(tester, 'New password', 'short');
      await _type(tester, 'Confirm password', 'short');
      await tester.tap(find.byType(CiButton));
      await tester.pump();
      expect(find.text('Use at least 8 characters.'), findsWidgets);
    });

    testWidgets('reveals each password field independently', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));
      TextField fieldIn(String label) => tester.widget<TextField>(
            find.descendant(
                of: _fieldNamed(label), matching: find.byType(TextField)),
          );

      expect(fieldIn('New password').obscureText, isTrue);
      await tester.tap(find.text('Show').first);
      await tester.pump();
      expect(fieldIn('New password').obscureText, isFalse);
      expect(fieldIn('Confirm password').obscureText, isTrue);
    });

    testWidgets('sits on ink ground', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, CiColors.onInk.bg);
    });
  });
}
