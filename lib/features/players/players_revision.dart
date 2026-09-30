// "The player list changed" — Phase 4.19f
//
// A player added from the create sheet has to appear on whatever screen is
// under the nav bar. That used to work because every screen passed its own
// `onPlayerAdded` refresh INTO the bar it rendered itself.
//
// The shell broke that by design: there is now ONE bar, it lives above the
// routed content, and it cannot know what it is sitting on. The first fix was
// to reset the active branch, which did refresh the tab but also popped it to
// its root - add a player from Player Profile and you were thrown back to the
// list.
//
// So the bar announces instead of navigating. Screens that show players
// subscribe and reload themselves, which leaves the navigation stack alone.
//
// A SIDE EFFECT WORTH HAVING: every subscribed screen reloads, not just the
// visible one. Under indexedStack the other tabs stay alive, so without this
// they would keep serving a list that silently predates the new player.

import 'package:flutter/foundation.dart';

/// Bumped whenever the set of players changes. The value itself is meaningless
/// - only the change matters.
final ValueNotifier<int> playersRevision = ValueNotifier<int>(0);

/// Call after a player is added, edited or deleted.
void notifyPlayersChanged() => playersRevision.value++;
