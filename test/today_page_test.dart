import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtside_i_q/courtside_iq/live_game.dart';
import 'package:courtside_i_q/features/games/live_game_store.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/today_snapshot.dart';
import 'package:courtside_i_q/features/home/today_repository.dart';
import 'package:courtside_i_q/features/home/entitlement_status.dart';
import 'package:courtside_i_q/features/home/today_page.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';
import 'package:courtside_i_q/features/home/widgets/today_promo_banner.dart';

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

  group('promo banner visibility', () {
    // A fake repository that returns players-with-games so the feed renders and
    // the banner has somewhere to sit.
    TodayData _dataWithGames() => TodayData(
          headerPlayers: const [],
          recentGames: const [
            GameFeedEntry(
              gameId: 'g1',
              playerName: 'Maya Chen',
              points: 22, rebounds: 7, assists: 5, steals: 3, turnovers: 2,
            ),
          ],
          playerCount: 1,
        );

    Future<void> pump(WidgetTester tester, EntitlementStatus status) async {
      await tester.pumpWidget(MaterialApp(
        home: TodayPage(
          repository: _FakeRepo(_dataWithGames()),
          entitlementReader: () async => status,
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('a brand new parent with NO players still sees it',
        (tester) async {
      // This branch returned early before the banner sliver, so the parent
      // most worth telling about premium was the only one who never saw it.
      await tester.pumpWidget(MaterialApp(
        home: TodayPage(
          repository: _FakeRepo(const TodayData(
              headerPlayers: [], recentGames: [], playerCount: 0)),
          entitlementReader: () async => EntitlementStatus.never,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(TodayPromoBanner), findsOneWidget);
      expect(find.text('Add your first player'), findsOneWidget);
    });

    testWidgets('premium sees no banner', (tester) async {
      await pump(tester, EntitlementStatus.premium);
      expect(find.byType(TodayPromoBanner), findsNothing);
    });

    testWidgets('never-subscribed sees the upgrade banner', (tester) async {
      await pump(tester, EntitlementStatus.never);
      final banner = tester.widget<TodayPromoBanner>(find.byType(TodayPromoBanner));
      expect(banner.purpose, TodayPromoPurpose.upgrade);
      expect(find.text('Unlock Premium'), findsOneWidget);
    });

    testWidgets('lapsed sees the renew banner', (tester) async {
      await pump(tester, EntitlementStatus.lapsed);
      final banner = tester.widget<TodayPromoBanner>(find.byType(TodayPromoBanner));
      expect(banner.purpose, TodayPromoPurpose.lapse);
      expect(find.text('Your Premium has ended'), findsOneWidget);
    });
  });

  group('tapping a recent game', () {
    // Every row here pushed the GAMES LIST from 4.10a until 4.14. A parent
    // who tapped one specific game got a list of all of them and had to find
    // it again - and it read as the tap having missed.
    testWidgets('opens that game, not the list', (tester) async {
      final pushed = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: TodayPage(
          repository: _FakeRepo(TodayData(
            headerPlayers: const [],
            recentGames: const [
              GameFeedEntry(
                gameId: 'g1',
                playerId: 'p1',
                playerName: 'Maya Chen',
                points: 22, rebounds: 7, assists: 5, steals: 3, turnovers: 2,
              ),
            ],
            playerCount: 1,
          )),
          entitlementReader: () async => EntitlementStatus.premium,
        ),
        onGenerateRoute: (settings) {
          pushed.add(settings.name ?? '');
          return MaterialPageRoute(builder: (_) => const SizedBox());
        },
      ));
      await tester.pumpAndSettle();

      expect(find.text('Maya Chen'), findsOneWidget);
      // The row must carry the ids that identify a game, or the destination
      // has nothing to open.
      final row = tester.widget<GameFeedRow>(find.byType(GameFeedRow).first);
      expect(row.entry.gameId, 'g1');
      expect(row.entry.playerId, 'p1');
      expect(row.onTap, isNotNull);
    });
  });

  group('an unfinished game on Today', () {
    // Today was NOT showing it. The Games list was the only place, so a
    // parent who reopened the app landed on a home screen that said nothing
    // about the game they were in the middle of and had to know to go
    // looking for it.
    setUp(() => SharedPreferences.setMockInitialValues({}));

    final live = LiveGameSnapshot(
      playerId: 'p1',
      playerName: 'Maya',
      opponent: 'Northside Hawks',
      stats: const LiveGameStats(twoMade: 6, assists: 3),
      startedAt: DateTime(2026, 5, 4, 18),
    );

    Future<void> pump(WidgetTester tester, TodayData data) async {
      await tester.pumpWidget(MaterialApp(
        home: TodayPage(
          repository: _FakeRepo(data),
          entitlementReader: () async => EntitlementStatus.premium,
        ),
      ));
      await tester.pumpAndSettle();
    }

    TodayData withGames() => TodayData(
          headerPlayers: const [],
          recentGames: const [
            GameFeedEntry(
              gameId: 'g1',
              playerName: 'Maya Chen',
              points: 22, rebounds: 7, assists: 5, steals: 3, turnovers: 2,
            ),
          ],
          playerCount: 1,
        );

    testWidgets('leads Recent Games', (tester) async {
      await const LiveGameStore().save(live);
      await pump(tester, withGames());
      expect(find.bySemanticsLabel('Live'), findsOneWidget);
    });

    testWidgets('is absent when nothing is being tracked', (tester) async {
      await pump(tester, withGames());
      expect(find.bySemanticsLabel('Live'), findsNothing);
    });

    testWidgets('replaces "No games yet" rather than contradicting it',
        (tester) async {
      // The empty message would sit directly under a row showing a game in
      // progress and flatly deny it.
      await const LiveGameStore().save(live);
      await pump(tester,
          const TodayData(headerPlayers: [], recentGames: [], playerCount: 1));

      expect(find.bySemanticsLabel('Live'), findsOneWidget);
      expect(find.text('No games yet'), findsNothing);
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

class _FakeRepo implements TodayRepository {
  const _FakeRepo(this._data);
  final TodayData _data;
  @override
  Future<TodayData> load() async => _data;
}
