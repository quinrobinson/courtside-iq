// Menu — Phase 4.15a
//
// The subscription row is the one worth guarding: it reports what a parent is
// paying for, and getting it wrong in either direction is a support email.

import 'dart:async';

import 'package:flutter/foundation.dart';
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
      versionReader: () async => 'Courtside IQ · v2.0.0 (Build 250)',
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

  group('the terms link', () {
    // Apple requires its standard EULA or your own; v1 uses Apple's. Google
    // has no equivalent, so a Play Store user sent to Apple's licence is
    // reading terms that do not govern their copy of the app.
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('iOS gets Apple\'s standard EULA', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(termsUrl, kAppleEulaUrl);
    });

    test('Android gets Courtside IQ\'s own terms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(termsUrl, kAndroidTermsUrl);
      expect(termsUrl, isNot(contains('apple.com')));
    });
  });

  testWidgets('the version line waits for the bundle rather than guessing',
      (tester) async {
    // Read from the bundle now, not kept in step with pubspec by hand. While
    // that read is in flight the line is ABSENT - a placeholder version is
    // exactly the stale string this change existed to remove.
    final bundle = Completer<String>();
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: MenuPage(
        entitlementReader: () async => EntitlementStatus.never,
        versionReader: () => bundle.future,
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Build'), findsNothing);

    bundle.complete('Courtside IQ · v2.0.0 (Build 250)');
    await tester.pumpAndSettle();
    expect(find.text('Courtside IQ · v2.0.0 (Build 250)'), findsOneWidget);
  });

  testWidgets('a bundle read that fails costs the line, not the screen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: MenuPage(
        entitlementReader: () async => EntitlementStatus.never,
        versionReader: () async => throw StateError('no bundle'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Log out'), findsOneWidget);
    expect(find.textContaining('Build'), findsNothing);
  });
}
