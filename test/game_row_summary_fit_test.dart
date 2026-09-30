// Game row summary fit — Quin, 2026-09-30
//
// The row's insight summary must fit TWO lines without clipping. The limit is
// a character count (kSummaryMaxChars), which is only a promise if the real
// font at the real width honours it. So this loads Hanken Grotesk itself -
// the test default (Ahem) draws every glyph as a full square and would prove
// nothing - and lays the actual row out at 360pt, the narrowest phone the
// app is checked against (see narrow_screen_test.dart), with the avatar and a
// two-digit lead taking their usual width.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/game_detail_builder.dart';
import 'package:courtside_i_q/courtside_iq/game_row_meaning.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';

Future<void> _loadHanken() async {
  final loader = FontLoader('HankenGrotesk');
  for (final w in [300, 400, 500, 600, 700]) {
    final bytes = File('assets/fonts/HankenGrotesk-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadHanken);

  // Quin's examples, plus wide lines at the full limit.
  final samples = [
    'Scoring efficiency was really impressive this game',
    'Showed good activity on the court with 7 points',
    'Made efficient use of her chances with 18 points',
    'Made smart moves with well-timed swings, 4 of 4 FTs',
    'Worked the glass hard with 11 rebounds, won inside',
  ];

  for (final showPlayer in [true, false]) {
    for (final s in samples) {
      testWidgets(
          '${showPlayer ? "Today/Games" : "profile"} row fits "$s" in two '
          'lines at 360pt', (tester) async {
        expect(s.length, lessThanOrEqualTo(kSummaryMaxChars));
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(MaterialApp(
          theme: CiTheme.base(),
          home: Scaffold(
            body: GameFeedRow(
              showPlayer: showPlayer,
              entry: GameFeedEntry(
                gameId: 'g',
                playerName: 'Maya Chen',
                opponent: 'Northside Hawks',
                playedAt: DateTime(2026, 3, 8),
                points: 38,
                rebounds: 7,
                assists: 5,
                steals: 3,
                turnovers: 2,
                fgAttempt: 14,
                insight: GameInsight(text: 'Long insight.', summary: s),
              ),
            ),
          ),
        ));

        final para = tester.renderObject<RenderParagraph>(find.text(s));
        expect(para.didExceedMaxLines, isFalse, reason: 'clipped: $s');
        // 18pt per line: two lines at most.
        expect(para.size.height, lessThanOrEqualTo(36.5), reason: s);
      });
    }
  }
}
