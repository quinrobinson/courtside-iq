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
// Answers are PARAGRAPHS, never bullets, and carry no em dashes. Tier order
// is Solid then Good then Elite, and Solid is the ENTRY level - it is the one
// thing here that gets misread as a poor grade.

class HelpTopic {
  const HelpTopic({required this.question, required this.answer});
  final String question;
  final String answer;
}

class HelpSection {
  const HelpSection({required this.title, required this.topics});
  final String title;
  final List<HelpTopic> topics;
}

const List<HelpSection> kHelpSections = [
  HelpSection(
    title: 'Using the app',
    topics: [
      HelpTopic(
        question: 'What stats can I track?',
        answer:
            'Courtside IQ tracks the counting stats that matter for '
            'development: points, rebounds split into offensive and '
            'defensive, assists, steals, blocks and turnovers. It also '
            'records makes and misses separately for two-pointers, '
            'three-pointers and free throws, which is where the shooting '
            'percentages and the scoring mix on each game come from.',
      ),
      HelpTopic(
        question: 'How do I track a game?',
        answer:
            'Tap the plus button in the bottom navigation and choose New '
            'Game. Pick the player, name the team and opponent, then start '
            'tracking. Tap as the action happens and the app keeps the '
            'running totals for you.',
      ),
      HelpTopic(
        question: 'When should I use Courtside IQ?',
        answer:
            'It is built for use during a live game, which is where you will '
            'get the most out of it. Tracking as it happens takes a tap per '
            'play and saves you reconstructing a game afterwards from memory.',
      ),
      HelpTopic(
        question: 'How many players can I add?',
        answer:
            'Every account can track one player for free. With a '
            'subscription you can add up to three, which covers most '
            'families with more than one kid playing. Each player keeps '
            'their own game history and averages, so progress never gets '
            'mixed together.',
      ),
    ],
  ),
  HelpSection(
    title: 'Ratings and insights',
    topics: [
      HelpTopic(
        question: 'What is Growth IQ?',
        answer:
            'Growth IQ is a single number between 40 and 99 that answers one '
            'question: how is this player developing. Most of it reflects '
            'how they are performing for their age, and the rest reflects '
            'whether they are improving. That mix is deliberate, because a '
            'player having a quieter season while clearly getting better is '
            'a different story from one who has plateaued. It updates as you '
            'log games.',
      ),
      HelpTopic(
        question: "Why doesn't my player have a Growth IQ yet?",
        answer:
            'There are two reasons it stays locked, and they need different '
            'things from you. If you have logged fewer than five games, keep '
            'logging, because the score needs enough history to mean '
            'anything. If the player has no birth date on file, add one from '
            'their profile. Growth IQ compares a player to others their own '
            'age, so without an age there is nothing fair to compare '
            'against, and we would rather show nothing than a number we '
            'cannot stand behind.',
      ),
      HelpTopic(
        question: "Why do you need my player's birth date?",
        answer:
            'Every rating in Courtside IQ is measured against players in the '
            'same age band, so an eight-year-old is never held to a high '
            "schooler's standard. The birth date is what puts them in the "
            'right band. We use it for nothing else, it is never shared, and '
            "you can add or change it any time from the player's profile.",
      ),
      HelpTopic(
        question: 'What do Solid, Good and Elite mean?',
        answer:
            'They are the three levels a rating can reach, and Solid is the '
            'starting point rather than a poor grade. Solid means a player '
            'is doing the thing at a level that holds up for their age. Good '
            'is a clear step above that, and Elite is the top of the range. '
            'Every level is a real result, and most games for most players '
            'land in Solid or Good.',
      ),
      HelpTopic(
        question: "Why didn't this game get an insight?",
        answer:
            'Insights come from what happened in the game, so a very quiet '
            'game does not produce one. If a player took only a couple of '
            'shots or barely touched the ball, there is not enough there for '
            'an honest read, and we would rather say nothing than pad it '
            'out. The stats are still saved and still count toward their '
            'averages and their Growth IQ.',
      ),
    ],
  ),
  HelpSection(
    title: 'Subscription',
    topics: [
      HelpTopic(
        question: 'What does the subscription include?',
        answer:
            'A subscription unlocks everything: live stat tracking, '
            'unlimited game history, up to three player profiles, season '
            'averages, Growth IQ and the AI read on each game.',
      ),
      HelpTopic(
        question: 'How much does it cost?',
        answer:
            'You can choose between \$1.99 per week or \$5.99 per month. The '
            'monthly plan is the better value across a season, and it is the '
            'only one that comes with a free trial.',
      ),
      HelpTopic(
        question: 'Is there a free trial?',
        answer:
            'Yes, on the monthly plan, and only if you have not subscribed '
            'before. It runs for seven days and you are not charged until it '
            'ends, so cancelling before then costs you nothing. The weekly '
            'plan does not include a trial.',
      ),
      HelpTopic(
        question: 'How do I manage or cancel my subscription?',
        answer:
            'Open Menu and tap Subscription to see your current plan. '
            'Cancelling happens in the app store rather than in Courtside '
            'IQ. On an iPhone or iPad, open Settings, tap your name, then '
            'Subscriptions. On Android, open the Play Store, tap your '
            'profile picture, then Payments and subscriptions. If you get '
            'stuck, send us a note from Menu and we will help.',
      ),
      HelpTopic(
        question: 'Can I get a refund?',
        answer:
            'Refunds are handled by the app store you subscribed through, '
            'not by us. Request one from your purchase history there and '
            'they will make the decision.',
      ),
    ],
  ),
  HelpSection(
    title: 'Your account',
    topics: [
      HelpTopic(
        question: 'Is my data private?',
        answer:
            'Your stats and player information are stored securely and are '
            'never sold or shared. You stay in control of your data, and you '
            'can remove any of it at any time.',
      ),
      HelpTopic(
        question: 'What happens if I delete my account?',
        answer:
            'Deleting your account removes your profile, every player on it, '
            'their full game history and every insight written for them. '
            'None of it can be recovered afterwards, so it is worth being '
            'sure before you confirm.',
      ),
      HelpTopic(
        question: 'Does deleting my account cancel my subscription?',
        answer:
            'No, and this is worth knowing before you delete anything. Your '
            'subscription is billed by the app store rather than by us, so '
            'removing your account here does not stop it. Cancel it in your '
            'app store subscriptions first, then delete your account. If you '
            'delete first you can still cancel afterwards from the same '
            'place.',
      ),
    ],
  ),
];

/// Every topic, flattened. For search and for tests.
List<HelpTopic> get kHelpTopics =>
    [for (final s in kHelpSections) ...s.topics];
