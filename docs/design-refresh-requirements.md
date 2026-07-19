# Courtside IQ — Design Refresh Functional Requirements

## Context

Courtside IQ is live on the App Store and Google Play (v1.4.0 in flight). The product works, but the current visual experience is mostly functional-basic: it does the job without feeling distinctive, polished, or emotionally sticky. The next phase is a **design refresh** that makes the app feel unique, crisp, and something parents form a connection with.

This document is the **functional baseline** that the redesign will be built on top of. It is deliberately **not** a visual spec. Its job is to capture, surface by surface, every piece of functionality that exists today (so nothing gets lost in the redesign) plus the enhancement opportunities worth exploring while we have the hood open. Visual direction (color, type, motion, layout) gets decided later, in Figma, against this baseline.

**Scope decisions (confirmed with the user):**
- **Coverage:** Entire app, all surfaces — auth/onboarding through settings.
- **Enhancements:** Woven in per surface — each surface lists current functionality, then opportunities to explore for that surface.
- **Baseline:** Canonical live behavior only. We document the shipped experience (V2 dashboard, V2 player profile, Edge Function insights). Legacy FlutterFlow duplicates and the dead Buildship path are noted as "to retire," not carried forward as requirements.

**Deliverable:** This document. No code changes in this phase — this is the requirements artifact that precedes design, which precedes code (per the Figma-first workflow).

---

## How to read this document

Each surface section follows the same shape:
- **Purpose** — the parent's job on this surface.
- **Current functionality (must carry forward)** — what exists today and has to survive the redesign.
- **Data shown / inputs captured** — what the surface reads or writes (ties to the Data & Metrics appendix).
- **States** — loading, empty, error, gated, conditional variants the design must account for.
- **Enhancement opportunities** — things worth exploring during the refresh. These are recommendations, not commitments; the design can adopt or defer each.

Two product rules govern every surface and are not restated each time:
1. **Development tool, not a stat tracker.** Every number connects to player growth. The redesign should make this positioning *feel* true, not just say it.
2. **Voice & tier language.** Warm, parent-friendly, encouraging. Tier hierarchy is **Solid → Good → Elite** (Solid is entry-level and must never read as a bad grade). No em dashes in user-facing copy. "app store" lowercase in cross-platform strings. Use the player's first name.

---

## Primary use cases & scenarios

Who opens this app, and in what moment. The redesign should be tested against these, not just against individual screens. Each names the design tension it creates.

**Personas:**
- **Single-player parent** — one child, following their growth season over season. The most common user. Wants the development story to feel personal and worth checking between games. Design tension: the app must feel rich and rewarding with only one player and a handful of games.
- **Multi-player parent** — two or three kids, often in different age bands. Needs fast switching and a clear read on each child without it feeling like ranking siblings against each other. Design tension: comparison without competition; age-band differences shown honestly.
- **Trainer / coach** — develops one or two athletes deliberately. More analytical, wants the "what to work on" to be specific and trustworthy. Design tension: depth without turning the app into a stat sheet.

**Core scenarios (cut across personas):**
- **Cold first run** — brand new account, zero players, zero games. The most fragile moment; everything is an empty or locked state. Design must turn this into a guided path to the first player and first game.
- **Live scoring from the stands** — fast game, one hand, glancing up, noisy gym, maybe poor signal. The highest-stress input context in the app. Speed, large targets, undo, and legibility beat density.
- **Post-game logging** — entering stats afterward from a scorebook or memory, at a calmer pace. A different rhythm than live tracking; may want quicker bulk entry.
- **The 5-game unlock** — the player crosses from "not enough data" to a real development story. This is the product's payoff moment and should feel like an arrival, not a quietly-appearing card.
- **Between-games review** — opening the app with no new game, just to read the development story, check the trend, and see "what to watch next." This is the retention loop; it must give the parent something even when nothing new happened.
- **Sharing** — sending a game or an insight to a coach, spouse, or grandparent. The shared artifact represents the brand outside the app.
- **Returning after a break** — coming back weeks or months later (off-season, injury). The app should re-orient the parent and make the rolling window's freshness legible.
- **Season / tryout context** — using the development story to prep for tryouts or reflect on a season. Ties to the Phase 3 "season concept" the design should leave room for.

---

## Cross-cutting functionality (applies app-wide)

The redesign owns these shared systems, not just individual screens.

**Primary navigation.** Bottom nav with four tabs — Home (Dashboard), Players, Games, Menu — plus a central "create game" action. The new design should treat this as the spine of the app and make the create-game action feel like the primary thing the app wants you to do.

**Premium gating.** A single source of truth: `isUserPremium`, synced from the RevenueCat `premium_users` entitlement (hard cutoff as of v1.4.0). Premium-gated surfaces present the paywall sheet rather than a dead end. The redesign must make the free-vs-premium boundary feel like an invitation, not a wall.

**Global state patterns.** Live game state (in-progress scoring), snackbar messaging (success/error), app-rating prompts, and theme preference (light/dark/system) all live in app state and surface across screens. The redesign should standardize how confirmations, errors, and "in-progress" states look and feel.

**Shared state patterns the design must style consistently:**
- **Loading** — skeleton loaders on lists/cards; spinners on data fetches.
- **Empty** — distinct empty states for no players, no games, no games-for-this-player, and below-threshold insight states. Each is an opportunity to teach and invite the next action, not just say "nothing here."
- **Error** — snackbar-based messaging plus inline validation.
- **Gated** — premium paywall presentation.
- **Disabled** — buttons disabled until required fields are valid.

**Theming.** Light, dark, and system modes are user-selectable in v1. **Superseded for 2.0 (decided 2026-07-19):** 2.0 is a single theme with a hybrid black-and-white palette, not a mode pair the user toggles. A white Today feed and an ink auth screen coexist in the same build, at the same time, and the user never chooses between them.

In code this is one `CiTheme.base()` plus two ground palettes, `CiColors.onLight` and `CiColors.onInk`; any region sitting on ink wraps itself in `CiSurface.ink`. What must still be defined from the start is **both grounds** for every new state and component, which is the same discipline the original requirement was reaching for.

**Open:** v1's user-facing theme preference still exists and still works, since the v1 pages theme off `FlutterFlowTheme` rather than this system. Whether 2.0 keeps that setting, and what it would mean when there are no modes, is unresolved and belongs to the 4E cutover.

**Enhancement opportunities (cross-cutting):**
- A cohesive design-token + component system so the redesign is consistent and maintainable, not screen-by-screen one-offs. This is the foundation that makes the app feel "crisp."
- A consistent "AI-generated" treatment (the spark/insight motif) so parents instantly recognize what's a Courtside IQ insight vs a raw number, wherever it appears.
- A unified motion language for stat increments, insight reveals, and tier changes — small, rewarding micro-interactions that make the app feel alive and premium.
- Standardized empty/loading/error components reused everywhere, so the app feels like one product.

---

## 1. Auth & Onboarding

**Purpose:** Get a new parent from install to their first player as fast as possible, and returning parents back in without friction.

**Current functionality (must carry forward):**
- Onboarding carousel with a "Get Started" CTA (page-indicator paging).
- Auth landing with three paths: Continue with Apple (iOS only), Continue with Google, Continue with Email. Terms and Privacy Policy links present.
- Email auth screen with Sign In / Sign Up tabs:
  - Sign In: email + password (show/hide toggle), inline "incorrect email or password" handling.
  - Sign Up: email + password + confirm password, real-time "passwords do not match" validation. On success, creates the auth user and a `users` row (id, email, empty first/last name).
- Forgot password → enter email → reset email sent.
- Reset password → new + confirm password → reset-successful confirmation → into the app.
- On successful auth (any method), user lands on the Dashboard.

**Data shown / inputs captured:** email, password, OAuth tokens; writes `users` record on signup.

**States:** loading/spinner during auth, validation errors, auth errors, disabled submit until fields valid.

**Enhancement opportunities:**
- The onboarding carousel is the single best place to establish the "development, not stats" promise emotionally before the parent ever sees a number. Worth a real narrative pass, not generic feature slides.
- Name is collected as empty strings at signup and edited later in settings — consider capturing first name (and optionally adding the first player) inside onboarding so the app is personalized and non-empty on first open.
- A guided first-run that ends on "add your first player" would eliminate the cold empty-dashboard moment entirely.
- Recently shipped: blue gradient was removed from email/onboard/reset screens — the refresh defines what replaces that visual language intentionally.

---

## 2. Dashboard / Home

**Purpose:** The parent's daily landing. Answer "how are my kids developing?" at a glance and route to the next action.

**Current functionality (must carry forward):**
- Greeting header with the user's display name.
- Aggregate context: player count and total games.
- Player snapshots (up to 3) as insight-bearing cards; tapping one opens that player's profile.
- Recent games feed (denormalized game rows with player, opponent, key stats, insight).
- Quick path to start a new game.
- Premium gating with paywall presentation where applicable.

**Data shown:** player snapshots, recent game rows (`v_player_game_stats`), development/insight signals per player, premium status.

**States:** loading skeleton, empty (no players → invite to add one), insight-present vs not-yet, premium-gated.

**Enhancement opportunities:**
- This is the surface most responsible for "parents drawing a connection." It should lead with the development story (trend, what's working, what to watch) rather than reading like a box score. The per-player development narrative already exists — surface it here, not just on the profile.
- A "since last game" or "this week" moment — what changed — gives parents a reason to open the app between games.
- Multi-player households (up to 3) need a clear at-a-glance comparison without making it feel like ranking siblings.
- The empty state (no players / no games yet) is high-leverage onboarding real estate; design it as a first-run guide, not a blank slate.
- Surface the trend direction (improving / stable / declining) as a recognizable, repeated visual signal.

---

## 3. Players

**Purpose:** Manage the 1–3 players a parent tracks, and go deep on each one's development.

### 3a. Players list
**Current functionality (must carry forward):**
- List of all the user's players (avatar/photo or fallback, first name, games context).
- "Add Player" entry point.
- Empty state when no players exist.
- Tapping a player opens their profile; edit path available.

**States:** skeleton loading, empty, loaded.

### 3b. Player profile (canonical V2)
**Current functionality (must carry forward):**
- Header: back, player name, edit affordance.
- Three tabs: **Averages | Development | Games**.
  - **Averages** — lifetime/aggregate stat cards (PPG, RPG, APG, SPG, BPG, TO/G, FG%, 3P%, FT%), plus age band context.
  - **Development** — the AI development story card (headline + "what's working" / "needs development" / "growth edge"), trend pill (improving/stable/declining), and a below-threshold unlock state when the player has fewer than 5 games. An "about this story" explainer is available.
  - **Games** — full game list for the player with inline stat highlights; tap to open game detail.
- Edit affordances: edit player info (sheet), upload/change profile photo (sheet).

**Data shown:** `player_profile_view` (lifetime aggregates + age band), `player_development_insights` (narrative), `player_trend_snapshots` (rolling 5-game trend), per-game rows.

**States:** loading, loaded, error, empty (no player), below-threshold development state.

### 3c. Add / edit player
**Current functionality (must carry forward):**
- **Add player** (sheet): first name (required), last name (optional), position (required, from positions lookup), birth date (drives age band; nullable → middle-band fallback). Increments player count; success confirmation. Account cap of 3 players.
- **Edit player:** first name, last name, team, position (up to 3), profile photo upload. Dedicated edit-position path.

**Data captured:** writes `players` (first/last name, position, team, birth_date, photo).

**Enhancement opportunities:**
- Birth date is critical — it drives age-band thresholds and therefore the accuracy of every rating. Today it's optional with a silent middle-band fallback. Consider making its value legible ("ratings are calibrated for 11U–13U") and nudging parents to set it. When it's missing, the design should be able to show a gentle "ratings will get more accurate once you add a birth date" affordance.
- The Development tab is the emotional core of the whole product. It deserves the most design investment: making the three-part story (bright spots / room to grow / watch for next) feel like a coach talking, with the trend visible over time.
- Phase 3 deferred a trend chart over time (PPSA across games) — the snapshot data already exists to power it; the redesign should leave room for it on the profile.
- Averages currently reads as a stat sheet; reframe aggregates around development (e.g., "where {name} is strongest") to stay on-brand.
- Photo and identity make the profile feel personal — lean into player identity (photo, position, team, age band) as the header that anchors the connection.

---

## 4. Game tracking

**Purpose:** Let a parent set up and score a game live from the stands, then save it.

### 4a. New game setup
**Current functionality (must carry forward):** Multi-step setup — select player (add one inline if needed, max 3), select team (add team inline), optionally select event (add event inline), enter opponent name (required). "Start Game" launches the live tracker with player/opponent/team/event context. Skeleton loading; submit disabled until player + team + opponent are set.

### 4b. Live stat tracker
**Current functionality (must carry forward):** Real-time stat entry during the game. Captures the full box score: FG made/attempt, 2PT made/attempt, 3PT made/attempt, FT made/attempt, missed 1/2/3, points (auto-calculated), offensive/defensive rebounds, assists, steals, blocks, offensive/defensive fouls, turnovers. Animated increment feedback. Pause (resume/end) and End Game flows. Live state persists in app state so an in-progress game survives navigation.

### 4c. Game complete & save
**Current functionality (must carry forward):** End-of-game summary, save (writes `player_game_stats`) or discard. Post-save, per-game AI insight is generated/fetched. App-rating prompt may appear after game completion.

### 4d. Game detail (view a saved game)
**Current functionality (must carry forward):** Full stat display with shooting percentages, the AI per-game insight (with an explainer of what insights are), a `highlight_metric` tag on the strongest metric, share to native share sheet, and an edit-stat path. Edit-live-game path for basic game info.

**Data captured/shown:** writes `games` + `player_game_stats`; reads `v_player_game_stats` and the `game_insights` jsonb (insight text, highlight_metric, tier_context).

**States:** setup/loading/validation; live active/paused/complete; saved detail loading/loaded/error.

**Enhancement opportunities:**
- The live tracker is the highest-stress, one-handed, glance-and-tap context in the app (parent in the stands, game moving fast). This is where crisp, large-target, low-error interaction design pays off most. Worth prioritizing tap accuracy, undo, and legibility over density.
- Reducing mis-taps: confirm/undo affordances, clear made-vs-missed grouping, and a running summary the parent can trust at a glance.
- The moment a game is saved and the insight appears is the app's payoff moment — design the reveal so the parent feels the "so what" immediately, tying the just-tracked numbers to growth.
- The `highlight_metric` tag and tier context are already computed; make them a consistent, recognizable element on every game row and detail.
- Consider whether opponent/event capture can be lighter so setup isn't a barrier to scoring.

---

## 5. Games (history)

**Purpose:** Browse and revisit all tracked games, across players or filtered to one.

**Current functionality (must carry forward):**
- All-games list with filter tabs (All Players / each player).
- Game rows: player, opponent, date, stat summary, insight signal.
- Entry point to start a new game.
- Empty states (no games at all; no games for a selected player).
- Tap a row → game detail (section 4d).

**Data shown:** `v_player_game_stats` filtered by player.

**States:** skeleton loading, empty, loaded, live-game-in-progress indicator.

**Enhancement opportunities:**
- History is where a development arc lives. Instead of a flat reverse-chronological list, consider grouping or visualizing progression (by event, by trend window, by improvement) so the list itself tells a growth story.
- Surface the rolling-5-game window concept here so parents understand what "recent form" the insights are based on.
- A live-game-in-progress row should be unmistakable and offer one-tap resume.

---

## 6. Insights engine (cross-surface feature)

Insights are not a screen — they're the product's reason to exist, surfaced on the dashboard, player profile, and game detail. The redesign must treat them as a first-class, recognizable system.

**Current functionality (must carry forward):**
- **Per-game insight** (Claude Haiku): warm 2–3 sentence growth-framed note generated on game save, cached per game, with a `highlight_metric` (ppsa / ast_tov / disrupt / effort) and `tier_context` (Solid/Good/Elite). Below a 5-shot-attempt threshold, no rating is shown (not a "zero").
- **Player development narrative** (Claude Sonnet): a 5-game rolling story with `headline`, `whats_working`, `needs_development`, `growth_edge`, `trend_direction`, and `strength_focus`. Unlocks at 5 games; below that, an unlock state shows "X of 5 games logged." Cached per latest game; regenerates when a new game is logged.
- Three core metrics drive all of it, with **age-band-aware tiers** (see appendix): PPSA (scoring efficiency), AST/TOV (playmaking), Effort + Disruption (defensive motor). Each has minimum-data thresholds before it rates.
- Insights are structured JSON, server-computed, cached — never regenerated on every open, never free-text-only.

**States:** below-threshold (per-game and per-player unlock states), cached vs freshly generated, age-band fallback (birth date missing).

**Enhancement opportunities:**
- Give insights a single, instantly recognizable visual identity (the spark motif) used consistently across dashboard, profile, and game detail so parents always know "this is Courtside IQ thinking."
- Design the unlock journey (0→5 games) as a deliberate, motivating progression, not just a locked card — it's the hook that drives the parent to track 5 games.
- Make tier language unmistakably encouraging in the visual system — Solid must look like a real achievement, never a low grade.
- When `trend_direction` is "improving," that's a celebration moment worth designing for.
- Surface the "what to watch for next game" (growth_edge) prominently — it's the single most actionable, coach-like thing the app produces and a strong reason to come back.
- Phase 3 deferred items the design should leave room for: positional context in narratives, a consistency metric, season concept, and a trend-over-time chart.

---

## 7. Menu, Profile & Account

**Purpose:** Manage account, preferences, support, and legal.

**Current functionality (must carry forward):**
- Menu hub: account header (avatar/initials, name, email), grouped options, app version/build, logout.
- Your Profile: avatar, name, email, with edit entry points and a delete-account path (with confirmation).
- Edit name (first/last), edit email (with confirm + validation), reset password.
- App appearance: light / dark / system theme selection.
- Logout returns to onboarding.

**Data shown/captured:** `users` (name, email); theme preference; auth actions (password, email change), RevenueCat login/logout on auth changes.

**States:** skeleton loading, loaded, deleting.

**Enhancement opportunities:**
- Settings is the lowest design-priority surface but still needs to inherit the new system so it doesn't feel like a different app.
- Consider surfacing subscription status / manage-subscription here as a clear, honest touchpoint (ties to the v1.4.0 hard entitlement cutoff).
- Profile is a natural home for an account-level identity moment if the brand refresh wants one.

---

## 8. Help & Feedback

**Purpose:** Answer common questions and capture parent feedback.

**Current functionality (must carry forward):**
- Help Center: accordion FAQ (getting started, what stats can be tracked, how to track a game, 3-player limit, etc.). FAQ answers in paragraph form (not bullets), per voice rules.
- Send Feedback: free-text feedback + email, submits to a feedback store, success confirmation.

**Enhancement opportunities:**
- FAQ is a place to reinforce the "development tool" framing and explain how insights and tiers work (parents will ask "what does Solid mean?"). The redesign can make this educational, not just transactional.
- Consider contextual help (e.g., an "about this story" explainer already exists on the Development tab) reused consistently wherever insights appear.

---

## 9. Subscription & Paywall

**Purpose:** Convert free parents to premium and manage entitlement honestly.

**Current functionality (must carry forward):**
- Paywall sheet presenting premium value (insights/analytics framing), pricing via RevenueCat, subscribe and restore-purchase actions, an FAQ accordion, and a dismiss path.
- Weekly and monthly plans.
- Entitlement is the hard source of truth (`premium_users`); premium-gated surfaces route here.
- Recently shipped: solid black backgrounds for upgrade banners and paywall, with black scoped to the content box (not the whole page) — the refresh should intentionally define the paywall's visual language rather than inherit this stopgap.

**States:** loading plans, purchase processing, error, already-premium (skip).

**Enhancement opportunities:**
- The paywall should sell the *development story*, not "analytics" — show, ideally with a real or sample insight, what premium unlocks emotionally.
- Gating moments throughout the app (where free users hit a wall) should feel like a preview/invitation. Define a consistent "premium teaser" pattern.
- Clarify the free-vs-premium boundary in the design system so parents always understand what they get.

---

## 10. Edge cases & boundary conditions (design needs)

Edge cases are where the happy-path screens fall short and net-new design surfaces hide. Each below names the condition, what happens today, and the design implication. The ones that require something genuinely new to be designed are collected in the punch list at the end.

### A. Data-volume thresholds
- **Player with 0 games** — Averages empty, Development locked at "0 of 5," Games empty. Design: a motivating locked/empty state across all three tabs, not three blank panels.
- **Player with 1–4 games** — Development still locked with progress ("3 of 5"); per-game insights present where the game cleared the shot threshold. Design: the unlock progression should build anticipation game over game.
- **Exactly 5 games (first story)** — the development narrative appears for the first time. Design: an explicit arrival moment, not a card that silently shows up.

### B. Per-game rating edge cases
- **Below 5 shot attempts** — no PPSA rating returns. Design: show the game without an efficiency tier and without an empty "—" that reads as a failing grade.
- **Zero-performance / DNP game** — minimal or no stats. Per product rule, return no rating and display nothing rather than a "zero" rating. Design: how a near-empty game looks in the feed and detail without ever reading as a bad grade.
- **Defense-only game** — no shots, but steals/rebounds/blocks. Disruption rates; PPSA and AST/TOV may not. Design: lead with the metric that did rate; never present a hole where an unrated metric would be.
- **Turnovers = 0 with assists** — ratio uses assists directly. Design: a sensible AST/TOV label when there's no turnover to divide by.
- **Elite-across-the-board game** — a true standout. Design: does the UI escalate or celebrate a ceiling game, or does it look identical to a Solid one?

### C. Player identity & lifecycle
- **Missing birth date** — falls back to 11U–13U with a `fallback_band` flag. Design: a gentle accuracy caveat ("ratings get more accurate once you add a birth date") plus an easy path to fix it.
- **Player ages across a band boundary** — e.g., turns 11 and moves 8U–10U → 11U–13U mid-tracking; thresholds shift going forward. Open question for product + design: are historical games and the rolling story re-rated under the new band, or frozen at the band they were generated under? This needs a decision and possibly UI to explain it.
- **3-player cap reached** — add-player must communicate the limit gracefully. Design: a clear cap state (and a decision on whether it ever becomes an upsell moment).
- **Long names / special characters / no photo** — truncation rules and an initials avatar fallback already exist. Design: confirm rules hold across the new components.
- **Deleting a player with games** — confirmation already exists. Design: clear messaging on what happens to that player's games and insights.

### D. Live game & input integrity
- **Interrupted live game** — app backgrounded, killed, phone dies, or parent navigates away mid-game. Live state persists in app state. Design: a "you have a game in progress, resume?" recovery prompt on return, plus an unmistakable in-progress indicator in the Games list.
- **Mis-tap / wrong stat** — Design: a clear, fast undo/decrement affordance reachable one-handed.
- **Offline gym (no signal)** — scoring is local, but per-game insight generation needs network on save. Design: confirm scoring works fully offline, and define what the parent sees when the insight can't generate yet (queued, "insight will appear when you're back online").
- **Duplicate / same-day / same-opponent games** — Design: enough disambiguation in lists (date, time, event) that two similar games never blur together.

### E. AI & network reliability
- **Insight generation slow or failed** — Edge Function timeout or Claude error, for both per-game and development insights. Design: loading, error, and retry states ("insight is taking a moment," "couldn't generate, tap to retry"). Today the happy path assumes success.
- **Development story regenerating after a new game** — cache invalidates and Sonnet regenerates. Design: a loading state for the refresh so the parent isn't staring at a stale or blank story.
- **Malformed / empty AI response** — Design: a safe fallback that still shows the game's numbers and never a broken card.

### F. Subscription & entitlement
- **Free user hits a premium gate mid-flow** — Design: a preview/teaser that shows the value (ideally a sample insight), not a dead end.
- **Premium lapses (entitlement expires, hard cutoff)** — insights the parent could previously see become gated again. Design: a graceful downgrade state so the development story doesn't just vanish jarringly; explain it and route to re-subscribe.
- **Restore purchase on a new device / after reinstall** — restore flow exists. Design: make it findable and reassuring.
- **Purchase failed or pending** — Design: clear error and pending states in the paywall.

### G. Trend & narrative tone
- **Declining or volatile trend** — `needs_development` must stay encouraging and never deficit-coded. Design: how a "declining" trend is shown gently and honestly, without alarming a parent.
- **Stale story (player hasn't played in a while)** — the 5-game rolling window may be months old. Design: surface "last played X ago" context so the freshness of the story is legible.

### H. Display & platform
- **Both grounds** — every new state and component (recovery prompts, downgrade states, retry cards) must be designed on light ground and on ink from the start. Not three user-selectable modes; see the Theming note above.
- **Large numbers, dynamic type, accessibility** — Design: stat displays and insight cards hold up at large text sizes and meet contrast.
- **iOS vs Android** — platform nav and affordance differences already handled; confirm the new system respects both.

### Net-new design needs surfaced by edge cases

These are the items that aren't covered by any current happy-path screen and should be added to the design backlog:
1. **In-progress game recovery** — resume prompt on return + a clear live indicator in the Games list.
2. **Edit-invalidates-insight handling** — when stats are edited after the insight was generated, either regenerate it or clearly disclaim that the insight reflects the original entry. (Product decision needed.)
3. **Insight loading / error / retry states** — for both per-game and development insights.
4. **Offline scoring + deferred insight sync** — score offline, generate the insight when connectivity returns.
5. **Subscription-lapse downgrade state** — graceful re-gating of previously visible insights.
6. **Age-band transition handling** — re-rate vs freeze decision, plus any UI to explain it.
7. **3-player cap state** — and whether it becomes an upsell.
8. **Zero-performance / below-threshold game display** — a treatment that never reads as a bad grade.
9. **Birth-date-missing accuracy caveat** — affordance plus an easy fix path.

---

## Appendix A — Data & Metrics reference (the engine behind every surface)

The redesign doesn't change this engine, but every surface's content is bounded by it. Designers should know exactly what data is available to show.

**Core entities:** `users`, `players` (incl. `birth_date` → age band), `games`, `player_game_stats` (full box score + `game_insights` jsonb), `player_team`/positions/events lookups.

**Insight & trend tables:** `player_game_stats.game_insights` (per-game jsonb), `player_development_insights` (per-player narrative, Sonnet, cached per latest game), `player_trend_snapshots` (rolling 5-game metrics, auto-generated by trigger on each game save, immutable).

**Views:** `v_player_game_stats` (denormalized game rows + insight), `player_profile_view` (lifetime aggregates + age band).

**Age bands** (from `birth_date`, null → 11U–13U fallback): 8U–10U, 11U–13U, 14U–18U.

**The three metrics:**
1. **PPSA (scoring efficiency)** = Points / (FG attempts + 0.44 × FT attempts). Needs ≥5 shot attempts to rate. Age-band Solid/Good/Elite thresholds (e.g., 8U–10U: 0.55 / 0.80 / 1.05 → 14U–18U: 0.75 / 1.00 / 1.25).
2. **AST/TOV (playmaking)** = Assists / Turnovers. Needs ≥3 assists to rate; Good at ≥2.0 ratio; Elite at ≥4.0 ratio with ≥4 assists.
3. **Effort + Disruption (defensive motor)** = (OReb×2.0)+(Steals×1.5)+(Blocks×1.0)+(DReb×0.5), rounded. Needs ≥3 to rate; Solid 3–5, Good 6–12, Elite ≥13.

**Tier rule:** Solid → Good → Elite. A null/unrated metric ("not enough data yet") is explicitly different from a zero or a low rating, and the design must represent the two differently.

**Thresholds source of truth:** `lib/courtside_iq/metrics_config.dart` (Dart) mirrored in `supabase/functions/_shared/metrics_config.ts` (TypeScript). Never hardcode elsewhere.

---

## Appendix B — Out of scope / to retire (not requirements)

These exist in the codebase but should **not** be carried forward as redesign requirements:
- Legacy V1 dashboard (`HomeWidget`) — superseded by the V2 `DashboardPage` (`kUseDashboardV2 = true`).
- Legacy V1 player profile (`players_profile_widget`) — superseded by the V2 profile.
- Dead Buildship insights path (`GetGameInsightsCall`, `nni3ua.buildship.run`) — replaced by Supabase Edge Functions.
- Legacy `player_game_insights` table — merged into `player_game_stats.game_insights`.
- Dev-only debug surfaces (e.g., player-insight debug page).

The design should target the canonical surfaces; retiring the legacy ones is a code concern, flagged here so the redesign doesn't accidentally spec the dead paths.

---

## Verification / definition of done for this phase

This phase produces a **document**, not code, so "done" means:
1. `docs/design-refresh-requirements.md` exists in the repo with the content above.
2. The user has reviewed it and confirmed it captures all current functionality across all surfaces with no gaps.
3. Enhancement opportunities are clearly separable from must-carry-forward functionality on every surface.

The document then becomes the input to the **Figma-first design phase**: every surface gets designed and approved in Figma (on the "Claude Code" page) against this baseline before any redesign code is written. No implementation happens off the back of this doc directly.

---

## Notes on process

- Per project rules, the requirements doc lives in `docs/` (version-controlled), mirroring the roadmap.
- This phase touches no Supabase env, no migrations, no Edge Functions, and no `_kUseTestSupabase` concerns — it is documentation only.
- Next step after approval: begin Figma design surface by surface, starting with the highest-leverage emotional surfaces (Dashboard, Player Development tab, the live tracker → insight reveal moment).
