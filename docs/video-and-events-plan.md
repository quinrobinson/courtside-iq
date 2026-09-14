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
| G1.1 | Game timeline concepts. 2–3 directions: what a parent sees, live versus post-game, how runs read, how a voided tap reads, density over a long game | Chat | G0.8 |
| G1.2 | Pick a direction | Quin | G1.1 |
| G1.3 | Figma: timeline frames. States needed: live during game, post-game, empty, single-entry, long-game density, voided entry | Figma | G1.2 |
| G1.4 | Figma: how the timeline sits inside the existing game detail screen without becoming a box score | Figma | G1.3, design inventory |
| G1.5 | Approve a variant | Quin | G1.4 |

### Build

| ID | Task | Where | Depends on |
|---|---|---|---|
| G1.6 | Migration: `stat_events` table and indexes | Code | G0.7 |
| G1.7 | Migration: `started_at` / `ended_at` on `games` | Code | G0.7 |
| G1.8 | Tracker writes `sequence_no`, `recorded_at`, `elapsed_ms` per tap | Code | G1.6 |
| G1.9 | Void-on-decrement, routed through one shared write path shared by the Miss buttons and the minus steppers | Code | G1.8 |
| G1.10 | Dual-write alongside the existing aggregate columns | Code | G1.9 |
| G1.11 | Rollup view deriving all 17 fields from events | Code | G1.10 |
| G1.12 | Parallel run: compare view against stored columns across a real sample | Code + Quin | G1.11 |
| G1.13 | Build the timeline UI from the approved Figma variant | Code | G1.5, G1.11 |
| G1.14 | Cutover: view becomes the read path, aggregate columns deprecated | Code | G1.12 |

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
