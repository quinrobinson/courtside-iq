import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/today_snapshot.dart';
import 'package:courtside_i_q/features/home/today_repository.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';

// The page itself pulls in the v1 nav bar and the router, so these cover the
// pieces that carry the decisions: the feed row's copy handling and the
// repository's shape. The page composition is verified on device.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameFeedEntry subtitle', () {
    GameFeedEntry entry({String? opponent, DateTime? at}) => GameFeedEntry(
          gameId: 'g1',
          playerName: 'Maya Chen',
          opponent: opponent,
          playedAt: at,
          points: 22,
          rebounds: 7,
          assists: 5,
          steals: 3,
          turnovers: 2,
        );

    test('joins opponent and date with a single separator', () {
      // Asserts the JOINING, not a weekday: hard-coding one encodes a calendar
      // lookup into the test, and the frame's "Sat, Mar 8" is mock copy for a
      // date that is actually a Sunday.
      final s = entry(opponent: 'Northside Hawks', at: DateTime(2026, 3, 8))
          .subtitle;
      expect(s, startsWith('vs Northside Hawks  ·  '));
      expect(s, endsWith('Mar 8'));
      // House rule: at most one middle dot per line.
      expect('·'.allMatches(s).length, 1);
    });

    test('drops the separator when the opponent is missing', () {
      // A game logged in a hurry has no opponent, and the row must not read
      // "vs   ·  Sat, Mar 8" or leave a dangling separator.
      final s = entry(at: DateTime(2026, 3, 8)).subtitle;
      expect(s, endsWith('Mar 8'));
      expect(s, isNot(contains('·')));
      expect(s, isNot(contains('vs')));
    });

    test('drops the separator when the date is missing', () {
      final s = entry(opponent: 'Northside Hawks').subtitle;
      expect(s, 'vs Northside Hawks');
      expect(s, isNot(contains('·')));
    });

    test('is empty when both are missing, so nothing renders', () {
      expect(entry().subtitle, isEmpty);
    });

    test('treats a blank opponent as missing', () {
      final s = entry(opponent: '   ', at: DateTime(2026, 3, 8)).subtitle;
      expect(s, endsWith('Mar 8'));
      expect(s, isNot(contains('vs')));
    });
  });

  group('GameFeedRow', () {
    Future<void> pump(WidgetTester tester, GameFeedEntry e) =>
        tester.pumpWidget(MaterialApp(
          theme: CiTheme.base(),
          home: Scaffold(body: GameFeedRow(entry: e)),
        ));

    testWidgets('shows all five stat columns', (tester) async {
      await pump(
        tester,
        const GameFeedEntry(
          gameId: 'g1',
          playerName: 'Maya Chen',
          points: 22,
          rebounds: 7,
          assists: 5,
          steals: 3,
          turnovers: 2,
        ),
      );
      for (final label in ['PTS', 'REB', 'AST', 'STL', 'TO']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('22'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('renders a zero stat rather than hiding it', (tester) async {
      // A zero here is a real result from a real game, unlike a missing
      // average with no games behind it.
      await pump(
        tester,
        const GameFeedEntry(
          gameId: 'g1',
          playerName: 'Maya Chen',
          points: 0,
          rebounds: 0,
          assists: 0,
          steals: 0,
          turnovers: 0,
        ),
      );
      expect(find.text('0'), findsNWidgets(5));
    });
  });

  group('TodayData', () {
    test('distinguishes no players from players without games', () {
      // Different screens. Conflating them would show "Add your first player"
      // to someone who already has one.
      const noPlayers =
          TodayData(headerPlayers: [], recentGames: [], playerCount: 0);
      const noGames =
          TodayData(headerPlayers: [], recentGames: [], playerCount: 2);

      expect(noPlayers.hasNoPlayers, isTrue);
      expect(noGames.hasNoPlayers, isFalse);
      // Both have an empty header, and that is expected.
      expect(noGames.headerPlayers, isEmpty);
    });

    test('the recent games cap is five, raised from production three', () {
      expect(kTodayRecentGamesLimit, 5);
    });
  });
}
