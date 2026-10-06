# 2.0 Screen Coverage Audit

Roadmap item **4.0**. Maps every v1 screen in `lib/pages/` to an approved 2.0 Figma frame in
`uvHb6HXvIVFwzSSXPtEVoc` (Screens page), so no 4C screen PR opens against a missing design.

**Legend:** ✅ designed · ⚠️ needs confirmation · ❌ needs design · ✂️ deliberately cut · 🧩 component (no screen frame needed)

Audit run: 2026-07-18. Figma inventory: 9 sections, ~80 frames.

---

## Headline

**Coverage is near-complete.** 35 v1 directories, of which 8 are shared components rather than
screens. Of the 27 real screens, **24 map cleanly to an approved frame**, 1 is a deliberate cut,
and **2 need confirmation**. No confirmed design gaps.

The 2.0 file also contains ~30 frames with *no* v1 equivalent — those are new 2.0 features
(Splash, Onboarding, Growth IQ, Stats & Trends, paywall carousel, locked/lapsed states), not gaps.

---

## v1 → 2.0 mapping

### Authentication

| v1 | 2.0 frame | |
|---|---|---|
| `authentication/user_auth` | Auth Landing | ✅ |
| `authentication/user_auth_email` | Email Auth (Sign In) · (Sign Up) · Validation Error | ✅ |
| `authentication/forgot_password` | Forgot Password | ✅ |
| `authentication/reset_password` | Reset Password | ✅ |
| `authentication/reset_succesful` | Reset Successful | ✅ |

### Home

| v1 | 2.0 frame | |
|---|---|---|
| `home/home` | Today · Empty (No Players) · Loading (Skeleton) | ✅ |

### Players

| v1 | 2.0 frame | |
|---|---|---|
| `players/players_list` | Players — List · Empty · Loading (Skeleton) | ✅ |
| `players/players_profile` | Player Profile · Averages · Games · Locked · Age-Band Transition | ✅ |
| `players/edit_player` | Edit Player | ✅ |
| `players/edit_player_position` | Edit Position | ✅ |
| `players/player_components` | — | 🧩 |

### Games

| v1 | 2.0 frame | |
|---|---|---|
| `games/all_games` | Games — List · Empty · No Games (Player Filter) · Loading | ✅ |
| `games/game_stats` | Game Detail | ✅ |
| `games/game_stat_tracker` | Live Stat Tracker · Offline Scoring + Deferred Sync | ✅ |
| `games/new_game` | Create — New Sheet · New Game — Setup · Team Selection | ✅ |
| `games/edit_live_game` | Game Paused · Dialog — Resume Game | ⚠️ |
| `games/game_components` | — | 🧩 |

⚠️ **`edit_live_game`** — Game Paused and Resume Game cover pausing/resuming a live game. Confirm
whether v1 also supports *editing already-recorded stats* mid-game. Per the design review, inline
steppers were kept and the edit-stat bottom sheet was deliberately deleted twice, so this is most
likely already resolved as "no separate edit screen." Verify before the 4.13 PR.

### Menu & Account

| v1 | 2.0 frame | |
|---|---|---|
| `menu/menu` | Menu | ✅ |
| `menu/your_profile` | Your Profile · Edit Name | ✅ |
| `menu/user_account` | Edit Email · Change Password · Delete Account · Success Confirmation | ✅ |
| `menu/support` | Help Center | ✅ |
| `menu/app_appearance` | — | ✂️ cut (prior decision) |
| `menu/menu_components` | — | 🧩 |

### Global / shared

| v1 | 2.0 frame | |
|---|---|---|
| `global/alert_confirm` | Dialog — Confirm · Destructive · Neutral | ✅ |
| `global/alert_dialog` | Dialog — Alert · Single Action | ✅ |
| `global/alert_rate` | Dialog — Rate App | ✅ |
| `global/custom_snack_bar` | Snackbar — Error / Success | ✅ |
| `global/send_feedback` | Send Feedback | ✅ |
| `global/empty_states` | Today/Players/Games/Stats & Trends empties | ✅ |
| `global/informational_dialog` | Game Insights Info · About Story Sheet · About Growth IQ | ⚠️ |
| `global/menu_list_empty_state` | — | ⚠️ |
| `global/bottom_sheets` | Add Player · Profile Photo · Premium Gate · Create New | ✅ |
| `global/custom_nav_bar` | — | 🧩 |
| `global/header_player_profile` | — | 🧩 (PlayerHeader, 0 instances — retire) |
| `global/sub_pg_header` | — | 🧩 |

⚠️ **`informational_dialog`** — three explainer surfaces exist. Confirm they cover every v1
info-dialog invocation, or whether v1 uses one generic dialog with variable copy (in which case a
generic 2.0 variant may be needed).

⚠️ **`menu_list_empty_state`** — no obvious 2.0 equivalent. Confirm this is still reachable; the
2.0 Menu is a fixed list with no empty condition, so this may be dead in v1 and simply drops.

---

## New in 2.0 (no v1 equivalent)

Not gaps — new feature surface. Splash · Onboarding ×3 · Guided First-Run ×2 · Stats & Trends ·
Full Breakdown · About Growth IQ · Player Profile Locked / Development Locked / Age-Band
Transition · Players List Premium Lapsed · Premium Upgrade Banner · Premium Lapse/Downgrade ·
Premium Locked (Trends Teaser) · 3-Player Cap · Add Player Gate (Free) · Birth Date Prompt · Set
Birth Date · Birth-date-missing caveat · Paywall ×3 slides + 4 states · Premium Gate Sheet ·
Event Selection · New Event · Game Complete & Save · Insight Loading / Error.

---

## Open items before 4C

1. Confirm the three ⚠️ rows above (cheap — check v1 routing, no design work unless a gap is real).
2. ~~Figma housekeeping: loose `flow-arrow` frames~~ — **closed, not an issue.** They are
   intentional visual cues from the design pass. Leave them alone.
3. ~~Confirm every ✅ frame is approved~~ — **closed 2026-07-18.** Everything currently in the
   Figma file has been signed off. Presence in the file = approved.

---

## Standing rule

If a screen, state, or dialog is reached during 4C with no approved frame: **stop coding**, design
it in Figma on the Screens page (in its flow section, wired with a connector from its entry point),
review, approve, then implement. Update this document when that happens.
