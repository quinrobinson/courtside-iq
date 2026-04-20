# Courtside IQ — Claude Code Context

## What this project is

Courtside IQ is a youth basketball player development app for parents of players ages 8–18. It is positioned as a **development tool, not a stat tracker**. Every feature, metric, and piece of copy should connect numbers to player growth. Parents are the primary user; players themselves are not.

The app is live on the App Store and Google Play. Primary audience: parents tracking 1–3 players.

## How the codebase is structured

This is a FlutterFlow-generated Flutter app with a Supabase backend.

**New feature workflow (Phase 1 onward):** New screens and features are built with Claude Code + Figma directly in Flutter/Dart — not through the FlutterFlow visual builder. New feature code lives in `lib/features/`. The existing FlutterFlow build is left untouched.

**FlutterFlow-generated code (do NOT edit — existing build, leave as-is):**
- `lib/main.dart`
- `lib/backend/supabase/` (generated table definitions)
- `lib/pages/` (generated screen widgets)
- Most files in `lib/flutter_flow/` (framework files)
- `ios/` and `android/` platform folders
- `pubspec.yaml` (managed by FlutterFlow)

**New feature code (safe to create and edit):**
- `lib/features/` — new screens and widgets built with Claude Code
- `lib/courtside_iq/` — shared config and utilities (e.g. `metrics_config.dart`)
- `lib/flutter_flow/custom_functions.dart` — Custom Functions, pure Dart utilities
- `assets/` — images, fonts, static files

**Supabase (fully owned in this repo, not touched by FlutterFlow):**
- `supabase/functions/` — Edge Functions (TypeScript, Deno runtime)
- `supabase/migrations/` — SQL migrations for schema changes
- Secrets live in the Supabase dashboard, never in the repo

**Rule of thumb:** If a change needs to persist, it lives in `lib/custom_code/`, `lib/flutter_flow/custom_functions.dart`, or `supabase/`. Anything else will be overwritten.

## Tech stack

- Flutter / Dart (client)
- FlutterFlow (visual builder, source of truth for UI and action flows)
- Supabase (database, auth, Edge Functions)
- Supabase Edge Functions in TypeScript (Deno runtime)
- Claude API (AI-powered insights — Haiku for per-game, Sonnet for player-level narrative)
- RevenueCat (subscriptions: weekly and monthly plans)
- Firebase Crashlytics (error monitoring)

## The roadmap

The full phased plan for current work is at `docs/roadmap.md`. Always read it at the start of a session. It covers:
- Phase 0: foundation cleanup (tier thresholds, jsonb migration, PPSA edge case)
- Phase 1: Buildship → Supabase Edge Functions migration + age data + metric improvements
- Phase 2: player-level development narrative (new feature)
- Phase 3: deferred items

When starting a session, the user will tell you which roadmap item to work on. Stay scoped to that item unless explicitly asked to expand.

## Design references

- Figma file: **CourtsideIQ — Performance Analytics** — https://www.figma.com/design/E8n8IE9ZnPRs6vykzINIyg/CourtsideIQ---Performance-Analytics. This is the single source of truth for UI designs across the project. Use the Figma MCP to read frames and draft variants; always land on an approved variant before writing UI code.
- **Claude-authored Figma work belongs on the "Claude Code" page** (not "Inspiration" or any active page the desktop app happens to be focused on). When creating new frames via `use_figma`, append to the Claude Code page explicitly — e.g. find the page with `/claude\s*code/i.test(p.name)` and `await page.loadAsync()` before appending. Place new frames beside the relevant existing section on that page.

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
- **Definition of Done for phase items = built + wired + device-verified.** Don't mark a `docs/roadmap.md` item complete until all three are true. A component built in `lib/features/` but not wired into call sites is **not done** — this is how the AddPlayerSheet got lost between Phase 1.2 and Phase 1.12. Every phase item in `roadmap.md` should carry three checkboxes so gaps are visible.
- **UX must be designed and approved in Figma before any code is written.** No exceptions for new screens, modals, sheets, banners, badges, empty states, or copy-visible surfaces. If a feature has a user-facing visual component, pause and ask for the Figma link (or a design pass) before implementing. Code-first UX produces throwaway work and mis-scoped PRs.
- **Always propose a plan before writing code.** State which files you'll touch, the order of changes, and what tests or verification you'll run. Wait for approval before executing.
- **Work on feature branches, never directly on main.** Branch naming: `phase-N-short-description` (e.g., `phase-0-tier-thresholds`).
- **Open pull requests for review** rather than merging to main directly. Keep PRs scoped to one roadmap item where possible.
- **Run `flutter analyze` before committing** any Dart changes. Fix warnings unless there's a reason not to.
- **For Edge Function work, test locally with `supabase functions serve`** before deploying. Deploy only when explicitly asked.
- **Show me new Edge Function files before deploying** until we've established a rhythm.

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
- Reaching for a different state management library (stay with what FlutterFlow generates)
- Editing any file outside the custom-code surfaces listed above
- Making schema changes that aren't a migration file
- Deploying Edge Functions to production
- Changing RevenueCat, Firebase, or auth configuration
- Any change that affects currently-live features (v1.3.2 behavior) without a feature flag

## Known tech debt worth knowing

- `lib/environment_values.dart` loads JSON but doesn't assign the decoded data. Dead code or latent bug — cleanup scheduled in Phase 0.5.
- Current `disruptSolid/Good/Elite` functions take thresholds as arguments, meaning cutoffs live in FF action flows. Cleanup scheduled in Phase 0.1.
- Current Buildship integration (`GetGameInsightsCall` in `lib/backend/api_requests/api_calls.dart`, URL `https://nni3ua.buildship.run/gameinsights`) is being replaced by Supabase Edge Functions in Phase 1.

## A note on the user

The user is a solo designer-developer who owns both product and code. They value clear plans, direct feedback, and working in small reviewable chunks. They prefer iterative refinement over big unreviewed drops. When in doubt, ship smaller and check in more often.
