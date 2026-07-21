import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/games_list_builder.dart';

GameListRow _g({
  String id = 'g1',
  String player = 'p1',
  String name = 'Maya',
  DateTime? at,
}) =>
    GameListRow(
      gameId: id,
      playerId: player,
      playerName: name,
      playedAt: at ?? DateTime(2026, 5, 4),
    );

void main() {
  group('playerOptions', () {
    test('is built from the GAMES, not the roster', () {
      // A player with no games has nothing to filter to, and their chip would
      // lead to an empty list that reads as a bug.
      final options = playerOptions([
        _g(player: 'p1', name: 'Maya'),
        _g(player: 'p2', name: 'Jordan'),
      ]);
      expect(options.map((o) => o.label), ['All', 'Jordan', 'Maya']);
    });

    test('is withheld entirely when there is only one player', () {
      // Every chip would show the same list.
      expect(playerOptions([_g(player: 'p1'), _g(id: 'g2', player: 'p1')]),
          isEmpty);
    });

    test('is withheld when there are no games', () {
      expect(playerOptions(const []), isEmpty);
    });
  });

  group('dateOptions', () {
    test('newest first, after an All chip', () {
      final options = dateOptions([
        _g(id: 'a', at: DateTime(2026, 4, 28)),
        _g(id: 'b', at: DateTime(2026, 5, 4)),
        _g(id: 'c', at: DateTime(2026, 5, 2)),
      ]);
      expect(options.map((o) => o.label),
          ['All dates', 'May 4', 'May 2', 'Apr 28']);
    });

    test('collapses games played on the same day', () {
      final options = dateOptions([
        _g(id: 'a', at: DateTime(2026, 5, 4, 9)),
        _g(id: 'b', at: DateTime(2026, 5, 4, 18)),
      ]);
      expect(options.length, 2, reason: 'All dates + one day');
    });

    test('ignores a game with no date rather than inventing one', () {
      final options = dateOptions([
        GameListRow(gameId: 'x', playerId: 'p1', playerName: 'Maya'),
      ]);
      expect(options, isEmpty);
    });
  });

  group('filterGames', () {
    final games = [
      _g(id: 'a', player: 'p1', name: 'Maya', at: DateTime(2026, 5, 4)),
      _g(id: 'b', player: 'p2', name: 'Jordan', at: DateTime(2026, 5, 4)),
      _g(id: 'c', player: 'p1', name: 'Maya', at: DateTime(2026, 4, 28)),
    ];

    test('no filters returns everything', () {
      expect(filterGames(games).length, 3);
    });

    test('filters by player', () {
      expect(filterGames(games, playerId: 'p1').map((g) => g.gameId),
          ['a', 'c']);
    });

    test('filters by date', () {
      expect(
          filterGames(games, dateId: dateKey(DateTime(2026, 5, 4)))
              .map((g) => g.gameId),
          ['a', 'b']);
    });

    test('applies both together', () {
      expect(
          filterGames(games,
                  playerId: 'p2', dateId: dateKey(DateTime(2026, 4, 28)))
              .map((g) => g.gameId),
          isEmpty);
    });
  });

  group('reconcileSelection', () {
    test('drops a selection whose chip no longer exists', () {
      // A parent filtered to May 4, then deleted that game. Without this the
      // selection outlives its chip and the list is permanently empty with no
      // visible way back.
      final options = dateOptions([_g(at: DateTime(2026, 5, 2))]);
      expect(reconcileSelection('2026-05-04', options), kAllDatesKey);
    });

    test('keeps a selection that is still offered', () {
      final options = dateOptions([_g(at: DateTime(2026, 5, 4))]);
      expect(reconcileSelection('2026-05-04', options), '2026-05-04');
    });

    test('leaves All alone', () {
      expect(reconcileSelection(kAllDatesKey, const []), kAllDatesKey);
    });
  });
}
