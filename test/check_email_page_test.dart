import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/auth/check_email_page.dart';

// Nothing here taps Resend: that reaches Supabase, which is not initialised in
// tests. What matters and IS testable is what each purpose says.

Future<void> _pump(WidgetTester tester, CheckEmailPurpose purpose,
        {String email = 'alex.rivera@email.com'}) =>
    tester.pumpWidget(MaterialApp(
      home: CheckEmailPage(purpose: purpose, email: email),
    ));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('signup', () {
    testWidgets('names the address so a typo is catchable', (tester) async {
      // A parent who typed the wrong address otherwise waits on an inbox that
      // will never receive anything.
      await _pump(tester, CheckEmailPurpose.signup);
      expect(find.textContaining('alex.rivera@email.com'), findsOneWidget);
    });

    testWidgets('offers a resend', (tester) async {
      await _pump(tester, CheckEmailPurpose.signup);
      expect(find.text('Resend email'), findsOneWidget);
    });
  });

  group('password reset', () {
    testWidgets('NEVER names the address', (tester) async {
      // SECURITY, not copy preference. Naming it confirms the address is
      // registered, which lets anyone probe which parents have accounts.
      await _pump(tester, CheckEmailPurpose.passwordReset,
          email: 'someone@example.com');
      expect(find.textContaining('someone@example.com'), findsNothing);
    });

    testWidgets('is conditional about whether the account exists',
        (tester) async {
      await _pump(tester, CheckEmailPurpose.passwordReset);
      expect(find.textContaining('If that email has an account'),
          findsOneWidget);
    });

    testWidgets('never asserts an email was sent', (tester) async {
      // "We sent you an email" is the same disclosure by another route.
      await _pump(tester, CheckEmailPurpose.passwordReset);
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');
      expect(texts.contains('We sent a link to'), isFalse,
          reason: 'reset copy must not confirm delivery to a known address');
    });

    testWidgets('states the expiry', (tester) async {
      // A link that silently stops working is indistinguishable from a broken
      // app.
      await _pump(tester, CheckEmailPurpose.passwordReset);
      expect(find.textContaining('expires in one hour'), findsOneWidget);
    });

    testWidgets('offers a resend', (tester) async {
      await _pump(tester, CheckEmailPurpose.passwordReset);
      expect(find.text('Resend link'), findsOneWidget);
    });
  });

  group('shared shape', () {
    testWidgets('both purposes share title, CTA and ink ground',
        (tester) async {
      for (final purpose in CheckEmailPurpose.values) {
        await _pump(tester, purpose);
        expect(find.text('Check your email'), findsOneWidget,
            reason: '$purpose');
        expect(find.text('Back to sign in'), findsOneWidget,
            reason: '$purpose');
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, CiColors.onInk.bg, reason: '$purpose');
      }
    });

    testWidgets('no copy uses an em dash', (tester) async {
      for (final purpose in CheckEmailPurpose.values) {
        await _pump(tester, purpose);
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .join(' ');
        expect(texts.contains('—'), isFalse, reason: '$purpose');
      }
    });
  });
}
