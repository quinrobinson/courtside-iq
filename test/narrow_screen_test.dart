// Narrow-screen layout — Phase 4.14
//
// 360pt, the width of a large share of Android phones and NARROWER THAN ANY
// DEVICE THIS APP HAS BEEN VERIFIED ON. Both headers here put five stat
// columns beside an outsized points figure, and both overflowed - the tracker
// by 62px on ordinary stats, shipped and signed off a day earlier, because
// the phone it was checked on is wider.
//
// A RenderFlex overflow throws in tests and paints a striped bar in release,
// so pumping the screen IS the assertion.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/game_detail_builder.dart';
import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/courtside_iq/metrics_config.dart';
import 'package:courtside_i_q/features/games/game_detail_page.dart';
import 'package:courtside_i_q/features/games/game_detail_repository.dart';
import 'package:courtside_i_q/features/games/live_game_store.dart';
import 'package:courtside_i_q/features/games/live_tracker_page.dart';

class _FakeRepo implements GameDetailRepository {
  const _FakeRepo(this.row);
  final GameDetailRow row;
  @override
  Future<GameDetailRow?> load(String gameId) async => row;
  @override
  Future<void> remove(String gameId) async {}
}

void _narrow(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the live tracker header fits at 360pt', (tester) async {
    _narrow(tester);
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: LiveTrackerPage(
        snapshot: LiveGameSnapshot(
          playerId: 'p1',
          playerName: 'Maya',
          opponent: 'Northside Hawks',
          stats: const LiveGameStats(
              twoMade: 8, offReb: 2, defReb: 5, assists: 5,
              steals: 3, blocks: 0, turnovers: 2),
          startedAt: DateTime(2026, 5, 4),
        ),
      ),
    ));
    await tester.pump();
  });

  testWidgets('the live tracker header fits with three-digit stats',
      (tester) async {
    // A whole-tournament tally, or a mis-tap held down. The row must not
    // break on a number the app will happily let a parent enter.
    _narrow(tester);
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: LiveTrackerPage(
        snapshot: LiveGameSnapshot(
          playerId: 'p1',
          playerName: 'Maya',
          stats: const LiveGameStats(
              twoMade: 60, offReb: 12, defReb: 11, assists: 13,
              steals: 14, blocks: 15, turnovers: 16),
          startedAt: DateTime(2026, 5, 4),
        ),
      ),
    ));
    await tester.pump();
  });

  testWidgets('Game Detail fits at 360pt', (tester) async {
    _narrow(tester);
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: GameDetailPage(
        gameId: 'g1',
        repository: _FakeRepo(GameDetailRow(
          gameId: 'g1',
          playerId: 'p1',
          playerName: 'Maya',
          opponent: 'Northside Hawks',
          playedAt: DateTime(2026, 3, 8),
          ageBand: AgeBand.u13,
          points: 122, fgMade: 48, fgAttempt: 94, twoMade: 40,
          threeMade: 8, threeAttempt: 20, ftMade: 10, ftAttempt: 12,
          offReb: 12, defReb: 15, assists: 13, steals: 14, blocks: 11,
          turnovers: 16,
          // The longest eyebrow the app can produce.
          insight: const GameInsight(
              text: 'A strong night.',
              highlightMetric: 'ppsa',
              storedTier: 'Elite'),
        )),
      ),
    ));
    await tester.pumpAndSettle();
  });
}
