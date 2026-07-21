import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/player_averages.dart';
import 'package:courtside_i_q/courtside_iq/players_list_builder.dart';
import 'package:courtside_i_q/features/home/entitlement_status.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';
import 'package:courtside_i_q/features/home/widgets/today_promo_banner.dart';
import 'package:courtside_i_q/features/players/players_list_page.dart';
import 'package:courtside_i_q/features/players/players_repository.dart';

class _FakeRepo implements PlayersRepository {
  const _FakeRepo(this._entries);
  final List<PlayerListEntry> _entries;
  @override
  Future<List<PlayerListEntry>> load() async => _entries;

  // The list never asks for averages or games; the profile does.
  @override
  Future<PlayerAverages> loadAverages(String playerId) async =>
      buildPlayerAverages(const []);

  @override
  Future<List<GameFeedEntry>> loadGames(String playerId) async => const [];
}

PlayerListEntry _entry(String id) => PlayerListEntry(
      playerId: id,
      firstName: 'Player $id',
      totalGames: 10,
      totalPoints: 180,
      totalRebounds: 60,
      totalAssists: 40,
      growthIq: 80,
    );

Future<void> _pump(
  WidgetTester tester, {
  required EntitlementStatus status,
  required int players,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: PlayersListPage(
      repository: _FakeRepo([for (var i = 0; i < players; i++) _entry('$i')]),
      entitlementReader: () async => status,
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('lapse banner', () {
    testWidgets('a lapsed parent keeps their list and gains a banner',
        (tester) async {
      // Their players are not taken away; the banner is the only difference.
      await _pump(tester, status: EntitlementStatus.lapsed, players: 2);
      expect(find.byType(TodayPromoBanner), findsOneWidget);
      expect(find.text('Your Premium has ended'), findsOneWidget);
      expect(find.text('Player 0'), findsOneWidget);
    });

    testWidgets('premium and free-tier lists show no banner', (tester) async {
      for (final s in [EntitlementStatus.premium, EntitlementStatus.never]) {
        await _pump(tester, status: s, players: 1);
        expect(find.byType(TodayPromoBanner), findsNothing, reason: '$s');
      }
    });
  });

  group('add player gating', () {
    testWidgets('free tier at the allowance gets the upgrade gate',
        (tester) async {
      await _pump(tester, status: EntitlementStatus.never, players: 1);
      await tester.tap(find.bySemanticsLabel('Add player'));
      await tester.pumpAndSettle();

      expect(find.text('Track more players'), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
    });

    testWidgets('premium at the cap is NOT sold to', (tester) async {
      // Offering premium to someone who already pays would be insulting.
      await _pump(tester, status: EntitlementStatus.premium, players: 3);
      await tester.tap(find.bySemanticsLabel('Add player'));
      await tester.pumpAndSettle();

      expect(find.text("You've reached 3 players"), findsOneWidget);
      expect(find.text('Manage players'), findsOneWidget);
      expect(find.text('See plans'), findsNothing);
    });

    // The ALLOWED path is deliberately not tested here: it opens the real
    // AddPlayerSheet, which reaches Supabase in initState. The decision itself
    // is covered by addPlayerAction in player_gating_test.dart, which is the
    // part that can be wrong. Asserting the sheet opens would only be testing
    // Flutter.
  });
}
