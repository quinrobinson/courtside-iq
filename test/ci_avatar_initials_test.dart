import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_avatar.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';

/// Initials must contrast with the FILL THEY SIT ON, per avatar style. The
/// neutral default is a light-grey chip with ink initials on ANY ground; the
/// switcher's filled state inverts; ringed and outlined read the ground.
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

  testWidgets('the neutral default shows ink initials on its grey fill, on any '
      'ground', (tester) async {
    // The app-wide default. Ground-independent: grey chip, ink initials.
    final color = await _initialsColor(
      tester,
      onInk: true,
      avatar: const CiAvatar(name: 'Maya Chen', size: 40),
    );
    expect(color, CiPalette.inkDefault);
  });

  testWidgets('a filled (switcher active) avatar inverts', (tester) async {
    // The switcher treatment: a white fill on ink, so the initials go ink.
    final color = await _initialsColor(
      tester,
      onInk: true,
      avatar: const CiAvatar(
        name: 'Maya Chen',
        size: 40,
        style: CiAvatarStyle.filled,
      ),
    );
    expect(color, CiColors.onInk.textInvert);
  });

  testWidgets('an outlined (switcher inactive) avatar reads the ground',
      (tester) async {
    final color = await _initialsColor(
      tester,
      onInk: true,
      avatar: const CiAvatar(
        name: 'Maya Chen',
        size: 40,
        style: CiAvatarStyle.outlined,
      ),
    );
    expect(color, CiColors.onInk.text);
  });
}
