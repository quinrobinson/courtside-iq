// Info sheet copy — Phase 4.11c
//
// Transcribed from the frames, held here rather than inline in the widgets so
// it reads as COPY and can be reviewed as copy. These paragraphs are the app
// explaining itself to a parent, which makes them product voice, not strings.
//
// House rules that apply to every line here: no em dashes; warm and
// development-focused; never a ranking against other children.

abstract final class InfoCopy {
  /// About Story Sheet (648:2215), reached from "About this story" on the
  /// Development tab.
  static const developmentStoryTitle = 'Your development story';

  static const developmentStoryBody =
      'After every few games, we write a short read on how your player is '
      'developing. What\'s clicking, where to focus next, and how their trends '
      'are moving. It\'s built from the same numbers you see here, summed up '
      'like a quick note from a coach, and it grows as you log more games.';

  /// About Growth IQ (691:2850).
  static const growthIqTitle = 'About Growth IQ';

  /// The last sentence is load-bearing. Growth IQ is age-normalized, which
  /// makes it look like a percentile, and the one thing it must never be read
  /// as is a leaderboard against other children.
  static const growthIqBody =
      'Growth IQ is one number for how your player is developing. It blends '
      'how well they score, create, and defend for their age with how much '
      'they are improving game to game. Improvement counts for real, so a '
      'player who keeps working will see it climb even while they are still '
      'learning. It is never a ranking against other kids.';
}
