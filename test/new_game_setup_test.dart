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
  CiButton startButton(WidgetTester tester) => tester.widget<CiButton>(
      find.ancestor(of: find.text('Start Game'), matching: find.byType(CiButton)));

  testWidgets('Start needs a player, a team AND an opponent', (tester) async {
    // The frame marks exactly one field OPTIONAL, which is the design saying
    // the others are not - and v1 disables Start without all three. An earlier
    // version required only the player.
    await _pump(tester, [_player('p1', 'Maya')]);
    expect(startButton(tester).onPressed, isNull,
        reason: 'a preselected player alone is not enough');

    await tester.enterText(find.byType(TextField), 'Hawks');
    await tester.pumpAndSettle();
    expect(startButton(tester).onPressed, isNull,
        reason: 'still no team');
  });

  testWidgets('a single player is preselected', (tester) async {
    // Nothing to choose, so the tap has only one possible answer.
    await _pump(tester, [_player('p1', 'Maya')]);
    expect(find.bySemanticsLabel('Maya'), findsOneWidget);
    // Team and event pickers become usable, which only happens once a player
    // is selected.
    expect(find.text('Select team'), findsOneWidget);
  });

  testWidgets('whitespace is not an opponent', (tester) async {
    await _pump(tester, [_player('p1', 'Maya')]);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();
    expect(startButton(tester).onPressed, isNull);
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
