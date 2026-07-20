import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/nav/ci_nav_bar.dart';

Future<void> _pump(WidgetTester tester, CiNavTab active) =>
    tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        bottomNavigationBar: CiNavBar(active: active, onCreate: () {}),
      ),
    ));

Icon _iconFor(WidgetTester tester, String label) => tester.widget<Icon>(
      find.descendant(
        of: find.bySemanticsLabel(label),
        matching: find.byType(Icon),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('structure', () {
    testWidgets('has four tabs plus a create button', (tester) async {
      await _pump(tester, CiNavTab.home);
      for (final label in ['Home', 'Players', 'Games', 'Menu', 'Create']) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('every destination is named for a screen reader',
        (tester) async {
      // The frame shows icons only. An unlabelled icon is unusable with
      // VoiceOver, which is the whole reason the labels exist despite never
      // being drawn.
      await _pump(tester, CiNavTab.home);
      expect(find.bySemanticsLabel('Players'), findsOneWidget);
    });
  });

  group('active state', () {
    testWidgets('the active tab is ink and the rest are muted',
        (tester) async {
      await _pump(tester, CiNavTab.players);
      expect(_iconFor(tester, 'Players').color, CiColors.onLight.text);
      expect(_iconFor(tester, 'Home').color, CiColors.onLight.textMuted);
      expect(_iconFor(tester, 'Games').color, CiColors.onLight.textMuted);
    });

    testWidgets('none active leaves every tab muted', (tester) async {
      // A screen that is not one of the four - the Create sheet's flow, say -
      // must not light up an unrelated tab.
      await _pump(tester, CiNavTab.none);
      for (final label in ['Home', 'Players', 'Games', 'Menu']) {
        expect(_iconFor(tester, label).color, CiColors.onLight.textMuted,
            reason: label);
      }
    });
  });

  group('touch targets', () {
    testWidgets('each tab clears the 44pt minimum', (tester) async {
      // Tapped one-handed, often while watching a game rather than the screen.
      await _pump(tester, CiNavTab.home);
      for (final label in ['Home', 'Players', 'Games', 'Menu']) {
        final size = tester.getSize(find.bySemanticsLabel(label));
        expect(size.width, greaterThanOrEqualTo(44), reason: label);
        expect(size.height, greaterThanOrEqualTo(44), reason: label);
      }
    });
  });

  group('ground', () {
    testWidgets('resolves the LIGHT palette even under an ink screen',
        (tester) async {
      // The bar sits beneath Today, whose hero is ink. It declares its own
      // ground so the icons cannot inherit the wrong one - the same mistake
      // that put black text in the hero's ghost tag.
      await tester.pumpWidget(MaterialApp(
        theme: CiTheme.ink(),
        home: Scaffold(
          bottomNavigationBar: CiNavBar(active: CiNavTab.home, onCreate: () {}),
        ),
      ));
      expect(_iconFor(tester, 'Home').color, CiColors.onLight.text);
    });
  });
}
