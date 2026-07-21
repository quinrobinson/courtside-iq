import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/player_averages.dart';
import 'package:courtside_i_q/courtside_iq/players_list_builder.dart';
import 'package:courtside_i_q/features/games/new_game_setup_page.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';
import 'package:courtside_i_q/features/players/players_repository.dart';

class _FakeRepo implements PlayersRepository {
  const _FakeRepo(this._players);
  final List<PlayerListEntry> _players;

  @override
  Future<List<PlayerListEntry>> load() async => _players;

  @override
  Future<List<AveragesGameRow>> loadGameRows(String playerId) async => const [];

  @override
  Future<List<GameFeedEntry>> loadGames(String playerId) async => const [];
}

PlayerListEntry _player(String id, String name) => PlayerListEntry(
      playerId: id,
      firstName: name,
      totalGames: 0,
      totalPoints: 0,
      totalRebounds: 0,
      totalAssists: 0,
    );

Future<NewGameSetup?> _pump(
  WidgetTester tester,
  List<PlayerListEntry> players,
) async {
  NewGameSetup? result;
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: NewGameSetupPage(
      repository: _FakeRepo(players),
      onStart: (s) => result = s,
    ),
  ));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('Start is disabled until a player is chosen', (tester) async {
    await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);

    final start = tester.widget<CiButton>(
        find.ancestor(of: find.text('Start Game'), matching: find.byType(CiButton)));
    expect(start.onPressed, isNull);

    await tester.tap(find.bySemanticsLabel('Maya'));
    await tester.pumpAndSettle();

    final after = tester.widget<CiButton>(
        find.ancestor(of: find.text('Start Game'), matching: find.byType(CiButton)));
    expect(after.onPressed, isNotNull);
  });

  testWidgets('a single player is preselected', (tester) async {
    // Nothing to choose, so the tap has only one possible answer.
    await _pump(tester, [_player('p1', 'Maya')]);
    final start = tester.widget<CiButton>(
        find.ancestor(of: find.text('Start Game'), matching: find.byType(CiButton)));
    expect(start.onPressed, isNotNull);
  });

  testWidgets('only the player is required to start', (tester) async {
    // A game with no team or opponent is still worth tracking, and a parent at
    // tip-off should not be blocked by a field.
    NewGameSetup? result;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: NewGameSetupPage(
        repository: _FakeRepo([_player('p1', 'Maya')]),
        onStart: (s) => result = s,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.playerId, 'p1');
    expect(result!.team, isNull);
    expect(result!.opponent, isNull);
    expect(result!.event, isNull);
  });

  testWidgets('an opponent is trimmed, and empty means none', (tester) async {
    NewGameSetup? result;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: NewGameSetupPage(
        repository: _FakeRepo([_player('p1', 'Maya')]),
        onStart: (s) => result = s,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();
    expect(result!.opponent, isNull, reason: 'whitespace is not an opponent');

    await tester.enterText(find.byType(TextField), '  Hawks  ');
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();
    expect(result!.opponent, 'Hawks');
  });

  testWidgets('the event label says it is optional; team does not',
      (tester) async {
    await _pump(tester, [_player('p1', 'Maya')]);
    expect(find.text('EVENT  ·  OPTIONAL'), findsOneWidget);
    expect(find.text('TEAM'), findsOneWidget);
  });

  testWidgets('team and event pickers are disabled without a player',
      (tester) async {
    // They read that player's lists, so there is nothing to open yet.
    await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);
    expect(find.text('Select team'), findsOneWidget);
    // Tapping does nothing rather than opening an empty sheet.
    await tester.tap(find.text('Select team'));
    await tester.pumpAndSettle();
    expect(find.text('Select team'), findsOneWidget);
  });
}
