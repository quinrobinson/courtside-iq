// Help Center content — Phase 4.15c
//
// Approved 2026-07-23. Pure Dart so the copy can be tested and so it does not
// live inside a 500-line widget the way v1's did, where four answers were
// wrong and nothing could tell.
//
// WHAT WAS WRONG IN v1, all of it shipped:
//
//   THE PLAYER LIMIT was stated as three for everyone, in two separate
//   answers. Free is ONE. A parent read that, added a second child, and hit
//   an upgrade gate the help center had told them was not there.
//   THE FREE TRIAL was promised to "every new subscriber". It is monthly-only
//   and first-time only, so a weekly subscriber was promised a trial they
//   could never get.
//   "MANAGE YOUR SUBSCRIPTION" named a button that 2.0 renamed to
//   Subscription.
//   THE STATS LIST predated the 2.0 tracker, which also records makes and
//   misses per shot type and splits rebounds.
//
// SIX BROAD ANSWERS, NOT TWELVE NARROW ONES. 507:1964 consolidates v1's list
// into questions a parent would actually phrase, and that is the shape here.
// The first answer is the frame's own copy, verbatim.
//
// TWO ARE ADDED beyond the frame, both carrying facts the frame predates:
// what happens to a subscription when an account is deleted (the expensive
// one - a parent who assumes it stops keeps being billed), and why a quiet
// game earns no insight, which 2.0 made visible.
//
// Answers are PARAGRAPHS, never bullets, and carry no em dashes. Solid is the
// ENTRY level - the one thing here that gets misread as a poor grade.

class HelpTopic {
  const HelpTopic({required this.question, required this.answer});
  final String question;
  final String answer;
}

const List<HelpTopic> kHelpTopics = [
  HelpTopic(
    question: 'What do Solid, Good, and Elite mean?',
    // 507:1964, verbatim. The last sentence does the work every other draft
    // of this answer was circling.
    answer:
        'Every rating falls into one of three levels. Solid means your '
        'player is handling the fundamentals well and building a base. Good '
        "means they're performing above that base with real consistency. "
        'Elite is the top level, where the skill has become a genuine '
        'strength. All three are positive, they just mark different points '
        'on the same growth path.',
  ),
  HelpTopic(
    question: 'How are ratings calculated?',
    answer:
        'Every rating comes from what you log during a game: points, '
        'rebounds split into offensive and defensive, assists, steals, '
        'blocks, turnovers, and makes and misses for two-pointers, '
        'three-pointers and free throws. Growth IQ pulls those together into '
        'a single number between 40 and 99. Most of it reflects how your '
        'player is performing for their age, and the rest reflects whether '
        'they are improving, because a quieter season while clearly getting '
        'better is a different story from having plateaued.',
  ),
  HelpTopic(
    question: "Why don't I see a rating yet?",
    answer:
        'There are two reasons a rating stays locked, and they need '
        'different things from you. If you have logged fewer than five '
        'games, keep logging, because the score needs enough history to mean '
        'anything. If the player has no birth date on file, add one from '
        'their profile. Ratings compare a player to others their own age, so '
        'without an age there is nothing fair to compare against, and we '
        'would rather show nothing than a number we cannot stand behind.',
  ),
  HelpTopic(
    question: 'How do I add another player?',
    answer:
        'Open the Players tab and tap the plus button. Every account can '
        'track one player for free, and a subscription raises that to three, '
        'which covers most families with more than one kid playing. Each '
        'player keeps their own game history and averages, so progress never '
        'gets mixed together.',
  ),
  HelpTopic(
    question: 'How does my subscription work?',
    answer:
        'A subscription unlocks everything: live stat tracking, unlimited '
        'game history, up to three players, season averages, Growth IQ and '
        'the read on each game. It is \$1.99 per week or \$5.99 per month, '
        'and the monthly plan is the better value across a season. The '
        'monthly plan also comes with a 7-day free trial if you have not '
        'subscribed before, which the weekly plan does not. Cancelling and '
        'refunds happen in the app store rather than in Courtside IQ: on an '
        'iPhone or iPad open Settings, tap your name, then Subscriptions, '
        'and on Android open the Play Store, tap your profile picture, then '
        'Payments and subscriptions.',
  ),
  HelpTopic(
    question: 'How is our data kept private?',
    answer:
        'Your stats and player information are stored securely and are never '
        'sold or shared. A birth date is used for one thing only, putting a '
        'player in the right age band so their ratings are fair, and it '
        'never leaves your account. You stay in control of all of it and can '
        'remove any of it at any time.',
  ),
  HelpTopic(
    question: "Why didn't this game get an insight?",
    answer:
        'Insights come from what happened in the game, so a very quiet game '
        'does not produce one. If a player took only a couple of shots or '
        'barely touched the ball, there is not enough there for an honest '
        'read, and we would rather say nothing than pad it out. The stats '
        'are still saved and still count toward their averages and their '
        'Growth IQ.',
  ),
  HelpTopic(
    question: 'Does deleting my account cancel my subscription?',
    answer:
        'No, and this is worth knowing before you delete anything. Your '
        'subscription is billed by the app store rather than by us, so '
        'removing your account here does not stop it. Cancel it in your app '
        'store subscriptions first, then delete your account. If you delete '
        'first you can still cancel afterwards from the same place.',
  ),
];

/// The footer beneath the list (507:1964), which opens Send Feedback.
const String kHelpFooterPrompt = 'Still need help? Send us a note.';
