# Handoff — Courtside IQ palette swap (Apr 2026)

Branch: `palette-tune-apr-2026` (create from `main`)

## What this is

A **color-values-only swap** in the FlutterFlow theme. No structural changes, no renames, no new tokens, no call-site edits. The existing semantic system (teal = primary, vividViolet = AI mark, techBlue = change/info, imperial = growth edge) is preserved; every token keeps its name. Only hex values change to pull the palette into a cohesive family.

## Why (context for Claude Code)

The current palette feels corporate because the four semantic colors (teal, vividViolet, techBlue, imperial/magenta) were each picked in isolation from Tailwind defaults. They do their semantic jobs but have no shared undertone, so they read as four unrelated strangers rather than a family.

The tuned palette shifts each color 5–10° toward a subtle warm undertone so they resonate as siblings, and repoints the AI mark from violet to a warm amber (Spark). Everything else — layout, components, interactions, typography — is explicitly out of scope.

## Decisions already made (do NOT relitigate)

1. **Keep all token names.** `teal`, `vividViolet`, `techBlue`, `imperial`, `crispCyan` all continue to exist. Call sites don't change. Only values change.
2. **Repoint violet → Spark.** The AI mark color changes from violet (`#9C1BFA`) to amber (`#F2A43A`). This means `vividViolet`, `violet4550`, and `violet1520` now render amber. This is intentional — purple implies "AI product," amber implies "insight."
3. **Elite tier = Jade-700 (`#0A6B5A`), not a new token.** Do not add a `jadeDeep`, `elite`, or `spark` token. `accent3` has been repointed to Jade-700 for this purpose.
4. **`error` separates from growth-edge Rose.** Error changes from `#FB3442` (which was nearly identical to imperial magenta) to `#DC2626` (true red). This is the one intentional behavior change.
5. **Dead neon tokens (`primary`, `accent1`, `neon` at `#9DFF00`) align with reality.** They were dead FlutterFlow defaults. Mapped to Jade-500 so they match the de-facto primary.

## Scope

### In scope
- Edit exactly one file: `dependencies/ff_theme/lib/flutter_flow/flutter_flow_theme.dart`
- Inside `class LightModeTheme extends FlutterFlowTheme`, replace the block of `late Color` color declarations with the block supplied below
- Run `flutter analyze`
- Device-verify on 3 screens (listed below)

### Out of scope
- Do NOT rename any token
- Do NOT add new tokens (including no `spark`, `jade`, `rose`, `eliteAccent`, etc.)
- Do NOT change typography, shadows, radii, or any non-color property
- Do NOT refactor call sites
- Do NOT touch `DarkModeTheme` (if it exists — project is light-only today)
- Do NOT edit the `courtside-iq-dashboard-v2.html` mockup (that's a separate cleanup task I'll flag separately)
- Do NOT open a PR that also includes roadmap/feature work

## The change

### File
`dependencies/ff_theme/lib/flutter_flow/flutter_flow_theme.dart`

### What to find
Inside `class LightModeTheme extends FlutterFlowTheme`, the block that:
- **Starts with:** `late Color primary = const Color(0xFF9DFF00);`
- **Ends with:** `late Color teal = const Color(0xFF2BC18C);`

### What to replace it with

```dart
// =============================================================================
// Courtside IQ — tuned palette (Apr 2026)
// Token names preserved. Values shifted for family cohesion.
// Full rationale: docs/palette-apr-2026.md (if committed) or handoff doc.
// =============================================================================

// Material / FF defaults — aligned from dead neon scheme to Jade
late Color primary = const Color(0xFF0FA889);           // was #9DFF00 (dead neon) → Jade-500
late Color secondary = const Color(0xFFE04867);         // was #FB3640 → Rose-500
late Color tertiary = const Color(0xFFF2A43A);          // was #E5A500 → Spark-500 (AI mark amber)
late Color alternate = const Color(0xFFE8E2D7);         // was #E0E000 (dead neon yellow) → warm neutral

// Text + surfaces
late Color primaryText = const Color(0xFF1B1D24);       // was #0F0F0F → Ink-900 (faint cool shift)
late Color secondaryText = const Color(0xFF3A3F4B);     // was #292928 → Ink-700
late Color primaryBackground = const Color(0xFFFFFFFF); // unchanged
late Color secondaryBackground = const Color(0xFFE2E0DF); // unchanged

// Accents — aligned to semantic four
late Color accent1 = const Color(0xFF0FA889);           // was #9DFF00 → Jade-500 (matches primary)
late Color accent2 = const Color(0xFFE04867);           // was #FB3640 → Rose-500
late Color accent3 = const Color(0xFF0A6B5A);           // was #287E87 → Jade-700 (serves as Elite deep-jade)
late Color accent4 = const Color(0xB2FFFFFF);           // unchanged

// Semantic state
late Color success = const Color(0xFF3F8C5C);           // was #44D600 → Moss-500 (warmer green)
late Color warning = const Color(0xFFC77A2E);           // was #FFCC00 → burnt amber (distinct from Spark)
late Color error = const Color(0xFFDC2626);             // was #FB3442 → true red (now distinct from Rose)
late Color info = const Color(0xFF2558B8);              // was #1D1D1D (nonsensical) → Steel-500

// Grayscale — warmer Ink neutrals
late Color gray4 = const Color(0xFFF8F7F4);             // was #F5F5F5 → Ink-50
late Color gray1 = const Color(0xFF3A3F4B);             // was #2B2B2B → Ink-700
late Color gray2 = const Color(0xFF7A8290);             // was #8A8A8A → Ink-500
late Color gray3 = const Color(0xFFD0D4DB);             // was #CCCCCC → Ink-300

// Utility tokens (unchanged except noted)
late Color neon = const Color(0xFF0FA889);              // was #9DFF00 (dead) → Jade-500 (matches primary)
late Color primaryButtonText = const Color(0xFF0F0F0F); // unchanged
late Color grayButton = const Color(0xFF94918E);        // unchanged
late Color pbg30 = const Color(0x4DFFFFFF);             // unchanged
late Color pbg0 = const Color(0x000F0F0F);              // unchanged
late Color bottomSheetBg = const Color(0x9A0F0F0F);     // unchanged
late Color disableText = const Color(0xFF585858);       // unchanged
late Color blackAlway = const Color(0xFF0F0F0F);        // unchanged
late Color shadow = const Color(0x57FFFFFF);            // unchanged
late Color zeroStatBG = const Color(0x00F0F0F0);        // unchanged

// AI mark — repointed from Violet to Spark
// All existing call sites using vividViolet/violet4550/violet1520 now render
// Spark amber automatically. No code changes required.
late Color vividViolet = const Color(0xFFF2A43A);       // was #9C1BFA → Spark-500
late Color violet4550 = const Color(0x72F2A43A);        // was 0x729C1BFA → Spark-500 @ 45% alpha
late Color violet1520 = const Color(0x0EF2A43A);        // was 0x0E9C1BFA → Spark-500 @ 5% alpha

// Global background — warm canvas
late Color globalBackground = const Color(0xFFF5F3EF);  // was #F0F0F0 → warm-lean neutral

// Named brand tokens — the semantic four
late Color techBlue = const Color(0xFF2558B8);          // was #023BFF → Steel-500 (change/info)
late Color crispCyan = const Color(0xFF0FA889);         // was #22D3EE → Jade-500 (cyan folded in)
late Color imperial = const Color(0xFFE04867);          // was #FB3640 → Rose-500 (growth edge, softened)
late Color teal = const Color(0xFF0FA889);              // was #2BC18C → Jade-500 (everyday primary)
```

## Plan (propose before implementing)

Per `CLAUDE.md`'s "plan before code" rule, Claude Code should propose the plan first, get confirmation, then execute. The plan is simple:

1. Create branch `palette-tune-apr-2026` off `main`
2. Open `dependencies/ff_theme/lib/flutter_flow/flutter_flow_theme.dart`
3. Locate the `late Color` block inside `class LightModeTheme extends FlutterFlowTheme` (not the abstract `FlutterFlowTheme` above it)
4. Replace the block with the code above
5. Run `flutter analyze` — expect zero new warnings
6. Device-verify on 3 screens (below)
7. Commit and open PR

## Verification (required before merge)

### Static
- `flutter analyze` returns clean (no new warnings)
- File compiles without errors
- All existing theme token references still resolve (spot-check 5+ call sites)

### Device-verified screens
Test on iOS simulator, hitting the **test** Supabase environment (`_kUseTestSupabase = true`).

1. **Player profile — Development tab**
   Verify: development story card sparkle is now amber (not purple), header reads correctly, three narrative sections render (Bright Spots = jade family, Room to Grow = softened rose, Watch for Next = amber)
2. **Game detail screen**
   Verify: `HighlightMetricTagWidget` ("Scoring" / "Playmaking" / "Hustle" tags) renders amber on amber-tint background — this widget hardcodes `Color(0xFFEDE9FE)` and `Color(0xFF6D28D9)` in `lib/custom_code/widgets/highlight_metric_tag_widget.dart`, so it will NOT pick up the theme change. **FLAG THIS** — do not fix in this PR, note it in the PR description for follow-up
3. **Any error/validation state**
   Trigger a form validation error. Confirm error red (`#DC2626`) is visibly distinct from growth-edge rose on a nearby Room-to-Grow section. If they still read as the same color, the palette tune failed its primary job

## Risks / things to watch

- **`HighlightMetricTagWidget` hardcodes violet.** That widget won't auto-update from the theme swap. Flag it in the PR description as a known follow-up, do not fix in this PR
- **Rose (`#E04867`) may still feel alarming on Room-to-Grow sections at full app scale.** This was flagged during palette design. If parent testers say it feels like their kid got in trouble, follow-up is to shift rose toward coral (more orange, less red)
- **`secondaryBackground` stayed at `#E2E0DF`.** It's close to but not identical to the new canvas (`#F5F3EF`). If this causes visible banding anywhere two surfaces meet, follow-up
- **The `courtside-iq-dashboard-v2.html` mockup in the repo is now out of sync.** Separate cleanup task — don't include in this PR

## Definition of done

Per `CLAUDE.md`:
- [x] Built — color block replaced
- [x] Wired — no wiring needed, token names preserved
- [x] Device-verified on all 3 screens above
- [x] PR opened with description noting `HighlightMetricTagWidget` hardcode as follow-up
- [x] `flutter analyze` clean

## What NOT to do (guardrails)

- Do not add `spark`, `jade`, `rose`, or any other new color token
- Do not rename `vividViolet` even though it now renders amber (intentional — avoids call-site churn; rename is a separate refactor)
- Do not fix `HighlightMetricTagWidget` in this PR (it's a behavior change disguised as cleanup; separate PR)
- Do not apply the same changes to any Supabase migration, Edge Function, or backend file (palette is client-only)
- Do not merge to main — open PR for review per `CLAUDE.md`
