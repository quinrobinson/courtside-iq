# Courtside IQ — Event Model and Video Plan

**This is the expansion of roadmap item 3.2 (event-level pattern analysis).** It is not a new roadmap. `stat_events` is 3.2's actual shape, and video is what 3.2 makes possible.

Detail spec: `docs/event-model-spec.md`. Read it before any schema or tracker work.

---

## Naming, before anything else

Three plans in this repo use overlapping phase numbers and it has already cost real confusion:

| Document | What its phases mean |
|---|---|
| `docs/courtside-iq-roadmap-v2.md` | Feature roadmap, Phases 0–3 |
| `docs/overhaul-plan.md` | Design system overhaul, Phases 0–7. Its Phase 4 is spacing migration. |
| The `phase-4-*` branches | The **2.0 Rebuild**, items 4.x. Renamed from "Phase 4" 2026-09-13; numbers kept. |

**Done 2026-09-13 (G0.5):** the workstream is renamed **2.0 Rebuild**. Item numbers are
deliberately unchanged, because 157 files in `lib/` and `test/` carry `Phase 4.x` in their headers.

**Still open:** the source document is on `main`, but STALE - 699 lines with Phases 0-3, against
2537 on the working branch. Not a missing file, 249 commits of drift. Cherry-picking the 2.0
Rebuild section onto `main` would put a document describing 2.0 onto a branch holding none of the
2.0 code, which is a worse lie than the gap. Needs a decision on merging the line, not housekeeping.

This plan uses **gates**, not phases, to stay out of the collision.

## Where work happens

| Tag | Meaning |
|---|---|
| **Chat** | Concepts, decisions, copy. Claude in chat. |
| **Figma** | Frames in **Courtside IQ 2.0** (`uvHb6HXvIVFwzSSXPtEVoc`), **Screens page** `65:6`, in the relevant flow section. NOT the E8n8 "Claude Code page" - that is the v1 legacy file, it has no 2.0 screens, and drafting there wasted a rebuild on 2026-07-23. Always land an approved variant before code. |
| **Code** | Claude Code, in the repo. |
| **Quin** | Only you can do it: review, device verification, product decisions. |

**The rule:** Chat before Figma, Figma before Code. No task marked Code starts before its Figma dependency has an approved variant.

---

## Gate 0 — Close what is open

**Done means:** four PRs merged, one unambiguous naming scheme, plan committed, three blocking questions answered.

| ID | Task | Where | Depends on |
|---|---|---|---|
| G0.1 | Review and merge PR #23 (photo paths, live bug) | Quin | — |
| G0.2 | Review and merge PR #22 (list skeletons) | Quin | — |
| G0.3 | Review #21 (deletes 20 files from a shipped app). Establish how "unreachable" was determined; check `lib/pages/` and generated nav | Quin + Code | — |
| G0.4 | Merge #21 then #24 (stacked) | Quin | G0.3 |
| G0.5 | Find the Phase 4 source doc, bring onto main, rename the workstream | Code | — |
| G0.6 | Fix CLAUDE.md roadmap path; add the Current work block | Code | — |
| G0.7 | Commit `event-model-spec.md` and this plan; link 3.2 in roadmap v2 | Code | — |
| G0.8 | **Palette resolution.** Read `docs/design-inventory.md`, answer which palette governs and the real hex on the orange LIVE badge | Chat | — |
| G0.9 | ~~Decide: is filming occasional and purposeful, or default for every game?~~ **ANSWERED 2026-09-13: occasional and purposeful.** | Quin | done |
| G0.10 | ~~Decide: confirm capture runs continuously alongside stat tapping~~ **ANSWERED: NO. They are modes, not simultaneous.** See below. | Quin | done |

~~G0.8 blocks every Figma task in the plan.~~ **G0.8 answered 2026-09-13:** one palette governs,
lime `#9DFF00` / orange `#FF4F00` / ink / white. The LIVE badge is `#FF4F00`, not Spark. Jade and
`#CDF330` are both dead artifacts. Full evidence in `docs/design-inventory.md` section 2.

### G0.10, answered by an existing design POC

**The question was badly posed.** It reads as ambiguous between video capture and stat capture. It
means VIDEO: does the camera run in the background while the parent taps stats?

**It was already answered**, in the E8n8 file on the **Gesture Recording** page (`1869:900`), a
completed POC that explored three directions and selected one:

> Phone down = stat tracking (full grid + Record toggle). Raise the phone = recording
> (camera-dominant, read-only stat summary, **no logging**). Lower = clip saved, back to tracking.

So tapping and filming are **mutually exclusive modes**. Also settled there: a Record toggle arms
the gesture, a ~1s arming window means a quick glance up records nothing, each raise is one
discrete clip with no pause/resume, and portrait is for tracking with landscape only while
recording.

**CONSEQUENCE — G3.10 NEEDS REWRITING.** "Rolling pre-roll buffer so a tap captures the seconds
before it" assumes tapping and filming coexist. In the selected flow a parent cannot tap while
recording, so there is no tap to pre-roll from. Either the pre-roll goes, or the interaction model
changes. They cannot both stand.

**CONSEQUENCE — G3.8 SHRINKS.** The ring buffer was the hard part of that spike. Without pre-roll
it is ordinary start/stop recording, and the real unknowns become the raise/lower state machine
(gravity vector, dwell thresholds) and whether a 1s arming window is reliable enough that a parent
never loses a clip they meant to catch.

**STALENESS WARNING for Gate 3 design.** The POC frames are drawn against the **v1** stat grid:
PTS/REB/AST/BLK/STL/TOV/PF/+/- with 2PT/3PT/1PT made-missed buttons. The shipped 2.0 tracker
(`138:611`) is different: three shot rows and six count tiles, no PF, no plus-minus. The
interaction model survives; the screens do not. Budget a redraw, not a copy-forward.

---

## Gate 1 design decisions — LOCKED 2026-09-13 (G1.1, G1.2)

Direction chosen: **per-stat ribbon plus a plain-language moment**, concepted in chat against
real data (397 prod games: median 19 events, p90 35, and 9% of games at 5 events or fewer).

| Decision | Value |
|---|---|
| Ribbons | **Three only:** Points (free throws included), Rebounds, Assists+Turnovers |
| Not ribboned | Steals, blocks. At 2-3 events a ribbon is noise. |
| Marks | Numbered, 26px. Circle 2pt, square 3pt, narrow pill ft. |
| Encoding | **Fill and shape, never green/red.** Filled = made / defensive / assist. |
| Ground | **Light.** Sits in Game Detail under a banded SectionHeader. |
| Accent | Lime, and ONLY on the marks a moment names. |
| Moments | Describe, never explain. No confidence, rhythm, or momentum. |

**Why assists and turnovers share a ribbon:** AST/TOV is already one rated metric with its own
thresholds, so the ribbon shows what the rating is made of.

**No green/red, deliberately.** Red on a child's missed shot is the thing this system avoids
everywhere else - CiBadge stopped colouring declines, Room to Grow sits on lime-wash rather than an
alarm colour. Fill and shape say the same thing without a verdict, and survive colour-blindness.

### Corrections are NOT shown — and this splits display from storage

A voided event **disappears from the ribbon and the remaining marks renumber**. The parent sees the
final state, never the correction.

**CONSEQUENCE, and it is a trap for later work:** the number on a mark is a DISPLAY INDEX over
confirmed events (1..n, contiguous), **not `stat_events.sequence_no`**. The spec is explicit that
voided rows keep their `sequence_no` and that gaps are normal, so the two numberings diverge the
moment a parent corrects anything. Anything that cites "attempt 8" to a parent means the display
index. Anything that queries the table means `sequence_no`. Never pass one where the other is
expected.

Moments are computed over the same confirmed-only sequence, so a void reshapes the moment too.

### Each ribbon is independently conditional

**A ribbon with nothing to show does not render.** No assists and no turnovers means no
Assists+Turnovers ribbon, not an empty one. Same for the other two. The combined ribbon only
vanishes when BOTH sides are zero; assists with no turnovers still has something to say.

This is not an edge case. Across 397 prod games:

| | games | share |
|---|---|---|
| All three ribbons show | 305 | 77% |
| No Assists+Turnovers ribbon | 68 | **17%** |
| No Rebounds ribbon | 38 | 10% |
| No Points ribbon | 17 | 4% |
| Whole section vanishes | 8 | 2% |

**Roughly one game in four drops at least one ribbon, and one in six is missing the
Assists+Turnovers ribbon specifically.** The section has to look deliberate at one, two, or three
ribbons - a layout that only reads well at three is wrong for a quarter of games.

### Empty is absence, not an empty state

A game with nothing to show **drops the whole section**, header included. No "no plays yet" copy,
no zero. This follows the standing rule that a zero-performance game returns no rating and displays
nothing. 8 of 397 prod games are affected.

### Frames actually needed

The plan listed six states. Two collapse once the above is settled:

| State | Frame? |
|---|---|
| Post-game, typical, all three ribbons (19 plays) | yes |
| Two ribbons, Assists+Turnovers absent | yes - 17% of games |
| Sparse (3 plays) | yes - 9% of games |
| Long-game density (35+, p90) | yes |
| Empty | yes, and it is Game Detail with the section absent |
| Voided entry | **no frame.** Renumbering means there is nothing to draw. |
| Live, during the game | **OPEN.** See below. |

**Live is still undecided.** The ground chosen is light; the tracker is ink throughout. Putting a
light block in the tracker is a departure, and the tracker is the one screen that must never lose
data. Recommendation: **post-game only for Gate 1**, revisit live afterwards. Not yet confirmed.

## Gate 1 — `stat_events` foundation

**Done means:** every tap writes a stat event, the timeline is visible, aggregates derive from events, and the old columns are deprecated. **No video in this gate.**

### Design

| ID | Task | Where | Depends on |
|---|---|---|---|
| G1.1 | ~~Game timeline concepts~~ **done** - three directions concepted visually | Chat | done |
| G1.2 | ~~Pick a direction~~ **done** - ribbon + moments hybrid | Quin | done |
| G1.3 | ~~Figma: timeline frames~~ **done** - five states drawn | Figma | done |
| G1.4 | ~~Figma: how the timeline sits inside game detail~~ **done** - built by cloning the real screen | Figma | done |
| G1.5 | ~~Approve a variant~~ **APPROVED 2026-09-13** | Quin | done |

### G1.5 APPROVED 2026-09-13 — what was signed off

**Where:** Figma page **Gate 1 — Game Timeline (WIP)** in `uvHb6HXvIVFwzSSXPtEVoc`. Five frames,
left to right: TYPICAL (19 plays, median), TWO RIBBONS (18 plays, no assists or turnovers), SPARSE
(3 plays), DENSE (35 plays, p90), EMPTY (section absent).

Built by **cloning the real Game Detail frame** and inserting the section into its existing vertical
auto-layout, so the header, stat tiles, insight card and Development rows are the live components
rather than redrawn approximations. G1.4 is satisfied by construction.

**Final encoding**

| | |
|---|---|
| Marks | 26px, numbered. Circle 2pt, square 3pt. |
| Free throws | Circles **enclosed by an outline**, one enclosure per TRIP to the line. A single shot reads as a double ring, a pair as a capsule. |
| FT circle size | **20px**, with a 14px internal gap. Forced by the grid: 26 mark + 8 gap = 34 pitch, so a 1-shot trip must be 26 wide and a 2-shot trip 60. |
| Row | **10 marks per row** at an 8px gap. Rows containing a trip hold fewer, because wrap fills by width. |
| Fill | Filled = made / defensive / assist. Outline = missed / offensive / turnover. |
| **Accent** | **NONE.** No lime anywhere in the section. |
| Values | Every number carries its unit: `22 PTS`, `5 AST  2 TO`, with a muted subline for detail. |
| Header | The existing `SectionHeader` component, retitled "How the game went", count in its Tag property. |

**No accent, deliberately.** A lime run-highlight was tried and rejected: three in a row is legible
on its own, and colouring it is the app telling a parent what to notice rather than letting them
see it. The accent stays unspent and available if something later genuinely earns it.

**SCORING MIX IS RETIRED.** The ribbons say what it said, in sequence. Its SectionHeader instance
was reused rather than replaced.

**Moments are optional, not fixtures.** A ribbon whose sample cannot support a pattern gets no
moment line. Four rebounds gets none; the SPARSE frame has none at all. Manufacturing a pattern
from three events is the failure mode the whole no-causal-explanation rule exists to prevent.

**Sparse still renders its ribbons.** Two shots and one rebound show as two thin ribbons rather
than hiding the section. The parent logged those plays; hiding them would read as lost data.

### SUPERSEDED 2026-09-15 — the ribbon direction was replaced by LANES

Everything in the G1.5 section above describes the **ribbon** direction. It was approved on
2026-09-13 and replaced two days later after exploring alternatives. Kept rather than deleted
because the reasoning matters.

**Why it changed.** Three independent per-stat ribbons cannot show a relationship BETWEEN stat
types. "The turnover came just before the run, not during it" is unsayable with three separate
sequences and obvious with one shared axis. That is a capability difference, not a restyle.

### APPROVED 2026-09-15 — LANES

Figma page **Gate 1 — Game Timeline (WIP)**, five frames at the left of the page. The five ribbon
frames sit to their right at 45% opacity, prefixed SUPERSEDED.

| | |
|---|---|
| Structure | One row per stat, all on ONE shared sequence axis |
| Lanes | **Points, Rebounds, Playmaking, Defense** - four, not five |
| Row | Label and value on the LEFT (82pt column), track on the right, full-bleed hairline between rows |
| Track rule | **Dotted**, gray300 `#C9C9C9`, 1.8pt, `dashPattern [0.01, 3.6]` with ROUND cap |
| Marks | Circles. Filled = made / defensive / assist / steal. Hollow = missed / offensive / turnover. |
| Free throws | **Enclosed by a white-filled capsule**, one per TRIP to the line. The white fill INTERRUPTS the dotted rule rather than overlapping it. |
| Axis | **Start and End**, never play numbers |
| Accent | **None** |

**Playmaking is combined, and the prod data is why.** Assists and turnovers were briefly split into
separate lanes. Across 397 games a Turnovers lane would be absent in **39%** of them and Assists in
33%, where a combined lane is absent in only 17%. All five lanes appeared in just **144 of 397
games (36%)**, so a five-lane layout was the minority case. Four lanes with a combined Playmaking
lane is the stable shape. Filled assist, hollow turnover, the same convention every other lane uses.

**Marks scale with the play count:** `clamp(trackWidth / plays - 1, 7, 13)`. At 35 plays the
spacing is 6.97pt, so a fixed 13pt dot would overlap its neighbour by half. Resolved sizes: 13 at
3 plays, 12.6 at 18, 11.8 at 19, 7 at 35. **The approved TYPICAL frame is still drawn at a fixed
13**, which is why its two adjacent Playmaking marks touch; the production component should use the
formula.

**No play numbers on the marks.** They were in the ribbon and do not fit at 13pt or below. A play
index is meaningless to a parent anyway, so moments describe position in words instead.

**Lane absence rates, from prod:** Points 4%, Rebounds 10%, Defense 25%, combined Playmaking 17%.
Average 3.89 lanes per game. A lane with no events does not render; a game with no events drops the
whole section.

### Known gaps in the approved frames

- **Copy is placeholder.** Written to keep numbers self-consistent, not through a copy pass.
- **The EMPTY frame is not a truthful whole screen.** It still shows Development rows and an
  insight card, which a genuinely zero-event game would not have. Only its TIMELINE behaviour is
  correct; the rest of that screen is a separate question.
- **The frames live on a WIP page, not the Screens page.** Deliberate. Decide before build whether
  the canonical Game Detail (`145:610`) is updated to match, or these stay as the reference.

### G1.6 / G1.7 applied to TEST 2026-09-15

Files: `supabase/migrations/20260915000000_stat_events.sql` and
`20260915000001_games_started_ended_at.sql`. **Test only**
(`yihmccmyijtyrffpzstb`). Prod untouched.

Verified after applying: 14 columns, RLS on, **4 policies and zero
`USING (true)`**, 7 indexes, **zero grants to `anon`**, both `games` columns
present, and 0 games carrying a `started_at` (nothing was backfilled).

**Ownership mirrors `player_game_stats`** - through `games.user_id`, not
`players.user_id`. Note `games.user_id` is TEXT while `players.user_id` is
UUID; this table is game-scoped so it follows the games side and casts.

**No `USING (true)`, four separate policies.** Permissive policies union with
OR, so a blanket policy is not additive - it becomes the ceiling and silently
voids the strict rule beside it. That is what leaked `game_events` on
2026-07-29.

**`started_at` is NOT backfilled.** All 397 existing games get null, because
`created_at` is when the row was WRITTEN - for a game queued offline that can
be days after it was played. Inventing a start time would make `elapsed_ms`
lie. Null means unknown and has to keep meaning unknown.

**Video-only event types are NOT in the CHECK constraint.** The spec permits
`drive` / `catch` / `closeout` eventually, but they are speculative names and
Gate 4 is gated on a spike that may fail outright. Adding them is a one-line
migration when they are real. `off_foul` and `def_foul` ARE included: those
columns already exist in `player_game_stats`, they are logged separately and
aggregated into one foul total, and including them avoids a migration if a
foul control ever ships.

**Promotion to prod happens after the G1.12 parallel run**, following the same
path 4.20b used. The schema is additive and safe to promote early; what must
not happen early is DEVELOPING against prod, because the G1.10 dual-write
turns every test tap into a real play inside a real family's game.

### Build

| ID | Task | Where | Depends on |
|---|---|---|---|
| G1.6 | ~~Migration: `stat_events` table and indexes~~ **APPLIED TO TEST 2026-09-15** | Code | done |
| G1.7 | ~~Migration: `started_at` / `ended_at` on `games`~~ **APPLIED TO TEST 2026-09-15** | Code | done |
| G1.8 | ~~Tracker writes `sequence_no`, `recorded_at`, `elapsed_ms` per tap~~ **DONE 2026-09-15** | Code | done |
| G1.9 | ~~Void-on-decrement, routed through one shared write path shared by the Miss buttons and the minus steppers~~ **DONE 2026-09-15** | Code | done |
| G1.10 | ~~Dual-write alongside the existing aggregate columns~~ **DONE 2026-09-15** | Code | done |
| G1.11 | ~~Rollup view deriving all 17 fields from events~~ **APPLIED TO TEST 2026-09-22** | Code | done |
| G1.12 | ~~Parallel run: compare view against stored columns until the coverage bar below is met~~ **DONE 2026-09-27: coverage bar met, 5 games, zero mismatches** | Quin | done |
| G1.13 | ~~Build the timeline UI from the approved Figma variant, and read it on Game Detail~~ **DONE 2026-09-23: [x] built [x] wired [x] device-verified** (table redesign, see below) | Code | done |
| G1.14 | ~~Cutover: events become the source of truth, `player_game_stats` a derived cache~~ **DONE 2026-09-27: [x] built [x] wired [x] device-verified** (reworded, see below; TEST only) | Code | done |

**G1.13 shipped the read path as well as the widget (2026-09-22).** Game Detail now reads a
game's `stat_events` and renders the lanes where Scoring Mix used to sit; Scoring Mix is retired
rather than moved, since the timeline says the same thing about how the points broke down and says
it in sequence. A game with no events shows no section at all, which is every game logged before
G1.10, so nothing regressed for the existing 397.

**G1.12 FIRST REAL GAME PASSED (2026-09-22).** One game tracked on a device against TEST: 12
rows, 1 voided (a deliberate take-back), 11 confirmed, `mismatched` empty on all 17 fields. The
chain from a real tap through the offline queue to a real row now works. One game is not the
"meaningful sample" G1.14 needs, so G1.12 stays open.

**G1.13 TABLE REDESIGN: BUILT, WIRED AND DEVICE-VERIFIED 2026-09-23.** Signed off on the phone,
including the scroll past 22 plays and the free-throw clearance.
Seeing the lanes on a phone showed two problems: every lane said its stat twice (POINTS above,
PTS beside), and Start/End sat under the tracks where nobody read them. A second pass on
2026-09-23 found the dense game illegible at 6pt marks, and the summary line floating.
Frames on the Gate 1 page, all on system tokens:
`TABLE · TYPICAL (19 plays)` 1013:567, `TABLE · DENSE (35 plays) · scrolls, at tip-off` 1018:569,
`TABLE · DENSE (35 plays) · scrolled to final` 1018:5523.
What changes in `game_timeline.dart`:
- Three edge-to-edge columns: label | timeline | stat. Every row has the Development rows' bottom
  hairline (`color/hairline`); the timeline column also has that hairline on its left and right
  edges. The timeline column is `color/surface-sunk`.
- Labels are the hero's abbreviations in the hero's caps style, `text-muted`: PTS, REB, AST·TO,
  STL·BLK. The stat column is Light 16 (the hero's secondary stats are Light 20), right-aligned.
  Each number is said once.
- A header row above the lanes, in the timeline column only: TIP-OFF, an arrow, FINAL, in
  `color/text`. The old Start/End footer goes.
- **Label and stat columns are both 74pt** (balanced 2026-09-23; the stat column was 55 and
  crowded "5·2" against the timeline's edge).
- **Scroll threshold: a 10pt minimum spacing, which is 22 plays at the design width** (it was 24
  before the columns were balanced; the rule held, the count moved). Up to 22, the track fits the
  column and marks scale 13 down to about 9pt. Above 22, spacing is fixed at 12pt with 11pt marks
  and the timeline column scrolls
  horizontally. Labels and totals stay pinned; the header and all four lanes scroll as ONE unit
  (the shared axis is the point of the design); it opens at tip-off; a right-edge fade in
  `surface-sunk` shows until the end is reached. From 391 prod games: p50 19, p75 27.5, p90 35,
  max 181. 148 of 391 games (38%) scroll; the rest stay static.
- Hollow marks and free-throw enclosures fill with `surface-sunk`, not white.
- **A free-throw trip gets room for its enclosure** (found on device 2026-09-23: a miss then two
  made free throws, and the capsule ran underneath the miss). Each trip adds 3.5pt before its
  first play and after its last, on the WHOLE axis since every lane shares one order, so the gap
  from the capsule to its neighbour equals the gap between any two plain marks. The clearance
  counts toward the scroll threshold: a 22-play game with a trip to the line scrolls.
- The summary line ("moment") takes the insight wash: `accent/lime-wash` fill, the `Icon/spark`
  used by the insight card, `color/text` copy, bottom hairline. Lime-wash plus spark already means
  "Courtside IQ noticed this" on this screen. NOTE: nothing generates a moment yet; the widget
  renders one only when given one.
- The section header stays the standard `CiSectionHeader` with the play count.
- Defense counts steals AND blocks; the old `STL` unit was wrong and STL·BLK fixes it.

**G1.12 DONE 2026-09-27. G1.14 IS UNBLOCKED.** (Was: the only thing blocking G1.14.)

**G1.14 REWORDED 2026-09-27: events are the source of truth; the stored columns are a cache the
database maintains.** "The view becomes the read path, aggregate columns deprecated" cannot be done
as written: almost every game has no events (every game before G1.10, every game from an app
version that does not write them), so reading stats from the rollup would blank them. The 17
columns stay and keep their meaning, and every reader (both views, the snapshot trigger, both
insight functions, seven app repositories) is untouched. What changed is who decides the values.

- Migration `20260927000000_stat_events_source_of_truth.sql`, **applied to TEST 2026-09-27**:
  - BEFORE INSERT/UPDATE on `player_game_stats`: for a (game, player) with ANY `stat_events` row,
    the 17 fields are overwritten from `v_stat_event_rollup`. No events, no change: older app
    versions and every existing game keep their client totals.
  - AFTER INSERT/UPDATE/DELETE on `stat_events` (statement-level): re-derives the affected rows.
  - AFTER UPDATE on `player_game_stats`: refreshes that game's trend snapshot, only when a total
    really changed (the snapshot trigger is insert-only and never recomputed).
  - Probed on TEST in a rolled-back transaction, 8 cases, all pass: no-events keeps client totals;
    wrong client totals overridden; a retry overwrite re-derived; void a made 3; late events;
    all voided gives zeros; events deleted hands control back; no-op update leaves snapshots alone.
  - Existing data unchanged (stats hash and snapshot count identical before and after).
- App: `lib/courtside_iq/game_sync/game_upload_steps.dart` owns the upload order, now games, then
  stat_events, then player_game_stats, then the insight. **A failed events upload now fails the
  upload** and the game stays queued; before, it was logged and swallowed. 5 tests.
- `v_stat_event_reconciliation` stays as a tripwire: empty-mismatched by construction now, so a
  non-empty row means a trigger was dropped or bypassed.
- **Device-verified 2026-09-27:** game `fecd7df8` tracked on a phone against TEST, 16 rows
  (2 voided: a block and a steal), 14 confirmed, stored 8 = derived 8, `mismatched` empty; events
  written ~1s after End Game, insight generated after the stats row.
- **Not yet:** promotion to prod, a reviewed step together with `stat_events` itself and an app
  release that writes events.

`[x] built` · `[x] wired` · `[x] device-verified`

**GATE 1 COMPLETE ON TEST (2026-09-27).**

**G1.12 EXIT BAR — DECIDED 2026-09-27: coverage, not count.** "Meaningful sample" had no finish
line. More ordinary games repeat paths that already pass; coverage is what finds bugs. G1.12 is
done when every row of `v_stat_event_reconciliation` has an empty `mismatched` AND the tracked
games, together, have exercised every path below. Games do not need to be real matches: tapping
through on a device against TEST at home counts.

Covered by the two games on TEST as of 2026-09-27 (11 and 32 plays, both clean):
- [x] 2s, 3s, free throws, makes and misses
- [x] offensive and defensive rebounds, assists, steals, turnovers
- [x] a voided (taken-back) non-scoring play (an assist)
- [x] a dense game past the 22-play scroll threshold (32 plays)

Covered by three more games on TEST, 2026-09-27 (all clean):
- [x] **a block** - in all three
- [x] **a take-back of a made 2 or 3** - `ae4f21ce`: a made 3 voided; stored and derived points both 0
- [x] **a game tracked offline, then synced** - `066c4b66`: ended 00:51:52, rows written 00:52:10.
  Online games write in the same second as End Game, so these came from the queue on reconnect
- [x] **the app force-quit mid-game, then resumed** - `066c4b66`: quit between play 4 (FT made)
  and play 5 (assist), confirmed by Quin; sequence 1-7 contiguous, no duplicates, a voided block
  after the restart

**Result: 5 games, 65 rows (12+32+2+12+7), `mismatched` empty on every row. Bar met.**

**Found along the way (not a G1.12 defect):** a game cannot be STARTED offline. New Game shows
"You're offline" when the players list cannot load, by 4.5's design (offline covers tracking and
saving, not setup). Test procedure: start online, go offline before the first tap. Whether a
parent with no signal at the gym should be able to start a game (cached players list) is a product
question, and a user-visible change that needs Figma first.

Check after each game: `select game_id, plays, mismatched from v_stat_event_reconciliation;` plus,
for the offline game, `max(created_at - recorded_at)` on its `stat_events` to confirm it really
replayed from the queue.

**G1.8 risk RESOLVED 2026-09-13, and the premise was void.** The tracker cannot be regenerated:
FlutterFlow was retired 2026-07-19, there is no `.flutterflow` project link in the repo, and
`lib/pages/` was deleted in 4.24. The 2.0 tracker is `lib/features/games/live_tracker_page.dart`,
hand-written and measured from `138:611`. `lib/custom_code/` is also the wrong destination now: it
is the FF bridge directory, down to five live action files.

**And the shared write path G1.9 asks for already exists.** `_tap(LiveStat, int delta)` at
`live_tracker_page.dart:105` is already the single funnel for every make, miss and undo, minus
steppers included. G1.9 is satisfied by construction.

Remaining real work is ordinary, roughly half a day, and folds into G1.10: write the event inside
`_tap`, extend `LiveGameSnapshot` to carry the array, and handle the OFFLINE QUEUE - the one
genuinely interesting part, since `game_sync_queue` replays built rows across app versions and
would need to carry events too.

---

## Gate 2 — Surfaces the events unlock

**Done means:** completeness is honest and visible, and a parent can drill into a metric. Still no video.

### Design

| ID | Task | Where | Depends on |
|---|---|---|---|
| G2.1 | Game detail with logging method. Filmed and logged read differently, neither looks lesser | Chat → Figma | G1.5 |
| G2.2 | Metric drill-down concepts. What a parent sees when they tap PPSA | Chat | G1.14 |
| G2.3 | **Lock the attribute list.** Which attributes the drill-down needs. This is what Gate 4 must eventually produce, so the design decides the CV target | Chat | G2.2 |
| G2.4 | Figma: drill-down frames, plus the zero-attribute state for unfilmed games | Figma | G2.3 |
| G2.5 | Copy: completeness language, FAQ entry, About this story update | Chat | G2.1 |

### Build

| ID | Task | Where | Depends on |
|---|---|---|---|
| G2.6 | `logging_method` and `completeness_score` on `games` | Code | G1.14 |
| G2.7 | Completeness rules in `metrics_config.dart` and the TypeScript mirror | Code | G2.6 |
| G2.8 | Both fields into both Edge Function prompts | Code | G2.7 |
| G2.9 | Sequence descriptors into the narrative prompt, under the no-causal-explanation rule | Code | G2.8 |
| G2.10 | Drill-down UI | Code | G2.4 |

---

## Gate 3 — Recording, no CV

**Done means:** a parent films a game and sees film attached to what they logged. Nothing automatic. This is the largest engineering gate in the plan.

### Design

| ID | Task | Where | Depends on |
|---|---|---|---|
| G3.1 | Capture mode concepts. Three states: Framed, Tapping, Down. How a parent enters and exits, what they see, what they never have to manage | Chat | G0.9, G0.10 |
| G3.2 | **Dark mode system.** If the design inventory shows dark is undocumented, define it as a token set before drawing capture screens | Figma | G0.8 |
| G3.3 | Figma: capture UI in all three states, portrait and landscape | Figma | G3.1, G3.2 |
| G3.4 | Figma: framing coach. Quiet rim indicator, one signal at a time | Figma | G3.3 |
| G3.5 | Figma: post-game capture summary. Warm, plain, never a grade on the parent | Figma | G3.3 |
| G3.6 | Figma: how clips appear inside the development story and game detail. No new nav item | Figma | G2.4 |
| G3.7 | Copy pass on everything in this gate | Chat | G3.5 |

### Build

| ID | Task | Where | Depends on |
|---|---|---|---|
| G3.8 | **Capture spike.** Can a custom camera widget with a rolling buffer live in this FlutterFlow app at all? Answer before committing to the gate | Code | — |
| G3.9 | Camera capture widget in `lib/custom_code/` | Code | G3.8 |
| G3.10 | Rolling pre-roll buffer so a tap captures the seconds before it | Code | G3.9 |
| G3.11 | Raise and lower state machine. Gravity vector against the optical axis, dwell thresholds, tuned loose: over-capture, never under-capture | Code | G3.9 |
| G3.12 | Local-first clip storage and metadata | Code | G3.10 |
| G3.13 | `clip_ref` written onto stat events | Code | G3.12 |
| G3.14 | Capture UI build | Code | G3.3, G3.9 |
| G3.15 | Post-game capture summary build | Code | G3.5, G3.12 |
| G3.16 | Clip playback inside the development story | Code | G3.6, G3.13 |

**G3.8 is a real gate on the gate**, and stays one. Scoped 2026-09-13 at **2-3 days**, throwaway
branch, nothing merged.

Already present: `NSCameraUsageDescription`, `android.permission.CAMERA`, and `video_player` for
playback. Absent: any camera CAPTURE plugin - only `image_picker` and `video_player` are in
`pubspec.yaml`, so `camera` is a new dependency and needs flagging per CLAUDE.md.

**The hard part is the rolling buffer, not the camera.** The `camera` plugin records start-to-stop
and gives no pre-roll. A tap-captures-the-previous-seconds buffer needs either continuous segmented
recording into a ring of short files, or a platform channel over `AVCaptureSession` and CameraX
`ImageAnalysis`. Second risk: iOS is hybrid SPM + CocoaPods since Flutter 3.44, with five plugins
already lacking SPM support and Flutter warning that becomes an error.

Day 1 preview on real iOS and Android hardware, confirming the hybrid build survives. Day 2 a
10-second ring buffer, measuring memory and thermals across a simulated 90-minute game. Day 3
whether buffer plus preview can coexist with the tracker UI's tap responsiveness - **a dropped tap
is worse than a missing clip.**

---

## Gate 4 — CV

**Gated on the feasibility spike. If the spike fails, this gate does not exist.**

### Design

| ID | Task | Where | Depends on |
|---|---|---|---|
| G4.1 | Suggestion confirmation concepts. Cannot feel like homework. Short post-game review, never a queue | Chat | G4.5 |
| G4.2 | Figma: confirmation surface, including the dismiss path | Figma | G4.1 |
| G4.3 | Figma: attribute drill-down extension, now with real data behind it | Figma | G2.4 |

### Build

| ID | Task | Where | Depends on |
|---|---|---|---|
| G4.4 | Integrate on-device pose and rim detection | Code | Spike passes, G3.16 |
| G4.5 | Attribute extraction over clip-scoped windows only. Never whole-game | Code | G4.4 |
| G4.6 | Write `video_derived` events per the merge rules in the spec | Code | G4.5 |
| G4.7 | Confirmation flow | Code | G4.2, G4.6 |
| G4.8 | Populate `completeness_score` from the tap-to-observed ratio | Code | G4.6 |

---

## Runs in parallel, starting now

### CV feasibility spike

Throwaway code. Not a gate, no design, no repo commitment.

**Question:** can on-device pose plus rim detection produce reliable attributes from handheld phone footage at a real youth game?

**Method:** film one game from where a parent normally stands. Run pose estimation and a rim detector over ten-second windows. Check whether handedness, drive direction, and catch type come out consistently.

**Why now:** if the answer is no, Gate 4 does not exist, and that changes what gets designed in Gate 3. Cheap, independent, and the highest-information thing available today.

---

## Guardrails

- **Design before schema.** The schema serves the screens. No `stat_events` migration before the timeline design is settled.
- `game_events` already exists and means **tournaments**. The new per-play table is `stat_events`. In this codebase, *event* means tournament and *stat event* means a single observed play.
- **Video is additive only.** No new nav item, no metric that requires film, no narrative section empty without it. A parent who never records has a complete product.
- **Parent taps are truth.** Video enriches an existing tap and never overwrites it. No confidence score auto-promotes a suggestion.
- **No face embeddings** anywhere in the CV pipeline.
- **On-device, clip-scoped inference only.** Never whole-game, never cloud video. No tripod, dock, or hardware purchase.
- **Completeness** never changes a rating value and is never framed as a parent shortfall.
- **Sequences** may be described, never causally explained.
