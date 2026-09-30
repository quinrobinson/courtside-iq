import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/player_gating.dart';

void main() {
  group('free tier', () {
    test('may add their first player', () {
      expect(addPlayerAction(isPremium: false, playerCount: 0),
          AddPlayerAction.allowed);
    });

    test('is gated at the free allowance', () {
      // The allowance is 1, mirroring free_player_limit() server-side.
      expect(addPlayerAction(isPremium: false, playerCount: 1),
          AddPlayerAction.upgradeGate);
    });

    test('an over-limit free user is gated, not broken', () {
      // Existing users can be over the limit: the RLS policy is INSERT-only
      // and never removed anyone's players. They simply cannot add more.
      expect(addPlayerAction(isPremium: false, playerCount: 3),
          AddPlayerAction.upgradeGate);
    });
  });

  group('premium', () {
    test('may add up to the cap', () {
      for (final n in [0, 1, 2]) {
        expect(addPlayerAction(isPremium: true, playerCount: n),
            AddPlayerAction.allowed, reason: 'count $n');
      }
    });

    test('hits the cap at three, and is NOT sold to', () {
      // Selling premium to someone who already pays would be insulting; the
      // cap state offers management instead.
      expect(addPlayerAction(isPremium: true, playerCount: 3),
          AddPlayerAction.capReached);
      expect(addPlayerAction(isPremium: true, playerCount: 5),
          AddPlayerAction.capReached);
    });
  });

  group('lapsed', () {
    test('is treated as free, so gets the upgrade path not the cap', () {
      // Their premium ended, so the way forward is renewing - not being told
      // to delete a child.
      expect(addPlayerAction(isPremium: false, playerCount: 2),
          AddPlayerAction.upgradeGate);
    });
  });

  group('limits', () {
    test('free matches the server, premium is client-only', () {
      expect(kFreePlayerLimit, 1);
      expect(kPremiumPlayerLimit, 3);
    });
  });
}
