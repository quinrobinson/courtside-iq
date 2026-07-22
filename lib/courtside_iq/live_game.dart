// Live game state — Phase 4.13
//
// What a parent is accumulating while they track a game, and the only place
// that knows how those numbers combine.
//
// Pure Dart. This is the most consequential arithmetic in the app - it is a
// record of a child's game that cannot be re-created afterwards - so it is
// separated from the screen entirely and every rule here is tested.
//
// POINTS ARE DERIVED, NEVER STORED. Two-pointers, threes and free throws are
// counted; the score is computed from them. A stored total can disagree with
// the shots that produced it, and the moment it does there is no way to know
// which one is right.

/// Everything tracked during a game.
class LiveGameStats {
  final int twoMade;
  final int twoMissed;
  final int threeMade;
  final int threeMissed;
  final int ftMade;
  final int ftMissed;

  final int offReb;
  final int defReb;
  final int assists;
  final int steals;
  final int blocks;
  final int turnovers;

  const LiveGameStats({
    this.twoMade = 0,
    this.twoMissed = 0,
    this.threeMade = 0,
    this.threeMissed = 0,
    this.ftMade = 0,
    this.ftMissed = 0,
    this.offReb = 0,
    this.defReb = 0,
    this.assists = 0,
    this.steals = 0,
    this.blocks = 0,
    this.turnovers = 0,
  });

  /// The score. Derived, always.
  int get points => twoMade * 2 + threeMade * 3 + ftMade;

  /// What the header shows as REB: the two kinds added, never tracked
  /// separately from them.
  int get rebounds => offReb + defReb;

  /// Field goals are twos AND threes. Free throws are not field goals - that
  /// is the convention every basketball box score uses, and getting it wrong
  /// would quietly change every shooting percentage in the app.
  int get fgMade => twoMade + threeMade;
  int get fgAttempted => twoMade + twoMissed + threeMade + threeMissed;
  int get ftAttempted => ftMade + ftMissed;

  /// True while nothing has been recorded. Used to decide whether ending the
  /// game needs a confirmation - discarding nothing is not a loss.
  bool get isEmpty =>
      points == 0 &&
      fgAttempted == 0 &&
      ftAttempted == 0 &&
      rebounds == 0 &&
      assists == 0 &&
      steals == 0 &&
      blocks == 0 &&
      turnovers == 0;

  LiveGameStats copyWith({
    int? twoMade,
    int? twoMissed,
    int? threeMade,
    int? threeMissed,
    int? ftMade,
    int? ftMissed,
    int? offReb,
    int? defReb,
    int? assists,
    int? steals,
    int? blocks,
    int? turnovers,
  }) =>
      LiveGameStats(
        twoMade: twoMade ?? this.twoMade,
        twoMissed: twoMissed ?? this.twoMissed,
        threeMade: threeMade ?? this.threeMade,
        threeMissed: threeMissed ?? this.threeMissed,
        ftMade: ftMade ?? this.ftMade,
        ftMissed: ftMissed ?? this.ftMissed,
        offReb: offReb ?? this.offReb,
        defReb: defReb ?? this.defReb,
        assists: assists ?? this.assists,
        steals: steals ?? this.steals,
        blocks: blocks ?? this.blocks,
        turnovers: turnovers ?? this.turnovers,
      );

  Map<String, int> toJson() => {
        'two_made': twoMade,
        'two_missed': twoMissed,
        'three_made': threeMade,
        'three_missed': threeMissed,
        'ft_made': ftMade,
        'ft_missed': ftMissed,
        'off_reb': offReb,
        'def_reb': defReb,
        'assists': assists,
        'steals': steals,
        'blocks': blocks,
        'turnovers': turnovers,
      };

  static LiveGameStats fromJson(Map<String, dynamic> json) {
    int v(String k) {
      final raw = json[k];
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      if (raw is String) return int.tryParse(raw) ?? 0;
      return 0;
    }

    return LiveGameStats(
      twoMade: v('two_made'),
      twoMissed: v('two_missed'),
      threeMade: v('three_made'),
      threeMissed: v('three_missed'),
      ftMade: v('ft_made'),
      ftMissed: v('ft_missed'),
      offReb: v('off_reb'),
      defReb: v('def_reb'),
      assists: v('assists'),
      steals: v('steals'),
      blocks: v('blocks'),
      turnovers: v('turnovers'),
    );
  }
}

/// Every stat a tap can change.
enum LiveStat {
  twoMade,
  twoMissed,
  threeMade,
  threeMissed,
  ftMade,
  ftMissed,
  offReb,
  defReb,
  assists,
  steals,
  blocks,
  turnovers,
}

/// Applies one tap.
///
/// [delta] is +1 or -1. NOTHING GOES BELOW ZERO: a parent cannot un-take a
/// shot that was never taken, and a negative count would poison every
/// percentage downstream. Clamping here rather than at the widget means it
/// holds for the undo path too.
LiveGameStats applyStat(LiveGameStats s, LiveStat stat, int delta) {
  int bump(int current) => (current + delta) < 0 ? 0 : current + delta;

  return switch (stat) {
    LiveStat.twoMade => s.copyWith(twoMade: bump(s.twoMade)),
    LiveStat.twoMissed => s.copyWith(twoMissed: bump(s.twoMissed)),
    LiveStat.threeMade => s.copyWith(threeMade: bump(s.threeMade)),
    LiveStat.threeMissed => s.copyWith(threeMissed: bump(s.threeMissed)),
    LiveStat.ftMade => s.copyWith(ftMade: bump(s.ftMade)),
    LiveStat.ftMissed => s.copyWith(ftMissed: bump(s.ftMissed)),
    LiveStat.offReb => s.copyWith(offReb: bump(s.offReb)),
    LiveStat.defReb => s.copyWith(defReb: bump(s.defReb)),
    LiveStat.assists => s.copyWith(assists: bump(s.assists)),
    LiveStat.steals => s.copyWith(steals: bump(s.steals)),
    LiveStat.blocks => s.copyWith(blocks: bump(s.blocks)),
    LiveStat.turnovers => s.copyWith(turnovers: bump(s.turnovers)),
  };
}

/// Reads a stat's current value.
int readStat(LiveGameStats s, LiveStat stat) => switch (stat) {
      LiveStat.twoMade => s.twoMade,
      LiveStat.twoMissed => s.twoMissed,
      LiveStat.threeMade => s.threeMade,
      LiveStat.threeMissed => s.threeMissed,
      LiveStat.ftMade => s.ftMade,
      LiveStat.ftMissed => s.ftMissed,
      LiveStat.offReb => s.offReb,
      LiveStat.defReb => s.defReb,
      LiveStat.assists => s.assists,
      LiveStat.steals => s.steals,
      LiveStat.blocks => s.blocks,
      LiveStat.turnovers => s.turnovers,
    };
