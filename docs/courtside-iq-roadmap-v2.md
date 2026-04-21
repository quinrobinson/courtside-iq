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
