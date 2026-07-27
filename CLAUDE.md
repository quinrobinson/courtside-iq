# Courtside IQ — Claude Code Context

## What this project is

Courtside IQ is a youth basketball player development app for parents of players ages 8–18. It is positioned as a **development tool, not a stat tracker**. Every feature, metric, and piece of copy should connect numbers to player growth. Parents are the primary user; players themselves are not.

The app is live on the App Store and Google Play. Primary audience: parents tracking 1–3 players.

## How the codebase is structured

This is a Flutter/Dart app with a Supabase backend.

**FlutterFlow is RETIRED (as of 2026-07-19).** It is no longer used and there are no plans to return
to it. Nothing regenerates, so **every file in this repo is editable**. The old "do NOT edit" list
existed only because FlutterFlow would overwrite those files; that risk is gone.

What this changes in practice:
- `pubspec.yaml` is ours. Adding a dependency is a normal decision (still flag it first).
- `lib/main.dart`, `lib/backend/supabase/`, `ios/`, `android/` are editable.
- `lib/pages/` was **deleted in roadmap 4.24 (2026-07-26)** - every v1 FlutterFlow screen is gone
  and 2.0 is the only path. `lib/index.dart` still defines the v1 route names/paths as abstract
  holder classes (same class names, e.g. `HomeWidget.routeName`) because the route table, every
  `goNamed`, and shipped deep links depend on them. They are not widgets; never construct them.

**Where new code goes:**
- `lib/features/` — new screens and widgets
- `lib/courtside_iq/` — shared config, metrics, and pure-Dart logic (`metrics_config.dart`,
  `growth_iq.dart`, `game_sync/`). Prefer this for anything that must survive the 2.0 rebuild:
  keep it free of Flutter widgets and Supabase imports so it stays testable.
- `scripts/` — one-off operational scripts, not part of the app build
- `assets/` — images, fonts, static files

**Supabase:**
- `supabase/functions/` — Edge Functions (TypeScript, Deno runtime)
- `supabase/migrations/` — SQL migrations for schema changes
- Secrets live in the Supabase dashboard, never in the repo

## Tech stack

- Flutter 3.44.6 / Dart 3.12.2 (client) — pinned in `.fvmrc`, run via `fvm`
- Supabase (database, auth, Edge Functions)
- Supabase Edge Functions in TypeScript (Deno runtime)
- Claude API (AI-powered insights — Haiku for per-game, Sonnet for player-level narrative)
- RevenueCat (subscriptions: weekly and monthly plans)
- Firebase Crashlytics (error monitoring)

## The roadmap

The full phased plan for current work is at `docs/courtside-iq-roadmap-v2.md`. Always read it at the start of a session. It covers:
- Phase 0: foundation cleanup (tier thresholds, jsonb migration, PPSA edge case) — **done**
- Phase 1: Buildship → Supabase Edge Functions migration + age data + metric improvements — **done**
- Phase 2: player-level development narrative — **done**
- Phase 3: deferred items
- **Phase 4: Courtside IQ 2.0** — the current work. New UI + Growth IQ, built incrementally behind
  flags and shipped as a single **2.0.0**. Sub-phases: 4.0 screen audit, 4A foundations, 4B design
  system, 4C screens by journey, 4D verification, 4E cutover. Phase 4A is complete.

**Companion docs:**
- `docs/2-0-screen-coverage.md` — every v1 screen mapped to its approved 2.0 Figma frame
- `docs/entitlement-audit-findings.md` — why free-tier enforcement is safe (audited against prod)

When starting a session, the user will tell you which roadmap item to work on. Stay scoped to that item unless explicitly asked to expand.

## Design references

- **TWO Figma files, distinct roles — confirm which one the user has open before authoring.** All **2.0 work lives in `uvHb6HXvIVFwzSSXPtEVoc`** ("Courtside IQ 2.0"), on its **Screens page** (`65:6`), which has NO "Claude Code" page. The older **`E8n8IE9ZnPRs6vykzINIyg`** ("CourtsideIQ — Performance Analytics") is the v1 reference file and the only one with a "Claude Code" page. For anything 2.0, author in `uvHb6` — do not place 2.0 drafts in the E8n8 Claude Code page (a parent drafting there wrongly on 2026-07-23 wasted a rebuild). To read a file's real page list use `use_figma` → `figma.root.children`; `get_metadata` with no nodeId has under-reported pages (returned 2 of 5 for `uvHb6`, hiding the Screens page). Always land on an approved variant before writing UI code.
- **The "Claude Code page" rule below applies to E8n8 (legacy) work only.** For E8n8: Claude-authored frames go on its "Claude Code" page (not "Inspiration" or any page the desktop app happens to be focused on) — find it via `/claude\s*code/i.test(p.name)`, `await page.loadAsync()`, and place beside the relevant section. For 2.0 (`uvHb6`), the equivalent rule is the Screens-page flow rule below: new screens go into their flow section; draft variants go in a clearly-labeled review area below the flow.
- **Organize the 2.0 Screens page as a FLOW, not a scatter.** The design-refresh file (`uvHb6HXvIVFwzSSXPtEVoc`) holds the high-fidelity screens, and they must be laid out so the user journey is legible: group each flow into a labeled Figma **Section** (Entry/Auth, Home/Today, Players, Games, New Game, Menu/Account, Premium/Paywall, Dialogs & States, etc.), arrange the screens left-to-right in journey order within each section, and draw **connector arrows** (lines + a small triangle head — FigJam Connectors are blocked in design mode) between screens to show what click leads where (including cross-section jumps like First-Run → Today, Menu Subscription → Paywall, Create → Setup → Live → Complete → Game Detail). Every NEW screen must be placed into its flow section and wired with a connector from its entry point, not just dropped on the canvas. The connectors/markings live in the gutters between frames, leaving the high-fi screens themselves untouched.

## Product constraints and rules

These apply to every change, every session:

**Copy and voice:**
- Never use em dashes in user-facing copy
- Tier hierarchy is **Solid → Good → Elite** (Solid is the entry level, not a strong rating — this has been misread before)
- Use "app store" (lowercase, generic) rather than "App Store" or "Google Play" in cross-platform strings
- Voice is warm, parent-friendly, development-focused
- Every rating level should feel acceptable — labels should encourage, not discourage
- Use player's first name for personalization when possible
- FAQ answers in paragraph form, not bullet points

**Metrics:**
- PPSA, AST/TOV, and Effort + Disruption have minimum-data thresholds before ratings activate (5 shot attempts for PPSA, 3 assists for AST/TOV, specific disrupt score minimums)
- Tier thresholds live in `lib/courtside_iq/metrics_config.dart` (created in Phase 0.1) and a mirrored TypeScript file in `supabase/functions/_shared/`. Never hardcode thresholds elsewhere.
- Zero-performance games should return no rating and display nothing (not a "zero" rating)

**AI insights:**
- Per-game insights use Claude Haiku
- Player-level development narratives use Claude Sonnet
- All insights return structured JSON, never free text alone
- Prompts live in version-controlled TypeScript, not external services
- Insights are cached per new game logged — never regenerated on every profile open

## Workflow preferences

- **When the user asks "which option?" or "should I do A or B?" — state a recommendation, give the one-line reason, then act.** Don't serve up a menu and wait. The user has said they prefer to understand the judgment call and move forward, not to pick from a checklist. If the decision is truly reversible and low-stakes, just make it.
- **Definition of Done for phase items = built + wired + device-verified.** Don't mark a `docs/courtside-iq-roadmap-v2.md` item complete until all three are true. A component built in `lib/features/` but not wired into call sites is **not done** — this is how the AddPlayerSheet got lost between Phase 1.2 and Phase 1.12. Every phase item in the roadmap should carry three checkboxes so gaps are visible.
- **UX must be designed and approved in Figma before any code is written.** No exceptions for new screens, modals, sheets, banners, badges, empty states, or copy-visible surfaces. If a feature has a user-facing visual component, pause and ask for the Figma link (or a design pass) before implementing. Code-first UX produces throwaway work and mis-scoped PRs.
- **Design with the `design-taste-frontend` ("Taste") skill in mind on every design pass.** Whenever designing or reviewing any user-facing surface (Figma frames or built UI), apply its transferable anti-slop lenses: reach past templated defaults, off-black not pure black, one earned accent used with intent (never decorative), control hierarchy with weight + color over raw scale, label-above inputs (no placeholder-as-label), one label per CTA intent, shape-consistency lock (bind radius tokens), full interactive state cycles, and the AI-tell bans (no neon/oversaturated glow by default, ration the middle-dot to 1 per line, zero em-dashes). It is a web/landing rubric, so skip the web-only rules (GSAP/scroll-hijack, hero-viewport, bento, image-gen). The lens for this system specifically: the real risk is "safe/templated/under-designed," not slop — lean into the brand motif (dot-burst) and let accent color carry meaning rather than shouting with full-bleed color. Skill lives at `~/.claude/.agents/skills/design-taste-frontend/SKILL.md`.
- **Always propose a plan before writing code.** State which files you'll touch, the order of changes, and what tests or verification you'll run. Wait for approval before executing.
- **Work on feature branches, never directly on main.** Branch naming: `phase-N-short-description` (e.g., `phase-0-tier-thresholds`).
- **Open pull requests for review** rather than merging to main directly. Keep PRs scoped to one roadmap item where possible.
- **Run `flutter analyze` before committing** any Dart changes. Fix warnings unless there's a reason not to.
- **For Edge Function work, test locally with `supabase functions serve`** before deploying. Deploy only when explicitly asked.
- **Show me new Edge Function files before deploying** until we've established a rhythm.

## Pending work (picked up next session)

**Backfill existing subscribers into `subscriptions`.** This is the last piece before free-tier
enforcement does anything. The table, `is_premium()`, the RevenueCat webhook, and the RLS limit are
all built and verified on **test**; the table is simply empty, so `is_premium()` returns false for
everyone and the paywall bypass stays open. That is a **deliberate, accepted state** - the user chose
not to risk production changes to close it.

To run the backfill:
- A **fresh RevenueCat secret API key** (customer read only) is ready. Never paste it into chat;
  load it with `read -s REVENUECAT_API_KEY && export REVENUECAT_API_KEY` so it does not land in the
  transcript or shell history. A previous key was leaked exactly this way and had to be revoked.
- `scripts/entitlement_audit.py` is the read-only precedent to model the backfill on.
- The rows that matter live in **prod**, so this needs the `subscriptions` table promoted there
  first. Do it as its own reviewed step with explicit approval, not folded into other work.

**Resolved 2026-07-19:** `20260615000001_backfill_trend_snapshots.sql` is applied to test and
recorded in `schema_migrations`. It was a **no-op on current data** - every game already had its
snapshot, since test holds no games predating the trigger. The point was closing the drift, not the
rows: an unapplied migration sitting in the repo is the pattern that broke the Games tab (4.6).

## Supabase environments

There are two Supabase projects. **Never mix them up.**

- **Test** — `yihmccmyijtyrffpzstb` (Courtside IQ Test 1)
- **Prod** — `ejwgxsszmfabujdqxxdz` (Courtside IQ v1, the live App Store / Play Store app)

**Rules:**
- All in-progress dev work targets **test**. Migrations, schema changes, and Edge Function deploys go to test first and stay there until the feature ships.
- **Never apply migrations, raw SQL, or Edge Function deploys to prod** without explicit user approval in the current message. Treat prod as read-only from Claude's side.
- The test-env switch lives in `lib/backend/supabase/supabase.dart` as `const bool _kUseTestSupabase = true;` (introduced on `infra-setup`, commit `3d3ad50`). Must be flipped to `false` before app store submission.
- **At the start of any session that touches Supabase — or anytime a device test is about to run — verify `_kUseTestSupabase` exists in `lib/backend/supabase/supabase.dart`.** If the current branch predates `infra-setup` (i.e. the flag isn't there), the app will hit prod and writes to new schema will silently fail. Flag this to the user before running; don't propose applying migrations to prod to "fix" it.
- When the user reports a save/fetch failing on a new feature, check the env flag and migration target before anything else.

## Schema and data model notes

Current Supabase tables relevant to insight work:
- `players` — player records (birth_date column added in Phase 1.1)
- `games` — match metadata
- `player_game_stats` — per-game stat rows; will hold `game_insights jsonb` after Phase 0
- `player_game_insights` — legacy table, merged into `player_game_stats` in Phase 0.3
- `v_player_game_stats` — view joining games + stats + insights
- `player_profile_view` — lifetime aggregate per player
- `player_development_insights` — new in Phase 2 (player-level narratives)
- `player_trend_snapshots` — new in Phase 2 (rolling 5-game metrics)

Never edit the database directly through the Supabase dashboard for schema changes. All schema changes go through `supabase/migrations/` files so they're version-controlled and reproducible.

## Things to flag before doing

Pause and check with me before:
- Introducing a new package or dependency
- Reaching for a different state management library (stay with the existing `FFAppState` / provider setup)
- Editing any file outside the custom-code surfaces listed above
- Making schema changes that aren't a migration file
- Deploying Edge Functions to production
- Changing RevenueCat, Firebase, or auth configuration
- Any change that affects currently-live features (v1.3.2 behavior) without a feature flag

## Known tech debt worth knowing

- `lib/environment_values.dart` loads JSON but doesn't assign the decoded data. Dead code or latent bug.
- ~~`test/widget_test.dart` permanently red~~ — **deleted 2026-07-19.** It was the default Flutter
  scaffold test: it pumped `MyApp()`, asserted nothing, and was named "Counter increments smoke
  test" in an app with no counter. Fixing it would have meant mocking Supabase startup to verify
  nothing. The suite is now fully green, so a red run means something is actually broken.
- `player_game_insights` still exists on **prod**. Phase 0.3 said to drop it after the merge; test
  dropped it, prod did not. Needs its own reviewed migration.
- iOS builds are now **hybrid SPM + CocoaPods** (Flutter 3.44 migrated automatically). Five plugins
  have no SPM support and Flutter warns this will eventually become an error.
- NOT a bug (was logged as one, note stayed stale): a game queued offline DOES get its AI insight
  when it syncs. `uploadPendingGame` upserts the rows then calls `generateGameInsight`, and the
  queue runs that same uploader on both the immediate save and the delayed flush. Closed 2026-07-22,
  device-verified 2026-07-26. Do not re-log this.
- The paywall bypass is **open by decision**: `subscriptions` is empty, so `is_premium()` is false
  for everyone until the backfill runs. The RLS limit is built and verified on test but has no data
  to act on yet. See "Pending work" below.

## A note on the user

The user is a solo designer-developer who owns both product and code. They value clear plans, direct feedback, and working in small reviewable chunks. They prefer iterative refinement over big unreviewed drops. When in doubt, ship smaller and check in more often.
