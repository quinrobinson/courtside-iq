// "The set of games changed" — Phase 4.18
//
// The twin of players_revision.dart, for the same reason. A game saved online
// reaches the server, but the Games list and the Today feed are kept alive by
// the nav shell's indexedStack, so they keep showing the list they loaded
// BEFORE the game existed - the parent saves, gets the confirmation, lands on
// Games, and their game is not there.
//
// The save announces instead. Screens that show games subscribe and reload
// themselves. The offline queue bumps this too, so a game that syncs minutes
// later on reconnect appears without the parent doing anything.

import 'package:flutter/foundation.dart';

/// Bumped whenever the set of games changes. The value is meaningless; only
/// the change matters.
final ValueNotifier<int> gamesRevision = ValueNotifier<int>(0);

/// Call after a game is saved, synced, or removed.
void notifyGamesChanged() => gamesRevision.value++;
