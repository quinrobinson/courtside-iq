# Courtside IQ — Design System Overhaul Assessment

**Branch:** `design-system-overhaul-v1.5`  
**Date:** 2026-05-05  
**Scope:** Custom code bucket only — `lib/features/`, `lib/courtside_iq/`, `lib/custom_code/`  
**Out of scope for code edits:** `lib/pages/` (96 generated FF files), `lib/flutter_flow/`, `lib/main.dart`

---

## Summary: Total Findings by Category

| Category | Count | Files |
|---|---|---|
| Hardcoded `Color(0xFF...)` | **122** | 21 |
| `Colors.*` references | **52** | 16 |
| `EdgeInsets` (spacing) | **85** | 18 |
| `SizedBox(height/width:)` (spacing) | **128** | 18 |
| `BorderRadius.circular(N)` (radius) | **58** | 19 |
| `TextStyle(...)` (typography) | **108** | 18 |
| `BoxShadow(...)` (elevation) | **4** | 3 |
| **Total token findings** | **557** | — |

### `Colors.*` breakdown (not all need tokens)
Of the 52 `Colors.*` references:
- ~14 are `Colors.transparent` — keep as-is (transparent is not a token)
- ~6 are `Colors.black.withValues(alpha:...)` — barrier/overlay uses, keep semantically
- ~24 are `Colors.white` → most → `CIColors.surface`; some on brand bg → `CIColors.inkOnBrand`
- ~8 are other (e.g., `Colors.white.withValues(alpha:...)` for overlays)

Net migration targets from `Colors.*`: **~32 items**.

---

## Blockers

### B1 — Font family: FF theme uses Montserrat + IBM Plex Sans, not DM Sans
**Severity: High.** Phase 1 must switch all FF typography to DM Sans. Custom widgets already use `CIType.fontFamily = 'DM Sans'` but some hardcoded `TextStyle` in custom code reference `fontFamily: 'Inter'` (4 occurrences in `averages_tab.dart` and `games_tab.dart`) — these need to become `CIType.fontFamily` or be removed.

DM Sans presence in `pubspec.yaml` must be verified before Phase 3 typography migration begins.

### B2 — Ink color shift is visible
`CIColors.ink = #1B1D24` replaces the current near-black `#0F0F0F` / `#1A1A1A` used throughout. This is a cool-toned navy vs. a warm near-black. Every primary text element changes. This is intentional and correct per v1.5, but worth a full visual check after Phase 2.

### B3 — Jade color shift is visible
Current `teal` (used for "Good" tier and trend indicators) = `#2BC18C`. New `CIColors.jade500` = `#0FA889`. These are similar but noticeably different greens. Tier dots, progress indicators, and trend pills will shift.

### B4 — Royal/purple is shifting significantly
Current `vividViolet` / `_purple` = `#9C1BFA` / `#7936FF`. New `CIColors.royal500` = `#6B35C9`. The shift from bright violet to deep royal purple affects development story cards and the spark gradient.

### B5 — Radius is halving for most cards
Cards currently at 16px radius drop to `CIRadius.xl` (12px) or `CIRadius.md` (6px). The most common large radius (16px) maps to `CIRadius.xl` (12px) — a notable tightening. Verify no clipping issues on avatar/pill elements.

---

## 0.1 Token Inventory — Per-Finding Table

### `lib/courtside_iq/skeleton_widget.dart`

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 24 | color | `Color(0xFFDADBDE)` | `CIColors.canvasSunk` | skeleton tint |
| 25 | radius | `BorderRadius.circular(radius)` | n/a — param | default param is `12.0` → change default to `CIRadius.xl` |

---

### `lib/custom_code/widgets/highlight_metric_tag_widget.dart`

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 38 | spacing | `EdgeInsets.symmetric(horizontal: 8)` | `CISpacing.s2` | tag padding |
| 40 | color | `Color(0xFFEDE9FE)` | `CIColors.royal50` | royal bg tint |
| 41 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | tag → should be `CIRadius.sm` (4px) per spec |
| 50 | color | `Color(0xFF6D28D9)` | `CIColors.royal500` | royal icon color |
| 52 | spacing | `SizedBox(width: 4)` | `CISpacing.s1` | icon-text gap |
| 55–58 | typography | `TextStyle(fontSize/fontWeight/color...)` | `CIType.caption` | tag text |
| 60 | color | `Color(0xFF5B21B6)` | `CIColors.royal600` | hover/pressed royal |

---

### `lib/features/dashboard/dashboard_page.dart` (L — highest priority)

**Colors:**

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 212 | color/bg | `Color(0xFFF2F3F5)` | `CIColors.canvas` | scaffold bg |
| 325 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | player name |
| 368 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | btn foreground |
| 369 | color | `Color(0xFFE3E1E0)` | `CIColors.hairline` | btn border |
| 429 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | nav pill border |
| 437 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | active tab text |
| 472 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | inactive tab icon |
| 487 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | count text |
| 591 | color | `Color(0xFF2BC18C)` | `CIColors.jade500` | insight accent — see B3 |
| 739 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | border side |
| 784 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | section heading |
| 797 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 853 | color | `Color(0xFFDADBDE)` | `CIColors.canvasSunk` | divider/separator |
| 927 | color | `Color(0xFFE3E1E0)` | `CIColors.hairline` | card border |
| 943 | color | `Color(0xFFE53935)` | `CIColors.rose500` | error/alert accent |
| 955 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 965 | color | `Color(0xFFE53935)` | `CIColors.rose500` | |
| 990 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 1002 | color | `Color(0xFF9A9A9A)` | `CIColors.ink3` | muted meta |
| 1045 | color | `Color(0xFFE2E0DF)` | `CIColors.hairline` | border |
| 1055 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 1065 | color | `Color(0xFF6A6A6A)` | `CIColors.ink3` | |
| 1092 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 1103 | color | `Color(0xFF7936FF)` | `CIColors.royal500` | royal accent — see B4 |

**Colors.* (non-transparent):**

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 610 | color | `Colors.white.withValues(alpha: 0.35)` | `CIColors.surface.withValues(alpha:0.35)` | overlay |
| 618 | color | `Colors.white` | `CIColors.inkOnBrand` | text on brand bg |
| 634 | color | `Colors.white` | `CIColors.inkOnBrand` | |
| 642 | color | `Colors.white.withValues(alpha: 0.8)` | `CIColors.inkOnBrand.withValues(alpha:0.8)` | |
| 658 | color | `Colors.white` | `CIColors.surface` | card/sheet bg |
| 925 | color | `Colors.white` | `CIColors.surface` | card bg |
| 974 | color | `Colors.white` | `CIColors.inkOnBrand` | text on colored bg |

**Spacing (EdgeInsets):**

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 272 | spacing | `EdgeInsets.fromLTRB(20, top+14, 20, 0)` | `CISpacing.s5` for h — top uses dynamic | keep top dynamic |
| 282 | spacing | `EdgeInsets.fromLTRB(20, 16, 20, 0)` | `CISpacing.s4` / `CISpacing.s5` | |
| 289 | spacing | `EdgeInsets.fromLTRB(20, 16, 20, 0)` | `CISpacing.s4` / `CISpacing.s5` | |
| 295 | spacing | `EdgeInsets.fromLTRB(20, 24, 20, 12)` | `CISpacing.s6` / `CISpacing.s3` | |
| 318 | spacing | `EdgeInsets.fromLTRB(20, 24, 20, 12)` | `CISpacing.s6` / `CISpacing.s3` | |
| 332 | spacing | `EdgeInsets.symmetric(horizontal: 20)` | `CISpacing.s5` | |
| 336 | spacing | `EdgeInsets.only(bottom: 12)` | `CISpacing.s3` | |
| 364 | spacing | `EdgeInsets.fromLTRB(20, 4, 20, 0)` | `CISpacing.s5` / `CISpacing.s1` | |
| 424 | spacing | `EdgeInsets.symmetric(horizontal: 10)` | — | 10 has no exact token; nearest s2(8) or s3(12); check visually |
| 481 | spacing | `EdgeInsets.only(left: i>0 ? 5 : 0)` | — | 5 → `CISpacing.s1` (4px) rounded |
| 551 | spacing | `EdgeInsets.only(...)` | review value | |
| 599 | spacing | `EdgeInsets.all(12)` | `CISpacing.s3` | |
| 606 | spacing | `EdgeInsets.symmetric(h:6, v:2)` | — | 6 → `CISpacing.s1` (4) rounded; check |
| 823 | spacing | `EdgeInsets.fromLTRB(20, top+20, 20, 0)` | `CISpacing.s5` | |
| 929 | spacing | `EdgeInsets.fromLTRB(16, 14, 16, 14)` | `CISpacing.s4` / nearest | 14 → `CISpacing.s3`(12) or `s4`(16); ask |
| 962 | spacing | `EdgeInsets.symmetric(...)` | review value | |

**SizedBox spacers** (select highlights):

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 307,309 | spacing | `SizedBox(height: 28)` | — | 28 → between s6(24) and s8(32); ask |
| 828 | spacing | `SizedBox(height: 8)` | `CISpacing.s2` | |
| 830 | spacing | `SizedBox(height: 32)` | `CISpacing.s8` | |
| 832 | spacing | `SizedBox(height: 28)` | — | see above |
| 834 | spacing | `SizedBox(height: 12)` | `CISpacing.s3` | |
| 980 | spacing | `SizedBox(height: 8)` | `CISpacing.s2` | |

**Radius:**

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 371 | radius | `BorderRadius.circular(12)` | `CIRadius.brXl` | card |
| 428 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | tab pill |
| 488 | radius | `BorderRadius.circular(3)` | `CIRadius.brXs` | pip/dot |
| 597 | radius | `BorderRadius.circular(12)` | `CIRadius.brXl` | insight card |
| 608 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | inner chip |
| 854 | radius | `BorderRadius.circular(12)` | `CIRadius.brXl` | divider ends |
| 926 | radius | `BorderRadius.circular(14)` | `CIRadius.brXl` | upgrade card |
| 966 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | tag |
| 1044 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | |

**Typography (select — see pattern):**

| Line | Category | Approx Style | Proposed Token | Notes |
|---|---|---|---|---|
| 321 | type | body/caption weight | `CIType.body` or `CIType.caption` | |
| 374 | type | button text | `CIType.bodyStrong` | |
| 433 | type | nav label | `CIType.caption` | |
| 780 | type | section heading | `CIType.h2` | |
| 951 | type | upgrade headline | `CIType.h2` or `CIType.h1` | |
| 970 | type | upgrade body | `CIType.small` | |
| 986 | type | upgrade CTA | `CIType.bodyStrong` | |

---

### `lib/features/dashboard/widgets/dashboard_avatar.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 17 | color | `Color(0xFFE8E8E8)` | `CIColors.canvasSunk` | avatar bg |
| 18 | color | `Color(0xFF6A6A6A)` | `CIColors.ink3` | avatar placeholder fg |

---

### `lib/features/dashboard/widgets/game_feed_card.dart` (M)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 7 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 8 | color | `Color(0xFFC0C0C0)` | `CIColors.ink4` | muted text |
| 9 | color | `Color(0xFF8A8A8A)` | `CIColors.ink3` | sub text |
| 10 | color | `Color(0xFFD9005C)` | `CIColors.rose500` | "room to grow" accent |
| 11 | color | `Color(0xFFE3E1E0)` | `CIColors.hairline` | card border |
| 13 | color | `Color(0xFF52535D)` | `CIColors.ink2` | badge text |
| 47 | color | `Colors.white` | `CIColors.surface` | card bg |
| 48 | radius | `BorderRadius.circular(16)` | `CIRadius.brXl` | card → drops to 12 |
| 101 | spacing | `EdgeInsets.symmetric(horizontal: 10)` | — | 10 → see B; round to `s2`(8) or `s3`(12) |
| 115 | spacing | `EdgeInsets.fromLTRB(16,12,16,14)` | `CISpacing.s4` / `CISpacing.s3` | inner padding |
| 163 | spacing | `EdgeInsets.symmetric(h:10, v:5)` | — | 5 → s1; 10 → ask |
| 166 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | badge |
| 237 | spacing | `EdgeInsets.symmetric(vertical: 10)` | — | 10 → ask |
| 239 | color | `Colors.white` | `CIColors.surface` | |
| 240 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | |
| 246,257,71,81,126,170 | type | hardcoded TextStyle | see CIType mapping | |
| 254 | spacing | `SizedBox(height: 3)` | — | micro gap, leave or → `CISpacing.xs` (none defined); add to followups.md |

---

### `lib/features/dashboard/widgets/snapshot_card.dart` (M)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 6 | color | `Colors.white` | `CIColors.surface` | |
| 7 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 8 | color | `Color(0xFF8A8A8A)` | `CIColors.ink3` | |
| 9 | color | `Color(0xFFE3E1E0)` | `CIColors.hairline` | |
| 43 | color | `Color(0xFF9C1BFA), Color(0xFFF2A43A)` | `CIColors.royal500`, `CIColors.spark500` | gradient; see B4 |
| 47 | radius | `BorderRadius.circular(16)` | `CIRadius.brXl` | outer card |
| 49 | spacing | `EdgeInsets.all(1.5)` | — | gradient border thickness, leave |
| 53 | radius | `BorderRadius.circular(14.5)` | `CIRadius.xl - 1.5` | inner radius nesting rule; adjust after outer |
| 61 | spacing | `EdgeInsets.fromLTRB(16,14,16,0)` | `CISpacing.s4` | |
| 74,83,104,119 | type | hardcoded TextStyle | `CIType.*` | |
| 101,116 | spacing | `EdgeInsets.fromLTRB(16,0,16,16)` | `CISpacing.s4` | |

---

### `lib/features/player_insight/player_profile_page.dart` (L)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 11 | color | `Color(0xFFF2F3F5)` | `CIColors.canvas` | bg |
| 12 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 13 | color | `Color(0xFF8A8A8A)` | `CIColors.ink3` | |
| 14 | color | `Colors.white` | `CIColors.surface` | card bg |
| 16 | color | `Color(0xFFE5E6E9)` | `CIColors.canvasSunk` | tab track |
| 145 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | tab pill inner |
| 271 | radius | `BorderRadius.circular(12)` | `CIRadius.brXl` | profile card |
| 284 | radius | `BorderRadius.circular(10)` | `CIRadius.brLg`(8) or `brXl`(12) | check nesting |
| 286 | shadow | `BoxShadow(...)` | `CIElevation.card` | card shadow |
| 305 | type | `TextStyle(...)` | `CIType.*` | tab label |
| 369 | color | `Color(0xFFC3BFBB)` | `CIColors.ink4` | muted icon |
| 382 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 384 | shadow | `BoxShadow(...)` | `CIElevation.pop` | tab indicator shadow |

---

### `lib/features/player_insight/widgets/about_story_sheet.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 3 | color | `Color(0xFF7936FF)` | `CIColors.royal500` | |
| 4 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 5 | color | `Color(0xFFE6E6E6)` | `CIColors.hairline` | |
| 25 | color | `Colors.white` | `CIColors.surface` | sheet bg |
| 28 | spacing | `EdgeInsets.fromLTRB(20,10,20,24+bottomInset)` | `CISpacing.s5` | |
| 39 | radius | `BorderRadius.circular(2)` | `CIRadius.brXs` | handle |
| 43,54,60 | spacing | `SizedBox(height: 20)` | `CISpacing.s5` | |
| 46,84,95 | type | `TextStyle(...)` | `CIType.*` | |
| 92 | spacing | `SizedBox(height: 8)` | `CISpacing.s2` | |

---

### `lib/features/player_insight/widgets/averages_tab.dart` (M)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 6 | color | `Colors.white` | `CIColors.surface` | |
| 7 | color | `Color(0xFFE0E1E5)` | `CIColors.hairline` | |
| 9 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 10 | color | `Color(0xFF6A6A6A)` | `CIColors.ink3` | |
| 11 | color | `Color(0xFF8E8E8E)` | `CIColors.ink3` | |
| 12 | color | `Color(0xFF2BC18C)` | `CIColors.jade500` | "good"/positive — see B3 |
| 13 | color | `Color(0xFFE6F7EF)` | `CIColors.jade50` | positive bg |
| 14 | color | `Color(0xFFD9005C)` | `CIColors.rose500` | "grow" |
| 15 | color | `Color(0xFFFBE5EE)` | `CIColors.rose50` | grow bg |
| 156,211 | radius | `BorderRadius.circular(16)` | `CIRadius.brXl` | metric tile |
| 232 | type | `TextStyle(fontFamily: 'Inter', ...)` | `CIType.caption` | **BLOCKER B1 — 'Inter' font** |
| 253,298 | radius | `BorderRadius.circular(10)` | `CIRadius.brLg`(8) | |
| 292 | color | `Color(0xFFD9D9D9)` | `CIColors.hairline` | flat delta border |
| 325 | type | `TextStyle(fontFamily: 'Inter', ...)` | `CIType.eyebrow` | **BLOCKER B1** |
| 333 | radius | `BorderRadius.circular(999)` | `CIRadius.full` | tier dot pill |

---

### `lib/features/player_insight/widgets/development_story_card.dart` (L — highest density)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 6 | color | `Color(0xFF7936FF)` | `CIColors.royal500` | "watch for next" — see B4 |
| 7 | color | `Color(0xFFF2A43A)` | `CIColors.spark500` | ✓ exact match |
| 8 | color | `Color(0xFFD9005C)` | `CIColors.rose500` | "room to grow" |
| 9 | color | `Color(0xFF2BC18C)` | `CIColors.jade500` | see B3 |
| 10 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 11 | color | `Color(0xFF8A8A8A)` | `CIColors.ink3` | |
| 12 | color | `Color(0xFFE0E1E5)` | `CIColors.hairline` | |
| 13 | color | `Color(0xFFF5F5F5)` | `CIColors.surfaceAlt` | track bg |
| 14 | color | `Color(0xFFE8E8E8)` | `CIColors.canvasSunk` | skeleton |
| 63 | color | `Colors.white` | `CIColors.surface` | card bg |
| 64 | radius | `BorderRadius.circular(16)` | `CIRadius.brXl` | card outer |
| 67 | shadow | `BoxShadow(...)` | `CIElevation.card` | card elevation |
| 193 | radius | `BorderRadius.circular(2)` | `CIRadius.brXs` | dot/handle |
| 241,247,304,441 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | inner chip |
| 382 | color | `isFilled ? _amber : Color(0xFFD0CDD0)` | `isFilled ? CIColors.spark500 : CIColors.canvasSunk` | progress dot |
| 403 | radius | `BorderRadius.circular(4)` | `CIRadius.brSm` | tag |
| 484 | radius | `BorderRadius.circular(10)` | `CIRadius.brLg` | CTA button |
| Typography (15 instances) | type | various `TextStyle(...)` | `CIType.*` | map per heading/body/caption rules |

---

### `lib/features/player_insight/widgets/development_tab.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 115 | spacing | `EdgeInsets.fromLTRB(16,12,16,24)` | `CISpacing.s4` / `CISpacing.s3` / `CISpacing.s6` | |
| 182 | spacing | `SizedBox(height: 14)` | — | 14 → ask; nearest `s3`(12) |
| 185 | radius | `BorderRadius.circular(4)` | `CIRadius.brSm` | tag |
| 187 | spacing | `EdgeInsets.symmetric(h:4, v:2)` | `CISpacing.s1` | tag padding |
| 196 | color | `Color(0xFF3A3F4B)` | `CIColors.ink2` | label |
| 205 | color | `Color(0xFF3A3F4B)` | `CIColors.ink2` | |

---

### `lib/features/player_insight/widgets/games_tab.dart` (M)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 10 | color | `Colors.white` | `CIColors.surface` | |
| 11 | color | `Color(0xFFE0E1E5)` | `CIColors.hairline` | |
| 13 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 14 | color | `Color(0xFF6A6A6A)` | `CIColors.ink3` | |
| 15 | color | `Color(0xFF8E8E8E)` | `CIColors.ink3` | |
| 84 | type | `TextStyle(color: _sub, fontFamily: 'Inter')` | `CIType.small` | **BLOCKER B1** |
| 148 | color | `Color(0xFF3A3F4B)` | `CIColors.ink2` | |
| 192,195,198 | radius | `BorderRadius.circular(16)` | `CIRadius.brXl` | game row card |
| 264 | radius | `BorderRadius.circular(10)` | `CIRadius.brLg` | |
| 340 | radius | `BorderRadius.circular(12)` | `CIRadius.brXl` | |
| 373 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | tag |
| 381 | color | `Color(0xFF52535D)` | `CIColors.ink2` | |

---

### `lib/features/player_insight/widgets/profile_photo_sheet.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 25 | color | `Color(0xFFF3F1EE)` | `CIColors.surfaceAlt` | bubble bg (warm) — closest is surfaceAlt |
| 26 | color | `Color(0xFF6A6A6A)` | `CIColors.ink3` | icon |
| 27 | color | `Color(0xFFFFEEF2)` | `CIColors.rose50` | destructive bubble bg |
| 28 | color | `Color(0xFFE52B6C)` | `CIColors.rose500` | destructive action |
| 29 | color | `Color(0xFF0F0F0F)` | `CIColors.ink` | |
| 30 | color | `Color(0xFF8A8A8A)` | `CIColors.ink3` | |
| 31 | color | `Color(0xFFE6E6E6)` | `CIColors.hairline` | |
| 109 | color | `Colors.white` | `CIColors.surface` | |
| 124 | radius | `BorderRadius.circular(2)` | `CIRadius.brXs` | handle |
| 215 | radius | `BorderRadius.circular(10)` | `CIRadius.brLg` | action button |

---

### `lib/features/player_insight/widgets/spark_icon.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 25 | color | `Color(0xFF9C1BFA), Color(0xFFF2A43A)` | `CIColors.royal500`, `CIColors.spark500` | gradient |

---

### `lib/features/player_insight/widgets/trend_pill.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 11 | color | `Color(0xFF2BC18C)` | `CIColors.jade500` | improving |
| 12 | color | `Color(0xFFD9005C)` | `CIColors.rose500` | declining |
| 13 | color | `Color(0xFF8A8A8A)` | `CIColors.ink3` | neutral |
| 16 | spacing | `EdgeInsets.symmetric(h:10, v:5)` | — | 10 → ask |
| 19 | radius | `BorderRadius.circular(6)` | `CIRadius.brMd` | pill |
| 23 | type | `TextStyle(fontSize/weight)` | `CIType.caption` | |

---

### `lib/features/players/add_player_sheet.dart` (M)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 6 | color | `Color(0xFFFFFFFF)` | `CIColors.surface` | sheet bg |
| 7 | color | `Color(0xFFF0F0F0)` | `CIColors.surfaceAlt` | field bg |
| 8 | color | `Color(0xFF1A1A1A)` | `CIColors.ink` | label |
| 9 | color | `Color(0xFFAAAAAA)` | `CIColors.ink4` | hint |
| 10 | color | `Color(0xFFE8E8E8)` | `CIColors.canvasSunk` | disabled button |
| 11 | color | `Color(0xFF1A1A1A)` | `CIColors.ink` | enabled button |
| 12 | color | `Color(0xFFC7C7C7)` | `CIColors.ink4` | handle |
| 129 | radius | `BorderRadius.circular(3)` | `CIRadius.brXs` | handle ends |
| 282 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | btn |
| 338 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | field |

---

### `lib/features/players/edit_player_sheet.dart` (M)
*(Same pattern as add_player_sheet — identical const color block, same radius values)*

| Lines | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 6–12 | color | same as add_player_sheet | same tokens | |
| 187 | radius | `BorderRadius.circular(3)` | `CIRadius.brXs` | |
| 324 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | |
| 381 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | |

---

### `lib/features/players/set_birth_date_sheet.dart` (M)
*(Same color block pattern as add/edit sheets)*

| Lines | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 4–10 | color | same as add_player_sheet | same tokens | |
| 110 | radius | `BorderRadius.circular(3)` | `CIRadius.brXs` | |
| 261 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | |
| 298 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | |

---

### `lib/features/players/birth_date_profile_banner.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 4 | color | `Color(0xFFE0F7F4)` | `CIColors.jade50` | banner bg |
| 5 | color | `Color(0xFF108A7C)` | `CIColors.jade700` | banner text |
| 34 | radius | `BorderRadius.circular(10)` | `CIRadius.brLg` | |
| 36 | spacing | `EdgeInsets.fromLTRB(16,14,14,14)` | `CISpacing.s4` | |
| 42 | type | `TextStyle(...)` | `CIType.small` | |

---

### `lib/features/players/birth_date_prompt_modal.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 5 | color | `Color(0xFFFFFFFF)` | `CIColors.surface` | |
| 6 | color | `Color(0xFF1A1A1A)` | `CIColors.ink` | |
| 7 | color | `Color(0xFF787878)` | `CIColors.ink3` | |
| 8 | color | `Color(0xFF1A1A1A)` | `CIColors.ink` | button bg |
| 9 | color | `Color(0xFFFFFFFF)` | `CIColors.inkOnBrand` | button text |
| 10 | color | `Color(0xFF787878)` | `CIColors.ink3` | link |
| 65 | spacing | `EdgeInsets.symmetric(horizontal: 32)` | `CISpacing.s8` | |
| 69 | radius | `BorderRadius.circular(16)` | `CIRadius.brXl` | modal |
| 71 | shadow | `BoxShadow(...)` | `CIElevation.modal` | modal shadow |
| 113 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | btn |

---

### `lib/features/players/picker_sheet.dart` (S)

| Line | Category | Current Value | Proposed Token | Notes |
|---|---|---|---|---|
| 11 | color | `Color(0xFFF0F0F0)` | `CIColors.surfaceAlt` | field bg |
| 12 | color | `Color(0xFF1A1A1A)` | `CIColors.ink` | |
| 13 | color | `Color(0xFFAAAAAA)` | `CIColors.ink4` | |
| 14 | color | `Color(0xFF7936FF)` | `CIColors.royal500` | selected accent |
| 15 | color | `Color(0xFFE6E6E6)` | `CIColors.hairline` | |
| 16 | color | `Color(0xFFC7C7C7)` | `CIColors.ink4` | handle |
| 69,73 | radius | `BorderRadius.circular(8)` | `CIRadius.brLg` | sheet inner |
| 141 | radius | `BorderRadius.circular(2)` | `CIRadius.brXs` | handle |

---

## 0.2 Surface Inventory

### Custom Code Bucket (editable)

| Surface | File | Bucket | Token Density | Complexity |
|---|---|---|---|---|
| Dashboard page | `lib/features/dashboard/dashboard_page.dart` | custom | 24 colors, 16 spacing, 9 radius, 13 type | **L** |
| Game feed card | `lib/features/dashboard/widgets/game_feed_card.dart` | custom | 7 colors, 5 spacing, 3 radius, 6 type | **M** |
| Snapshot card | `lib/features/dashboard/widgets/snapshot_card.dart` | custom | 5 colors, 4 spacing, 2 radius, 4 type | **M** |
| Dashboard avatar | `lib/features/dashboard/widgets/dashboard_avatar.dart` | custom | 2 colors | **S** |
| Player profile page | `lib/features/player_insight/player_profile_page.dart` | custom | 8 colors, 4 spacing, 3 radius, 1 shadow, 4 type | **L** |
| Averages tab | `lib/features/player_insight/widgets/averages_tab.dart` | custom | 10 colors, 10 spacing, 5 radius, 12 type, **2× 'Inter' font** | **M** |
| Development story card | `lib/features/player_insight/widgets/development_story_card.dart` | custom | 10 colors, 11 spacing, 8 radius, 1 shadow, 15 type | **L** |
| Development tab | `lib/features/player_insight/widgets/development_tab.dart` | custom | 2 colors, 3 spacing, 2 radius | **S** |
| Games tab | `lib/features/player_insight/widgets/games_tab.dart` | custom | 6 colors, 11 spacing, 6 radius, 10 type, **1× 'Inter' font** | **M** |
| About story sheet | `lib/features/player_insight/widgets/about_story_sheet.dart` | custom | 3 colors, 2 spacing, 1 radius, 3 type | **S** |
| Profile photo sheet | `lib/features/player_insight/widgets/profile_photo_sheet.dart` | custom | 7 colors, 2 spacing, 2 radius | **S** |
| Spark icon | `lib/features/player_insight/widgets/spark_icon.dart` | custom | 2 colors (gradient) | **S** |
| Trend pill | `lib/features/player_insight/widgets/trend_pill.dart` | custom | 3 colors, 1 spacing, 1 radius, 1 type | **S** |
| Add player sheet | `lib/features/players/add_player_sheet.dart` | custom | 7 colors, 2 spacing, 3 radius, 7 type | **M** |
| Edit player sheet | `lib/features/players/edit_player_sheet.dart` | custom | 7 colors, 2 spacing, 3 radius, 7 type | **M** |
| Set birth date sheet | `lib/features/players/set_birth_date_sheet.dart` | custom | 7 colors, 7 spacing, 3 radius, 9 type | **M** |
| Birth date banner | `lib/features/players/birth_date_profile_banner.dart` | custom | 2 colors, 1 spacing, 1 radius, 1 type | **S** |
| Birth date modal | `lib/features/players/birth_date_prompt_modal.dart` | custom | 6 colors, 2 spacing, 1 radius, 1 shadow, 4 type | **S** |
| Picker sheet | `lib/features/players/picker_sheet.dart` | custom | 6 colors, 4 spacing, 3 radius, 3 type | **S** |
| Highlight metric tag | `lib/custom_code/widgets/highlight_metric_tag_widget.dart` | custom | 3 colors, 2 spacing, 1 radius, 1 type | **S** |
| Skeleton box | `lib/courtside_iq/skeleton_widget.dart` | custom | 1 color, 1 radius (param default) | **S** |
| **Dev debug page** | `lib/features/dev/player_insight_debug_page.dart` | custom | dev only | **skip** |

**Total custom surfaces: 21** (+ 1 skipped dev page)
- L: 3, M: 8, S: 10

### Generated (FF-MANUAL bucket) — catalog only, no code edits

| Area | Files | Notes |
|---|---|---|
| Authentication | 10 files (user_auth, user_auth_email, forgot_password, reset_password, reset_successful) | [FF-MANUAL] |
| Games | 20 files (all_games, new_game, edit_live_game, game_stat_tracker, game_stats + components) | [FF-MANUAL] |
| Global components | 18 files (dialogs, sheets, nav bar, snack bar, headers, empty states) | [FF-MANUAL] |
| Home | 2 files (home_model, home_widget) | [FF-MANUAL] |
| Menu | 12 files (menu, appearance, profile, account edit, support, accordion) | [FF-MANUAL] |
| Players | 12 files (list, profile, edit, components) | [FF-MANUAL] |

**Total generated surfaces: 74 files across 6 areas.** These will be handled in the FF visual editor batch after all code phases complete.

---

## 0.3 FF Theme Audit

**File:** `dependencies/ff_theme/lib/flutter_flow/flutter_flow_theme.dart`

### Current vs. v1.5 Target — Colors

| FF Color Name | Current Value | v1.5 Target | Token | Change |
|---|---|---|---|---|
| `primary` | `#9DFF00` (neon green) | `#1B1D24` | `ink` | **Major** — neon → near-black |
| `secondary` | `#FB3640` (red) | `#0FA889` | `jade500` | **Major** |
| `tertiary` | `#E5A500` (amber) | `#6B35C9` | `royal500` | **Major** |
| `alternate` | `#E0E000` (yellow) | `#F2A43A` | `spark500` | Major |
| `primaryText` | `#0F0F0F` | `#1B1D24` | `ink` | Minor (warm → cool) |
| `secondaryText` | `#292928` | `#4A4D56` | `ink2` | Minor |
| `primaryBackground` | `#FFFFFF` | `#EFEFF1` | `canvas` | Minor |
| `secondaryBackground` | `#E2E0DF` | `#FFFFFF` | `surface` | Notable |
| `accent1` | `#9DFF00` | `#E04867` | `rose500` | Major |
| `accent2` | `#FB3640` | `#2558B8` | `steel500` | Major |
| `accent3` | `#287E87` | `#E5E5E8` | `canvasSunk` | Major |
| `accent4` | `#B2FFFFFF` (72% white) | `#E2E2E5` | `hairline` | Major |
| `globalBackground` | `#F2F3F5` ✓ (already updated) | `#EFEFF1` | `canvas` | Minor drift (close) |
| `teal` | `#2BC18C` | `#0FA889` | `jade500` | Minor (shade shift) |
| `vividViolet` | `#9C1BFA` | `#6B35C9` | `royal500` | Notable |

**Custom colors NOT in the v1.5 system** (flag for followups.md):
- `neon`, `techBlue`, `crispCyan`, `imperial` — old palette colors with no v1.5 mapping; still referenced by FF-generated pages. Do NOT remove — flag as [FF-MANUAL] cleanup.
- `gray1/2/3/4`, `grayButton`, `primaryButtonText`, `pbg30/0`, `bottomSheetBg`, `disableText`, `blackAlway`, `shadow`, `zeroStatBG`, `violet4550`, `violet1520` — legacy semantic names. Map what you can; flag the rest.

### Current vs. v1.5 Target — Typography

| FF Type Style | Current Font | Current Weight/Size | v1.5 Target | Notes |
|---|---|---|---|---|
| `displayLarge` | Montserrat | 700 / 50px | DM Sans 400 / 56px | Weight inversion + font change |
| `displayMedium` | Montserrat | 700 / 42px | DM Sans 400 / 40px | Weight inversion |
| `displaySmall` | Montserrat | 600 / 34px | DM Sans 400 / 28px | Weight inversion |
| `headlineLarge` | Montserrat | 600 / 30px | DM Sans 700 / 22px | → `h1` |
| `headlineMedium` | Montserrat | 400 / 26px | DM Sans 700 / 17px | → `h2` |
| `headlineSmall` | Montserrat | 400 / 22px | DM Sans 600 / 14px | → `h3` |
| `titleLarge` | IBM Plex Sans | 600 / 22px | DM Sans 700 / 14px | → `h3`/`bodyStrong` |
| `titleMedium` | IBM Plex Sans | 600 / 18px | DM Sans 500 / 14px | → `bodyStrong` |
| `titleSmall` | IBM Plex Sans | 600 / 16px | DM Sans 500 / 14px | → `bodyStrong` |
| `bodyLarge` | IBM Plex Sans | 400 / 16px | DM Sans 400 / 14px | → `body` |
| `bodyMedium` | IBM Plex Sans | 400 / 14px | DM Sans 400 / 14px | → `body` |
| `bodySmall` | Montserrat | 400 / 14px | DM Sans 400 / 13px | → `small` |

**Critical finding:** FF theme fonts are Montserrat + IBM Plex Sans. These are used in ALL generated pages. Phase 1 must switch every font to DM Sans and remap weights to match v1.5 type scale. This is the highest-impact typography change.

### FF Theme built-in tokens (FFDesignTokens)

The file contains `FFSpacing` and `FFRadius` classes with different scales than v1.5:

| FF token | FF value | CISpacing/CIRadius equivalent |
|---|---|---|
| `FFSpacing.xs` | 4 | `CISpacing.s1` ✓ |
| `FFSpacing.sm` | 8 | `CISpacing.s2` ✓ |
| `FFSpacing.md` | 16 | `CISpacing.s4` ✓ |
| `FFSpacing.lg` | 24 | `CISpacing.s6` ✓ |
| `FFSpacing.xl` | 32 | `CISpacing.s8` ✓ |
| `FFRadius.sm` | 8 | `CIRadius.lg` (8) ✓ |
| `FFRadius.md` | 16 | `CIRadius.xl` (12) — close but not matching |
| `FFRadius.lg` | 24 | no equivalent — too large |
| `FFRadius.full` | 9999 | `CIRadius.full` ✓ |

**Note:** `FFRadius.md = 16` and `FFRadius.lg = 24` are larger than any v1.5 radius token. Generated pages using `FFRadius.md` for cards will still be at 16px after Phase 1 — this is the main radius issue in the generated bucket. Flag for FF visual editor batch.

---

## Ambiguities / Ask-Before-Migrating Items

These values don't have clear 1:1 token mappings and need a decision before Phase 2–4 proceeds:

| Value | Location(s) | Question |
|---|---|---|
| `10px` horizontal spacing | dashboard, game_feed_card, trend_pill, etc. | Round to `s2`(8) or `s3`(12)? |
| `28px` height spacer | dashboard_page | Round to `s6`(24) or `s8`(32)? |
| `14px` EdgeInsets vertical | various | Round to `s3`(12) or `s4`(16)? |
| `5px` padding | game_feed_card, trend_pill | Round to `s1`(4)? |
| `6px` horizontal padding | dashboard | Round to `s1`(4) or `s2`(8)? |
| `3px` height spacer | game_feed_card:254 | Leave as-is or add to followups.md? |
| `BorderRadius.circular(10)` | averages_tab, player_profile, games_tab, development_story_card | → `brLg`(8) or `brXl`(12)? |
| `BorderRadius.circular(14)` | dashboard upgrade card | → `brXl`(12)? |

---

## Followup Items (not in scope for this overhaul)

These were spotted but require more than a token swap:

- `averages_tab.dart:232` — hardcoded `fontFamily: 'Inter'` in a TextStyle inline (not a token issue, but a font cleanup)
- `games_tab.dart:84` — same `fontFamily: 'Inter'`
- `averages_tab.dart:325` — same `fontFamily: 'Inter'`
- `snapshot_card.dart:43` — purple→amber gradient; gradient itself may want a `CICardDecorations` helper
- `skeleton_widget.dart` — radius is a constructor param with hardcoded default; consider making it a required param
- `game_feed_card.dart:254` — `SizedBox(height: 3)` micro-gap; no token for 3px

---

## Phase Execution Recommendation

Given the inventory above, suggested phase 2 attack order:

1. **Shared small widgets** (S complexity, high reuse): `trend_pill`, `spark_icon`, `highlight_metric_tag`, `skeleton_box`, `dashboard_avatar` — ~15 total changes, good warmup
2. **Sheet cluster** (M — three near-identical): `add_player_sheet`, `edit_player_sheet`, `set_birth_date_sheet` — nearly identical color blocks, batch efficiently
3. **Remaining S widgets**: `about_story_sheet`, `profile_photo_sheet`, `birth_date_banner`, `birth_date_modal`, `picker_sheet`, `development_tab`
4. **Dashboard cluster**: `dashboard_page` (L), `game_feed_card` (M), `snapshot_card` (M)
5. **Player profile cluster**: `player_profile_page` (L), `development_story_card` (L), `averages_tab` (M), `games_tab` (M)
6. **Courtside IQ shared**: `skeleton_widget` (S)
