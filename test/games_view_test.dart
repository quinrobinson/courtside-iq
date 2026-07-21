import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';
import 'package:courtside_i_q/features/players/widgets/games_view.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

GameFeedEntry _game({
  String gameId = 'g1',
  String? opponent = 'Northside Hawks',
  String? eventName,
  DateTime? playedAt,
}) =>
    GameFeedEntry(
      gameId: gameId,
      playerName: '',
      opponent: opponent,
      eventName: eventName,
      playedAt: playedAt ?? DateTime(2026, 3, 7),
      points: 22,
      rebounds: 7,
      assists: 5,
      steals: 3,
      turnovers: 2,
    );

void main() {
  testWidgets('the opponent carries the title, not the player name',
      (tester) async {
    // Inside one player's own profile, repeating their name on every row
    // says nothing.
    await tester.pumpWidget(_host(GamesView(games: [_game()])));

    expect(find.text('vs Northside Hawks'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('a game logged without an opponent still has a title',
      (tester) async {
    await tester.pumpWidget(_host(GamesView(games: [_game(opponent: null)])));

    expect(find.text('Game'), findsOneWidget);
    // Never a dangling "vs".
    expect(find.text('vs '), findsNothing);
  });

  testWidgets('the event fills the slot the frame labels Home', (tester) async {
    // There is no home/away column in the schema. The event is the real
    // qualifier a parent has for a game.
    await tester.pumpWidget(_host(GamesView(
      games: [_game(eventName: 'Spring Classic')],
    )));

    expect(find.text('Sat, Mar 7 · Spring Classic'), findsOneWidget);
  });

  testWidgets('no event leaves the date alone, with no dangling separator',
      (tester) async {
    await tester.pumpWidget(_host(GamesView(games: [_game()])));

    expect(find.text('Sat, Mar 7'), findsOneWidget);
  });

  testWidgets('the header counts the games and singularises one', (tester) async {
    await tester.pumpWidget(_host(GamesView(games: [_game()])));
    expect(find.text('1 Game'), findsOneWidget);

    await tester.pumpWidget(_host(GamesView(
      games: [_game(gameId: 'a'), _game(gameId: 'b')],
    )));
    expect(find.text('2 Games'), findsOneWidget);
  });

  testWidgets('empty shows the invitation, not an empty header', (tester) async {
    await tester.pumpWidget(_host(const GamesView(games: [])));

    expect(find.text('Games appear here once you log one.'), findsOneWidget);
    expect(find.text('0 Games'), findsNothing);
  });

  testWidgets('tapping a row reports that game', (tester) async {
    String? opened;
    await tester.pumpWidget(_host(GamesView(
      games: [_game(gameId: 'game-42')],
      onOpenGame: (id) => opened = id,
    )));

    await tester.tap(find.text('vs Northside Hawks'));
    expect(opened, 'game-42');
  });
}
