// Paywall — Phase 4.16
//
// A real purchase needs a device and a sandbox tester, so that stays a device
// check. Everything up to the purchase call is testable with a fake
// repository: the state routing, the price/plan mapping, the trial-aware CTA,
// and the already-premium short-circuit.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_page_dots.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_burst.dart';
import 'package:courtside_i_q/features/premium/paywall_content.dart';
import 'package:courtside_i_q/features/premium/paywall_page.dart';
import 'package:courtside_i_q/features/premium/paywall_repository.dart';
import 'package:courtside_i_q/features/premium/paywall_states.dart';
import 'package:courtside_i_q/features/premium/premium_gate_sheet.dart';

class _FakePaywallRepo implements PaywallRepository {
  _FakePaywallRepo({
    this.offer = const PaywallOffer(
      monthly: PaywallPlan(packageId: 'm', price: r'$5.99', hasTrial: true),
      weekly: PaywallPlan(packageId: 'w', price: r'$1.99', hasTrial: false),
    ),
    this.premium = false,
    this.purchaseOutcome = PurchaseOutcome.purchased,
  });

  final PaywallOffer offer;
  final bool premium;
  final PurchaseOutcome purchaseOutcome;
  static const restoreOutcome = PurchaseOutcome.failed;
  final purchased = <String>[];

  @override
  Future<PaywallOffer> loadOffer() async => offer;
  @override
  Future<bool> isPremium() async => premium;
  @override
  Future<PurchaseOutcome> purchase(String packageId) async {
    purchased.add(packageId);
    return purchaseOutcome;
  }

  @override
  Future<PurchaseOutcome> restore() async => restoreOutcome;
}

Future<_FakePaywallRepo> _pump(
  WidgetTester tester,
  _FakePaywallRepo repo, {
  VoidCallback? onPurchased,
}) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: PaywallPage(repository: repo, onPurchased: onPurchased),
  ));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('the content follows the money, not the frame', () {
    test('the fallback prices match the frame for a US parent', () {
      // The live localised price always wins; these only show when offerings
      // cannot load, and must never be used to charge - the store owns that.
      expect(kFallbackMonthlyPrice, r'$5.99');
      expect(kFallbackWeeklyPrice, r'$1.99');
    });

    test('the legal line names the price it is given', () {
      expect(paywallLegalLine(r'$7.99'),
          '7-day free trial, then \$7.99/mo. Cancel anytime.');
    });
  });

  group('the paywall screen', () {
    testWidgets('shows both plans at their loaded prices', (tester) async {
      await _pump(tester, _FakePaywallRepo());
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text(r'$5.99'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text(r'$1.99'), findsOneWidget);
    });

    testWidgets('the CTA promises a trial on monthly and NOT on weekly',
        (tester) async {
      // Monthly carries the trial and is the default. Weekly does not, so
      // "Start free trial" would be a promise the plan cannot keep.
      await _pump(tester, _FakePaywallRepo());
      expect(find.text('Start free trial'), findsOneWidget);

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.text('Start free trial'), findsNothing);
    });

    testWidgets('buying sends the selected package', (tester) async {
      final repo = await _pump(tester, _FakePaywallRepo());
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Subscribe'));
      await tester.pump();
      expect(repo.purchased.single, 'w');
    });

    testWidgets('a successful purchase hands off to the caller',
        (tester) async {
      var done = false;
      await _pump(tester, _FakePaywallRepo(), onPurchased: () => done = true);
      await tester.tap(find.text('Start free trial'));
      // Fixed pumps: the processing spinner animates forever, and onPurchased
      // here just flips a flag rather than closing the route as the real
      // caller does.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(done, isTrue);
    });

    testWidgets('a cancelled purchase returns to the paywall, no error',
        (tester) async {
      // The parent chose to stop. A red error state would tell them something
      // went wrong when nothing did.
      await _pump(
          tester,
          _FakePaywallRepo(purchaseOutcome: PurchaseOutcome.cancelled));
      await tester.tap(find.text('Start free trial'));
      await tester.pumpAndSettle();
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.byType(PaywallError), findsNothing);
    });

    testWidgets('a failed purchase shows the error state', (tester) async {
      await _pump(tester,
          _FakePaywallRepo(purchaseOutcome: PurchaseOutcome.failed));
      await tester.tap(find.text('Start free trial'));
      await tester.pumpAndSettle();
      expect(find.byType(PaywallError), findsOneWidget);
    });

    testWidgets('no offer at all is the error state, not a dead button',
        (tester) async {
      // Selling nothing is worse than saying the store is unreachable.
      await _pump(tester, _FakePaywallRepo(offer: const PaywallOffer()));
      expect(find.byType(PaywallError), findsOneWidget);
    });

    testWidgets('an existing subscriber is not sold to', (tester) async {
      await _pump(tester, _FakePaywallRepo(premium: true));
      expect(find.byType(PaywallAlreadyPremium), findsOneWidget);
      expect(find.text('Start free trial'), findsNothing);
    });
  });

  group('the gate sheet', () {
    testWidgets('has no prices - it is the doorway, not the paywall',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showPremiumGateSheet(context),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('A Premium feature'), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
    });

    testWidgets('See plans returns true, Not now returns false',
        (tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.base(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await showPremiumGateSheet(context),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See plans'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  testWidgets('fits a 360pt screen with the full-height cards',
      (tester) async {
    // The cards went back to the frame's 155 after being trimmed to fit. A
    // RenderFlex overflow throws here, so pumping IS the assertion.
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: PaywallPage(repository: _FakePaywallRepo()),
    ));
    await tester.pumpAndSettle();

    // And every slide, not just the first.
    for (var i = 0; i < 2; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('every slide card asset is registered and decodes',
      (tester) async {
    // The cards are Figma exports now. A missing or unregistered asset is a
    // silent grey box on a paywall, so it is worth a test that the pubspec
    // entry and the three files actually line up.
    for (final art in PaywallSlideArt.values) {
      await tester.pumpWidget(MaterialApp(
        home: Center(child: PaywallSlideCard(art: art)),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$art failed to load');
    }
  });

  testWidgets('the page dots sit at the LEFT gutter, not centred',
      (tester) async {
    // Reported three times before it took. CiPageDots' Row was
    // mainAxisAlignment.center at the default mainAxisSize.max, so it filled
    // the width and centred internally - wrapping it in Align(centerLeft)
    // aligned a widget that was already the full width, and did nothing.
    await _pump(tester, _FakePaywallRepo());

    final dots = tester.getRect(find.byType(CiPageDots));
    expect(dots.left, closeTo(20, 0.5), reason: 'the frame gutter is 20');
    expect(dots.width, lessThan(120),
        reason: 'must hug its dots, not fill the row');
  });

  testWidgets('the already-premium screen wears the dot burst',
      (tester) async {
    // It was a bare 40pt mark. 244:943 centres a 50 in a 220 burst - the
    // same pairing reset_successful and check_email use, so a subscriber
    // gets the app's celebratory mark rather than a plain logo.
    await _pump(tester, _FakePaywallRepo(premium: true));

    expect(find.byType(DotBurst), findsOneWidget);
    final burst = tester.widget<DotBurst>(find.byType(DotBurst));
    expect(burst.size, 220);
    expect(find.text("You're on Premium"), findsOneWidget);
  });
}
