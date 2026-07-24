import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_logo_mark.dart';
import 'package:courtside_i_q/courtside_iq/design/components/dot_burst.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/auth/auth_landing_page.dart';

// Nothing here taps a sign-in button: those call the real authManager against
// Supabase. What is testable without a device is which controls EXIST, which
// is exactly where the platform bug would live.

Future<void> _pump(WidgetTester tester, {bool? isAndroid}) =>
    tester.pumpWidget(MaterialApp(
      home: AuthLandingPage(isAndroidOverride: isAndroid),
    ));

Finder _button(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(CiButton),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('platform', () {
    testWidgets('Apple is absent on Android, not merely disabled',
        (tester) async {
      // v1 renders an empty Container in its place. Apple sign-in on Android
      // is a dead end, and a DISABLED button still says "this exists for you"
      // to someone who can never use it.
      await _pump(tester, isAndroid: true);
      expect(_button('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Apple'), findsNothing);
    });

    testWidgets('Apple is present on iOS', (tester) async {
      await _pump(tester, isAndroid: false);
      expect(_button('Continue with Apple'), findsOneWidget);
    });

    testWidgets('Google and Email are on both platforms', (tester) async {
      for (final android in [true, false]) {
        await _pump(tester, isAndroid: android);
        expect(_button('Continue with Google'), findsOneWidget,
            reason: 'isAndroid=$android');
        expect(_button('Continue with Email'), findsOneWidget,
            reason: 'isAndroid=$android');
      }
    });
  });

  group('composition', () {
    testWidgets('every action button spans the width', (tester) async {
      // These read as a stack of equal choices. A hugging button would break
      // the column and make one option look secondary.
      await _pump(tester, isAndroid: false);
      final width = tester.getSize(find.byType(AuthLandingPage)).width;
      for (final label in [
        'Continue with Apple',
        'Continue with Google',
        'Continue with Email',
      ]) {
        final w = tester.getSize(_button(label)).width;
        expect(w, greaterThan(width - 80), reason: '$label was $w');
      }
    });

    testWidgets('Email is the lime CTA; OAuth buttons are not', (tester) async {
      await _pump(tester, isAndroid: false);
      CiButtonStyle styleOf(String label) =>
          tester.widget<CiButton>(_button(label)).style;

      expect(styleOf('Continue with Email'), CiButtonStyle.lime);
      expect(styleOf('Continue with Google'), CiButtonStyle.primary);
      expect(styleOf('Continue with Apple'), CiButtonStyle.primary);
    });

    testWidgets('renders the heading, subhead and divider', (tester) async {
      await _pump(tester, isAndroid: false);
      expect(find.text('Get started'), findsOneWidget);
      expect(
          find.text("Track your player's development, game by game."),
          findsOneWidget);
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('sits on ink ground', (tester) async {
      await _pump(tester, isAndroid: false);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, CiColors.onInk.bg);
    });
  });

  group('legal links', () {
    testWidgets('both are present and tappable', (tester) async {
      // An app store review looks for these. Losing the recognizer turns them
      // into decorative text that still LOOKS like a link.
      await _pump(tester, isAndroid: false);

      final richText = tester.widget<RichText>(
        find
            .descendant(
                of: find.byType(Text), matching: find.byType(RichText))
            .last,
      );

      final spans = <InlineSpan>[];
      richText.text.visitChildren((s) {
        spans.add(s);
        return true;
      });

      TextSpan spanFor(String text) => spans
          .whereType<TextSpan>()
          .firstWhere((s) => s.text == text,
              orElse: () => throw StateError('no span for "$text"'));

      expect(spanFor('Terms of Service').recognizer, isNotNull);
      expect(spanFor('Privacy Policy').recognizer, isNotNull);
    });

    test('destinations match the ones v1 shipped', () {
      // Changing these silently would point users at the wrong policy.
      expect(kTermsUrl,
          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
      expect(kPrivacyUrl, 'https://www.courtsideiq.app/policy');
    });
  });

  group('logo mark', () {
    testWidgets('takes the ground colour instead of being a black asset',
        (tester) async {
      // logo-mark.png is solid black, so on ink ground it vanished into the
      // background. The mark reads the ground instead.
      //
      // Asserts the CONTRACT (colour is inherited, and the mark is tintable),
      // not the drawing mechanism - it moved from a CustomPainter to a tinted
      // SVG in 4.19e and the guarantee is what matters, not how it is painted.
      await _pump(tester, isAndroid: false);
      final mark = tester.widget<CiLogoMark>(find.byType(CiLogoMark));
      expect(mark.color, isNull, reason: 'should inherit, not hardcode');

      final svg = tester.widget<SvgPicture>(
        find.descendant(
            of: find.byType(CiLogoMark), matching: find.byType(SvgPicture)),
      );
      expect(svg.colorFilter, isNotNull,
          reason: 'must be tinted, or it renders as the flat asset colour');
    });

    testWidgets('burst matches the frame and the mark is the tuned size',
        (tester) async {
      // The burst shipped at 300 first and read as oversized; the frame is
      // 220. The mark is 54, up from the frame's 44, because at 44 it looked
      // lost inside the burst on device.
      await _pump(tester, isAndroid: false);
      expect(tester.getSize(find.byType(CiLogoMark)).width, 50);
      expect(tester.getSize(find.byType(DotBurst)).width, 220);
    });
  });
}
