# Courtside IQ — Design System Overhaul Plan

**Goal:** Apply the v1.5 design system (colors, typography, spacing, radius, elevation) to the existing Courtside IQ FlutterFlow app **without changing any functionality, components, or layouts**.

**Reference files** (must be in the repo):
- `lib/courtside_iq/design_tokens.dart` — Dart constants, source of truth for code
- `docs/courtside-iq-design-system-spec.md` — markdown reference for grep
- `docs/courtside-iq-design-system.html` — visual reference (rendered separately)

**This plan is the first thing to read.** Do not start applying tokens before completing Phase 0.

---

## Non-goals (read first, do not violate)

These are explicit guardrails. If something seems like an obvious improvement, it goes in `followups.md`, not this PR.

- **No new components.** If a screen needs something that doesn't exist yet, document it and skip.
- **No removed components.** Even if a component looks unused, it stays.
- **No layout changes.** Same widget tree, same hierarchy, same constraints. Only visual tokens change.
- **No functionality changes.** No state management touches, no logic edits, no API calls modified.
- **No refactoring beyond token swaps.** Tempting opportunities to clean up code go in `followups.md`.
- **No FlutterFlow visual editor surgery during code work.** When a change requires the FF visual editor, flag it and continue — those go in a separate manual pass.

The single exception: if a hardcoded color or spacing value is *clearly* a bug (e.g. `Color(0xFF000001)` typo), fixing it counts as on-mission. Note it in the PR.

---

## Phase 0 — Assessment (must complete before any changes)

The point of Phase 0 is to map the territory before driving through it. Output is a single markdown file (`overhaul-assessment.md`) that becomes the input to every later phase.

### 0.1 Token inventory

Run a comprehensive scan of `lib/` for everything that should reference the new system. Use ripgrep or equivalent.

**Find every:**
- `Color(0xFF...)` — hardcoded color literal
- `Colors.<name>` — Material color reference
- `FlutterFlowTheme.of(context).<name>` — FF theme reference
- `EdgeInsets.all(N)`, `EdgeInsets.symmetric(...)`, `EdgeInsets.fromLTRB(...)` — hardcoded spacing
- `BorderRadius.circular(N)`, `BorderRadius.only(...)` — hardcoded radius
- `TextStyle(...)` instantiations with literal `fontSize`, `fontWeight`, `color`
- `BoxShadow(...)` instantiations
- `Container(decoration: BoxDecoration(...))` blocks

**Output format** (one row per finding):
```
file_path:line_number | category (color/spacing/radius/type/shadow) | current_value | proposed_token | notes
```

Categorize files into three buckets:

- **Generated** — `lib/main.dart`, `lib/flutter_flow/`, files under `lib/pages/` that are pure FF output. Cannot be edited directly. Changes must go through FF theme settings or visual editor.
- **Custom widgets** — files under `lib/courtside_iq/`, `lib/features/`, custom widget code in `lib/widgets/`. **Editable directly.** This is where the bulk of code work happens.
- **Theme** — `lib/flutter_flow/flutter_flow_theme.dart`. The single most important file: changes here propagate everywhere via `FlutterFlowTheme.of(context)`. Edit indirectly through FF App Properties → Theme Settings.

### 0.2 Surface inventory

List every screen and major widget in the app. For each, note:
- What design tokens it currently uses (which colors, what spacing/radius)
- Which bucket it falls into (generated / custom / theme)
- Estimated complexity for the overhaul (S/M/L)

This becomes the per-phase checklist later.

### 0.3 FF theme audit

Open `flutter_flow_theme.dart` and document:
- All current color names and values
- All current text styles
- Any custom values defined outside the standard FF set

Note discrepancies between the current FF theme and the v1.5 system. The output of this is the spec for the FF theme update in Phase 1.

### 0.4 Deliverable

A single file at `docs/overhaul-assessment.md` containing:
- Total findings by category (e.g. "147 hardcoded colors, 89 hardcoded radii")
- The full per-finding inventory
- Per-screen complexity estimate
- FF theme audit
- Any blockers identified (e.g. FF version constraint, missing fonts)

**Do not proceed past Phase 0 until this file exists and has been reviewed.**

---

## Phase 1 — FlutterFlow theme update (highest blast radius)

This phase makes the biggest visual change with the smallest amount of work because every screen reading `FlutterFlowTheme.of(context)` updates automatically.

### 1.1 Update FF theme via App Properties (manual, in FF)

In FlutterFlow's visual editor, go to App Properties → Theme Settings → Custom Colors and update each color to the v1.5 values:

| FF theme name | New value | Token |
|---|---|---|
| Primary | `#1B1D24` | `ink` (yes, primary is now Ink, not Jade) |
| Secondary | `#0FA889` | `jade500` |
| Tertiary | `#6B35C9` | `royal500` |
| Alternate | `#F2A43A` | `spark500` |
| Primary Background | `#EFEFF1` | `canvas` |
| Secondary Background | `#FFFFFF` | `surface` |
| Primary Text | `#1B1D24` | `ink` |
| Secondary Text | `#4A4D56` | `ink2` |
| Accent 1 | `#E04867` | `rose500` |
| Accent 2 | `#2558B8` | `steel500` |
| Accent 3 | `#E5E5E8` | `canvasSunk` |
| Accent 4 | `#E2E2E5` | `hairline` |

**Important:** the FF theme primary going from Jade to Ink is a behavior change for any widget bound to `primary` — this is how we propagate the "primary buttons are now black" rule. Verify in Phase 1.4 that nothing visually broke.

### 1.2 Update FF theme typography

In Theme Settings → Typography, update each style to match `CIType.*`. DM Sans must be set as the font family (already in the project per `userMemories`). Critical inversions:

- Display* styles → weight 400 (NOT 700)
- Heading styles (h1, h2, h3) → weights 700/700/600
- Body and small stay at 400

### 1.3 Drop `design_tokens.dart` into the project

Place at `lib/courtside_iq/design_tokens.dart`. This is what custom code references.

Verify import compiles cleanly:
```dart
import 'package:courtside_iq/courtside_iq/design_tokens.dart';
```

### 1.4 Theme verification

- Run the app on a device.
- Open every primary screen (Dashboard, Player Profile, Game Log, Insights, Settings).
- Visually compare to current production: anything that was using `theme.primary` should now be Ink (black), anything using `theme.secondary` should be Jade.
- **Do not fix anything that looks wrong yet.** Just write down what looks wrong in `phase-1-issues.md`. The fixes happen in Phase 2+.
- Take screenshots of every screen — these are the "before tokens" reference for later phases.

### 1.5 Commit checkpoint

Single commit, single PR. Title: `phase 1: design system theme update (v1.5)`.

PR description must include the screenshots from 1.4 and the `phase-1-issues.md` file.

---

## Phase 2 — Color migration in custom code

Replace every hardcoded color in the **custom widgets bucket** with `CIColors.*` tokens.

### 2.1 Order of attack

Follow this order — it minimizes wasted work:

1. **Shared widgets first.** Anything in `lib/widgets/`, `lib/courtside_iq/`, or imported by multiple screens.
2. **Dashboard widgets.** Highest visibility surface.
3. **Player Profile widgets.** Densest surface, most opportunities for wins.
4. **Game Log widgets.**
5. **Settings, menu, modal sheets.**
6. **One-off screens.**

For each file, work top-to-bottom, replacing hardcoded color values with the closest-meaning token. The mapping is in `design-system-spec.md` and `design_tokens.dart`.

### 2.2 Mapping rules (when in doubt)

When a hardcoded color doesn't have an obvious 1:1 token replacement, use this:

- **Brand-ish green/teal** → `CIColors.jade500`
- **Brand-ish purple** → `CIColors.royal500`  
- **Reds, magentas (for "grow" or "warning")** → `CIColors.rose500`
- **Oranges, ambers (for "elite" or "highlight")** → `CIColors.spark500`
- **Blues (for "info" or data)** → `CIColors.steel500`
- **Pure whites for cards** → `CIColors.surface`
- **Off-whites for backgrounds** → `CIColors.canvas` or `CIColors.canvasSunk`
- **Near-black text** → `CIColors.ink`
- **Mid-gray text** → `CIColors.ink2`
- **Light gray text/icons** → `CIColors.ink3`

If a color doesn't fit any of the above, **stop and add it to `followups.md`**. Do not invent new tokens.

### 2.3 Per-file workflow

For each custom widget file:

1. Open file. Note the screen it's part of.
2. Run search for `Color(0x` and `Colors.` within the file.
3. Replace each match with the appropriate `CIColors.*` token. Add the import if missing.
4. Run `flutter analyze` on the file. Fix any errors.
5. Visual-check the screen on a device.
6. Commit per-file or per-feature, not all at once.

### 2.4 Verification per screen

After each screen's color migration:

- Compare side-by-side with the Phase 1.4 screenshot.
- Note: text contrast must be visibly correct. `ink` on `surface` is the safest default; `ink2` on `surface` is fine for body. Anything else, double-check.
- Tier tags should still match their semantic colors (Solid → steel, Good → jade, Elite → spark, Grow → rose, AI → royal).
- Update `phase-2-progress.md` with screen status.

### 2.5 Commit checkpoint

Multiple commits, one PR per area (shared widgets, dashboard, player profile, etc.). Title format: `phase 2.N: color migration — [area]`.

---

## Phase 3 — Typography migration

Replace every hardcoded `TextStyle(...)` with `CIType.*` references where the intent matches.

### 3.1 Critical rule: the inversion

**Hero numerals (anything that displays a stat, score, percentage, count) must be weight 400.** This is the most common source of "looks wrong" feedback. If you're touching a TextStyle that wraps a number larger than 18px, default to `CIType.displaySm`, `displayMd`, or `displayLg` — all of which are weight 400 with tabular figures.

If you find a number-displaying TextStyle that's already at weight 700 with a hardcoded color, that's the highest-value swap in the entire overhaul. Don't miss it.

### 3.2 Mapping rules

| If TextStyle has... | Use... |
|---|---|
| `fontSize >= 28` and is a number | `displaySm`, `displayMd`, or `displayLg` (pick by exact size) |
| `fontSize 18-22` and is a heading | `h1` (22) or `h2` (17) |
| `fontSize 14` and is bold | `h3` if it's a label; `bodyStrong` if it's body emphasis |
| `fontSize 14` and is regular weight | `body` |
| `fontSize 13` | `small` |
| `fontSize 11` | `caption` |
| `fontSize 10` and uppercase | `eyebrow` |

For numbers in stat rows or columns: `caption` or `bodyStrong` with `fontFeatures: [FontFeature.tabularFigures()]` added inline.

### 3.3 Per-file workflow

Same as Phase 2: open file, find TextStyles, replace with tokens, analyze, visual-check, commit.

If a TextStyle has a custom property that doesn't map (e.g. specific letter spacing, italic), use the closest token via `.copyWith()`:
```dart
CIType.body.copyWith(fontStyle: FontStyle.italic)
```

### 3.4 Verification per screen

For each screen, walk through this checklist:

- Are all hero numbers (scores, percentages, big stats) visibly **lighter** than their labels above them? If they're heavier or equal, the inversion isn't applied yet.
- Do columns of numbers line up vertically (tabular figures)? If digits drift, tabular features aren't on.
- Are headings using h1/h2/h3 weights (700/700/600)? Compare against the design system HTML.
- Does any text look weirdly small/large compared to neighbors? Could be a missed font-size literal.

### 3.5 Commit checkpoint

One PR per area. Title: `phase 3.N: typography migration — [area]`.

---

## Phase 4 — Spacing migration

Replace every hardcoded `EdgeInsets`, `SizedBox(height/width: N)`, and `Padding(padding: ...)` value with `CISpacing.*` references.

### 4.1 The signature value

Card-to-card gap is **8px (`CISpacing.s2`)**. Anywhere you find a `Column` or `ListView` with `SizedBox(height: 16)` or `SizedBox(height: 12)` between cards, change it to `s2`. This is the single most impactful spacing change in the overhaul.

### 4.2 Mapping rules

| Old value | New token | Notes |
|---|---|---|
| 4 | `s1` | |
| 8 | `s2` | **Card gaps default here** |
| 12 | `s3` | When section needs to breathe more |
| 16 | `s4` | Tight card inner padding |
| 20 | `s5` | Standard card inner padding |
| 24 | `s6` | Section breaks |
| 32 | `s8` | Major section breaks |
| 40 | `s10` | |
| 48 | `s12` | |

If a value doesn't fit (e.g. `EdgeInsets.all(13)`), round to the nearest token — don't invent intermediate tokens. If the rounding looks wrong visually, check the design system HTML — usually the answer is one step different than expected.

### 4.3 Per-screen verification

After each screen's spacing migration:

- Card gaps are visibly tighter than before. If the screen looks the same, you missed something.
- Inner padding is consistent across cards on the same screen.
- No card touches another card without a gap.
- Sections within a card have 8–12px between them, not 16+.

### 4.4 Commit checkpoint

One PR per area. Title: `phase 4.N: spacing migration — [area]`.

---

## Phase 5 — Radius migration

Replace every hardcoded `BorderRadius.circular(N)` with `CIRadius.brMd` (or appropriate token).

### 5.1 Mapping rules

| Old value | New token | Use |
|---|---|---|
| 2 | `brXs` | Status dots |
| 4, 6 | `brSm` | Tags, buttons, inner pills |
| 8, 10, 12, 14 | `brMd` | **Cards (most common — round down/up to 6)** |
| 16, 18, 20 | `brLg` | Group containers |
| 24+ | `brXl` | Sheets, modals |
| Anything circular | `BorderRadius.circular(CIRadius.full)` | Avatars, pill bars |

The big change: **most cards in the app are currently at 12–16px radius. They go to 6px.** Verify against `design-system-spec.md` if uncertain.

### 5.2 Nesting rule check

After applying radius tokens, do a quick visual pass on each screen: does any element have a radius equal to or larger than its parent? If yes, the nesting rule is violated. Drop the child by one step.

### 5.3 Commit checkpoint

One PR. Title: `phase 5: radius migration`.

---

## Phase 6 — Elevation migration

Replace hardcoded `BoxShadow(...)` lists with `CIElevation.*` references.

### 6.1 Mapping rules

| Old shadow recipe | New token |
|---|---|
| 1px shadow + hairline-like border | `CIElevation.card` |
| Stack of 2+ shadows on cards | `CIElevation.card` (downgrade — cards don't float) |
| Modal/sheet shadows | `CIElevation.modal` |
| Tooltip/popover shadows | `CIElevation.pop` |
| No shadow, just border | `CIElevation.hairline` |

If a card has an elaborate multi-layer shadow stack: **downgrade to `card`**. The system says cards don't float. The exception is hero cards (Tier 5), which use `CIElevation.hero`.

### 6.2 Commit checkpoint

One PR. Title: `phase 6: elevation migration`.

---

## Phase 7 — Verification & polish

After phases 1–6 are merged, do a full app walkthrough.

### 7.1 The walkthrough script

Open every screen in this order and compare to the v1.5 design system HTML:

1. App launch screen / onboarding
2. Sign in / sign up
3. Dashboard (home)
4. Player profile — Averages tab
5. Player profile — Games tab
6. Player profile — Development (insight) tab
7. Game log entry / new game flow
8. Settings menu
9. All modal sheets and bottom sheets
10. Empty states, error states, loading states

For each screen, write down:
- What looks right
- What looks wrong (with a screenshot)
- Whether the issue is a token miss (we forgot to swap) or a structural issue (would need real refactoring — goes to `followups.md`)

### 7.2 Token miss cleanup

For every "token miss" finding, fix in a single PR titled `phase 7: token miss cleanup`. This catches the long tail of values we missed during scan-and-replace.

### 7.3 Followups documentation

For every "structural issue" finding, add to `followups.md` with:
- The screen
- What's wrong
- What change would be needed (in 1–2 sentences)
- Suggested phase to address it

This is the input for the *next* design system pass — the one that will touch components and layouts.

---

## FlutterFlow-specific notes

These are the realities of working in an FF-generated codebase. Plan around them.

### What lives where

- **`lib/main.dart`, `lib/pages/<screen>/<screen>_widget.dart`** — generated. Do not edit directly. Use FF visual editor.
- **`lib/flutter_flow/flutter_flow_theme.dart`** — generated. Do not edit directly. Use FF App Properties → Theme Settings.
- **`lib/flutter_flow/*` (other files)** — generated. Do not edit.
- **`lib/courtside_iq/`** — custom code namespace. **Edit freely.** This is where `design_tokens.dart` lives.
- **`lib/features/<name>/`** — custom widget folders for specific features. **Edit freely.**
- **`lib/custom_code/widgets/`, `lib/custom_code/actions/`** — FF custom code slots. **Edit freely** but mirror changes back to FF if the widget is referenced in the visual editor.

### When code edits aren't enough

Some changes can only happen in the FF visual editor:

- Updating widget-level color/font/spacing bindings on FF-generated widgets
- Adding theme color references to widget property bindings
- Changing FF theme tokens (this propagates back to generated code)

When you find one of these during code work: **document it, don't try to fix it via code edits.** Generated files will get overwritten on the next FF regeneration. Flag in the PR as `[FF-MANUAL]` and put the list in a top-level `ff-manual-changes.md` file.

After all code phases are done, a separate manual session in FF visual editor handles all `[FF-MANUAL]` items as one batch.

### Regeneration safety

If FF regenerates while overhaul is in progress:
- Files in `lib/courtside_iq/`, `lib/features/`, `lib/custom_code/` are safe.
- Files in `lib/pages/` and `lib/flutter_flow/` will be overwritten.
- Run a re-assessment of any overwritten files and reapply token changes.

To minimize regeneration risk: **do not push major FF changes during overhaul.** No new screens, no new state variables, no new actions. Just visual property bindings on existing widgets.

---

## Execution timeline (estimate)

This is a guess based on typical app sizes. Adjust after Phase 0 reveals actual scope.

| Phase | Scope | Estimate |
|---|---|---|
| 0 — Assessment | Inventory + planning | 1 day |
| 1 — FF theme update | Manual FF + tokens file | Half day |
| 2 — Color migration | All custom widgets | 2–3 days |
| 3 — Typography migration | All custom widgets | 1–2 days |
| 4 — Spacing migration | All custom widgets | 1–2 days |
| 5 — Radius migration | All custom widgets | Half day |
| 6 — Elevation migration | All custom widgets | Half day |
| 7 — Verification & polish | Walkthrough + cleanup | 1 day |
| FF visual editor batch | Manual `[FF-MANUAL]` items | 1 day |

**Total:** roughly 8–10 working days end-to-end, assuming no regeneration accidents and the assessment phase doesn't reveal major surprises.

---

## Definition of done

The overhaul is complete when:

1. Every primary screen visually matches the v1.5 design system HTML reference within reasonable tolerance.
2. No hardcoded color, radius, spacing, or text style values remain in the custom code bucket. (Generated code is exempt — those propagate via FF theme.)
3. `flutter analyze` passes with no new warnings introduced by the overhaul.
4. The app runs on iOS and Android devices with no visual regressions in functionality.
5. `followups.md` contains every structural improvement deferred during this pass.
6. The v1.3.x → v1.4.0 release notes describe the overhaul and link to the design system doc.

If a screen genuinely cannot be brought to spec without layout changes, it gets called out explicitly in `followups.md` and stays as-is for now.
