// Event types — Phase 4.11d
//
// `game_events.event_type` stores 'Long-Term' or 'Short-Term', which is the
// vocabulary of whoever built the table. A parent labelling their kid's
// weekend tournament should not have to translate that.
//
// SO THE STORED VALUE AND THE SHOWN LABEL DIFFER ON PURPOSE, and this file is
// the only place that knows it. Approved 2026-07-21 as a display change only:
// nothing migrates, and event_types_list keeps its rows.
//
// Pure Dart, so the mapping is testable and cannot quietly diverge between the
// list sheet and the add sheet - which it already did once, in the Figma draft.

/// The two kinds of event a game can belong to.
enum EventType {
  /// Stored 'Long-Term'. A season or a league: many games over months.
  season,

  /// Stored 'Short-Term'. A tournament: a handful of games over a weekend.
  tournament,
}

extension EventTypeX on EventType {
  /// What a parent reads.
  String get label => switch (this) {
        EventType.season => 'Season',
        EventType.tournament => 'Tournament',
      };

  /// What the database holds. Never shown.
  String get stored => switch (this) {
        EventType.season => 'Long-Term',
        EventType.tournament => 'Short-Term',
      };
}

/// Parses a stored value.
///
/// Returns null rather than guessing when the value is absent or unrecognised.
/// A row written before this mapping existed, or by hand, should render
/// without a type rather than being mislabelled as the wrong one.
EventType? eventTypeFromStored(String? stored) {
  final s = stored?.trim().toLowerCase();
  if (s == null || s.isEmpty) return null;
  if (s == 'long-term' || s == 'long term') return EventType.season;
  if (s == 'short-term' || s == 'short term') return EventType.tournament;
  return null;
}
