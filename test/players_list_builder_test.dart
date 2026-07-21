import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/players_list_builder.dart';
import 'package:courtside_i_q/courtside_iq/today_builder.dart';

PlayerListPlayerRow _player({
  String id = 'p1',
  String first = 'Maya',
  String? position = 'Guard',
  String? band = '11U-13U',
  int games = 12,
  int points = 222,
  int rebounds = 74,
  int assists = 49,
}) =>
    PlayerListPlayerRow(
      playerId: id,
      firstName: first,
      position: position,
      ageBand: band,
      totalGames: games,
      totalPoints: points,
      totalRebounds: rebounds,
      totalAssists: assists,
    );

TodayGameRow _game({String player = 'p1', required int day}) => TodayGameRow(
      playerId: player,
      gameId: 'g$day',
      createdAt: DateTime(2026, 1, day),
      points: 20,
      fgAttempt: 12,
      ftAttempt: 4,
      offReb: 2,
      defReb: 4,
      assist: 5,
      steal: 3,
      turnover: 2,
      block: 1,
    );

void main() {
  group('averages', () {
    test('are lifetime totals over games, to one decimal', () {
      final e = buildPlayerList(
        players: [_player(games: 12, points: 222, rebounds: 74, assists: 49)],
        games: const [],
      ).single;
      expect(e.ppg, '18.5');
      expect(e.rpg, '6.2');
      expect(e.apg, '4.1');
    });

    test('are null with no games, not 0.0', () {
      // "0.0 PPG" states a season that never happened.
      final e = buildPlayerList(
        players: [_player(games: 0, points: 0, rebounds: 0, assists: 0)],
        games: const [],
      ).single;
      expect(e.ppg, isNull);
      expect(e.rpg, isNull);
      expect(e.apg, isNull);
    });
  });

  group('subtitle', () {
    test('joins position, band and games', () {
      expect(_entry(position: 'Guard', band: '11U-13U', games: 12).subtitle,
          'Guard, 11U-13U · 12 games');
    });

    test('drops missing pieces without stray separators', () {
      // A just-added player has no position or band.
      expect(_entry(position: null, band: null, games: 0).subtitle, '0 games');
      expect(_entry(position: 'Guard', band: null, games: 5).subtitle,
          'Guard · 5 games');
    });

    test('singular for one game', () {
      expect(_entry(games: 1).subtitle, endsWith('1 game'));
      expect(_entry(games: 2).subtitle, endsWith('2 games'));
    });
  });

  group('growth iq', () {
    test('a player with too few games shows no gauge, not a zero', () {
      final e = buildPlayerList(
        players: [_player(games: 1)],
        games: [_game(day: 1)],
      ).single;
      expect(e.growthIq, isNull);
      expect(e.hasGrowthIq, isFalse);
    });

    test('groups games per player, so one cannot unlock another', () {
      final list = buildPlayerList(
        players: [_player(id: 'p1'), _player(id: 'p2', first: 'Jordan')],
        games: [
          for (var d = 1; d <= 10; d++) _game(player: 'p1', day: d),
          _game(player: 'p2', day: 11),
        ],
      );
      expect(list.firstWhere((e) => e.playerId == 'p2').growthIq, isNull);
    });

    test('orders games oldest first, so the trend is not inverted', () {
      final asc = [for (var d = 1; d <= 10; d++) _game(day: d)];
      final desc = asc.reversed.toList();
      final a = buildPlayerList(players: [_player()], games: asc).single;
      final b = buildPlayerList(players: [_player()], games: desc).single;
      expect(a.growthIq, b.growthIq);
      expect(a.growthIqDelta, b.growthIqDelta);
    });
  });

  group('an assumed age band is never stated as fact', () {
    // get_age_band() returns '11U-13U' when birth_date IS NULL, so ageBand is
    // NEVER null. Reported on device: a player created with no birth date was
    // listed as "11U-13U", which the app has no way of knowing.
    PlayerListEntry entry({required bool hasBirthDate}) => PlayerListEntry(
          playerId: 'p1',
          firstName: 'Jordan',
          position: 'Guard',
          ageBand: '11U-13U',
          hasBirthDate: hasBirthDate,
          totalGames: 0,
          totalPoints: 0,
          totalRebounds: 0,
          totalAssists: 0,
        );

    test('a known band is shown', () {
      final e = entry(hasBirthDate: true);
      expect(e.knownAgeBand, '11U-13U');
      expect(e.subtitle, contains('11U-13U'));
    });

    test('an assumed band is withheld everywhere', () {
      final e = entry(hasBirthDate: false);
      // The band survives for the rating maths...
      expect(e.ageBand, '11U-13U');
      // ...but nothing may show it.
      expect(e.knownAgeBand, isNull);
      expect(e.subtitle, isNot(contains('11U')));
      expect(e.subtitle, 'Guard · 0 games');
    });
  });

  // The trend WORD is no longer built here. It lives in CiBadge.growthTrend,
  // which is also what colours the chip, so the word and its tone cannot
  // drift apart across Today, the list, and the profile. Covered by
  // today_hero_test and player_list_row_test.
}

PlayerListEntry _entry({String? position, String? band, int games = 5}) =>
    buildPlayerList(
      players: [
        PlayerListPlayerRow(
          playerId: 'p1',
          firstName: 'Maya',
          position: position,
          ageBand: band,
          totalGames: games,
          totalPoints: games * 18,
          totalRebounds: games * 6,
          totalAssists: games * 4,
        ),
      ],
      games: const [],
    ).single;
