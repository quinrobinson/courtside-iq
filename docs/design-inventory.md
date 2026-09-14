# Design Inventory

Read-only audit. No code, migrations, or Figma nodes were created or modified.

- **Compiled:** 2026-09-13
- **Branch:** `phase-4-sdk-upgrade` (clean), HEAD `4cfec7c`
- **Figma file audited:** `uvHb6HXvIVFwzSSXPtEVoc` - document titled **Courtside IQ 2.0**
- **Figma file cross-referenced:** `E8n8IE9ZnPRs6vykzINIyg` - **CourtsideIQ - Performance Analytics** (v1 legacy)

**Note on the file name in the brief.** The brief labels the file "CourtsideIQ - Performance
Analytics" but gives the URL for `uvHb6HXvIVFwzSSXPtEVoc`. Those are two different files.
"CourtsideIQ - Performance Analytics" is `E8n8IE9ZnPRs6vykzINIyg`, the v1 legacy file. The URL
you supplied is Courtside IQ 2.0. I inventoried the URL, which matches `CLAUDE.md`'s rule that
all 2.0 work lives in `uvHb6`. I also read `E8n8`'s variable collection, because it turned out to
answer the palette question (section 2).

**Note on `lib/pages/`.** The brief asks me to map frames to `lib/pages/` and `lib/features/`.
`lib/pages/` no longer exists. It was deleted in roadmap 4.24 on 2026-07-26; every v1
FlutterFlow screen went with it. All screen code now lives in `lib/features/`, with shared
design-system pieces in `lib/courtside_iq/design/`. Every citation below points at a real file
on this branch.

**How "code exists" was determined.** Most 2.0 files carry a header comment naming the Figma node
they were measured from (for example `live_tracker_page.dart:3` says "Measured from 138:611").
I extracted every `nnn:nnn` node reference from `lib/features/` and `lib/courtside_iq/design/`
and joined it against the frame list. Where a frame had no citation I checked call sites by hand.
Where I could not resolve it either way, the row says so.

---

## 1. Frame inventory

### Pages in `uvHb6HXvIVFwzSSXPtEVoc`

Seven pages. (`get_metadata` with no nodeId under-reports this; the list below is from
`figma.root.children`, per the `CLAUDE.md` rule.)

| Page | id | Top-level children | Role |
|---|---|---|---|
| Branding | `923:3219` | 2 | Logo lockup, logo mark, DotBurst |
| Foundations | `22:2` | 1 | Token specimen board: primitives, semantic light/dark, type, spacing, radius, ambient glow |
| Screens | `65:6` | 9 sections + loose nodes | All 2.0 screen designs |
| Icons | `49:6` | 2 | Icon grid board + one `Icon/chevron-down` component |
| Components | `25:2` | 2 | Components Board + the `Field` component set |
| Site Map | `3:2` | 1 | One frame: header, legend, Row A, Row B, open product questions |
| Store Screens | `940:40` | 12 frames + 2 labels | App Store 6.9in set, Play 1080x1920 set, Play feature graphic |

The Screens page holds **91 screen frames** across 9 sections, plus 1 decorative `flow-arrow`
frame, plus 2 loose frames parked outside any section, plus a large number of `entry-label` /
connector TEXT nodes that sit in the gutters as flow annotation.

### Non-screen pages

| Page / frame | Represents | Status | Code |
|---|---|---|---|
| Branding / `Logo` `923:3226` | Wordmark + logo mark lockup | **Shipped** | `lib/courtside_iq/design/components/ci_logo_mark.dart` (cites `923:3515`); `assets/images/logo-mark.svg` |
| Branding / `Frame 1` `926:3518` | DotBurst motif | **Shipped** | `lib/courtside_iq/design/components/dot_burst.dart` |
| Foundations / `Foundations` `22:3` | Token specimen board | **Shipped** | `lib/courtside_iq/design/tokens/ci_colors.dart`, `ci_type.dart`, `ci_metrics.dart`; reviewable via `lib/features/dev/token_gallery_page.dart` |
| Icons / `Icons Board` `49:7` | Icon set specimen | **Uncertain** - the app draws from Material `Icons.*` throughout (for example `live_tracker_page.dart:237` uses `Icons.pause`). I found no ported icon set. Whether the board is a spec the code ignores, or documentation of chosen Material glyphs, is not determinable from the file. |
| Icons / `Icon/chevron-down` `574:6` | The only icon published as a component | **Uncertain** - same reason |
| Site Map / `Courtside IQ 2.0 - Site Map` `3:3` | Planning artifact, not a screen | n/a | Tracker only |
| Store Screens / `S1-S6`, `P1-P6`, Feature Graphic | Store listing assets | **Shipped** | `store-assets/`, `docs/store-assets-2-0.md` |

### Screens page - Section 1 · Entry & Auth (`448:2025`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Splash | `191:789` | Launch screen | Shipped | `lib/features/onboarding/splash_view.dart` |
| Onboarding (Slide 1 · Promise) | `248:950` | Onboarding carousel | Shipped | `lib/features/onboarding/onboarding_page.dart` |
| Onboarding (Slide 2 · Insights) | `250:955` | Onboarding carousel | Shipped | `lib/features/onboarding/onboarding_page.dart` |
| Onboarding (Slide 3 · Growth) | `250:1287` | Onboarding carousel | Shipped | `lib/features/onboarding/onboarding_page.dart` |
| Auth Landing | `251:965` | Sign in / sign up choice | Shipped | `lib/features/auth/auth_landing_page.dart` |
| Email Auth (Sign In) | `253:972` | Email sign in | Shipped | `lib/features/auth/email_auth_page.dart` |
| Email Auth (Sign Up) | `254:975` | Email sign up | Shipped | `lib/features/auth/email_auth_page.dart` |
| Guided First-Run (Step 1 · Welcome) | `321:1451` | Post-signup guided setup | Shipped | `lib/features/onboarding/first_run_flow.dart` |
| Guided First-Run (Step 2 · First Player) | `323:1462` | Post-signup guided setup | Shipped | `lib/features/onboarding/first_run_flow.dart` |
| Signup - Check Your Email | `765:3144` | Email confirmation wait | Shipped | `lib/features/auth/check_email_page.dart` |
| Forgot Password | `608:2152` | Request reset link | Shipped | `lib/features/auth/forgot_password_page.dart` |
| Forgot Password - Link Sent | `765:3370` | Reset link sent | Shipped | `lib/features/auth/check_email_page.dart` (one screen, two purposes) |
| Reset Password | `608:2172` | Set new password | Shipped | `lib/features/auth/reset_password_page.dart` |
| Reset Successful | `608:2198` | Reset confirmation | Shipped | `lib/features/auth/reset_successful_page.dart` |

### Screens page - Section 2 · Home (`448:2331`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Today | `65:7` | Home feed | Shipped | `lib/features/home/today_page.dart`, `widgets/today_hero.dart` (`65:8`) |
| Today - Empty (No Players) | `204:763` | Zero-data home | Shipped | `lib/features/home/today_page.dart` |
| Premium - Upgrade Banner (Today) | `327:1450` | Free-tier promo banner | Shipped | `lib/features/home/widgets/today_promo_banner.dart` |
| Premium - Lapse / Downgrade (Today) | `333:1717` | Lapsed-subscriber banner | Shipped | `lib/features/home/widgets/today_promo_banner.dart` |
| Today - Loading (Skeleton) | `670:2559` | Home loading state | Shipped | `lib/features/home/widgets/today_skeleton.dart` |

### Screens page - Section 3 · Players (`448:2371`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Players - Empty (No Players) | `206:806` | Zero-data players list | Shipped | `lib/features/players/players_list_page.dart` |
| Players - List | `272:1557` | Players list | Shipped | `lib/features/players/players_list_page.dart`, `widgets/player_list_row.dart` |
| Player Profile | `93:211` | Profile, Development tab | Shipped | `lib/features/players/player_profile_page.dart`, `widgets/development_view.dart` |
| Player Profile - Averages | `97:340` | Profile, Averages tab | Shipped | `lib/features/players/widgets/averages_view.dart` |
| Player Profile - Games | `98:583` | Profile, Games tab | Shipped | `lib/features/players/widgets/games_view.dart` |
| Player Profile - Development (Locked) | `156:704` | Free-tier locked development | Shipped | `lib/features/players/widgets/development_view.dart` |
| Player Profile - Locked | `663:2426` | Lapsed / free profile lock | Shipped | `player_profile_page.dart:319`, `widgets/averages_view.dart` |
| Player Profile - Age-Band Transition | `687:2742` | Rating freeze on age-band change | Shipped | `lib/features/players/widgets/age_band_notice.dart` (cites `687:2892`) |
| Players List - Premium Lapsed (Locked) | `660:2224` | Lapsed lock on the list | Shipped | `players_list_page.dart:141` (`EntitlementStatus.lapsed`) |
| Game Detail | `145:610` | Single-game detail | Shipped | `lib/features/games/game_detail_page.dart`, `game_insight_card.dart`, `design/components/ci_scoring_mix.dart` |
| Game Insights Info | `668:2555` | "About insights" explainer sheet | Shipped | `game_detail_page.dart:166` -> `showCiInfoSheet` (copy is inline there, not in `info_copy.dart`) |
| About Story Sheet | `648:2188` | Development-story explainer | Shipped | `design/components/ci_info_sheet.dart` (`648:2195`), `players/info_copy.dart` (`648:2215`) |
| About Growth IQ | `691:2838` | Growth IQ explainer | Shipped | `ci_info_sheet.dart` (`691:2845`), `info_copy.dart` (`691:2850`) |
| Full Breakdown | `435:1922` | Full stat breakdown | Shipped | `lib/features/players/full_breakdown_page.dart` |
| **Stats & Trends** | `307:1407` | Trends screen | **Specced only** | No code. `player_profile_page.dart:506` states outright: "'View trends' is still absent: its destination is Stats & Trends, which is scoped out of 4.11." |
| **Premium - Locked (Trends Teaser)** | `331:1661` | Locked trends teaser | **Specced only** | No code. Blocked on Stats & Trends existing. |
| Edit Player | `387:1901` | Edit player screen | Shipped | `lib/features/players/edit_player_page.dart` |
| Edit Position | `641:2176` | Position picker sheet | Shipped | `design/components/ci_sheet.dart` (`641:2183`, `641:2214`); driven from `edit_player_page.dart` |
| Add Player Sheet | `302:1395` | Add player | Shipped | `lib/features/players/add_player_sheet_v2.dart` (cites `302:1402`) |
| Add Player Gate (Free) | `652:2192` | Free-tier upgrade gate sheet | Shipped | `lib/features/players/widgets/player_gates.dart` |
| 3-Player Cap State | `651:2199` | Paid-tier cap dialog | Shipped | `lib/features/players/widgets/player_gates.dart` |
| Set Birth Date | `643:2181` | Birth month/year picker | Shipped | `lib/features/players/birth_date_sheet.dart` (cites `643:2188`), `design/components/ci_wheel_picker.dart` |
| Birth Date Prompt | `647:2188` | Proactive birth-date ask | Shipped | `lib/features/players/birth_date_nudges.dart` -> `birth_date_gate.dart`, wired in `today_page.dart:36` and `player_profile_page.dart:41`. **Uncertain on node id:** the code cites `649:2201`, not `647:2188`. The dialog is clearly built; which of the two frames it was measured from is not recoverable from the file. |
| **Birth-date-missing caveat** | `649:2199` | Uncalibrated-rating caveat banner | **Specced only, deliberately dropped** | `birth_date_nudges.dart:5-12` says the banner "IS DELIBERATELY NOT HERE" because "no birth date, no rating" removed the thing it caveated. The frame is now an orphan. |
| Profile Photo Sheet | `646:2185` | Photo picker sheet | Shipped | `lib/features/players/profile_photo_sheet.dart` (cites `646:2192`) |
| Edit Player - Teams & Events | `799:3234` | Teams/events rows on Edit Player | Shipped | `lib/features/players/teams_events_sheets.dart`, `edit_player_page.dart` |
| Teams Sheet | `800:32` | Team list sheet | Shipped | `lib/features/players/teams_events_sheets.dart` |
| Events Sheet | `800:45` | Event list sheet | Shipped | `lib/features/players/teams_events_sheets.dart` |
| Add Team Sheet | `800:64` | Add team | Shipped | `lib/features/players/teams_events_sheets.dart` |
| Add Event Sheet | `800:3298` | Add event | Shipped | `lib/features/players/teams_events_sheets.dart` |

The four Teams/Events sheets carry no node citation in code; `teams_events_sheets.dart:3` says
"Designed 2026-07-21 and approved. Four surfaces" and describes exactly these four. Mapping is
confident by description, not by id.

### Screens page - Section 4 · Games (`448:2390`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Games - Empty (No Games) | `206:984` | Zero-data games list | Shipped | `lib/features/games/games_list_page.dart` (cites `206:1025`) |
| Games - List | `263:1016` | Games list | Shipped | `lib/features/games/games_list_page.dart` |
| Games - Live In Progress | `683:2597` | List with a live game | Shipped | `games_list_page.dart`, `home/widgets/game_feed_row.dart` (both cite `683:2752`) |
| Games - No Games (Player Filter) | `683:2755` | Filtered-to-empty state | Shipped | `games_list_page.dart` (cites `683:2910`) |
| flow-arrow | `451:1952` | Flow annotation, not a screen | n/a | Decorative |

**Organization note:** Game Detail sits in Section 3 · Players, not Section 4 · Games, even
though the Games list is one of its two entry points. The gutter label `486:1968`
("← from Games tab (tap a game)") documents the profile-tab entry. There is no connector from
Games - List to Game Detail.

### Screens page - Section 5 · New Game (`448:2391`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Create - New Sheet | `281:1303` | Create action sheet | Shipped | `lib/features/nav/create_sheet.dart`; shell `design/components/ci_sheet.dart` (`281:1313`) |
| New Game - Setup | `286:1328` | Pre-game setup | Shipped | `lib/features/games/new_game_setup_page.dart` |
| Team Selection | `454:1932` | Team picker | Shipped | `lib/features/games/game_setup_pickers.dart` |
| Event Selection | `456:2010` | Event picker | Shipped | `lib/features/games/game_setup_pickers.dart` |
| New Event | `458:1932` | Create event inline | Shipped | `lib/features/games/game_setup_pickers.dart` (no id citation; the file describes inline add for both pickers) |
| Live Stat Tracker | `138:611` | In-game tracker | Shipped | `lib/features/games/live_tracker_page.dart` (also cites `138:621`, `138:631`, `724:3149`) |
| Game Paused | `459:1934` | Pause safety lock | Shipped | `lib/features/games/game_paused_dialog.dart` |
| Offline Scoring + Deferred Sync | `654:2199` | Offline banner on tracker | Shipped | `live_tracker_page.dart` `OfflineBanner`; `design/components/ci_offline_banner.dart` (`654:2378`) |
| Game Complete & Save | `291:1334` | Post-game save | Shipped | `lib/features/games/game_complete_page.dart` (also `291:1358`, `443:1971`) |

**Known divergence, documented in code.** `game_setup_pickers.dart:13-16`: the Team Selection and
Event Selection frames use an older "X" close treatment; the code renders them with the `CiSheet`
shell instead. The comment ends "THE FRAMES SHOULD BE UPDATED, not the code." That update has not
happened.

### Screens page - Section 6 · Menu & Account (`448:2392`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Menu | `294:1331` | Menu screen | Shipped | `lib/features/menu/menu_page.dart`; `design/components/ci_settings_row.dart` |
| Your Profile | `295:1385` | Account profile | Shipped | `lib/features/menu/your_profile_page.dart`; `ci_sub_page_header.dart` |
| Edit Name | `496:1952` | Edit display name | Shipped | `lib/features/menu/edit_name_page.dart` |
| Edit Email | `496:1986` | Edit email | Shipped | `lib/features/menu/edit_email_page.dart` |
| Change Password | `496:2020` | Change password | Shipped | `lib/features/menu/change_password_page.dart` |
| Delete Account | `505:1961` | Account deletion | Shipped | `lib/features/menu/delete_account_page.dart` |
| Help Center | `507:1964` | FAQ / help | Shipped | `lib/features/menu/help_center_page.dart`; `courtside_iq/help_content.dart` |
| Send Feedback | `508:1972` | Feedback form | Shipped | `lib/features/menu/send_feedback_page.dart`, `feedback_repository.dart` |
| Success Confirmation | `667:2553` | Feedback-sent sheet | Shipped | `lib/features/menu/feedback_sent_sheet.dart` |

### Screens page - Section 7 · Premium / Paywall (`448:2393`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Premium - Gate Sheet | `335:1881` | Generic premium gate | Shipped | `lib/features/premium/premium_gate_sheet.dart`, `players/add_player_flow.dart` |
| Paywall - Premium (Slide 1 · Story) | `234:910` | Paywall carousel | Shipped | `lib/features/premium/paywall_content.dart`, `paywall_page.dart` |
| Paywall - Premium (Slide 2 · Trends) | `237:1354` | Paywall carousel | Shipped | `paywall_content.dart`, `paywall_page.dart` |
| Paywall - Premium (Slide 3 · Insights) | `237:889` | Paywall carousel | Shipped | `paywall_content.dart`, `paywall_page.dart` |
| Paywall - State · Loading | `242:910` | Paywall state | Shipped | `lib/features/premium/paywall_states.dart` |
| Paywall - State · Processing | `243:920` | Paywall state | Shipped | `paywall_states.dart` |
| Paywall - State · Error | `243:1386` | Paywall state | Shipped | `paywall_states.dart` |
| Paywall - State · Already Premium | `244:943` | Paywall state | Shipped | `paywall_states.dart` |

`paywall_states.dart` additionally cites `726:3127`, `726:3290`, `726:3424`, which are not
top-level frames on the Screens page. They are most likely nested nodes inside the paywall
frames; I did not resolve them.

### Screens page - Section 8 · Dialogs & States (`448:2394`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| Dialog - Confirm · Destructive | `370:1886` | Destructive confirm | Shipped | `design/components/ci_confirm_dialog.dart` |
| Dialog - Confirm · Neutral | `371:1901` | Neutral confirm | Shipped | `ci_confirm_dialog.dart`, `menu/menu_page.dart` |
| **Dialog - Alert · Single Action** | `371:1910` | One-button alert | **Specced only** | No citation anywhere; `showCiConfirmDialog` is two-button only (title, body, confirm, `cancelLabel`). I found no single-action variant. |
| Dialog - Resume Game | `379:1901` | Resume an interrupted game | Shipped | `lib/features/games/resume_game_dialog.dart` |
| Insight - Loading | `424:1904` | AI insight loading | Shipped | `lib/features/games/game_insight_card.dart` |
| Insight - Error | `425:1909` | AI insight error | Shipped | `game_insight_card.dart` |
| **Dialog - Rate App** | `462:1949` | App-store rating prompt | **Specced only** | `in_app_review: ^2.0.11` remains in `pubspec.yaml:83`, but `showInAppReview` had **zero call sites** and `lib/custom_code/actions/show_in_app_review.dart` was deleted 2026-09-13 (see "Dead v1.5 island" below). Nothing builds this dialog. |

### Screens page - Section 9 · States & Validation (`514:1975`)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| **Players - Loading (Skeleton)** | `515:1975` | Players list loading | **Specced only** | `players_list_page.dart:170` renders `const Center(child: CircularProgressIndicator())`. The skeleton is not built. |
| **Games - Loading (Skeleton)** | `682:2785` | Games list loading | **Specced only** | `games_list_page.dart:404` renders `const Center(child: CircularProgressIndicator())`. Same. |
| Snackbar - Error / Success | `521:2009` | Toast | Shipped | `design/components/ci_toast.dart` |
| Email Auth - Validation Error | `524:2009` | Field validation state | Shipped | `lib/features/auth/email_auth_page.dart` |
| **Stats & Trends - Empty** | `526:2012` | Trends zero-data | **Specced only** | Blocked on Stats & Trends (`307:1407`). |

Today's skeleton (`670:2559`) **is** built (`today_skeleton.dart`). The two list skeletons are
the outliers, which makes them look like an unfinished pass rather than a decision.

### Screens page - loose frames (outside any section)

| Frame | id | Represents | Status | Code |
|---|---|---|---|---|
| What's New in 2.0 (sheet) | `892:3184` | Post-upgrade what's-new sheet | Shipped | `lib/features/onboarding/whats_new_sheet.dart`, `whats_new_gate.dart` |
| Icon options | `899:6` | Icon exploration board for the sheet above | n/a | Exploration artifact, not a screen |

Both sit below Section 9 at y ≈ 11850, outside any Section, with a TEXT label above reading
"What's new in 2.0 - upgrade sheet (DRAFT for review)". The sheet is shipped, so the DRAFT label
is stale and both frames are unsectioned, which violates the `CLAUDE.md` flow-section rule.

### Code with no corresponding design

| File | Represents | Status |
|---|---|---|
| `lib/features/dev/token_gallery_page.dart` | Design-token review screen; booted directly from `main.dart:91` when `kShowTokenGallery` is true | **Built, unverified** (internal tool, no design intended) |
| ~~`lib/features/dev/player_insight_debug_page.dart`~~ | Insight debug screen | **Deleted 2026-09-13.** Its only entry point was the orphaned `open_player_insight_debug.dart`, so it was already unreachable. |
| `lib/features/nav/ci_nav_shell.dart`, `create_flow.dart`, `first_run_gate.dart`, `whats_new_gate.dart` | Routing and gate logic | **Built, unverified** (no visual surface of their own) |
| `lib/features/nav/ci_nav_bar.dart` | Tab bar | Shipped (cites `68:264`; the `TabBar` component set is `47:124`) |

### Dead v1.5 island - REMOVED 2026-09-13

**Resolved on branch `phase-4-remove-v1-5-island`.** The section below records what was found and
what was done, because the finding is the reason the palette question kept recurring.

**What was found.** A set of files on disk that compiled, used the **v1.5 Jade/Canvas palette**
(`CIColors.jade50`, `CIColors.jade700`, and so on) inside a 2.0 app, and were unreachable: every
route in `lib/flutter_flow/nav/nav.dart` builds a `lib/features/` 2.0 page, and nothing outside
`lib/custom_code/` imported `lib/custom_code/widgets/`.

**Correction to an earlier draft of this document.** That draft said `lib/custom_code/actions/`
was dead in its entirety. It was not. Four of its eleven actions are live and called from 2.0
code, and they remain in the tree:

| Kept action | Called from |
|---|---|
| `sendRecoveryEmail` | `check_email_page.dart:98`, `forgot_password_page.dart:88` |
| `updatePassword` | `reset_password_page.dart:86` |
| `logoutOfRevenueCat` | `nav.dart:198`, `nav.dart:352` |
| `generateGameInsight` | `supabase_game_uploader.dart:84` |

**What was deleted** (20 files, 1 edit, 2,202 lines):

- `lib/custom_code/widgets/` in full: `birth_date_profile_banner_widget.dart`,
  `birth_date_prompt_gate.dart`, `highlight_metric_tag_widget.dart`, `index.dart`
- Seven dead actions: `lock_portrait_mode.dart` (`main.dart:42` calls `SystemChrome` directly),
  `login_to_revenue_cat.dart`, `show_in_app_review.dart`, `set_dark_mode_on.dart`,
  `set_dark_mode_off.dart`, `set_dark_mode_system.dart`, `open_player_insight_debug.dart`
- `lib/custom_code/actions/index.dart` rewritten to export only the four live actions
- Six orphaned feature files: `players/birth_date_profile_banner.dart`,
  `players/birth_date_prompt_modal.dart`, `players/set_birth_date_sheet.dart`,
  `players/edit_player_sheet.dart`, `players/picker_sheet.dart`,
  `player_insight/widgets/profile_photo_sheet.dart`
- `lib/features/dev/player_insight_debug_page.dart`, whose only entry point was
  `open_player_insight_debug.dart`
- `lib/courtside_iq/skeleton_widget.dart` and `lib/courtside_iq/design_tokens.dart`

**Verification.** `fvm flutter test` 699 passing before and after. `fvm flutter analyze` 379
issues / 0 errors before, 336 issues / 0 errors after. A grep for `0FA889`, `F2A43A`, `6B35C9`,
`E04867`, `F5F3EF`, `EFEFF1`, `F3F3F5`, `CIColors`, `CIType`, `CISpacing`, `CIRadius` across
`lib/` returns zero hits.

**What was deliberately left.**

- `in_app_review: ^2.0.11` in `pubspec.yaml`. Unused now, but Rate App (`462:1949`) is a designed
  frame that may still be built, and removing the dependency touches `pubspec.lock`, iOS
  SPM/CocoaPods, and Android during a live staged rollout for no user benefit.
- `lib/main.dart`. Its `_themeMode` / `setThemeMode` pair is dead now that the dark-mode actions
  are gone, and its `ff_theme` import is analyzer-flagged unused. It is the app entry point during
  a rollout watch; this belongs in its own change.
- `dependencies/ff_theme/`. This is where the April 2026 jade palette swap actually lives. No live
  widget references `FlutterFlowTheme` anywhere outside `lib/custom_code/` and `lib/flutter_flow/`,
  so the jade values there render nowhere and the package is already inert. Removing it is a
  larger, separate change.

So: every reachable path to the v1.5 palette is gone from `lib/`, and the token file itself is
deleted. The inert `ff_theme` package still holds the old values on disk.

Note `lib/features/players/profile_photo_sheet.dart` (2.0, live, cites `646:2192`) was the live
twin of the deleted `lib/features/player_insight/widgets/profile_photo_sheet.dart` (v1.5, dead).
Two files with the same basename; `edit_player_page.dart:35` and `test/profile_photo_sheet_test.dart`
both pointed at the live one, which is why the suite stayed green.

---

## 2. Palette resolution

### What is actually defined where

| Palette | Primary | Surface | Where it is defined | Last touched |
|---|---|---|---|---|
| (a) v1.5 Canvas | Jade `#0FA889` | see below | `docs/design-system-spec.md`, `docs/courtside-iq-design-system.html`, `lib/courtside_iq/design_tokens.dart`, `dependencies/ff_theme/.../flutter_flow_theme.dart` | 2026-05-07 (`f57d09a` / `492bd02`) |
| (b) lime `#CDF330` | `#CDF330` | ink `#0F0F0F` | **`E8n8IE9ZnPRs6vykzINIyg`** variable collection, variable named `Neon` | legacy v1 file |
| (c) shipped 2.0 | lime `#9DFF00` | white `#FFFFFF` / ink `#0F0F0F` | `uvHb6` **Primitives** + **Color** variable collections; `lib/courtside_iq/design/tokens/ci_colors.dart` | 2026-07-23 (`707a5db`) |

**`#CDF330` appears nowhere in this repository and nowhere in the 2.0 Figma file.** I grepped the
whole working tree and scanned every solid fill on every page of `uvHb6`. Zero hits. It is
variable `Neon` in the legacy `E8n8` file, alongside `Carmine #FF5514` (a near-miss for 2.0's
`#FF4F00`) and `Green #44D600`. So palette (b) is a v1 artifact, not a competing 2.0 brand.

**Palette (a) is not internally consistent.** The Canvas surface value has three different hexes
in circulation, all in files last touched the same day:

| Value | Source |
|---|---|
| `#F5F3EF` | `docs/palette-swap-handoff.md` (`globalBackground`, "warm canvas") |
| `#EFEFF1` | `docs/design-system-spec.md` and `docs/courtside-iq-design-system.html` |
| `#F3F3F5` | `lib/courtside_iq/design_tokens.dart:87` and `flutter_flow_theme.dart:182` (comment: "canvas (exact value)") |

The hex you quoted, `#F5F3EF`, is the handoff-doc value and is the one **not** present in any
Dart file.

**Palette (c) is the only one bound to Figma variables.** The `uvHb6` Primitives collection holds
exactly two accents: `accent/lime #9DFF00` (plus hover `#93EE00`, wash `#F1FFD2`) and
`accent/orange #FF4F00` (hover `#EC4900`, wash `#FFE7DC`). `lib/courtside_iq/design/tokens/ci_colors.dart`
mirrors all 22 primitives byte for byte. No jade, royal, steel, rose, or spark token exists in
either the 2.0 file or `ci_colors.dart`.

### Is the dark tracker an intentional in-game mode, or drift?

**Intentional, and designed that way.** The Figma frame `Live Stat Tracker` `138:611` has a
top-level fill of `#0F0F0F`. `live_tracker_page.dart:3` says "Measured from 138:611. INK
THROUGHOUT - the whole screen, not just a hero," and the page wraps itself in `CiSurface.ink`
(`live_tracker_page.dart:116`). The white Make button is a deliberate design judgement, recorded
at `live_tracker_page.dart:12-14`: "THE MAKE BUTTON IS WHITE AND TWICE THE WIDTH OF MISS... a
parent watching their kid is looking at the court, not the phone."

It is not a mode in the theming sense. `ci_colors.dart:70-78` is explicit: "2.0 is a SINGLE theme
with a hybrid black-and-white palette, not a light/dark mode pair the user toggles. `onLight` and
`onInk` are the two grounds a region can sit on - a white Today feed and a dark auth screen
coexist in the same app, at the same time." Dark screens in 2.0 include Auth Landing, Email Auth,
Guided First-Run, the Today hero, the Full Breakdown hero, the Add Player Gate sheet, and the
tracker.

### Is a dark mode defined anywhere in Figma as a documented set?

**Yes.** The `uvHb6` **Color** variable collection has two modes, **Light** and **Dark**, and all
18 semantic tokens resolve in both. The Foundations page carries a specimen frame labelled
"SEMANTIC COLOR · LIGHT / DARK MODES". The resolved set:

| Token | Light | Dark |
|---|---|---|
| `color/bg` | `base/white` `#FFFFFF` | `ink/default` `#0F0F0F` |
| `color/surface` | `base/white` `#FFFFFF` | `ink/default` `#0F0F0F` |
| `color/surface-sunk` | `gray/50` `#F7F7F7` | `ink/soft` `#1A1A1A` |
| `color/surface-raised` | `base/white` `#FFFFFF` | `ink/soft` `#1A1A1A` |
| `color/surface-invert` | `ink/default` `#0F0F0F` | `base/white` `#FFFFFF` |
| `color/text` | `#0F0F0F` | `#FFFFFF` |
| `color/text-muted` | `gray/500` `#8A8A8A` | `gray/400` `#A8A8A8` |
| `color/text-faint` | `gray/400` `#A8A8A8` | `gray/600` `#6B6B6B` |
| `color/text-invert` | `#FFFFFF` | `#0F0F0F` |
| `color/border` | `gray/150` `#E9E9E9` | `dark/border` `#2E2E2E` |
| `color/border-strong` | `#0F0F0F` | `#FFFFFF` |
| `color/border-faint` | `gray/100` `#F1F1F1` | `dark/border-faint` `#222222` |
| `color/hairline` | `gray/150` `#E9E9E9` | `dark/border` `#2E2E2E` |
| `color/accent-good` | `accent/lime` `#9DFF00` | `accent/lime` `#9DFF00` |
| `color/accent-energy` | `accent/orange` `#FF4F00` | `accent/orange` `#FF4F00` |
| `color/on-accent` | `ink/default` `#0F0F0F` | `ink/default` `#0F0F0F` |
| `color/focus-ring` | `#0F0F0F` | `#FFFFFF` |
| `color/nav-glass` | `#FFFFFF` @ 0.72 | `#0F0F0F` @ 0.62 |

Two deltas between the Figma set and the code:

1. **Figma calls them modes; the code calls them grounds.** Same values, different mental model.
   `CiColors.onLight` / `CiColors.onInk` are two constants that coexist, applied per region via
   `CiSurface.ink`, not swapped globally.
2. **`color/surface-raised` was deliberately not ported.** `ci_colors.dart:112-119` explains: it
   resolves to the same value as `surface` in Light and the same value as `surface-sunk` in Dark,
   so it was a synonym rather than a level. The code carries five extra tokens Figma does not:
   `surfaceDeep`, `fieldFill`, `textSoft`, `accentGoodWash`, `accentEnergyWash`. Each has a
   written rationale in the file.

### Is the orange LIVE badge Spark `#F2A43A`, or outside the token set?

**Neither. It is `#FF4F00`, and it is inside the 2.0 token set.** Both sources agree exactly:

- **Figma:** in `Live Stat Tracker` `138:611`, the text node "LIVE" has fill `#0F0F0F` and its
  parent pill (`138:628`) has fill `#FF4F00`.
- **Code:** `live_tracker_page.dart:231` renders `CiBadge.live()`, which is
  `CiBadgeTone.energy` (`ci_badge.dart:139`), resolving to `c.accentEnergy` = `CiPalette.orange`
  = `Color(0xFFFF4F00)` (`ci_colors.dart:62`).

`#F2A43A` (Spark) exists only in `lib/courtside_iq/design_tokens.dart:81` and
`docs/courtside-iq-design-system.html`, both v1.5 artifacts last touched 2026-05-07. It appears
on **zero** frames in the 2.0 Figma file.

`ci_badge.dart:127-129` records the semantic decision: "ORANGE MEANS 'HAPPENING NOW' HERE, not
'attention'. It is the only place in the app that uses it that way."

### Which palette do the most recently edited frames use?

**All of them use palette (c).** Figma does not expose per-node modification timestamps through
the Plugin API, so I used node-id ordinality as the recency proxy (higher id = created later in
the file's life). The highest-id frames on the Screens page are `892:3184` (What's New sheet),
`899:6` / `900:x` (Icon options), `800:x` / `801:x` (Teams & Events), `799:3234`, `765:3370`,
`691:2838`, `687:2742`. Fill tallies for those frames:

| Frame | Fills used |
|---|---|
| What's New in 2.0 (sheet) `892:3184` | `#9DFF00` ×219, `#FFFFFF`, `#A8A8A8`, `#1E1E1E`, `#D9D9D9`, `#0F0F0F` |
| Add Event Sheet `800:3298` | `#0F0F0F`, `#FFFFFF`, `#8A8A8A`, `#9DFF00` |
| Edit Player - Teams & Events `799:3234` | `#0F0F0F`, `#FFFFFF`, `#8A8A8A`, `#E9E9E9`, `#F7F7F7`, `#FF4F00`, `#A8A8A8`, `#9DFF00` |
| Teams Sheet `800:32` | `#0F0F0F`, `#E9E9E9`, `#FF4F00`, `#FFFFFF`, `#8A8A8A` |
| About Growth IQ `691:2838` | `#FFFFFF`, `#0F0F0F`, `#9DFF00`, `#4D4D4D`, `#000000` |
| Player Profile - Age-Band Transition `687:2742` | `#FFFFFF`, `#0F0F0F`, `#8A8A8A`, `#E9E9E9`, `#9DFF00`, `#A8A8A8`, `#6B6B6B`, `#F3F3F3` |

Across the **entire Screens page** (8,275 nodes, 55 distinct solid fills), the top of the tally is
`#9DFF00` ×2518, `#0F0F0F` ×1046, `#FFFFFF` ×979, `#8A8A8A` ×367, `#A8A8A8` ×266. Zero instances
of `#0FA889`, `#F5F3EF`, `#EFEFF1`, `#6B35C9`, `#2558B8`, `#E04867`, `#F2A43A`, or `#CDF330`.
The Store Screens page tallies the same way. The Branding page is white and `#0F0F0F` only.

**Minor drift worth noting** (small counts, likely hand-picked rather than token-bound):
`#9EFF00` ×4, `#C2EB26` ×4, `#D4E0BD` ×3 (near-lime), and a long tail of off-token greys
(`#E7E7E7` ×93, `#D9D9D9` ×57, `#E2E2E2` ×27, `#999999` ×24, `#808080` ×23, `#8C8C8C` ×22,
`#737373` ×19). `#4285F4` / `#34A853` / `#FBBC05` / `#EA4335` ×1 each are the Google "G" mark on
the auth screens.

### Summary of findings

- Three palettes are in circulation, but only one is bound to Figma variables in the 2.0 file and
  only one is used by the 2.0 code: lime `#9DFF00` / orange `#FF4F00` / ink `#0F0F0F` / white.
- Palette (a) Jade/Canvas is confined to files last touched 2026-05-07 and, in the app, only to
  code that was **unreachable** (the dead v1.5 island in section 1, deleted 2026-09-13). Its three
  doc/code sources disagreed with each other on the Canvas hex.
- Palette (b) `#CDF330` is a variable in the legacy `E8n8` file. Nothing in this repo or in the
  2.0 file references it.
- The dark tracker is intentional and measured from the frame; dark is a documented Figma mode,
  reinterpreted in code as a per-region ground rather than a user-toggleable theme.
- The LIVE badge is `#FF4F00`, a first-class token, not Spark and not off-system.

Decision is yours. I am not picking.

---

## 3. Component coverage

The `uvHb6` Components page holds **67 `COMPONENT` / `COMPONENT_SET` nodes** in two top-level
containers: `Components Board` `25:3` and the free-standing `Field` set `571:177`.

### Real Figma components

| Component | id | Type | Variants | Code |
|---|---|---|---|---|
| LogoMark | `25:5` | COMPONENT | - | `design/components/ci_logo_mark.dart` |
| **Badge** | `25:17` | COMPONENT_SET | Tone = Good / Energy / Neutral | `design/components/ci_badge.dart` |
| **Button** | `26:19` | COMPONENT_SET | Style = Primary / Secondary / Lime / Orange × Size = Md / Sm (8) | `design/components/ci_button.dart` |
| IconButton | `27:11` | COMPONENT_SET | Tone = Light / Dark | in `ci_button.dart` / inline `_IconTap` |
| **StatTile** | `28:13` | COMPONENT_SET | Size = Md / Sm | `design/components/ci_stat_tile.dart` |
| DotGauge | `29:5` | COMPONENT | - | `design/components/dot_gauge.dart` |
| SegmentBar | `30:5` | COMPONENT | - | `design/components/ci_segment_bar.dart`, `ci_scoring_mix.dart` |
| JerseyTile | `30:19` | COMPONENT_SET | Size = Lg / Md | `design/components/ci_avatar.dart` (uncertain mapping) |
| TabBar | `47:124` | COMPONENT_SET | Active = Home / Players / Games / Menu | `features/nav/ci_nav_bar.dart` |
| SegmentedTabs | `32:35` | COMPONENT_SET | Active = Averages / Development / Games | `design/components/ci_segmented_tabs.dart` |
| Stepper | `32:37` | COMPONENT | - | `design/components/ci_stepper.dart` |
| **RecentGameRow** | `33:5` | COMPONENT | - | `features/home/widgets/game_feed_row.dart` |
| SnapshotCard | `70:107` | COMPONENT | - | `features/home/widgets/today_hero.dart` (uncertain) |
| PlayerSwitcher | `72:165` | COMPONENT | - | `features/home/widgets/today_hero.dart` (uncertain) |
| Avatar | `80:173` | COMPONENT | - | `design/components/ci_avatar.dart` |
| SectionHeader | `91:173` | COMPONENT | - | `design/components/ci_section_header.dart` |
| **Field** | `571:177` | COMPONENT_SET | Tone (Light/Dark) × Type (Text/Dropdown/Password/Textarea) × State (Default/Focus/Error/Filled) = 26 | `design/components/ci_field.dart` |

### Against your specific list

| Asked about | Real Figma component? | Notes |
|---|---|---|
| **Tier chips (Solid / Good / Elite)** | **No.** One-off use of the `Badge` set. | `Badge` has three tones (Good / Energy / Neutral). There is no `Tier` component and no Solid/Good/Elite variant axis. Tier labels come from data: `game_detail_page.dart:536-540` sets `label: row.tier.label` and gives the accent only to `GameTier.elite`, leaving Good and Solid on `neutral`. So the design system has no tier chip; the app composes one from a generic badge. |
| **Metric cards** | **Yes** - `StatTile` `28:13` (Size = Md / Sm). | `ci_stat_tile.dart`. |
| **Game row** | **Yes** - `RecentGameRow` `33:5`. | Shared: `game_feed_row.dart` serves Today, the Games list, and the profile Games tab (via `showPlayer`). This is the shared-component pattern done right. |
| **List and row patterns** | **Partial.** `RecentGameRow` and `SectionHeader` are components. | `player_list_row.dart` and `ci_settings_row.dart` have no component in the file; they were drawn inline on `272:1557` and `294:1331` respectively. |
| **Empty and zero-data states** | **No.** All one-off frames. | Seven empty/zero frames exist (`204:763`, `206:806`, `206:984`, `683:2755`, `526:2012`, plus the skeletons) but none is a component. Code has `design/components/ci_empty_state.dart`, so the code is **more** componentized than the design here. |
| **Buttons** | **Yes** - `Button` `26:19`, 8 variants; plus `IconButton` `27:11`. | Note the variant axis is Style × Size only. No Default / Pressed / Disabled / Loading states are drawn. Per the Taste rubric's "full interactive state cycles", that is a real gap in the set. |
| **Development card** | **No.** | Development is a profile **tab** drawn inline on `93:211` and `156:704`, not a component. Code matches: `widgets/development_view.dart` is a tab renderer, not a card. See section 4. |
| **Bright Spots / Room to Grow / Watch for Next** | **No, and the names have changed.** | No component. In the shipped 2.0 the three sections are **"What's Working"**, **"Room to Grow"**, and **"WATCH NEXT GAME"** (`development_view.dart:236-246`). "Bright Spots" and "Watch for Next" do not appear anywhere in the codebase. Both "What's Working" and "Room to Grow" render on the same `accentGoodWash` `#F1FFD2` block (`_WashBlock`), deliberately: `development_view.dart:256-259` says giving Room to Grow an alarm colour "would tell a parent their child is failing." "WATCH NEXT GAME" is a separate ink `_FocusBlock`. |

### Component coverage gaps worth naming

- No state variants on `Button` (no pressed, disabled, loading, focus).
- No `Card` / surface component at all, in a system built from cards.
- No tier chip, in a product whose core vocabulary is Solid -> Good -> Elite.
- No empty-state component, though the code has one.
- `Icon/chevron-down` `574:6` is the only icon published as a component, on a page with a
  19-glyph icon board. The other glyphs are not components.
- `LogoMark` `25:5` still carries the **old** geometry. `CLAUDE.md` already flags this: the app
  renders the new SVG everywhere, but Figma instances (which carry fill overrides, some on light
  grounds) still show the pre-2026-07-27 mark. Confirmed still open.

---

## 4. Gaps

Your list, checked against what is actually in the file and the tree.

| Claimed gap | Verdict | Evidence |
|---|---|---|
| **Game row component pass** | **Correct, but not for the reason the roadmap gives.** The row itself is fully designed (`RecentGameRow` `33:5`) and built (`game_feed_row.dart`). What is missing is roadmap **1.11**: the `highlight_metric` tag ("Scoring" / "Playmaking" / "Hustle") on game rows. No 2.0 frame shows such a tag, and `game_feed_row.dart` renders none. The data exists end to end (`generate-game-insight/index.ts:320` writes `highlight_metric`; `game_detail_repository.dart:105` reads it), and it **is** surfaced, but on **Game Detail** as "SCORING EFFICIENCY · ELITE" inside the insight card, not on the row. So 1.11 as written was silently relocated. Whether the row tag is still wanted is a product call. |
| **Birth date input** | **Not a gap. Designed and built.** Frames: `Set Birth Date` `643:2181`, `Birth Date Prompt` `647:2188`, `Add Player Sheet` `302:1395` (which carries a "Birth date · Optional" row, `add_player_sheet_v2.dart:220`). Code: `birth_date_sheet.dart` (cites `643:2188`), `ci_wheel_picker.dart`, `birth_date_nudges.dart`, `birth_date_gate.dart`, wired into `today_page.dart` and `player_profile_page.dart`. Note the field is **optional** on Add Player, whereas roadmap 1.2 said "required for new player creation". That is a divergence, not a gap. |
| **Profile inline prompt** | **Correct that it does not exist, but it was designed then deliberately killed.** The frame is `Birth-date-missing caveat` `649:2199`. `birth_date_nudges.dart:5-12` says it "IS DELIBERATELY NOT HERE": once "no birth date, no rating" shipped there was no uncalibrated rating left to caveat, and on the Development tab it put the same sentence on screen twice. The ask now lives in the Development tab's empty state. The dead v1.5 `birth_date_profile_banner.dart` was the old jade-coloured version of this; it was unreachable and has been deleted. **This needs no Figma work; it needs the orphan frame retired or annotated.** |
| **Development card** | **Partially correct, and the divergence is bigger than "no design".** Roadmap 2.8 specified a **card at the top of the player profile**, above the stats list, with three sub-sections (Emerging strength / Growth opportunity / Parent nudge) and a violet sparkle. What shipped is a **tab** (`93:211`, `widgets/development_view.dart`) with a DotGauge, a trend chip, a headline, "What's Working", "Room to Grow", "WATCH NEXT GAME", and "About this story". Designed and built, but as a different object under a different name and a different palette. The roadmap entry is stale, not the design. |
| **Beta feedback button** | **Correct. Genuinely absent.** No frame in `uvHb6` mentions beta. No `beta_tester` column, flag, or "Give feedback on this story" string anywhere in `lib/` or `supabase/`. Roadmap 2.5 (line 458) and its design implication (line 462) were never executed. Note `Send Feedback` `508:1972` and `feedback_sent_sheet.dart` do exist as a general feedback path, which may make the beta-specific button moot now that 2.0 has shipped to both stores. |

### Additional gaps found, not on your list

| Gap | Status | Evidence |
|---|---|---|
| **Stats & Trends** `307:1407` | Specced only | Designed, plus its locked variant `331:1661` and empty state `526:2012`. No code. `player_profile_page.dart:506` records the deliberate omission of the "View trends" button rather than shipping a button that goes nowhere. Three frames, one feature, zero implementation. |
| **Players list skeleton** `515:1975` | Specced only | `players_list_page.dart:170` uses a `CircularProgressIndicator`. |
| **Games list skeleton** `682:2785` | Specced only | `games_list_page.dart:404` uses a `CircularProgressIndicator`. |
| **Dialog - Alert · Single Action** `371:1910` | Specced only | `showCiConfirmDialog` is two-button only. No single-action path found. |
| **Dialog - Rate App** `462:1949` | Specced only | Dependency still installed; the v1 action file was deleted 2026-09-13. Nothing builds this. |
| **Team / Event Selection frames are stale** | Design behind code | `game_setup_pickers.dart:13-16` says the frames use an old "X" close and the code uses the `CiSheet` shell, ending "THE FRAMES SHOULD BE UPDATED, not the code." |
| **What's New sheet frames are unsectioned and mislabelled** | Housekeeping | `892:3184` and `899:6` sit outside every Section at y ≈ 11850 under a label saying "(DRAFT for review)", but `whats_new_sheet.dart` is shipped. Violates the `CLAUDE.md` flow-section rule. |
| **`Button` set has no interactive states** | Component gap | Style × Size only. |
| **`LogoMark` component `25:5` holds old geometry** | Known, still open | Already flagged in `CLAUDE.md`. Confirmed unresolved. |

---

## 5. Design-to-data mismatches

Checked by scanning every TEXT node inside all 91 screen frames for clock, timer, minutes,
quarter, period, foul, duration, and `HH:MM` patterns, then reading the schema in
`supabase/migrations/20260101000000_baseline_schema.sql` and `lib/courtside_iq/game_sync/game_columns.dart`.

### Confirmed clean

**No frame anywhere in the file shows a game clock, a timer, minutes played, a quarter or period
indicator, or a foul control.** The 76 regex hits were, without exception, the iOS status-bar
time "9:41" and two instances of the word "ended" in "Your Premium has ended". This is a clean
result and it is worth recording: the design file and the data model agree that none of these
exist.

Corroborating code:
- `LiveStat` (`live_game.dart:143-156`) has exactly 12 members: `twoMade`, `twoMissed`,
  `threeMade`, `threeMissed`, `ftMade`, `ftMissed`, `offReb`, `defReb`, `assists`, `steals`,
  `blocks`, `turnovers`. No fouls, no minutes, no time.
- The tracker frame `138:611` contains exactly these controls and no others: PTS/REB/AST/STL/BLK/TO
  header, three shot rows (2PT/3PT/FT), six count tiles (OReb, DReb, Assists, Steals, Blocks,
  Turnovers), a LIVE pill, Pause and End.
- Pause is a dialog with two outcomes, `PausedChoice.resume` and `PausedChoice.end`
  (`game_paused_dialog.dart:24`). Nothing in it records or displays elapsed time. Your
  characterisation of it as a safety lock is exactly what the code does.

### Live mismatch: home/away on Player Profile - Games

**`Player Profile - Games` `98:583` shows a home/away designation the schema cannot supply, and
still does.** The frame's rows read:

```
vs Northside Hawks      Sat, Mar 8 · Home
at Eastlake Raptors     Tue, Mar 4 · Away
vs Cedar Park Suns      Sun, Mar 2 · Home
at Riverside Kings      Thu, Feb 27 · Away
vs Valley Titans        Sat, Feb 22 · Home
```

Two separate things the data cannot do: the `· Home` / `· Away` suffix, and the `at` versus `vs`
prefix that alternates with it.

`public.games` has `id`, `created_at`, `opponent_team`, `game_live`, `user_id`, `player_id`,
`player_team_name`, `event_name`, `event_type`. There is no home/away column and I found no
occurrence of `is_home`, `isHome`, or `homeAway` anywhere in the tree.

**The code already resolved this; the design was never updated.** `game_feed_row.dart:58-64`:

> "Fills the slot the frame labels 'Home', which has no column behind it: the schema has never
> recorded home or away. The event is the real qualifier a parent has for a game."

So `dateSubtitle` renders "Sat, Mar 8 · Spring Classic" using `event_name`, and `opponentTitle`
always uses the `vs` prefix, never `at`. The shipped screen and the approved frame therefore
disagree on two visible strings. **This is the one place where an engineer building from the
frame today would build something the database cannot back.**

### Stored-twice: `fg_made` / `fg_attempt`

Confirmed. `player_game_stats` carries `fg_made` and `fg_attempt` alongside `two_made`,
`two_attempt`, `three_made`, `three_attempt`. `save_game.dart:70-71` writes `s.fgMade` and
`s.fgAttempted`, which are derived from the two- and three-point fields. The Game Detail frame
`145:610` displays "Field Goal 57%", "3-Point 40%", "Free Throw 80%", so the aggregate is
surfaced. It is redundancy, not a design mismatch: the design shows a value the schema can supply
twice over.

`game_detail_builder.dart:88` records why the duplication persists: "older rows only have
`fg_made`, so deriving keeps both eras working." Removing the columns would break historical rows.

### `off_foul` / `def_foul` with no tracker control

Confirmed, and the design agrees with the tracker, not with the schema. Both columns exist in
`player_game_stats` (baseline schema lines 96-97) and both are in `kStatsColumns`
(`game_columns.dart:42-43`), so the save path will happily write them. But:

- `LiveStat` has no foul member, so nothing can ever set them to a non-zero value.
- No frame in the file shows a foul control or a foul readout.
- The Game Detail frame `145:610` lists PTS / REB / AST / STL / BLK / TO and never fouls.

So these are **dead columns**: present in the schema, present in the column allow-list, absent
from the design, absent from the UI, and permanently `0` by default. Not a design-to-data
mismatch; a data-to-nothing orphan.

### No timestamps on stat entry, no `started_at` / `ended_at`

Confirmed and consistent with the design. `games` has `created_at timestamptz default now()` and
`game_live boolean`, nothing else temporal. `player_game_stats` has no timestamp column at all.

Nothing in the design needs them:
- Game rows show a **date** only ("Sat, May 4"), which `created_at` supplies.
- The `Games - List` date filter chips ("All dates", "May 4", "May 2", "Apr 28", "Apr 26",
  "Apr 21") are day-granularity and `created_at` supplies those too.
- `Games - Live In Progress` `683:2597` marks the live row with a LIVE pill and shows **no**
  duration, elapsed time, or start time. `game_feed_row.dart:72-77` confirms `games.game_live` is
  the only source, with at most one true at a time.

One thing to be aware of rather than a mismatch: `created_at` is the moment the row was
**written**, not the moment the game was **played**. For an offline game flushed by
`game_sync_queue` days later, the date shown on the row is the sync date. I did not trace whether
the queue preserves the original timestamp on upsert; that is worth a separate check before any
feature leans on game date as game-played date.

### Summary

| Known fact | Confirmed? | Does any design contradict it? |
|---|---|---|
| No game clock, none planned | Yes | No. Zero clock references in 91 frames. |
| Pause is a safety lock, not a timer | Yes | No. `PausedChoice.resume` / `.end` only. |
| Minutes played not tracked | Yes | No. No frame shows minutes or MPG. |
| No timestamps on stat entry | Yes | No. |
| `games` has `created_at` + `game_live`, no `started_at` / `ended_at` | Yes | No. |
| `off_foul` / `def_foul` have no tracker control | Yes | No. Also absent from every design. |
| `fg_made` / `fg_attempt` stored twice | Yes | No. Redundant, deliberately retained for old rows. |

**One mismatch found that is not on your list:** the home/away designation on
`Player Profile - Games` `98:583`.

---

## Uncertainties

Listed explicitly rather than guessed at.

1. **Icons page intent.** I cannot tell whether `Icons Board` `49:7` is a spec the code ignores
   (the app uses Material `Icons.*`) or documentation of which Material glyphs were chosen.
   *Resolved by:* you saying which, or by comparing the 19 glyphs on the board against the
   Material names used in `lib/features/`.

2. **`JerseyTile` `30:19`, `SnapshotCard` `70:107`, `PlayerSwitcher` `72:165`.** Three components
   with no node citation in any Dart file. I mapped them to `ci_avatar.dart` and `today_hero.dart`
   by appearance and name. *Resolved by:* opening each component and comparing against the
   rendered Today hero on device.

3. **Birth Date Prompt node id.** The dialog is built, but the code cites `649:2201` (inside the
   caveat frame) while the prompt frame is `647:2188`. *Resolved by:* screenshotting both and
   comparing against the shipped dialog.

4. **`paywall_states.dart` cites `726:3127`, `726:3290`, `726:3424`.** These are not top-level
   frames on the Screens page. Probably nested nodes inside the paywall frames. *Resolved by:*
   `getNodeByIdAsync` on each. I did not chase it because all four paywall state frames map
   cleanly already.

5. **`created_at` versus game-played date for offline-synced games.** See section 5. *Resolved by:*
   reading `game_sync/supabase_game_uploader.dart` and checking whether the queued payload carries
   an explicit `created_at`.

6. **Figma per-node modification times.** Not exposed by the Plugin API. All recency claims in
   section 2 rest on node-id ordinality, which is a reliable proxy for **creation** order and only
   a weak proxy for **edit** order. A frame created early and heavily edited last week would look
   old by this measure. *Resolved by:* the Figma version history UI, which I cannot read from here.

7. **Whether the `Icon options` board `899:6` and the "(DRAFT for review)" label are live or
   stale.** The sheet they belong to has shipped. *Resolved by:* you confirming the icon choice
   is settled, after which both can be sectioned or archived.
