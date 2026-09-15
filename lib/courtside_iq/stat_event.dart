// Stat events — G1.8 / G1.9
//
// One record per observed play, in the order the parent tapped them. The
// totals in [LiveGameStats] say WHAT happened; these say WHEN, relative to
// each other, which is what the approved game timeline shows.
//
// Pure Dart, like live_game.dart and for the same reason: this is a record of
// a child's game that cannot be re-created afterwards, so the arithmetic lives
// away from the screen and every rule here is tested.
//
// EVENTS ARE NOT WRITTEN PER TAP. They accumulate in the snapshot alongside
// the totals, persist locally on every tap through LiveGameStore, and upload
// with the game. A parent in a gym has no signal, and a write that needs the
// network on the tap path would either block the UI or lose the play.
//
// A DECREMENT IS NOT AN EVENT. It is a correction to one. Tapping minus voids
// the most recent confirmed event of that type rather than appending a
// negative row, because "he did not take that shot after all" is a different
// fact from "he took a shot worth minus one".

import 'live_game.dart';

/// Where a stat event stands. Mirrors `stat_events.status`, minus the two
/// values only video can produce.
///
/// `suggested` and `dismissed` exist in the table for video-derived events and
/// are deliberately absent here: nothing in the tracker can produce them, and
/// an enum that admits states the code cannot reach invites handling that is
/// never exercised.
enum StatEventStatus { confirmed, voided }

/// One observed play.
class StatEvent {
  /// Monotonic within a game, starting at 1.
  ///
  /// VOIDED EVENTS KEEP THEIR NUMBER, so gaps are expected and correct. The
  /// number a parent sees on screen is a display index counted over confirmed
  /// events only, and is NOT this. Never pass one where the other is wanted.
  final int sequenceNo;

  final LiveStat stat;

  /// Wall clock at the moment of the tap.
  ///
  /// A parent taps after the possession ends, sometimes at the next dead ball,
  /// so this is good to roughly ten seconds. It is what video will sync
  /// against; it is not accurate enough to display.
  final DateTime recordedAt;

  final StatEventStatus status;

  const StatEvent({
    required this.sequenceNo,
    required this.stat,
    required this.recordedAt,
    this.status = StatEventStatus.confirmed,
  });

  bool get isConfirmed => status == StatEventStatus.confirmed;

  StatEvent voided() => StatEvent(
        sequenceNo: sequenceNo,
        stat: stat,
        recordedAt: recordedAt,
        status: StatEventStatus.voided,
      );

  Map<String, dynamic> toJson() => {
        'seq': sequenceNo,
        'stat': stat.name,
        'at': recordedAt.toIso8601String(),
        'status': status.name,
      };

  /// Null when the row cannot be trusted.
  ///
  /// The outbox is a cross-version format: a game queued in a gym may be
  /// flushed by a build that shipped weeks later. A payload this cannot parse
  /// must be skipped, not guessed at.
  static StatEvent? fromJson(Map<String, dynamic> json) {
    final seq = json['seq'];
    final statName = json['stat'];
    final at = json['at'];
    if (seq is! int || statName is! String || at is! String) return null;

    final stat = LiveStat.values.where((s) => s.name == statName).firstOrNull;
    final when = DateTime.tryParse(at);
    if (stat == null || when == null) return null;

    return StatEvent(
      sequenceNo: seq,
      stat: stat,
      recordedAt: when,
      status: json['status'] == 'voided'
          ? StatEventStatus.voided
          : StatEventStatus.confirmed,
    );
  }
}

/// `LiveStat` to the `stat_events.event_type` value.
///
/// NOTE THE SINGULARS. The tracker enum reads as a running count (`assists`,
/// `steals`) while the column names are per-event (`assist`, `steal`), and
/// player_game_stats already uses the singular. Getting this wrong writes rows
/// the CHECK constraint rejects, which on the upload path means a game that
/// fails every retry.
const Map<LiveStat, String> kStatEventType = {
  LiveStat.twoMade: 'two_made',
  LiveStat.twoMissed: 'two_missed',
  LiveStat.threeMade: 'three_made',
  LiveStat.threeMissed: 'three_missed',
  LiveStat.ftMade: 'ft_made',
  LiveStat.ftMissed: 'ft_missed',
  LiveStat.offReb: 'off_reb',
  LiveStat.defReb: 'def_reb',
  LiveStat.assists: 'assist',
  LiveStat.steals: 'steal',
  LiveStat.blocks: 'block',
  LiveStat.turnovers: 'turnover',
};

/// The result of one tap: the new totals and the new event list, together.
typedef TapResult = ({LiveGameStats stats, List<StatEvent> events});

/// Applies one tap to both the totals and the event list.
///
/// THE ONE PLACE A TAP IS RECORDED. The Miss buttons and the minus steppers
/// are two routes to the same counter, and both come through here. If either
/// ever writes directly to [applyStat] instead, the totals and the events
/// drift apart silently and the parallel run in G1.12 is what finds out.
///
/// [delta] is +1 or -1. The totals clamp at zero exactly as they did before;
/// a decrement with nothing to undo changes neither the count nor the list.
TapResult applyTap(
  LiveGameStats stats,
  List<StatEvent> events,
  LiveStat stat,
  int delta, {
  DateTime? at,
}) {
  final nextStats = applyStat(stats, stat, delta);

  // Nothing moved, so nothing is recorded. This is the minus-at-zero case:
  // applyStat clamps, and the event list has to agree with it or the two
  // representations disagree about a play that never happened.
  if (readStat(nextStats, stat) == readStat(stats, stat)) {
    return (stats: nextStats, events: events);
  }

  if (delta > 0) {
    // Voided events keep their slot, so the next number comes off the end of
    // the list rather than off a count of what is still confirmed.
    final nextSeq = events.isEmpty ? 1 : events.last.sequenceNo + 1;
    return (
      stats: nextStats,
      events: [
        ...events,
        StatEvent(
          sequenceNo: nextSeq,
          stat: stat,
          recordedAt: at ?? DateTime.now(),
        ),
      ],
    );
  }

  // Void the most recent CONFIRMED event of this type. Searching backwards
  // matters: undo should take back the last one, not the first.
  final i = events.lastIndexWhere((e) => e.stat == stat && e.isConfirmed);
  if (i < 0) return (stats: nextStats, events: events);

  final next = [...events];
  next[i] = next[i].voided();
  return (stats: nextStats, events: next);
}

/// How many confirmed events of [stat] the list holds.
///
/// This is the number that must equal the stored total. It is the whole
/// dual-write guarantee in one function, and the parallel run compares exactly
/// this against player_game_stats.
int countConfirmed(List<StatEvent> events, LiveStat stat) =>
    events.where((e) => e.stat == stat && e.isConfirmed).length;

/// True when every total is backed by exactly that many confirmed events.
///
/// Cheap enough to assert in tests on every tap, which is where a drift
/// between the two representations gets caught while it is still one line of
/// code rather than a season of games.
bool eventsMatchTotals(LiveGameStats stats, List<StatEvent> events) =>
    LiveStat.values.every(
      (s) => readStat(stats, s) == countConfirmed(events, s),
    );

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
