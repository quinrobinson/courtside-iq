# Courtside IQ — Holistic Roadmap (v2)

**Scope:** Migration from Buildship to Supabase Edge Functions, data model improvements, metric math refinements, age-aware ratings, and the player-level development narrative feature. Each item includes design implications so nothing ships without considering the parent-facing experience.

**Guiding principle:** Every change must reinforce the development-first positioning. Numbers connect to growth language. Ratings feel earned. Copy is warm and parent-friendly. Tier hierarchy stays consistent: Solid → Good → Elite.

**Decisions locked in (v2 update):**
- Age data: birth date (year + month) captured in Phase 1; age-band PPSA thresholds ship with Phase 1
- Rolling window for development narrative: last 5 games (fixed)
- Minimum games threshold for narrative unlock: 5 games
- Season concept: deferred to Phase 3 (rolling window handles immediate need)
- Models: Haiku for per-game insights, Sonnet for development narrative
- Parallel run duration: 1 week (schedule during active-use period)
- Beta group for Phase 2: yes, requires beta infrastructure setup inside Phase 2

---

## Status tracker

**Definition of Done:** a phase item is only complete when all three boxes are checked. "Built" alone is not "done" — the AddPlayerSheet shipped in Phase 1.2 but wasn't wired to call sites until Phase 1.12, costing real user value in between.

- `[b]` **Built** — code/migration/function exists in the repo
- `[w]` **Wired** — every call site, route, or entry point uses it
- `[v]` **Verified** — observed working on a real device/prod build (not just `flutter analyze`)

### Phase 0

| Item | b | w | v | Notes |
|---|---|---|---|---|
| 0.1 Centralize tier thresholds | ✅ | ✅ | ✅ | `metrics_config.dart` + disrupt call sites fixed (PR #1, #8) |
| 0.2 `game_insights` → jsonb | ✅ | ✅ | ✅ | View exposes jsonb; client shim decodes both shapes (PR #10) |
| 0.3 Merge `player_game_insights` | ✅ | ✅ | ❓ | Confirm legacy table dropped on prod |
| 0.4 PPSA FT-only edge case | ✅ | ✅ | ❓ | Verify with a real FT-only game |
| 0.5 Clean up `environment_values.dart` | ❓ | ❓ | ❓ | Unconfirmed — investigate |

### Phase 1

| Item | b | w | v | Notes |
|---|---|---|---|---|
| 1.1 `birth_date` column | ✅ | ✅ | ✅ | Test DB has column; player_profile_view exposes `age_band` |
| 1.2 Player creation with birth date | ✅ | ✅ | ✅ | `AddPlayerSheet` wired to all 5 entry points (PR #10) |
| 1.3 Existing player backfill (gate + banner) | ✅ | ✅ | ✅ | BirthDatePromptGate + BirthDateProfileBannerWidget live |
| 1.4 Edge Function fallback for null birth date | ✅ | ✅ | 🟡 | Code-path only. BirthDateGate blocks UI reach; no null-DOB players left once gate runs |
| 1.5 Age-band PPSA thresholds | ✅ | ✅ | ✅ | Verified via Jada 8U-10U game: PPSA 2.0 → Elite tier threshold applied |
| 1.6 Effort/Disruption rebalance + AST/TOV floor | ✅ | ✅ | ✅ | Dart + TS configs match spec (oreb×2/steals×1.5/blocks×1/dreb×0.5; Elite AST/TOV requires ≥4 assists) |
| 1.7 Supabase Edge Function toolchain | ✅ | ✅ | ✅ | Deploy path works (PR #5) |
| 1.8 `generate-game-insight` function | ✅ | ✅ | ✅ | End-to-end verified: Claude → jsonb → view, full payload written |
| 1.9 Per-game prompt design | ✅ | ✅ | ✅ | Varied highlight_metric observed (ppsa, disrupt). Em-dash enforcement weak, logged as tech debt |
| 1.10 FF client migration (Buildship → Edge) | ✅ | ✅ | ✅ | PR #2 merged; single route via `generateGameInsight` action |
| 1.11 `highlight_metric` tag UI | ✅ | ✅ | ✅ | Purple pill replaces fallback icon (PR #9, #10) |
| 1.12 Parallel run + cutover | ✅ | ✅ | ✅ | Buildship already removed; Edge Function verified across normal/below-threshold/age-band cases |

### Phase 2

| Item | Built | Wired | Device-verified | Notes |
|------|-------|-------|-----------------|-------|
| 2.1 `player_development_insights` table | ✅ | — | — | Table + RLS on test (migration `20260420000001`) |
| 2.2 `player_trend_snapshots` table + trigger + backfill | ✅ | — | — | Table (`20260420000002`), trigger (`20260420000003`); backfill verified: Jada 7 snapshots, Jordan 0 (below threshold) |
| 2.6 `generate-player-insight` Edge Function | ✅ | ✅ | ✅ | Deployed to test; smoke tested via `tool/smoke_player_insight.dart`; wired into `PlayerProfilePageV2` Development tab; device-verified |
| 2.x Player Profile V2 (3-tab + Development story) | ✅ | ✅ | ✅ | New screen `lib/features/player_insight/player_profile_page.dart`; reached via dev redirect in `BirthDateProfileBannerWidget` (`_kRedirectToV2Profile`); Figma baselines on Claude Code page (1532:212, 1535:212/230/253). Averages + Games tabs fully built (PRs on `phase-2-player-profile-v2`): shared picker model, profile photo editor, edit sheet, Games-tab → GameStats navigation, white-card borders, V1-parity AppBar icons |
| 2.7 Prompt tuning — growth-edge specificity | ✅ | ✅ | ✅ | `PROMPT_VERSION` bumped to `v2`; growth edge now requires concrete in-game moment + read anchored to weakest metric, max 22 words, no volume goals; device-verified on Jada (skip-pass weak-side wing read) |
| 2.8 Narrative split into 3 sections (Bright Spots / Room to Grow / Watch for Next) | ✅ | ✅ | ✅ | `PROMPT_VERSION` → `v3`; Edge Function returns `whats_working` + `needs_development`; color-coded accent sections in `development_story_card.dart` (green/magenta/purple); v2 cache purged on test |
| 2.9 Below-threshold state copy and design | ✅ | ✅ | ✅ | Figma V2 "preview" variant chosen (Claude Code page, `1571:305`); `_BelowBody` renders dynamic chip + headline + progress + 3 ghost accent sections at 0.4 opacity; device-verified on 4/5 and 0/5 profiles |
| 2.10 Cache-aware loading UX | ✅ | ✅ | ✅ | Parallel client-cache read + Edge Function refresh; `AnimatedSwitcher` fade-swap on arrival; refresh-failed-while-cached state hides trend pill and shows neutral-gray retry chip (Figma `1592:268`). No "Updated" pill — discarded as noise since parents log games themselves |
| 2.11 In-context "About this story" tooltip | ✅ | ✅ | ✅ | Tappable footer on Development tab opens `AboutStorySheet` bottom sheet (Figma `1595:243`) with "How this story is created" + "Why it changes". Help Center FAQ entries dropped from scope to avoid FF edits |

**Parked for Phase 2:**
- **`highlight_metric` selection logic.** Currently Claude picks freely from `ppsa | ast_tov | disrupt | effort | null` with no rules in the prompt, so selection can feel arbitrary across similar games. Decide between (a) adding explicit selection rules to the prompt (e.g. "pick the highest-tier metric"), or (b) computing the highlight server-side and passing the choice to Claude. Tie the decision to the Phase 2 narrative prompt design work.

### Outstanding tech debt / follow-ups

- Backfill `highlight_metric` on prod (test manually backfilled for testuser)
- Edge Function should always write a non-null `highlight_metric` (root cause of the null-values-but-key-exists bug)
- Mirror null-safety fixes (`CreateNewWidget`, `HomeWidget:837`, `NewGameWidget:484`) in FlutterFlow before next regeneration
- Client-side below-threshold short-circuit in `game_stat_tracker_widget` duplicates server-side logic; consolidate or document which wins
- Claude ignores the "no em dashes" prompt rule intermittently; strengthen prompt or add post-process strip before jsonb write
- Profile screen doesn't auto-refresh after birth-date backfill sheet closes; needs invalidation on return
- Rebuild path broken: `flutter pub get` pulled SDK-incompatible packages; pin or revert lock before next device rebuild

---

## Phase 0 — Foundation (before any new features)

Non-negotiable cleanup that prevents tech debt from compounding once Phase 1 and 2 ship. All of this should land before the first Edge Function goes live.

### 0.1 Centralize tier thresholds

**Problem:** `disruptSolid`, `disruptGood`, `disruptElite` take threshold arguments, meaning actual cutoffs live in FlutterFlow action flows. Changing them requires hunting down every call site.

**Action:**
- Create `lib/courtside_iq/metrics_config.dart` with all thresholds as top-level constants (PPSA, AST/TOV, Effort + Disruption, activation minimums).
- Refactor `disruptSolid/Good/Elite` to read from constants instead of arguments.
- Mirror the same constants in a TypeScript module inside the Edge Functions repo so client and server always agree.

**Design implication:** Any future tier language change touches one file. Tooltip copy, FAQ entries, and insight prompts can all reference the same source of truth.

### 0.2 Convert `game_insights` from text to jsonb

**Problem:** Flat string locks us into the first prompt version. Can't A/B test, can't add structure, can't store metadata.

**Action:**
- Add `game_insights_v2 jsonb` column to `player_game_stats` (merged per 0.3).
- Define schema: `{ version, model, text, highlight_metric, tier_context, prompt_version, generated_at }`.
- Ship Phase 1 Edge Function writing both old string and new jsonb fields for one release.
- Update `v_player_game_stats` view to expose both.
- Deprecate string field after two releases of clean data.

**Design implication:** Future UI can render `highlight_metric` as a small tag next to the insight ("Scoring" / "Playmaking" / "Hustle"). Opens the door to filtering or surfacing insights by type on the dashboard.

### 0.3 Merge `player_game_insights` into `player_game_stats`

**Decision:** Merge. Put `game_insights jsonb` directly on `player_game_stats`. Drop `player_game_insights` table after migration.

**Action:**
- Add jsonb column to `player_game_stats`
- Migrate existing string insights from `player_game_insights` into new column on matching rows
- Update view definitions
- Drop old table

**Design implication:** None directly — backend hygiene. Speeds up profile load slightly.

### 0.4 Fix PPSA free-throws-only edge case

**Problem:** `ppsa()` returns `0.0` when `fgAttempted == 0`, even if the player scored from the line.

**Action:**
```dart
double ppsa(int fgAttempted, int ftAttempted, int? points) {
  if (fgAttempted == 0 && ftAttempted == 0) return 0.0;
  if (points == null) return 0.0;
  double denominator = fgAttempted + (0.44 * ftAttempted);
  if (denominator == 0) return 0.0;
  return points / denominator;
}
```

Port same logic to TypeScript for the Edge Function.

**Design implication:** Rare edge case, but parents of younger players (where FT-only games are more common) won't see a misleading 0.0 rating.

### 0.5 Clean up `environment_values.dart`

**Problem:** `FFDevEnvironmentValues.initialize()` loads JSON but never assigns decoded data. Either dead code or latent bug.

**Action:** Determine if used. If not, delete. If intended, wire up the assignment and document what it controls.

**Design implication:** None. Hygiene.

---

## Phase 1 — Migrate per-game insights + add age data + ship age-band thresholds

The biggest phase. Combines backend migration with a meaningful data model addition (age) and metric math improvements. Treat it as a real release, not a plumbing swap.

### 1.1 Add birth date to players schema

**Schema change:**
- Add `birth_date date` column to `players` table (nullable)
- Create SQL helper function `get_age_band(birth_date)` that returns '8U-10U' | '11U-13U' | '14U-18U' based on age relative to current date
- Alternative: compute age band on the fly in Edge Function

**Design implication — significant:**
- New required field on player creation flow
- New optional field on player edit flow (becomes effectively required when user wants accurate ratings)
- First-launch prompt for existing users to backfill birth date for existing players
- Copy work across creation flow, edit flow, first-launch prompt, FAQ, tooltips

### 1.2 Player creation flow update

**Action:**
- Add birth date input to player creation screen
- Use year + month picker (not full date — parents may not remember day, and we don't need it)
- Validate: birth year must produce age 3–19 (reasonable range for youth basketball, gives buffer on both ends)
- Field is required for new player creation

**Copy draft:**

> **When was [Player] born?**
>
> We use this to make sure ratings are appropriate for their age. Your player's stats are compared against others in the same age group.
>
> [Month picker]  [Year picker]

**Design implication:**
- New screen/step in player creation. Figma work needed.
- Decide: standalone step in the flow, or inline field on existing creation form? Inline is faster but the messaging matters — dedicate enough visual weight that parents understand the "why."
- Input component: stacked month + year pickers, or a single combined picker. Native iOS/Android month-year pickers vary; consider a custom simple implementation for consistency.

### 1.3 Existing player backfill flow

**Problem:** Every existing player has no birth date. The app needs to prompt users to fill this in without feeling like a gate.

**Action:**
- On first launch after the update, show a one-time modal per player: "Add [Player]'s birth year for more accurate ratings"
- Modal is dismissible; re-prompt after 7 days if still missing
- On player profile, show a subtle inline prompt at the top of the profile when birth date is missing
- Edge Function falls back gracefully when birth date is null (see 1.4)

**Copy draft (modal):**

> **Help us improve Jordan's ratings**
>
> We've added age-appropriate ratings to Courtside IQ. Set Jordan's birth year so his stats are compared against players in the same age group.
>
> [Set birth year]  [Remind me later]

**Copy draft (inline prompt on profile):**

> Set birth year for age-appropriate ratings → [tap to add]

**Design implication:**
- Modal design needed for first-launch prompt
- Inline prompt component needed for profile
- Dismissal logic: track dismissal per-player, re-prompt interval of 7 days
- Existing users shouldn't feel punished — the copy frames this as an improvement, not a correction

### 1.4 Edge Function fallback for missing birth date

**Decision:** Null birth date uses middle band (11U–13U) as the safest compromise. Flag this in the insight jsonb so UI can optionally prompt the user to add age.

**Why middle band:** Avoids the worst outcomes on both ends — 8U players don't fail to hit Elite with high thresholds, and 18U players don't hit Elite too easily with low thresholds. Middle is the safest default.

**Design implication:**
- Optional: UI can show a subtle "Ratings could be more accurate" indicator when insight was generated with fallback band
- Not required for v1 — the inline birth-year prompt already nudges users

### 1.5 Age-band PPSA thresholds

**Ship:**
- **8U–10U:** Solid ≥ 0.55, Good ≥ 0.80, Elite ≥ 1.05
- **11U–13U:** Solid ≥ 0.65, Good ≥ 0.90, Elite ≥ 1.15
- **14U–18U:** Solid ≥ 0.75, Good ≥ 1.00, Elite ≥ 1.25

**Action:**
- Add to `metrics_config.dart` as an age-band-keyed structure
- Mirror in Edge Function TypeScript
- Update `ppsaSolid/Good/Elite` functions to take age band as an argument
- Client reads age band from player record; Edge Function computes it from birth date

**Design implication:**
- Tooltip on PPSA rating needs to mention "age-appropriate" so parents understand why a 1.0 PPSA is Good for a 17-year-old but Elite for a 9-year-old
- FAQ entry explaining age bands

### 1.6 Other metric improvements

**Effort + Disruption weight rebalance:**

Current: `(oreb × 2) + (steals × 1) + (blocks × 0.5) + (dreb × 0.5)`
Proposed: `(oreb × 2) + (steals × 1.5) + (blocks × 1) + (dreb × 0.5)`

Rationale: blocks and steals are active disruption requiring timing and effort; current weights under-credit them relative to defensive rebounds.

**Design implication:** Hustle-focused players (often smaller guards) will score better relative to rebound-heavy bigs. No UI changes needed; worth a short release note mention.

**AST/TOV volume floor for Elite:**

Current Elite: ratio ≥ 4:1
Proposed Elite: ratio ≥ 4:1 AND assists ≥ 4

**Design implication:** Rare "cheap Elite" ratings go away. No UI changes.

### 1.7 Stand up Supabase Edge Function toolchain

**Action:**
- Install Supabase CLI locally
- Set `ANTHROPIC_API_KEY` as a Supabase project secret
- Create `supabase/functions/generate-game-insight/` with hello-world
- Deploy and verify auth flows from FlutterFlow with test Custom Action

**Design implication:** None — infrastructure.

### 1.8 Write `generate-game-insight` Edge Function

**Function contract:**
- **Input:** `{ game_id: string }`
- **Auth:** Supabase JWT in Authorization header
- **Output:** `{ insight: jsonb, cached: boolean }`

**Function flow:**
1. Verify auth; extract user_id from JWT
2. Fetch `player_game_stats` row for `game_id`
3. Verify the game's player belongs to the authenticated user
4. Check 5-shot-attempt gate; if below, return structured "not enough data" response and skip Claude call
5. Compute PPSA, AST/TOV, Effort + Disruption server-side
6. Fetch player birth date; compute age band (or use middle band fallback)
7. Determine tiers for each metric using age-appropriate PPSA thresholds
8. Build prompt with stats, tiers, age band, player first name
9. Call Claude API (Haiku) with prompt
10. Parse JSON response
11. Write to `player_game_stats.game_insights` (jsonb) and preserve backward-compat string
12. Return insight to client

**Why `game_id` only on input:** Moving computation server-side is cleaner, more secure, and eliminates the fg_made denormalization mismatch from the current Buildship payload.

**Design implication:** Client-side stat tracker code that previously assembled the 17-field payload gets simpler.

### 1.9 Prompt design for per-game insight

**Goals:**
- Warm, parent-friendly tone
- 2–3 sentences max (glanceable)
- References one or two specific things from the game
- Connects the number to growth language
- Suggests one small thing to watch or encourage
- No em dashes, no jargon, no raw stat recitation

**Prompt skeleton:**

```typescript
const systemPrompt = `You are a youth basketball development specialist writing a short insight for a parent about their child's game. Your voice is warm, encouraging, and grounded. You help parents see how numbers connect to their player's growth.

Guidelines:
- 2 to 3 sentences
- Use the player's first name naturally
- Reference specific tier language (Solid, Good, Elite) only when provided
- Never list raw stats; always connect them to development
- Never use em dashes
- Close with one small, encouraging observation or thing to watch for next time
- Output valid JSON only`;

const userPrompt = `Generate a game insight for ${firstName}'s recent game.

Age band: ${ageBand}
Position: ${position}

Game stats:
- Points: ${points}
- Scoring efficiency (PPSA): ${ppsa} — ${ppsaTier} for ${ageBand}
- Playmaking (AST/TOV): ${astTovRatio} with ${assists} assists — ${astTovTier || 'not yet rated'}
- Effort + Disruption: ${disruptScore} — ${disruptTier}

Return JSON with this exact shape:
{
  "text": "The insight, 2 to 3 sentences",
  "highlight_metric": "ppsa" | "ast_tov" | "disrupt" | "effort" | null,
  "tier_context": "Solid" | "Good" | "Elite" | null
}`;
```

**Design implication:**
- `highlight_metric` is new structured data the UI can use. First use: a small tag next to the sparkle icon.
- "Not yet rated" language for AST/TOV below activation threshold needs to land gracefully.
- Prompt will iterate. Expect 5–10 rounds against real games.

### 1.10 FlutterFlow client changes

**Action:**
- Replace `GetGameInsightsCall` URL and payload in `api_calls.dart`. New payload: `{ game_id }`.
- Add feature flag `FFAppState().useEdgeFunctionInsights` bool to route between Buildship and Edge Function.
- Update `game_stat_tracker_widget.dart` to route based on flag.
- Remove client-side write to `player_game_insights` — the function does it now.
- Improve error handling: surface "Insight unavailable for this game" state rather than silent failure.

**Design implication:**
- Loading states on "Creating performance insights..." don't need to change.
- Error state needs design — a subtle non-alarming indicator on the game row.

### 1.11 UI: surface `highlight_metric` tag on game rows

**Action:**
- On player profile game list, next to existing violet sparkle icon, add a small tag showing highlight metric
- Tag copy: "Scoring" / "Playmaking" / "Hustle" (maps to ppsa / ast_tov / disrupt)
- Use existing color tokens; subtle

**Design implication:**
- Small Figma design pass on game row component
- Shown only when `highlight_metric` is non-null

### 1.12 Parallel run and cutover

**Action:**
- Ship Phase 1 behind feature flag. Enable for your own account first.
- **Schedule the parallel-run week deliberately** — pick a week you know you'll log multiple games. One week is only enough if you're actively using the app.
- Log both Buildship and Edge Function outputs on the same games. Compare quality.
- After week of clean parallel run, flip flag for all users.
- Keep Buildship code for one release as rollback safety.
- Remove Buildship code and cancel subscription after two clean weeks on Edge Functions.

**Design implication:** None during parallel run. If quality regresses, iterate the prompt before flipping the flag.

---

## Phase 2 — Player-level development narrative (new feature)

The feature that makes the development-first positioning real. Treat it as a marquee release.

### 2.1 Schema: `player_development_insights` table

```
id                            uuid, pk, default gen_random_uuid()
player_id                     uuid, fk → players, not null
user_id                       uuid, fk → users, not null
generated_at_game_id          uuid, fk → games, not null
games_included_count          int, not null
insight_json                  jsonb, not null
model                         text, not null
prompt_version                text, not null
created_at                    timestamptz, default now()

unique (player_id, generated_at_game_id)
index on (player_id, created_at desc)
```

**Design implication:** Clean versioning lets you re-run old insights with newer models. `generated_at_game_id` makes cache invalidation trivial.

### 2.2 Schema: `player_trend_snapshots` (rolling 5-game metrics)

Updated on every game save via Supabase trigger or Edge Function:

```
id                            uuid, pk
player_id                     uuid, fk → players
as_of_game_id                 uuid, fk → games
games_in_window               int (fixed at 5)
rolling_ppsa                  numeric
rolling_ast_tov_ratio         numeric
rolling_assists_per_game      numeric
rolling_disrupt_score         numeric
rolling_points_per_game       numeric
ppsa_games_above_solid        int (out of 5)
ppsa_games_above_good         int
ppsa_games_above_elite        int
trend_direction_ppsa          text ('improving' | 'stable' | 'declining')
created_at                    timestamptz
```

**Design implication:**
- Enables development prompt to reference trends directly
- Unlocks future "trends chart" UI with no additional computation
- Enables consistency story in narrative ("4 of 5 games above Solid efficiency")
- One extra write per game save — acceptable cost

### 2.3 Minimum games threshold: 5

Below 5 games logged, no development narrative generated. Show below-threshold state instead.

**Design implication:**
- Below-threshold state is the single most important first-impression design element for this feature
- Parents who never reach 5 games will only see this state
- Progress ring or illustration showing games logged toward unlock
- Copy must feel encouraging, not gating

### 2.4 Rolling window: fixed last 5 games

**Decision locked:** Narrative always uses last 5 games once threshold is met. Responsive to recent form. Simple for users to understand ("story based on your last 5 games").

**Design implication:**
- UI can confidently label: "Based on [Player]'s last 5 games"
- Clear mental model for parents: the story reflects recent form
- If trajectory improves, narrative updates quickly — feels rewarding

### 2.5 Build beta tester infrastructure

**Action:**
- Set up TestFlight (iOS) and Google Play internal testing (Android) if not already in place
- Add `beta_tester boolean` column to `users` table, default false
- Feature flag in Edge Function and FlutterFlow to show Phase 2 UI only when beta_tester = true
- Build simple in-app feedback mechanism: button on development card saying "Give feedback on this story" → opens mailto or form
- Recruit 10–20 beta testers (personal network, App Store reviewers, existing engaged users)

**Design implication:**
- Beta feedback button component — subtle, non-disruptive
- Beta-only "thanks for testing" state or indicator so testers know they're in the beta
- Onboarding email or in-app first-launch note for beta users explaining what to look for

**Flag this as its own small work item inside Phase 2** — it's not free.

### 2.6 Write `generate-player-insight` Edge Function

**Function contract:**
- **Input:** `{ player_id: string }`
- **Output:** `{ insight: jsonb, cached: boolean, games_until_unlock: int | null }`

**Function flow:**
1. Verify auth; verify player belongs to user
2. Fetch latest game id for player from `games`
3. Check cache: does `player_development_insights` row exist for (player_id, latest_game_id)?
4. If cache hit, return cached insight with `cached: true`
5. If games logged < 5, return below-threshold response with `games_until_unlock`
6. Fetch `player_profile_view` for lifetime context
7. Fetch latest `player_trend_snapshots` row
8. Fetch last 5 games from `v_player_game_stats`
9. Fetch player birth date, compute age band
10. Build development narrative prompt with 5-game rolling data + age band
11. Call Claude API (Sonnet)
12. Parse JSON
13. Upsert into `player_development_insights`
14. Return insight with `cached: false`

### 2.7 Prompt design for player-level narrative

**Goals:**
- Tells a development story, not a stat summary
- Opens with trajectory, not a number
- Identifies one emerging strength
- Identifies one growth opportunity, framed positively
- Offers one specific thing the parent can reinforce
- 4–6 sentences total
- Uses player's first name throughout
- No em dashes
- Age-appropriate framing

**Output shape:**

```json
{
  "headline": "Short, encouraging one-liner, 5 to 8 words",
  "narrative": "The main development story, 3 to 5 sentences",
  "emerging_strength": "One area where growth is visible, 1 sentence",
  "growth_opportunity": "One area to keep developing, framed positively, 1 sentence",
  "parent_nudge": "Specific thing the parent can notice or reinforce, 1 sentence",
  "highlight_metric": "ppsa" | "ast_tov" | "disrupt" | "effort" | "consistency" | null
}
```

**Design implication:**
- Each field is a separate renderable element
- UI can prioritize or collapse based on space
- Prompt must handle edge cases: all-Elite player, all-below-threshold player

### 2.8 UI: Development card at top of player profile

**Placement:** Top of player profile, below name/photo block, above stats list. The development narrative is the feature that separates Courtside IQ from stat trackers — placement should reflect that.

**Layout (mobile-first):**

```
[Player name, photo, position, team]
───────────────────────────────────────
[Development card]
  [Sparkle icon]  Headline
                  Narrative paragraph

  [Three small sections]
  Emerging strength    Growth opportunity    Parent nudge
  [icon + 1 line]      [icon + 1 line]       [icon + 1 line]

  Based on [Player]'s last 5 games
───────────────────────────────────────
[Stats list, season totals, game list]
```

**Design implication:**
- New card component needed
- Reuses existing design tokens (vivid violet sparkle, existing type scale)
- Three sub-sections need iconography (emerging strength = trend up, growth opportunity = target, parent nudge = supportive gesture)
- Keep stylistically consistent with existing FFIcons
- Loading state: skeleton shimmer matching loaded shape
- Stale-cache state: render cached immediately, fire background refresh, swap with fade animation
- Below-threshold state: replace card with progress/unlock state from 2.3/2.9

### 2.9 Below-threshold state copy and design

Three games is roughly when a parent is most at risk of churning. Copy here matters.

**Copy draft:**

> **Jordan's development story is taking shape**
>
> Every game you log helps us understand Jordan's growth better. Once you've tracked 5 games, you'll see a personalized development story with emerging strengths, growth opportunities, and things to reinforce.
>
> 3 of 5 games logged ▓▓▓░░

**Design implication:**
- Uses player's first name
- Frames remaining games as progress, not a paywall
- Previews unlocked feature contents
- Simple visual progress indicator

### 2.10 Cache-aware loading UX

Three states UI must handle:

1. **No cache + below threshold** → unlock state
2. **Cache valid (latest game id matches)** → render instantly, no API call
3. **Cache exists but stale (newer games since)** → render cached version instantly, fire background call, swap when ready

**Design implication:**
- Parents open profiles often. State 3 is the performance pattern that makes this feel snappy.
- Swap animation: gentle fade, not pop
- Subtle cue when new content arrives — "Updated" pill that dismisses after a few seconds, or brief color pulse

### 2.11 Copy: tooltip and FAQ updates

**New FAQ entries (paragraph form):**
- "How is my player's development story created?"
- "How often does the development story update?"
- "Why does my player have a different development story than last week?"
- "What do emerging strength, growth opportunity, and parent nudge mean?"
- "Why does my player need to log 5 games to see their story?"
- "How does age affect my player's ratings?"

**Design implication:** Full FAQ pass. Tone must match existing voice. No em dashes. Development framing throughout.

### 2.12 Release notes and marketing

Phase 2 is a marquee feature.

**Draft release notes:**

> **Introducing Player Development Stories**
>
> Courtside IQ now goes beyond the box score. Every player profile features a personalized development story that connects your player's stats to how they're growing as a basketball player. See emerging strengths, identify growth opportunities, and get specific things to reinforce between games. Unlock your player's development story after logging 5 games.

**Design implication:**
- App store screenshots should feature the development card prominently
- One-time in-app announcement on first Phase 2 launch for existing (non-beta) users
- Consider a social post or email to existing users teasing the feature

---

## Phase 3 — Deferred

Items worth doing but not essential for Phase 1 + 2 ship.

### 3.1 Season concept

Add `seasons` table with user-defined date ranges. Profile gets a season filter.

### 3.2 Event-level pattern analysis

`game_events` table enables richer narratives ("most assists come in transition") if data is captured.

### 3.3 Consistency metric

Stability score — standard deviation of PPSA across window, or percentage of games above threshold.

### 3.4 Positional context in prompts

Feed position into prompts: "Strong rebounding for a guard."

### 3.5 Foul-as-availability signal

Fold fouls into a "game impact" or "availability" signal for older age bands.

### 3.6 Trend chart UI

`player_trend_snapshots` enables PPSA-over-time chart on profile with minimal new work.

### 3.7 Fallback band indicator in UI

Subtle "Ratings could be more accurate" indicator when insight was generated with middle-band fallback due to missing birth date.

---

## Sequencing at a glance

**Phase 0 (Foundation — before any features):**
1. Centralize tier thresholds
2. Convert game_insights to jsonb
3. Merge player_game_insights into player_game_stats
4. Fix PPSA free-throws-only edge case
5. Clean up environment_values.dart

**Phase 1 (Migration + age + metric improvements):**
6. Add birth_date to players schema
7. Player creation flow update (birth date field)
8. Existing player backfill flow (first-launch modal + inline prompt)
9. Edge Function fallback for null birth date
10. Age-band PPSA thresholds in config
11. Effort + Disruption weight rebalance
12. AST/TOV volume floor for Elite
13. Supabase Edge Function toolchain setup
14. generate-game-insight function
15. Per-game prompt iteration
16. FlutterFlow client migration
17. highlight_metric tag UI on game rows
18. Parallel run week
19. Cutover and Buildship removal

**Phase 2 (Player development narrative):**
20. player_development_insights table
21. player_trend_snapshots table + trigger
22. Beta tester infrastructure (TestFlight, Google Play internal, feedback mechanism)
23. generate-player-insight function
24. Development narrative prompt iteration
25. Development card UI (top of profile)
26. Below-threshold state design + copy
27. Cache-aware loading UX
28. FAQ updates
29. Beta run (2+ weeks with 10–20 testers)
30. Release notes + app store screenshots + announcement
31. General release

**Phase 3 (Deferred):** season concept, event analysis, consistency metric, positional context, foul signals, trend chart, fallback band indicator.

---

## What to build first

Start with Phase 0.1 (centralize tier thresholds) and 0.2 (jsonb migration). These are low-risk, high-leverage changes that unlock the rest of Phase 1. The birth_date schema change (Phase 1.1) should come early because the Edge Function (Phase 1.8) depends on age-band logic being in place.

Natural first pull request:
- metrics_config.dart with all thresholds
- birth_date column added to players (migration)
- jsonb column added to player_game_stats (migration)
- PPSA edge case fix

That's a cohesive foundation PR that doesn't ship any user-facing change yet but unblocks everything else.

---

# Phase 4 — Courtside IQ 2.0 (new UI + Growth IQ)

**Release strategy:** built incrementally behind flags, shipped publicly as a single **version 2.0.0**. Each sub-phase merges to `main` on its own PR and is safe to sit unreleased; nothing user-visible turns on until 4E flips the flags.

**Design source of truth:** Figma `uvHb6HXvIVFwzSSXPtEVoc` (Screens page, organized as flow sections). Product decisions are locked in memory `product-decisions-2-0`. No screen gets built before its frame is approved.

**Definition of Done — every item carries all three:**
`[ ] built` · `[ ] wired` (reachable from a real call site) · `[ ] device-verified` (`fvm flutter run --release`)

**Environment rule for the whole phase:** all work targets **test** (`yihmccmyijtyrffpzstb`). `_kUseTestSupabase = true` on every 2.0 branch. Prod is read-only until 4E.

**Standing design rule for the whole phase:** if we reach a screen, state, or dialog that has no approved 2.0 Figma frame, **stop coding**. Design it in Figma on the Screens page (placed in its flow section, wired with a connector from its entry point), review it, get approval, and only then implement. No UI gets improvised at the keyboard, and no v1 screen gets carried forward "temporarily" because a 2.0 frame is missing.

**End state:** by 4E there are **no v1 screens left**. `lib/pages/` is deleted, not deprecated. A 2.0 release that still routes to a FlutterFlow dialog is not done.

---

## Phase 4.0 — Screen coverage audit (runs first)

### 4.0 Reconcile every v1 screen and state against Figma

**Problem:** v1 has 35 screen/component directories under `lib/pages/`. The 2.0 Figma file covers the main journeys well, but edge cases (password reset, rate prompt, feedback, snackbars, informational dialogs, permission-denied, offline, expired states) may have no frame. Discovering a missing frame mid-build stalls that PR and invites improvised UI.

**Action:**
- Enumerate every v1 route in `lib/pages/` **and every reachable state within it** — empty, loading, error, offline, permission-denied, expired, first-run, below-threshold.
- Map each to a Figma frame on the 2.0 Screens page.
- Classify each: **designed** (frame exists + approved) / **needs design** (gap) / **deliberately cut** (e.g. App Appearance, per prior decision).
- Commit the result as `docs/2-0-screen-coverage.md` — a living checklist, updated as gaps close.
- Everything marked *needs design* becomes a Figma backlog worked **before** its 4C screen PR starts.

**Known candidates for *needs design*** (to confirm, not assume): `forgot_password`, `reset_password`, `reset_succesful`, `alert_rate`, `send_feedback`, `custom_snack_bar`, `informational_dialog`, `empty_states`, `menu_list_empty_state`, `support`, `your_profile`, `user_account`, `edit_player_position`, `edit_live_game`.

**Design implication:** Turns edge-case risk into a known, sized backlog at the start of the phase instead of a series of mid-PR surprises. This is the item that protects the 4C schedule.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

---

## Phase 4A — Foundations (no user-visible change)

Everything in 4A is invisible to users and unblocks everything after it. This is the natural first PR set.

### 4.1 Growth IQ into config

**Decision:** 70% age-normalized ability + 30% improvement, on a 40–99 display scale. Ability = equal thirds of PPSA, AST/TOV, Disruption. Improvement = last-5 vs prior window; supplies the Building/Steady/Rising qualifier and the delta. Locked until 5 games. Never a rank or percentile.

**Action:**
- Extend `lib/courtside_iq/metrics_config.dart` with Growth IQ weights, band normalization, scale floor/ceiling, and the 5-game lock.
- Mirror in `supabase/functions/_shared/metrics_config.ts`. Client and server must not drift.
- Pure Dart function `growthIq(...)` in `lib/courtside_iq/` with unit tests covering: below-threshold, floor clamp, decline lowers score, age-band change freeze.
- Age-band transition: freeze earned ratings for display, normalize trend series underneath.

**Design implication:** DotGauge renders this directly. Every 2.0 screen showing a number depends on it.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.2 AI usage telemetry

**Problem:** AI cost is currently estimated, not measured. Model and throttle decisions need evidence.

**Action:**
- `ai_usage` table, service-role only (RLS on, no policies). FKs `on delete set null` so cost history survives record deletion.
- `_shared/ai_usage.ts` writer; failures swallowed so telemetry can never break insight generation.
- Log from both Edge Functions, success and failure paths.
- Rollup queries: spend per user per month, per game, per model.
- Set a spend cap in the Anthropic console.

**Design implication:** None user-facing. Enables the model-tier decisions in 4.3.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.3 Per-user AI throttle

**Action:** Cap generations per user per day in both Edge Functions. Set the limit from one week of real 4.2 data, not a guess. Costs don't explode from growth, they explode from retry loops.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.4 Server-side entitlement

**Problem:** premium currently trusts client state. A bug once gave everyone free premium.

**Action:**
- RevenueCat webhook → Edge Function → `subscriptions` table. Server becomes source of truth.
- Enforce free-tier limits (1 player / 3 games) in **RLS**, not UI.
- Distinguish billing-issue from expired (the lapsed states are already designed).
- Pull prices from RevenueCat Offerings instead of the hardcoded $5.99/$1.99.

**Design implication:** Makes the Lapsed and Locked screens truthful rather than cosmetic.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.5 Offline-first live tracking

**Problem:** gyms have poor or no wifi; live tracking must not lose a game.

**Action:**
- Client-generated UUIDs + upsert so retries can't duplicate.
- Hive outbox queue; flush on reconnect.
- Add `connectivity_plus` (**new dependency — flag before adding**).
- Visible sync state in the tracker UI (designed: "offline scoring + deferred sync").

**Design implication:** Removes the single biggest failure mode in the core loop.

`[x] built` · `[x] wired` · `[x] device-verified` — **DONE 2026-07-19** (commit `9342dc1`)

**Scope was narrower than this item assumed.** Live tracking was ALREADY safe: every stat setter
writes through to `FlutterSecureStorage`, so a crash or dead battery mid-game loses nothing. The
real gap was only the final save, which fired two inserts with no retry.

Verified on device: tracked a game, airplane mode on, saved (reported success), airplane mode off,
game synced unattended. Database confirmed exactly one game row and one stats row.

**CARRY-OVER GAP for 4.13 / 4.14:** a game queued offline never receives its AI insight. Generation
needs a server row so it is skipped while offline, and the later sync uploads the rows without
triggering it. The 2.0 tracker rebuild should generate the insight after a successful sync.

**Still unbuilt: the UI surface.** The "Offline Scoring + Deferred Sync" frame exists in Figma but
was drawn for the 2.0 tracker, so it was deliberately not retrofitted onto the FlutterFlow screen.
`gameSyncQueue.pendingCount` streams the queue depth for whatever renders it in 4C.

### 4.6 Migration hygiene

**Problem:** `players`, `games`, `player_game_stats` were created outside migrations, so there is no from-scratch reproducible schema. Test also carries two migrations absent from the repo (`revert_player_profile_view_age_band`, a duplicate `add_birth_date_to_player_profile_view`).

**Action:**
- Dump prod schema (structure only) → commit as `20260101000000_baseline_schema.sql`.
- Reconcile the two test-only migrations into the repo.
- Verify a blank project can be stood up from `supabase/migrations/` alone.

**Design implication:** None. Prerequisite for trusting the 4E prod promotion.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.6b Flutter / Dart SDK upgrade

**Problem:** the project is pinned to Flutter 3.35.0 / Dart 3.9.0 (Aug 2025). Current stable is
**Flutter 3.44.6 / Dart 3.12.2** (2026-07-09) — nine minor versions and ~11 months behind. The
original reason for the pin was FlutterFlow regenerating `pubspec.yaml`; **FlutterFlow is retired,
so that constraint is gone.**

**Why before 4B/4C, not after:** those phases write thousands of lines of new UI. Building them on
3.9 and upgrading later means verifying every 2.0 screen twice. Upgrade once, then build on the SDK
we actually ship. Shipping a 2.0.0 major release on an 11-month-old SDK is also a poor combination
as app store minimum requirements move.

**Action** (validated by the spike below — follow in order):
- Confirm the target stable at upgrade time (it moves; 3.44.6 as of 2026-07-18).
- `.fvmrc` → target version; `pubspec.yaml` sdk constraint `>=3.0.0 <4.0.0` → `>=3.9.0 <4.0.0`.
- Bump `font_awesome_flutter` to `^11.0.0` and `page_transition` to `^2.2.1` **in both**
  `pubspec.yaml` and `dependencies/lock_orientation_library_opafp4/pubspec.yaml`.
- Fix the three `FaIconData` call sites listed below.
- `flutter analyze` clean, `flutter test` green, full device pass on iOS + Android in `--release`.

### Spike results (2026-07-18, throwaway worktree on 3.44.6 / Dart 3.12.2)

Measured, not estimated. **The upgrade is small — roughly half a day including a device pass.**

| Check | Result |
|---|---|
| `flutter pub get` | ✅ resolved, zero version conflicts |
| `flutter analyze` | ✅ **0 errors** — 993 warnings, 2311 infos, none blocking |
| Compile | ❌ 3 call-site errors, all downstream of two package bumps |

**Two packages block it:**

1. `font_awesome_flutter` **10.7.0 → ^11.0.0**. It extends `IconData`, now a `final class`.
   10.12 is NOT enough; the 11.x major is required.
2. `page_transition` **2.1.0 → ^2.2.1**. References the removed `CupertinoPageTransitionsBuilder`
   constructor.

**The font_awesome 11 bump changes `FaIcon` to take `FaIconData` instead of `IconData`**, which
cascades into exactly three call sites:

- `lib/flutter_flow/flutter_flow_widgets.dart:215`
- `lib/flutter_flow/flutter_flow_icon_button.dart:67`
- `dependencies/lock_orientation_library_opafp4/lib/flutter_flow/flutter_flow_widgets.dart:215`

**GOTCHA — the vendored package must be bumped in lockstep.** `dependencies/lock_orientation_library_opafp4/pubspec.yaml`
mirrors the app's dependency pins. Bumping only the root `pubspec.yaml` fails resolution with a
misleading `"... from path is forbidden"` error. Every version bump goes in **both** files.

**Not verified by the spike:** no full iOS/Android release build, and the app was never launched on
a device. Compile-clean is not runs-correctly, especially for the FlutterFlow UI layer.

**ORDERING DECISION — RESOLVED: keep the plan order, do NOT pull 4.24 forward.** The concern was
that the cascade would land in `lib/pages/` (doomed code). It largely does for *warnings* — 865 of
993, and 731 of those are just unused imports — but warnings do not block a build. The only three
hard errors are in `lib/flutter_flow/`, and patching three call sites in soon-to-be-deleted files
is a trivial cost, not grounds for reshuffling the phase.

`[x] built` · `[x] wired` · `[x] device-verified` — **DONE 2026-07-19** (commit `695f52a`)

**Outcome matched the spike.** Two package bumps, three call sites, ~half a day. `flutter analyze`
clean, 16 Growth IQ tests pass, `--release` device run on iPhone with no visible regressions.

**Unplanned side effect worth carrying forward: the iOS build migrated to Swift Package Manager.**
Flutter 3.44 did this automatically on the first device run - `Podfile.lock` lost 177 lines and two
`Package.resolved` files appeared (now committed; they pin SPM versions). The build is now hybrid:
`app_links`, `flutter_native_splash`, `share_plus`, `sign_in_with_apple` and `sqflite` have no SPM
support and stay on CocoaPods, which Flutter warns will eventually become an error. **Relevant to
4.22** - the local release pipeline assembles the iOS app differently now than it did for 1.4.0.

**Known-failing test, NOT caused by this:** `test/widget_test.dart` fails on both 3.35.0 and 3.44.6
(verified in a worktree at the pre-upgrade commit). It is the default scaffold test pumping
`MyApp()` without initializing Supabase. Delete or fix it - a permanently-red test trains everyone
to ignore test output.

> Numbered `4.6b` rather than renumbering 4.7-4.24. The cascade of edits that would cause across an
> already-reviewed document is a worse trade than one irregular label.

---

## Phase 4B — Design system in code

### 4.7 Tokens and primitives
Colors (ink/white, lime/orange), Hanken Grotesk type scale, radius scale (chip 6 / control 10 / sheet 14 / dialog 18 / pill 999), spacing. Ported from Figma variables.
`[x] built` · `[ ] wired` · `[x] device-verified`

### 4.8 Shared components
DotGauge, DotBurst, Chip (filter), underline TabBar (navigation), Avatar, stat grid with vertical seams, edge-to-edge hairline, delta chip (direction-aware by meaning), Field, pill button.
**Rules:** chips are filters, tabs are navigation; hairlines always full-bleed; content on lime or orange is always ink.
`[x] built` · `[ ] wired` · `[x] device-verified`

**`wired` stays unchecked deliberately.** Every component here is device-verified
in the token gallery, but the gallery is not a call site. Nothing in the shipping
app imports these yet, so by our own Definition of Done 4B is not complete - it is
*built and proven*, waiting on 4C to consume it. This is the AddPlayerSheet failure
mode, and the box is what keeps it visible. **4B closes when 4C's screens land, not
before.**

Known gaps to settle when the first screen consumes these:
- Light-mode field fill is `surfaceSunk`, inferred from the token system rather
  than verified against a Figma light-mode auth frame. Dark mode is measured.
- `CiAvatar` renders `Image.network` with no cache or placeholder. Fine for the
  gallery, likely not for a scrolling players list.

---

## Phase 4C — Screens, in journey order

Built against approved Figma frames, in `lib/features/`. **Decision: new screens live alongside the FlutterFlow pages *during development only*.** Routing switches per-screen behind the 2.0 flag so any screen can fall back to its v1 page if it regresses mid-phase. This coexistence is a scaffold with an expiry date — see 4.24, which removes it entirely before ship. No screen may enter 4C without an approved Figma frame (see 4.0).

| # | Flow | Screens |
|---|---|---|
| 4.9 | Entry/Auth | Splash (Dot Burst), Onboarding ×3, Auth Landing, Email auth (sign-in/sign-up chips + validation error), Forgot Password, Reset Password, Reset Successful |
| 4.10 | Home/Today | Today feed, empty + first-run states |

**4.10 decisions, 2026-07-20:**

- **Growth IQ is computed CLIENT-SIDE** via `lib/courtside_iq/growth_iq.dart`.
  It is not stored anywhere. The repository feeds per-game metrics into the
  existing formula.
- **The Today header shows ONLY players with a computable Growth IQ.** A player
  with too few games is absent from the header while remaining everywhere else
  in the app. The header is about growth, and growth needs games; a zero would
  be a claim about the child. Encoded in `headerSnapshots()`.
- **Paging dots follow the FILTERED count.** Two players where only one
  qualifies is a single-item header with no dots.
- **Recent games cap raised from 3 to 5.** A deliberate change from production
  behaviour, not an accident of the redesign.
- **The bottom nav is its own item, not part of 4.10.** It is shared chrome
  across Today, Players, Games and Menu, and folding it in would make 4.10
  unreviewable. Currently still the v1 `CustomNavBarWidget`.

**4.10a is BUILT, WIRED and DEVICE-VERIFIED (2026-07-20).** `kUseToday2` is on.
`DashboardPage` is untouched and still reachable by turning it off.

Corrections that came out of two device reviews, each measured from the frame
rather than nudged by eye: the second carousel player was unattributed (now
"Maya's Growth IQ"); the PPG tag is a ghost, not a filled chip; the stat
columns are `spaceBetween`, since equal `Expanded` slots pooled their slack on
the right; both feed bands share `kFeedBandHeight`; and the hero now DECLARES
its ground with `CiSurface.ink` rather than only painting ink - without that,
every component resolving its palette from context read LIGHT and rendered
ink-on-ink.

**One deliberate departure from the frame:** the Growth IQ delta is a chip, not
the frame's plain lime text. Consistency with every other delta in the app beat
matching one frame. **The frame should be updated to follow.**

**KNOWN ISSUE: the bottom overscroll shows ink.** Scrolling past the end of the
feed reveals the ink scaffold beneath it. Deferred 2026-07-20 pending the nav
rebuild, but **the nav is unlikely to fix it on its own**: the cause is that the
scaffold is ink so the TOP overscroll can reveal ink under the dark hero, and
the trailing light filler only extends to the viewport edge. The real fix is a
bottom-anchored light layer behind the scroll view, independent of the nav.
Revisit when the nav lands, and do not assume it went away.

**STATUS-BAR ICONS ARE WRONG ON EVERY INK SCREEN.** The app pins DARK icons
globally, from when it was a light-mode design, so the clock and signal bars are
black on near-black. Today overrides it with an `AnnotatedRegion`; **Auth,
Onboarding and Splash have the same bug and have not been fixed.** Today is
simply the first screen dark enough at the very top for it to show.

**DESIGN GAP: the empty header.** A user whose players all lack enough games
gets an EMPTY header carousel, and no frame covers it. This is NOT the same as
`Today - Empty (No Players)` (`204:763`), which is for a user with no players
at all. The new state is "players exist, none have enough games yet" - which is
every user's first days in the app, so it is not an edge case.

`headerSnapshots()` can return empty and its callers must handle it. **Needs a
Figma pass before 4.10a can be considered done.**
| 4.11 | Players | Players list, Player Profile, Averages, Games, Full Breakdown, About Growth IQ |

**4.9 scope was widened on 2026-07-19.** Auth Landing and the Forgot / Reset /
Reset Successful trio had approved Figma frames and live v1 equivalents, but no
phase item owned them. An unowned screen means either a v1 page survives into
2.0 or password reset breaks at cutover, so they now belong to 4.9 explicitly.

**4.9 progress:**

- Screen flags moved to `lib/features/flags.dart` (one registry, deleted whole
  in 4.24). `kUseDashboardV2` moved there too.
- Email Auth built and routed behind `kUseAuth2`, keeping the v1 route name and
  path so every existing navigation call reaches it unchanged. Flag is ON.
  `[x] built` · `[x] wired` · `[x] device-verified` (sign in AND sign up)

**Test now diverges from prod on email confirmation. Remember this at 4E.**

`Confirm email` was turned OFF on the test project (`yihmccmyijtyrffpzstb`) on
2026-07-19, because Supabase's built-in email service is throttled to a few
messages an hour and it was blocking every signup attempt. **Prod still has
confirmation ON.**

Consequences:
- The signup flow verified on test is NOT the one a real parent gets. On prod
  they receive a confirmation email and are not signed in until they click it.
  The post-signup navigation to Home was verified against the confirmation-off
  path only.
- Before cutover, either verify signup on a project with confirmation ON, or
  design the "check your email" state that prod signup requires. **There is no
  Figma frame for that state today** - it is a genuine gap in 4.9's coverage,
  not just an unverified path.

Test accounts on test: `testuser@mail.com` (2 players) and `testuser2@gmail.com`
(created 2026-07-19, zero players). Keep the second one: a user with no players
is what the free-tier RLS limit needs in order to be exercised at all.
- **Two regressions caught on device, both worth remembering:**
  - *Dead sign-in button.* The screen called authManager but never navigated.
    Sign-in succeeded and left the parent sitting on the auth screen. The v1
    screen calls `prepareAuthEvent()` then `pushNamedAuth` explicitly; nothing
    redirects an authenticated user off the auth route on its own.
  - *Account lockout.* An 8-character minimum was applied to SIGN IN, barring
    every account created before that rule existed, in their own app, with no
    recourse since password reset is not built yet. Length is a rule about
    creating a password. `validatePassword` (sign in) now checks only that
    something was typed; `validateNewPassword` (sign up) holds the minimum.
- **Design note:** the Validation Error frame draws the sign-in/sign-up control
  as underline tabs while the other two frames use chips. Decided in favour of
  chips, since a second tab idiom would undercut the real navigation tabs.
  **The Figma frame is stale and should be updated.**
- Auth Landing built and routed behind `kUseAuthLanding2`. Google and Apple
  sign-in both device-verified 2026-07-19.
  `[x] built` · `[x] wired` · `[x] device-verified` (glow and mark sizing still
  being tuned on device)
- **Reading the v1 widget before writing the replacement caught four behaviours
  the frame does not show**, and this is now the standing approach for 4C:
  Apple is hidden on Android; OAuth uses `goNamedAuth` (replaces the stack)
  while email uses `pushNamed` (keeps it); `prepareAuthEvent()` precedes every
  OAuth call; the legal links are real and point at Apple's standard EULA and
  `courtsideiq.app/policy`.
- **Figma's code export is lossy. Read the node tree, not just the generated
  code.** Two things were silently missing from the export and only found in
  the metadata: the `TapGestureRecognizer` on the legal links, and the 220x220
  ellipse behind the burst that produces its glow (`251:977`). Both would have
  shipped as quiet regressions against the design.
- Component fixes that came out of this screen:
  - `DotBurst` geometry was absolute, calibrated for the 390 Splash frame, so
    it was only correct at that one size. Now scales from a 390 reference;
    identical output at 390, correct at every other size.
  - `DotBurst` gained `glowOpacity` for the haze the frame carries.
  - `CiButton` gained `leading` for brand marks. `FaIconData` is not
    assignable to `IconData`, and a brand mark must not be recoloured to the
    label colour.
  - `CiLogoMark` is painted rather than an asset: `logo-mark.png` is solid
    black and vanished on ink ground, and no white version exists in the repo.
- Forgot Password, Reset Password and Reset Successful built and routed behind
  `kUsePasswordReset2`. **Flag is OFF** and must stay off until the deep link
  lands: Reset Password is reached by a recovery link, and today that link
  opens a web page, not the app.
  `[x] built` · `[x] wired` · `[x] device-verified`

**Part A is DONE and device-verified 2026-07-19.** Full loop confirmed on a
real device against test: Forgot Password sends, the email arrives, the link
opens the app, Reset Password applies, and the new password signs in.

**The FlutterFlow page still cannot be switched off.** Every recovery email
already sent points at it, and older installs keep sending it. It can only be
retired once those links have expired and those installs have updated.

**Two device-only bugs, both from the same root cause: two clocks that do not
agree.** Supabase emits `passwordRecovery` the instant it parses the link,
while `AppStateNotifier` is driven by a separate user stream that lags. Acting
on the Supabase event alone navigated to a `requireAuth` route while the app
still believed nobody was signed in:

  1. FFRoute honoured a stale "come back here once you log in" stash and sent
     the parent to Home before they could type a password.
  2. With that cleared, `requireAuth && !loggedIn` bounced them to /onBoard.

Chasing each destination in turn was treating symptoms. The listener now waits
for the app's own `loggedIn` before navigating, with a 15s give-up so a
recovery session that never materialises leaves the app usable.

**ORIGINAL RISK, NOW RESOLVED - kept for the record.**

The recovery email redirects to `https://courtside-iq.flutterflow.app/resetPassword`,
a FlutterFlow-hosted web page. FlutterFlow was retired 2026-07-19. The page is
up today (verified HTTP 200), but if that hosting ever lapses, **every reset
link in every inbox stops working and affected users cannot get back in.**

Decision 2026-07-19: replace it with a `courtsideiq://` deep link so reset
happens natively on the 2.0 screen. Split into two parts, screens first:

- **Part A, still to do:** register `courtsideiq://` on iOS and Android, handle
  the incoming recovery link, add the redirect to Supabase's allowlist.
  Current state: iOS has **no** deep-link configuration at all (no associated
  domains, no custom scheme beyond Google Sign-In's). Android has a custom
  scheme `webapp://courtsideiq.app` with `flutter_deeplinking_enabled`.
  `app_links` is in pubspec but **imported nowhere** - a dead dependency.
- **Not a clean cutover.** Emails already sent keep pointing at the FlutterFlow
  page, so it has to stay alive through the transition whatever we do.

**Design gaps found building these:**

- **No frame for what Forgot Password shows after sending.** v1 popped a
  dialog. Using the design system's Snackbar (`521:2009`) rather than inventing
  a dialog or a fourth screen. Same family as the missing signup confirmation
  state. Both want a design pass.
- **The length rule sat under the wrong field.** The frame places "Use at least
  8 characters." under CONFIRM PASSWORD, but the rule is enforced on NEW
  PASSWORD, so a parent would read the rule under one field and see it violated
  under another. Moved to the field it governs. **The frame should be updated.**

### 4.9b Undesigned states (BLOCKS 4E cutover)

Two states the app genuinely needs, that no Figma frame covers. Both were
found while building 4.9. Neither is a nice-to-have: the first is what every
new user on prod sees, and shipping without it means signup appears to hang.

**Per the standing rule, these get designed and approved in Figma before any
code.** Place them in the Entry/Auth flow section with connectors from their
entry points.

| # | State | Why it is needed | b | w | v |
|---|---|---|---|---|---|
| 4.9b.1 | **Signup - check your email** (`765:3144`) | Prod has email confirmation ON. After signup a parent is NOT signed in until they click the link, so the app must say so. | ☑ | ☑ | ☑ |
| 4.9b.2 | **Forgot Password - link sent** (`765:3370`) | Replaces the Snackbar. Copy does not confirm whether an account exists. | ☑ | ☑ | ☑ |

**Both verified on device 2026-07-19 with email confirmation temporarily ON.**
Signup showed Check Your Email naming the address, the confirmation link
confirmed the account, and the full recovery loop ran end to end: request,
email, deep link into the app, new password set, Password Updated.

**A LATENT BUG WAS FOUND ONLY BECAUSE CONFIRMATION WAS TURNED ON.** With it
OFF, signup returned a session and everything looked right. With it ON, signup
did nothing at all - silently. `emailCreateAccountFunc` returns null for an
unconfirmed account, which is indistinguishable from a failure, so the screen
bailed before it could ever render. **The screen was built, wired, tested and
still could not have worked on prod.** Fixed by calling `signUp` directly,
where the SESSION rather than the user says whether they are signed in.

**Two open items from this verification:**

1. **Signup confirmation links open a browser, not the app.** The project's
   Site URL is still `http://localhost:3000`, a FlutterFlow web-preview
   leftover, so tapping the link lands on a Safari error page. **The account
   IS confirmed** - verified in `auth.users` - but a parent has no way to know
   that, and it looks like signup failed at the last step. Same shape as the
   password-reset problem, same fix: pass `emailRedirectTo` on signup and
   handle the resulting event. The deep-link plumbing already exists.
2. **One recovery failure was never explained.** It landed on onboarding
   instead of Reset Password, then stopped reproducing once the parent signed
   out first. The strongest hypothesis is a stale session: "Back to sign in"
   navigates without clearing one, so recovery cannot assume a signed-out
   start. **Not fixed, because a third speculative fix is not a fix.**
   Diagnostic logging is left in `password_recovery_listener.dart` behind
   `_kLogRecovery`; flip it to true if this recurs.

**Frames approved and built 2026-07-19.** One screen, `CheckEmailPage`, with a
`CheckEmailPurpose` enum - the two frames are clones differing only in body copy
and which resend they offer, so two files would have been duplication.

**4.9b.1 CANNOT be device-verified on test, by choice.** It only appears when
signup does NOT sign the parent in, which is what email confirmation produces.
Test has confirmation OFF and the user has chosen to keep it that way, so on
test signup falls through to Home and this screen never renders. Nine tests
cover the copy rules; the render itself is unverified until either confirmation
is turned on temporarily or cutover reaches prod. **Do not tick `v` for 4.9b.1
without one of those.**

4.9b.2 is reachable on test and should be verified on the next device run:
Forgot password, submit, and the screen replaces the old snackbar.

**Frames drafted 2026-07-19, AWAITING APPROVAL.** Both sit in the `1 · Entry &
Auth` section on the Screens page, inserted in journey order rather than
appended: Check Your Email directly after Email Auth (Sign Up), Link Sent
directly after Forgot Password. Ten existing frames shifted right to open the
slots, and the section widened to 7980.

Both are clones of Reset Successful, so the status bar, back button, dot burst,
button instance and type scale are the existing ones rather than reproductions.
Shared shape: burst, "Check your email" h1, one line of body, a lime CTA, and a
text link beneath it for the secondary action.

Copy decisions to preserve when these are built:

- **The signup screen names the address** ("We sent a link to
  alex.rivera@email.com"), so a parent catches a typo instead of hunting in an
  inbox that will never receive anything. **The reset screen must NOT** - it
  says "If that email has an account", and reads identically whether or not the
  address is registered. Confirming existence would let anyone probe which
  parents have accounts.
- Both offer a resend, because the commonest failure here is an email that
  never arrives or lands in spam, and a dead end is the worst outcome.
- The reset screen states the expiry (one hour), since a link that silently
  stops working is indistinguishable from a broken app.

**Connectors deliberately not drawn.** CLAUDE.md asks new screens to be wired
with connectors from their entry points, but the whole file contains exactly
ONE such node (`flow-arrow`, in `4 · Games`). Two orphan arrows in a section
with none would be noise. Wiring Entry & Auth properly is worth doing as its
own pass.

**Also for the Figma file, found while building 4.9:**

- **Email Auth - Validation Error (`524:2009`)** draws the sign-in/sign-up
  control as underline tabs while the other two frames use chips. Chips won.
  The frame is stale.
- **Reset Password (`608:2172`)** places "Use at least 8 characters." under
  CONFIRM PASSWORD, but the rule is enforced on NEW PASSWORD. Moved in code to
  the field it governs; the frame should follow.

### 4.9 Splash + Onboarding

- Splash and Onboarding x3 built and routed behind `kUseEntry2`.
  `[x] built` · `[x] wired` · `[x] device-verified`
- **Native splash checked on device: no white or coloured flash before the dot
  burst.** The earlier concern about LaunchScreen.storyboard did not
  materialise, so nothing to fix there.
- **The onboarding VISUAL DESIGN is accepted as good-for-now, not final.** The
  user intends a further design pass. Nothing outside `onboarding_page.dart`
  depends on the slides' internals, so a redesign is a Figma pass plus swapping
  copy, images and layout in one file.
- **The mockup fade is owned in CODE, not the image.** The exports are fully
  opaque (alpha 255 throughout) and fade by darkening toward `#0F0F0F`. A ramp
  painted into pixels cannot be smoothed from code - anything added compounds
  with it and steepens the falloff. **The Figma mockups still carry that baked
  gradient; removing it would let the code-side ramp do the whole job and read
  smoother.** Worth doing in the next design pass.
- **Splash is painted, not an image.** It replaces
  `assets/images/App_Load_d.png`, a fixed bitmap drawn with `BoxFit.cover` that
  distorted on any aspect ratio it was not drawn for. It also replaces the
  loading placeholder inside `FFRoute`, so a regression shows on every cold
  start.
- **THREE onboarding slides, not v1's four.** A deliberate change in the 2.0
  design, not a port.
- **The slide mockups ARE images**, exported from Figma at 3x (463KB total).
  Decided 2026-07-19 against the general "avoid images" preference: they are
  static marketing artwork of a fictional player, not functioning UI, and
  rebuilding them from live components would mean maintaining three fake
  screens plus a sparkline component nothing else needs yet. **They will drift
  as the real screens evolve - re-export when the underlying frames change.**

**Open: the NATIVE splash has not been touched.** iOS still has
`LaunchScreen.storyboard` with `LaunchBackground`/`LaunchImage`, and
`flutter_native_splash` is a dependency with no config block. That renders
before Flutter boots, so if its background is not `#0F0F0F` there is a visible
flash on every cold start ahead of the 2.0 splash. Invisible in debug, obvious
on device. **Check on the device run; fix before cutover.**

### Remaining in 4.9

- 4.9b: the two undesigned states above. **This is all that is left.**

**Carry-over defects for 4.11 — verify these do not return in the rebuild:**

- **Duplicate narrative generation.** The v1 profile page swapped tab widgets by
  type, so every return to the Development tab remounted it and fired another
  paid Sonnet call. Fixed in v1 via request de-duplication in
  `PlayerInsightService`; **the 2.0 rebuild must not reintroduce the pattern.**
  Whatever replaces the tab control should either keep the tabs alive or hoist
  the fetch above them.
- **The server-side claim row is UNEXERCISED.** The claim-row guard in
  generate-player-insight has never actually raced - the client dedup absorbed
  every duplicate before it reached the server. Treat it as unverified
  defense-in-depth and exercise it deliberately during 4.11.
- **`readCached` ignores the game id.** It returns the player's most recent
  insight regardless of which game generated it, so a stale narrative can render
  instantly while the current one loads. Not fixed in v1; fix in the rebuild.
| 4.12 | Games | Games list, filters, skeleton, live-in-progress, no-games |
| 4.13 | New Game | Create → Setup → Live Tracker → Complete |
| 4.14 | Game Detail | Hero, stat rows, shooting blocks, scoring mix, insight card, remove game |
| 4.15 | Menu/Account | Menu, subscription, settings |
| 4.16 | Premium/Paywall | Carousel ×3 + Loading / Processing / Error / Already-Premium |
| 4.17 | Locked & lapsed | Development locked, Profile locked, Players lapsed, Age-band transition |

Each carries `[ ] built` · `[ ] wired` · `[ ] device-verified`.

**Watch item:** paywall/onboarding snapshots are static clones of real screens. Fixing a source screen does **not** update them — re-clone on change.

---

## Phase 4D — Verification

### 4.18 End-to-end passes
Full journey on iOS and Android in `--release`. Offline tracking with wifi disabled mid-game. Entitlement: fresh / premium / lapsed / billing-issue. Growth IQ: <5 games, exactly 5, decline, age-band crossing.
`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.19 Copy audit
No em dashes. Solid → Good → Elite ordering correct. Lowercase "app store". No screen displays a player attribute with no capture field.
`[ ] built` · `[ ] wired` · `[ ] device-verified`

---

## Phase 4E — Cutover to 2.0.0

**Nothing here happens without explicit approval at the time.**

### 4.20 Promote schema to prod
Apply 4A migrations to prod in order. Requires 4.6 complete. Backup first.
`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.21 Deploy Edge Functions to prod
`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.22 Flip flags and ship
`_kUseTestSupabase = false`. 2.0 routing flag on. Version `2.0.0`, build number above live. Local release pipeline (JDK 17 + FF keystore for Android, Transporter for iOS).
`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.23 Store assets
New screenshots, release notes, updated listing copy for the 2.0 UI.
`[ ] built` · `[ ] wired` · `[ ] device-verified`

### 4.24 Retire all v1 screens

**Decision:** 2.0 ships with **zero** v1 screens. The old FlutterFlow UI does not align with the new look and feel, so a partial migration is not an acceptable end state.

**Action:**
- Confirm every entry in `docs/2-0-screen-coverage.md` is *designed + built* or *deliberately cut*. Nothing may still be *needs design*.
- Remove the per-screen 2.0 routing flags — 2.0 becomes the only path, not the default path.
- **Delete `lib/pages/`.** Remove its routes, imports, and any now-orphaned FlutterFlow widgets.
- `flutter analyze` clean; grep for lingering `pages/` imports.
- Full journey re-run on device after deletion — this is where a missed route surfaces as a crash rather than a stale screen.

**Gate:** this item blocks 4.22. Do not cut the 2.0.0 build until `lib/pages/` is gone and the app still passes 4.18.

**Design implication:** The visual inconsistency risk (a v1 dialog appearing inside a 2.0 flow) is eliminated by construction rather than by inspection.

`[ ] built` · `[ ] wired` · `[ ] device-verified`

---

## Phase 4 sequencing

**PR 0 (audit):** 4.0 screen coverage audit → `docs/2-0-screen-coverage.md`. Read-only, no code. Produces the Figma design backlog.
**PR 1 (foundations):** 4.1 Growth IQ + 4.2 telemetry + 4.6 migration hygiene. No user-visible change.
**PR 2:** 4.4 entitlement + 4.3 throttle.
**PR 3:** 4.5 offline tracking.
**PR 3.5:** 4.6b Flutter/Dart SDK upgrade — on its own, never mixed with feature work. An SDK bump
plus a dependency cascade is hard enough to review without unrelated changes in the diff. Scope is
known from the spike: two package bumps, three call sites, ~half a day. Ordering question resolved
(keep this position).
**PR 4:** 4.7 + 4.8 design system.
**PR 5–13:** one per screen flow (4.9–4.17). Each is gated on its frames being *designed* in the coverage doc.
**PR 14:** 4.18 + 4.19 verification fixes.
**PR 15:** 4.24 v1 retirement — delete `lib/pages/`, re-verify.
**PR 16:** 4E cutover and 2.0.0 ship.

**Figma design work runs in parallel** from PR 0 onward: every gap the audit finds gets designed and approved before its screen PR opens. Design is never the thing a code PR waits on mid-flight.

**Start with PR 0, then PR 1.** The audit is cheap, read-only, and sizes the unknown — it tells us how much Figma work Phase 4 actually contains before we commit to a schedule. Then Growth IQ, which is the hard dependency: every 2.0 screen shows the number, so nothing above it can be honestly built or verified until the formula is real and tested.
