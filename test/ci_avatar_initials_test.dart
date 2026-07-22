import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_avatar.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

/// Initials must contrast with the FILL THEY SIT ON. Keying them to `selected`
/// worked only while that flag also decided the fill; the ringed treatment
/// filled sunk ink while still counting as selected, and the initials came out
/// ink-on-ink and vanished.
Future<Color> _initialsColor(
  WidgetTester tester, {
  required Widget avatar,
  required bool onInk,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: onInk
        ? CiSurface.ink(child: Scaffold(body: Center(child: avatar)))
        : Scaffold(body: Center(child: avatar)),
  ));
  return tester.widget<Text>(find.text('MC')).style!.color!;
}

void main() {
  testWidgets('a ringed avatar keeps readable initials on ink', (tester) async {
    final color = await _initialsColor(
      tester,
      onInk: true,
      avatar: CiAvatar(
        name: 'Maya Chen',
        size: 54,
        ringColor: CiColors.onInk.accentGood,
        ringWidth: 2,
      ),
    );
    // White on the sunk-ink fill, not ink-on-ink.
    expect(color, CiColors.onInk.text);
  });

  testWidgets('an unringed selected avatar still inverts', (tester) async {
    // The switcher treatment: a white fill, so the initials go ink.
    final color = await _initialsColor(
      tester,
      onInk: true,
      avatar: const CiAvatar(name: 'Maya Chen', size: 40),
    );
    expect(color, CiColors.onInk.textInvert);
  });

  testWidgets('an unselected avatar reads on the ground', (tester) async {
    final color = await _initialsColor(
      tester,
      onInk: true,
      avatar: const CiAvatar(name: 'Maya Chen', size: 40, selected: false),
    );
    expect(color, CiColors.onInk.text);
  });
}
