import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_logo_mark.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_burst.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/onboarding/onboarding_page.dart';
import 'package:courtside_i_q/features/onboarding/splash_view.dart';

Future<void> _pump(WidgetTester tester) =>
    tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('slides', () {
    test('there are three, not the four v1 shipped', () {
      // Not a port. The 2.0 file has three slides; v1 ran a four-page
      // PageView. Carrying the fourth over would invent content.
      expect(kOnboardingSlides.length, 3);
    });

    test('every slide has copy and an asset path', () {
      for (final s in kOnboardingSlides) {
        expect(s.title, isNotEmpty);
        expect(s.body, isNotEmpty);
        expect(s.image, startsWith('assets/images/onboarding/'));
      }
    });

    test('no copy uses an em dash', () {
      for (final s in kOnboardingSlides) {
        expect(s.title, isNot(contains('—')));
        expect(s.body, isNot(contains('—')));
      }
    });

    testWidgets('opens on the first slide', (tester) async {
      await _pump(tester);
      expect(find.text('More than a stat tracker'), findsOneWidget);
      expect(find.text('Insights, not box scores'), findsNothing);
    });

    testWidgets('swiping advances to the next slide', (tester) async {
      await _pump(tester);
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Insights, not box scores'), findsOneWidget);
    });
  });

  group('page indicator', () {
    // Shape carries position, not colour alone, so it survives a glance and
    // does not depend on colour perception.
    double widthOfDot(WidgetTester tester, int i) => tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer).at(i))
        .constraints!
        .maxWidth;

    testWidgets('the active page is a wider pill than the rest',
        (tester) async {
      await _pump(tester);
      final active = widthOfDot(tester, 0);
      final inactive = widthOfDot(tester, 1);
      expect(active, greaterThan(inactive));
      expect(inactive, 6);
    });

    testWidgets('the pill follows the page', (tester) async {
      await _pump(tester);
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(widthOfDot(tester, 1), greaterThan(widthOfDot(tester, 0)));
    });

    testWidgets('announces position to a screen reader', (tester) async {
      await _pump(tester);
      expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);
    });
  });

  group('exits', () {
    testWidgets('Skip and Get Started are both present on every slide',
        (tester) async {
      // Onboarding is not a gate. A parent who already knows what the app does
      // should not have to page through three slides to reach sign-in.
      await _pump(tester);
      for (var i = 0; i < 3; i++) {
        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
        // Rich text: "Sign in" is a TextSpan, not a Text widget of its own.
        expect(find.textContaining('Already have an account'), findsOneWidget);
        if (i < 2) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('the sign-in footer is reachable by a screen reader',
        (tester) async {
      await _pump(tester);
      // The label matches the visible words: a screen reader user and a
      // sighted user should get the same thing.
      expect(find.bySemanticsLabel('Already have an account? Sign in'),
          findsOneWidget);
    });

    testWidgets('Get Started is the lime CTA', (tester) async {
      await _pump(tester);
      final button = tester.widget<CiButton>(find.byType(CiButton));
      expect(button.style, CiButtonStyle.lime);
      expect(button.expand, isTrue);
    });
  });

  group('SplashView', () {
    testWidgets('is painted, with no image asset to stretch', (tester) async {
      // It replaces a fixed bitmap drawn with BoxFit.cover, which distorted on
      // any aspect ratio it was not drawn for.
      await tester.pumpWidget(const MaterialApp(home: SplashView()));
      expect(find.byType(Image), findsNothing);
      expect(find.byType(DotBurst), findsOneWidget);
      expect(find.byType(CiLogoMark), findsOneWidget);
    });

    testWidgets('sizes the burst to the screen width', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashView()));
      final width = tester.getSize(find.byType(SplashView)).width;
      expect(tester.getSize(find.byType(DotBurst)).width, width);
    });

    testWidgets('names its ground rather than inheriting one', (tester) async {
      // It renders inside the router, above any CiSurface, so an inherited
      // palette would be whatever happened to be in scope.
      await tester.pumpWidget(const MaterialApp(home: SplashView()));
      final box = tester.widget<ColoredBox>(
        find.descendant(
            of: find.byType(SplashView), matching: find.byType(ColoredBox)).first,
      );
      expect(box.color, CiColors.onInk.bg);
    });
  });
}
