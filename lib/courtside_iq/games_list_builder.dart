// Games list — Phase 4.12
//
// The all-games list and its two filters. Measured from Games — List
// (263:1016): a row of PLAYER chips over a row of DATE chips, then the same
// RecentGameRow used on Today and the profile.
//
// Pure Dart. Filtering is the whole substance of this screen, and it is the
// kind of thing that quietly goes wrong at the edges - an empty result, a
// filter that outlives the rows it referred to, a date that renders one way
// in the chip and another in the row.
//
// NEWEST FIRST. The v1 list ordered created_at ASCENDING, so it opened on the
// oldest game a parent had ever logged. The frame shows May 4, May 2, Apr 28.

import 'games_list_types.dart';

export 'games_list_types.dart';

/// The "no filter" chip, first in both rows.
const String kAllPlayersId = '';
const String kAllDatesKey = '';

/// Player chips, in the order they appear.
///
/// Built from the GAMES, not from the roster: a player with no games has
/// nothing to filter to, and offering their chip leads to an empty list that
/// looks like a bug.
List<GameFilterOption> playerOptions(List<GameListRow> games) {
  final seen = <String, String>{};
  for (final g in games) {
    if (g.playerId.isEmpty) continue;
    seen.putIfAbsent(g.playerId, () => g.playerName);
  }
  final options = seen.entries
      .map((e) => GameFilterOption(id: e.key, label: e.value))
      .toList()
    ..sort((a, b) => a.label.compareTo(b.label));

  // Only worth offering when there is a choice to make. One player means
  // every chip shows the same list.
  if (options.length < 2) return const [];
  return [const GameFilterOption(id: kAllPlayersId, label: 'All'), ...options];
}

/// Date chips, newest first, scoped to whatever the player filter left.
///
/// Scoped deliberately: a date chip that yields nothing because the selected
/// player did not play that day is a dead control, and the parent cannot see
/// why.
List<GameFilterOption> dateOptions(List<GameListRow> games) {
  final seen = <String, DateTime>{};
  for (final g in games) {
    final d = g.playedAt;
    if (d == null) continue;
    seen.putIfAbsent(dateKey(d), () => d);
  }
  if (seen.isEmpty) return const [];

  final dates = seen.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return [
    const GameFilterOption(id: kAllDatesKey, label: 'All dates'),
    for (final e in dates)
      GameFilterOption(id: e.key, label: shortDate(e.value)),
  ];
}

/// Stable key for a calendar day, ignoring the time of day.
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "May 4", matching the chips in the frame.
String shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// Applies both filters. An empty id means "all".
List<GameListRow> filterGames(
  List<GameListRow> games, {
  String playerId = kAllPlayersId,
  String dateId = kAllDatesKey,
}) {
  return games.where((g) {
    if (playerId.isNotEmpty && g.playerId != playerId) return false;
    if (dateId.isNotEmpty) {
      final d = g.playedAt;
      if (d == null || dateKey(d) != dateId) return false;
    }
    return true;
  }).toList();
}

/// Keeps a selection valid as the underlying rows change.
///
/// A parent filtered to Maya on May 4, then deletes that game: the chip is
/// gone but the selection would survive and leave the list permanently empty
/// with no way back except a chip that no longer exists.
String reconcileSelection(String selected, List<GameFilterOption> options) {
  if (selected.isEmpty) return selected;
  return options.any((o) => o.id == selected) ? selected : kAllDatesKey;
}
