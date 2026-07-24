import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_logo_mark.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_burst.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_metrics.dart';
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

  group('slide composition', () {
    testWidgets('the capture fades into the dark ground with an ink overlay',
        (tester) async {
      // Matches the Figma frames (ScreenMockup/fade): the fade is an INK
      // gradient painted OVER the capture, not a transparency mask. It must end
      // FULLY OPAQUE so the capture blends into the dark ground and the ambient
      // glow behind stays hidden beneath it - a transparency mask would instead
      // let the glow bleed through the capture's lower edge. It must also start
      // clear and begin low, leaving most of the capture visible.
      await _pump(tester);

      final fades = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .map((b) => b.gradient)
          .whereType<LinearGradient>()
          .where((g) =>
              g.begin == Alignment.topCenter && g.end == Alignment.bottomCenter)
          .toList();

      expect(fades, isNotEmpty, reason: 'the ink fade gradient is missing');
      final fade = fades.first;
      // Clear at the top, fully opaque at the base: blends to ink, not to
      // nothing.
      expect(fade.colors.first.a, closeTo(0, 0.001));
      expect(fade.colors.last.a, closeTo(1, 0.001));
      // Begins low - the fade should not eat the top half of the capture.
      expect(fade.stops!.first, 0);
      expect(fade.stops![1], greaterThan(0.5));
    });

    testWidgets('spacing comes off the scale, not from nudging',
        (tester) async {
      await _pump(tester);
      // Childless SizedBoxes only: those are spacers. A SizedBox WITH a child
      // is a component sizing itself, not a gap in this layout.
      final gaps = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.child == null)
          .map((b) => b.height)
          .whereType<double>()
          .where((h) => h > 0)
          .toSet();
      // Not a const Set: doubles have no primitive equality.
      final scale = <double>[
        CiSpace.s1, CiSpace.s2, CiSpace.s3, CiSpace.s4,
        CiSpace.s5, CiSpace.s6, CiSpace.s7, CiSpace.s8,
      ];
      for (final g in gaps) {
        expect(scale.contains(g), isTrue, reason: '$g is not on the scale');
      }
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
