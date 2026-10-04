import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/player_gating.dart';

// Roadmap 3.8: free is 1 player and 3 games.
void main() {
  group('starting a game, free tier', () {
    test('games 1 to 3 are allowed', () {
      for (final n in [0, 1, 2]) {
        expect(startGameAction(isPremium: false, gameCount: n),
            StartGameAction.allowed,
            reason: '$n games logged');
      }
    });

    test('the 4th game is gated', () {
      // The allowance is 3, mirroring free_game_limit() server-side.
      expect(startGameAction(isPremium: false, gameCount: 3),
          StartGameAction.upgradeGate);
    });

    test('an account already over the allowance is gated, not broken', () {
      // Eight prod accounts were over 3 when the limit arrived. The policy is
      // INSERT-only, so they keep every game and meet the gate on the next.
      expect(startGameAction(isPremium: false, gameCount: 43),
          StartGameAction.upgradeGate);
    });
  });

  group('starting a game, premium and lapsed', () {
    test('premium is never gated', () {
      for (final n in [0, 3, 51]) {
        expect(canStartGame(isPremium: true, gameCount: n), isTrue,
            reason: '$n games logged');
      }
    });

    test('a lapsed subscriber is treated as free', () {
      expect(canStartGame(isPremium: false, gameCount: 12), isFalse);
    });
  });

  group('free games left', () {
    test('counts down and never goes negative', () {
      expect(freeGamesLeft(isPremium: false, gameCount: 0), 3);
      expect(freeGamesLeft(isPremium: false, gameCount: 2), 1);
      expect(freeGamesLeft(isPremium: false, gameCount: 3), 0);
      expect(freeGamesLeft(isPremium: false, gameCount: 9), 0);
    });

    test('is null for premium', () {
      expect(freeGamesLeft(isPremium: true, gameCount: 2), isNull);
    });
  });

  group('New Game hint (Figma 1182:5522, 1182:5585)', () {
    test('shows the count at 1 and 2 games', () {
      expect(freeGamesUsedHint(isPremium: false, gameCount: 1),
          '1 of 3 free games used');
      expect(freeGamesUsedHint(isPremium: false, gameCount: 2),
          '2 of 3 free games used');
    });

    test('is hidden before the first game, at the allowance, and for premium',
        () {
      expect(freeGamesUsedHint(isPremium: false, gameCount: 0), isNull);
      expect(freeGamesUsedHint(isPremium: false, gameCount: 3), isNull);
      expect(freeGamesUsedHint(isPremium: true, gameCount: 1), isNull);
    });

    test('never carries a sales line', () {
      // Quin dropped "Premium is unlimited." from the 2-of-3 state.
      expect(freeGamesUsedHint(isPremium: false, gameCount: 2),
          isNot(contains('Premium')));
    });
  });

  group('Create sheet New game subtitle (Figma 1184:5451)', () {
    test('shows only when one free game is left', () {
      expect(newGameRowFreeHint(isPremium: false, gameCount: 2),
          '1 free game left');
      for (final n in [0, 1, 3, 7]) {
        expect(newGameRowFreeHint(isPremium: false, gameCount: n), isNull,
            reason: '$n games logged');
      }
    });

    test('never shows for premium', () {
      expect(newGameRowFreeHint(isPremium: true, gameCount: 2), isNull);
    });
  });

  test('the free game allowance matches the server', () {
    expect(kFreeGameLimit, 3);
  });
}
