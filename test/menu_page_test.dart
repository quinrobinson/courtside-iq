// Menu — Phase 4.15a
//
// The subscription row is the one worth guarding: it reports what a parent is
// paying for, and getting it wrong in either direction is a support email.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/home/entitlement_status.dart';
import 'package:courtside_i_q/features/menu/menu_page.dart';

Future<void> _pump(
  WidgetTester tester, {
  EntitlementStatus status = EntitlementStatus.never,
  Future<void> Function()? onSignOut,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: MenuPage(
      entitlementReader: () async => status,
      onSignOut: onSignOut,
      versionLabel: 'Courtside IQ · v2.0',
    ),
  ));
  if (settle) await tester.pumpAndSettle();
}

void main() {
  testWidgets('carries every row the frame draws', (tester) async {
    await _pump(tester);
    for (final row in const [
      'Subscription',
      'Help Center',
      'Send Feedback',
      'Terms of Service',
      'Privacy Policy',
      'Log out',
    ]) {
      expect(find.text(row), findsOneWidget, reason: '$row is missing');
    }
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('SUPPORT'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
  });

  group('the subscription row', () {
    testWidgets('says Free for someone who never subscribed', (tester) async {
      await _pump(tester, status: EntitlementStatus.never);
      expect(find.text('Free'), findsOneWidget);
    });

    testWidgets('says Premium for a subscriber', (tester) async {
      await _pump(tester, status: EntitlementStatus.premium);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Free'), findsNothing);
    });

    testWidgets('says Expired rather than Free after a lapse', (tester) async {
      // "Free" would read as a plan they chose. Expired says what happened.
      await _pump(tester, status: EntitlementStatus.lapsed);
      expect(find.text('Expired'), findsOneWidget);
    });

    testWidgets('shows NOTHING until the plan is known', (tester) async {
      // Flashing "Free" at a paying subscriber for half a second is the kind
      // of thing that gets a support email.
      await _pump(tester, status: EntitlementStatus.premium, settle: false);
      await tester.pump();
      expect(find.text('Free'), findsNothing);
      expect(find.text('Subscription'), findsOneWidget);
    });
  });

  group('logging out', () {
    testWidgets('asks first', (tester) async {
      var signedOut = false;
      await _pump(tester, onSignOut: () async => signedOut = true);

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(signedOut, isFalse, reason: 'not until confirmed');
    });

    testWidgets('cancelling stays signed in', (tester) async {
      var signedOut = false;
      await _pump(tester, onSignOut: () async => signedOut = true);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(signedOut, isFalse);
    });

    testWidgets('confirming signs out', (tester) async {
      var signedOut = false;
      await _pump(tester, onSignOut: () async => signedOut = true);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      // The confirm button, not the row that opened the dialog.
      await tester.tap(find.text('Log out').last);
      await tester.pumpAndSettle();
      expect(signedOut, isTrue);
    });
  });
}
