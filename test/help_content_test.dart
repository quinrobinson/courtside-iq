// Help Center copy — Phase 4.15c
//
// These are not style checks for their own sake. Four answers shipped in v1
// stating things the app does not do, and the reason nothing caught them is
// that the copy lived inside a 500-line widget where it could only be read by
// a person who already knew the answer. Here it can be asserted against.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/help_content.dart';
import 'package:courtside_i_q/courtside_iq/player_gating.dart';

void main() {
  group('the facts it states', () {
    test('the free tier is ONE player, not three', () {
      // v1 said "up to 3 player profiles per account" in TWO answers with no
      // mention of a free limit. A parent added their second child and hit an
      // upgrade gate the help center had told them was not there.
      final players = kHelpTopics
          .firstWhere((t) => t.question.contains('How many players'));
      expect(players.answer, contains('one player for free'));
      expect(players.answer, contains('up to three'));
      // And the numbers still match the code.
      expect(kFreePlayerLimit, 1);
      expect(kPremiumPlayerLimit, 3);
    });

    test('the trial is monthly-only and first-time-only', () {
      // v1 promised it to "every new subscriber". A weekly subscriber was
      // promised a trial they could never get.
      final trial =
          kHelpTopics.firstWhere((t) => t.question.contains('free trial'));
      expect(trial.answer, contains('monthly plan'));
      expect(trial.answer, contains('not subscribed before'));
      expect(trial.answer, contains('weekly plan does not include'));
    });

    test('cancelling is described as happening in the app store', () {
      // Not in Courtside IQ. The single most expensive thing to get wrong
      // here: a parent who believes we cancelled it keeps being billed.
      final cancel = kHelpTopics
          .firstWhere((t) => t.question.contains('manage or cancel'));
      expect(cancel.answer, contains('app store'));
      expect(cancel.answer, isNot(contains('Manage Your Subscription')));
    });

    test('deleting an account is said NOT to cancel the subscription', () {
      final delete = kHelpTopics
          .firstWhere((t) => t.question.startsWith('Does deleting'));
      expect(delete.answer, startsWith('No'));
      expect(delete.answer, contains('app store'));
    });

    test('the locked Growth IQ answer covers BOTH causes', () {
      // Five games and a missing birth date need different things from the
      // parent. An answer naming only one leaves half of them stuck.
      final locked = kHelpTopics
          .firstWhere((t) => t.question.contains("doesn't my player have"));
      expect(locked.answer, contains('five games'));
      expect(locked.answer, contains('birth date'));
    });
  });

  group('house style', () {
    test('no em dashes anywhere', () {
      for (final t in kHelpTopics) {
        expect(t.question, isNot(contains('—')), reason: t.question);
        expect(t.answer, isNot(contains('—')), reason: t.question);
      }
    });

    test('answers are paragraphs, never bullet lists', () {
      for (final t in kHelpTopics) {
        expect(t.answer, isNot(contains('\n')), reason: t.question);
        expect(t.answer.trimLeft(), isNot(startsWith('-')), reason: t.question);
        expect(t.answer.trimLeft(), isNot(startsWith('•')), reason: t.question);
      }
    });

    test('the tier hierarchy reads Solid, Good, Elite', () {
      final tiers =
          kHelpTopics.firstWhere((t) => t.question.contains('Solid'));
      expect(tiers.answer.indexOf('Solid'),
          lessThan(tiers.answer.indexOf('Good')));
      expect(tiers.answer.indexOf('Good'),
          lessThan(tiers.answer.indexOf('Elite')));
      // Solid is the ENTRY level. This is the one thing here that gets
      // misread as a poor grade.
      expect(tiers.answer, contains('starting point'));
    });

    test('every topic actually answers something', () {
      expect(kHelpTopics, isNotEmpty);
      for (final t in kHelpTopics) {
        expect(t.question.trim(), isNotEmpty);
        expect(t.answer.trim().length, greaterThan(40), reason: t.question);
        expect(t.question, endsWith('?'), reason: t.question);
      }
    });

    test('no question is asked twice', () {
      // v1 answered the player limit in two places and got it wrong in both,
      // which is how one correction can still leave the error on screen.
      final asked = kHelpTopics.map((t) => t.question.toLowerCase()).toList();
      expect(asked.toSet().length, asked.length);
    });
  });
}
