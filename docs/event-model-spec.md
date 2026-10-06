# Courtside IQ — Event Model and Game Completeness (Spec v1)

**Scope:** Introduce `stat_events` as the unifying record for everything observed in a game, regardless of whether it came from a parent tap or from video. Add logging method and completeness as first-class fields on the game. Define exactly what those fields affect in the metric math and what they must never affect.

**Why now:** Video mode is designed but not built. The moment a second source of observation exists, two things become permanent if they aren't decided first: how the two sources reconcile, and how the app talks about incomplete data. Both are expensive to retrofit and cheap to decide on paper.

**Guiding principle:** One record, two sources. Video is never a parallel product. It adds depth to events that already exist and never creates a separate place to go.

---

## Decisions locked in

- **Events are the substrate.** Both parent taps and video-derived reads write to `stat_events`. Same table, same shape, different `source`.
- **Parent taps are truth.** Video enriches a parent observation, never overwrites it. Video-only events arrive as suggestions requiring confirmation.
- **Logging method is first-class and applies to every game**, not just filmed ones. Manually logged games have always been incomplete. Video makes that visible; it does not create it.
- **Method, not grade.** A game is `logged`, `filmed`, or `both`. Never "partial," never "incomplete." The label describes what the parent did, not how well they did it.
- **Video is additive only.** No new nav item, no metric that requires film, no narrative section that is empty without it. A parent who never records has a complete product.
- **Completeness affects volume, never rates.** Rate metrics compute normally at any completeness. Volume gates do not.
- **Do not measure what cannot be measured.** Ship the method label in v1. A numeric completeness score stays nullable until video or a validated heuristic can populate it honestly.

---

## 1. `stat_events` schema

```sql
create table stat_events (
  id             uuid primary key default gen_random_uuid(),
  game_id        uuid not null references games(id) on delete cascade,
  player_id      uuid not null references players(id),

  event_type     text not null,        -- see taxonomy below
  sequence_no    integer not null,     -- monotonic within game; the array index
  recorded_at    timestamptz not null default now(),
  elapsed_ms     integer,              -- recorded_at minus games.started_at
  source         text not null,        -- 'parent_tap' | 'video_derived'
  status         text not null default 'confirmed',
                                       -- 'confirmed' | 'suggested' | 'dismissed' | 'voided'
  confidence     numeric,              -- null for parent_tap; 0..1 for video_derived

  attributes     jsonb default '{}'::jsonb,
  clip_ref       jsonb,                -- { clip_id, start_offset_ms, end_offset_ms }
  merged_into    uuid references stat_events(id),

  created_at     timestamptz not null default now()
);

create index on stat_events (game_id, player_id);
create index on stat_events (game_id, sequence_no);
create index on stat_events (player_id, event_type, recorded_at);
create index on stat_events using gin (attributes);
```

### Timestamping

**There is no game clock and there will not be one.** Pause is a safety lock that prevents stray taps when the player is off the floor. It is not a timer, minutes played are not tracked, and adding on-floor tracking would put real burden on the parent for little return. Design around its absence rather than approximating it.

What exists and is trustworthy:

`sequence_no` is a monotonic counter within a game. It is the array index, it is exact, and it is what every chronological feature should read. Order never depends on clock resolution or on two taps landing in the same millisecond.

`recorded_at` is wall clock. This is what video syncs against, since a clip has a wall-clock start and no notion of game time. No loss here: the video merge plan is unaffected because it was always going to key off wall clock.

`elapsed_ms` is wall-clock offset from `games.started_at`, stored for convenience. Requires adding `started_at` and `ended_at` to `games`.

**What `elapsed_ms` cannot do.** It measures session time, not game time. It includes halftime, timeouts, bench time, and whatever happened before the parent started tracking. It is a rough proxy for position in the game and nothing more.

**Rule:** `sequence_no` for anything about order. `elapsed_ms` for coarse buckets only, never for a displayed time, never for a claim about when in the game something happened.

Pause spans could be recorded as game metadata, since they may correlate with bench time. Worth capturing cheaply, not worth trusting or building on yet.

**Taps lag the play.** A parent taps after the possession ends, sometimes at the next dead ball, sometimes in a batch. Every `recorded_at` from `parent_tap` is accurate to roughly ten seconds. That sets the video merge window at ±8s and means no screen should ever display a precise time for a tapped event.

### Corrections

The tracker has minus steppers on every counter, and a decrement is not an event. It is a correction to one.

**Decrement voids the most recent confirmed event of that type in the game** by setting `status = 'voided'`. It never writes a negative row and never hard-deletes. Rollups already exclude anything that is not `confirmed`, so the arithmetic stays correct with no special handling. Voided rows keep their `sequence_no`, which means gaps in the sequence are normal and expected.

Retaining voids is worth the storage. Correction rate per parent and per event type is a direct measurement of tap reliability, and it is the most credible input available for a completeness heuristic before video exists.

**Design implication:** the Miss buttons and the "Made 0 minus" rows are two paths to the same counter. Both must route through the same event write and the same void logic, or the array and the totals will drift.

**Read path assumption:** the player is the unit, not the game. Cross-game player queries ("every drive going left this season") are the primary read, not the exception, and the attribute filter is what makes them possible. Game-scoped rollups still matter for reconciliation against `player_game_stats`, but they are not what the product is organized around. Index for both from the start.

### Naming: why not `game_events`

**`game_events` already exists and means something else entirely.** It is the tournament and event record (`event_name`, `event_type`, `user_id`, `player_id`), backed by an `event_types_list` lookup, and `games` carries matching `event_name` and `event_type` columns. It answers "which tournament was this game part of," not "what happened during the game."

Naming the new table `game_events` would collide with a live table and make both unreadable. It is `stat_events`.

"Event" is now overloaded in this codebase. Standing convention: **event** means tournament, **stat event** means a single observed play.

### Event type taxonomy (reconciled against the live schema)

`player_game_stats` carries exactly 17 stat fields: `points`, `fg_made`, `fg_attempt`, `two_made`, `two_attempt`, `three_made`, `three_attempt`, `ft_made`, `ft_attempt`, `off_reb`, `def_reb`, `assist`, `steal`, `turnover`, `block`, `off_foul`, `def_foul`.

Stat event types, matching those names:

`two_made`, `two_missed`, `three_made`, `three_missed`, `ft_made`, `ft_missed`, `off_reb`, `def_reb`, `assist`, `steal`, `block`, `turnover`, `off_foul`, `def_foul`

**Fouls are a split case.** `off_foul` and `def_foul` exist in the schema but have no control in the tracker UI, so they are always null or zero in practice. Including them in the taxonomy costs nothing and means no migration is needed later if a foul control ships. Roadmap 3.5 wants fouls as an availability signal.

**`fg_made` and `fg_attempt` are aggregates** of the two-point and three-point fields. This is the denormalization mismatch from Phase 1.8, and it is structural rather than a bug: the same number is stored twice. Deriving from stat events removes the second copy permanently. Nothing writes `fg_made` once the rollup view is the read path.

`points` is likewise derived, never stored.

Video may eventually emit types with no stat equivalent (`drive`, `catch`, `closeout`). Those are permitted, carry no stat weight, and exist only to feed narrative context.

### Attributes

Open jsonb, deliberately. This is where video earns its place. Nothing here affects a rating; it exists to make the development narrative specific.

```json
{
  "hand": "left" | "right",
  "direction": "left" | "right" | "middle",
  "catch_type": "catch_and_shoot" | "off_the_dribble",
  "dribbles_before": 2,
  "contested": true,
  "finish": "layup" | "floater" | "pullup"
}
```

Parent-tap events will usually have empty attributes. That is expected and fine.

**Design implication:** metric drill-down becomes possible without new metrics. Tapping PPSA can show "on 13 filmed attempts, 11 went right" as a detail on a number that already exists.

---

## 2. Source and merge rules

**M1. Parent tap wins on existence.** If a parent logged a shot attempt, that shot attempt happened. No video output can delete or contradict it.

**M2. Video enriches by attachment.** When a video-derived event matches a parent tap (same `event_type`, `occurred_at` within a tolerance window, recommended ±4s), the video row sets `merged_into` to the tap row and the tap row absorbs its `attributes` and `clip_ref`. The tap row remains the single countable event.

**M3. Video-only events are suggestions.** A video-derived event with no matching tap is written with `status = 'suggested'`. It does not count toward any stat until a parent confirms it. Dismissal sets `status = 'dismissed'` and is retained, because dismissals are the cheapest model-quality signal available.

**M4. Confidence never auto-promotes.** No confidence threshold, however high, converts a suggestion into a confirmed event without a human. This is the rule that protects the ratings, and it should not be relaxed for convenience later.

**M5. Rollups count confirmed only.** Any aggregate reads `status = 'confirmed' and merged_into is null`.

**Design implication:** the confirmation surface is a real design problem and should be scoped separately. It must not feel like homework. Best guess is a short post-game review of a handful of high-confidence suggestions, never a queue.

---

## 3. Game-level fields

```sql
alter table games
  add column logging_method      text not null default 'logged',
       -- 'logged' | 'filmed' | 'both'
  add column completeness_score  numeric,     -- nullable; 0..1; null = unknown
  add column completeness_source text;        -- 'video_derived' | 'heuristic' | null
```

`logging_method` is always known and set at game close.

`completeness_score` stays null until something can populate it honestly. Video is the first credible source: once video-derived events exist, the ratio of parent-tapped events to total observed events is a real measurement. A tap-density heuristic against age-band norms is a possible second source, but it should be validated against filmed games before it is trusted.

**Do not** infer a score from tap count alone in v1. A quiet game and a poorly logged game look identical from tap count, and guessing wrong here damages trust in exactly the place the product cannot afford it.

---

## 4. What completeness affects

### Unaffected (compute normally at any completeness)

- **PPSA.** Ratio. Survives sampling as long as misses are unbiased.
- **AST/TOV ratio.** Same reasoning.
- **Effort + Disruption score.** Weighted composite of counts, but read as a per-game figure and already noisy. No change.
- **Tier assignment for any of the above**, subject to the volume rules below.

### Affected

- **Activation minimums** (including the 5-shot-attempt insight gate). Evaluated on confirmed logged volume, unchanged. A thin game failing activation is correct behavior, not a bug. It should never be reported as the parent's failure.
- **AST/TOV Elite volume floor (assists ≥ 4).** A game where `logging_method != 'logged'` and `completeness_score` is null or below 0.8 may not *block* an Elite tier elsewhere, and must not be used as evidence of low playmaking volume in the narrative.
- **5-game rolling window.** Games below a completeness threshold still appear in the window for rate purposes but are excluded from any volume-based aggregate. Recommended threshold: 0.7, applied only when a score exists.
- **Narrative prompt.** `logging_method` and `completeness_score` are passed into `generate-game-insight` and the development narrative prompt. Language hedges accordingly. A lightly logged game should not produce a confident claim about volume or consistency.

### Never

- Completeness never changes a rating value.
- Completeness never produces an apology in the ratings UI.
- Completeness is never framed as a parent shortfall in any copy, anywhere.

**Design implication:** the FAQ needs one entry on why a filmed game may show fewer counted plays. Warm, plain, one paragraph, no hedging language.

---

## 5. Relationship to `player_game_stats`

`player_game_stats` stays authoritative through the transition. Follow the pattern already used in Phase 0.2.

1. Stat tracker dual-writes: existing aggregate columns plus one `stat_events` row per tap.
2. A rollup view derives aggregates from events and is compared against the stored columns during a parallel run.
3. Once they agree across a meaningful sample, the view becomes the read path and the aggregate columns are deprecated.

Events must never become a second source of truth running alongside the first. Either the parallel run closes or the events table is a liability.

---

## 6. The arc worth building toward

Today, a filmed game has a thinner tap log, so completeness flags a gap. As video-derived events mature, filmed games become the most complete games in the system, because the camera does not get distracted or go cheer.

The field is the same. Its meaning inverts. Design the UI so that inversion does not require a migration or a redesign, which mostly means: describe what was captured, never apologize for what was not.

---

## Open questions

1. **Sequence insights.** Which chronological patterns are safe to surface. See the caution below.
2. **Fouls.** Add a tracker control now or defer with Roadmap 3.5.
3. **Confirmation UX.** Scoped separately. The constraint is that it cannot feel like a chore.
4. **Storage ceiling for `clip_ref`.** Clips are local-first. What happens on device change, reinstall, or a full photo library? Events outliving their clips is a state that needs a defined behavior.
5. **Completeness threshold values.** 0.7 and 0.8 above are placeholders. They should be set from real filmed-game data, not chosen now.

---

## What the chronological array unlocks, and what it does not

Ordered events make sequence questions answerable with no video at all: shots missed before the first make, consecutive makes, what happened on the possession after a turnover, whether production clusters in one half.

**The caution.** These patterns are seductive and mostly noise at youth sample sizes. Three makes in a row out of twelve attempts is what randomness looks like, not a hot hand. [likely] If the narrative starts explaining sequences as confidence, rhythm, or momentum, the app is generating confident fiction about a child, which is the exact failure the ratings work has avoided so far.

**Rule:** sequences may be reported as description ("made three straight in the second half"). They may not be given causal explanation. No claims about confidence, nerves, rhythm, or settling in. Where a sequence is genuinely rare, say so plainly and leave the interpretation to the parent.

One pattern that may survive the noise: **slow starts.** If a player is consistently scoreless across the opening events of many games, that is potentially real and actionable. Note that without a game clock this is measured in events, not minutes, which makes it weaker than it first sounds: a game where the parent logged little early looks identical to a game where the player did little early. It needs the rolling window to establish and should be held to a high bar before it reaches a parent.

---

## Sequencing

**Now (schema, low risk, ships independently of video):**
1. `stat_events` table and indexes
2. `games` completeness fields, defaulting every existing row to `logged`
3. Add `started_at` and `ended_at` to `games`; tracker writes `sequence_no`, `recorded_at`, `elapsed_ms` per event
4. Tracker dual-write, including void-on-decrement through a single shared path
5. Rollup view and parallel run

**After (metric math and narrative):**
6. Completeness rules in `metrics_config.dart` and the TypeScript mirror
7. `logging_method` and `completeness_score` into both prompts
8. Sequence descriptors into the narrative prompt, under the no-causal-explanation rule
9. FAQ entry

**Then (video):**
10. Video mode writes `video_derived` events per the merge rules
11. Confirmation surface
12. Attribute-driven drill-down inside existing metrics
