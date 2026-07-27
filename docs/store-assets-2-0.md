# 4.23 — Store assets for 2.0.0

Release notes, listing copy, and the screenshot plan. Copy rules applied
throughout: no em dashes, warm parent voice, development-not-stats
positioning, reassurance before features (the 4.19c rule, in shorter form).

Character limits are stated per field so nothing gets truncated at upload.

---

## Current listings, captured 2026-07-26

**iOS** (id6748415872, live v1.4.0): name shows as **"CourtSide IQ"** (capital
S - fix casing at submission), subtitle **"Basketball Stat Tracker"**,
description leads "Track progress. Build confidence." and pitches "players,
parents, and coaches."

**Play** (com.mycompany.courtsideiq): correct name casing, same description,
plus pricing copy that is STALE FOR 2.0: "Start free with one player profile
and up to three games. Upgrade to the Pro Plan..." - 2.0's free tier has no
game limit (the only cap is 1 player) and nothing in the app says "Pro Plan";
it says Premium. Must not ship under 2.0.

**Three deliberate changes the new copy makes:**
1. Subtitle stops calling the product a stat tracker (the core positioning
   rule). "stat tracker" moves to the HIDDEN iOS keywords field, where it
   keeps its search weight without being read as positioning.
2. Audience commits to parents (the product truth) instead of
   players/parents/coaches.
3. Tier copy matches the shipped app: free = 1 player, Premium = up to 3,
   no game limits, "Premium" not "Pro Plan".

---

## 1. Release notes

**The first thing an existing parent reads about this change.** Reassurance
leads: their data is safe. Features come second.

### iOS — App Store "What's New" (limit 4,000; keep it scannable)

> Courtside IQ 2.0 is here: a fresh look and a deeper read on how your player
> is developing.
>
> First things first: everything you have logged is safe. Your players, your
> games, and every insight are all here, wearing a new design.
>
> New in 2.0:
>
> • Growth IQ: one number for how your player is developing, built from how
> they score, create, and defend for their age, plus how much they are
> improving game to game.
> • Development story: what's working, room to grow, and the one thing to
> watch for in their next game.
> • A faster live tracker, built for one hand in the stands.
> • A clearer Games list, and a full read on every game you log.
>
> Courtside IQ is a development tool, not a stat tracker. Every number
> connects to your player's growth.

### Android — Play "What's new" (limit 500 characters)

> Courtside IQ 2.0: a fresh look and a deeper read on development.
>
> Everything you have logged is safe: your players, games, and insights are
> all here, wearing a new design.
>
> New: Growth IQ, one number for how your player is developing. A development
> story with what's working and room to grow. A faster live tracker built for
> one hand in the stands.

(437 characters, fits with headroom.)

---

## 2. Listing copy

### iOS

| Field | Limit | Draft |
|---|---|---|
| Subtitle | 30 | `Youth basketball development` (29) |
| Promotional text | 170 | `New in 2.0: Growth IQ, one number for how your player is developing, plus a development story that turns every game into what's working and what to work on next.` (161) |
| Keywords | 100 | `stats,stat,tracker,player,performance,tracking,growth,coach,kids,hoops,game,insights,ratings,AAU` (96) |

**Keywords rationale.** Current live field: `basketball stats, Basketball stat
tracker, player stats, youth basketball, performance tracking` - full phrases
with repeats, so most of the budget is spent twice. Apple combines single
words across commas into phrases, and words in the app NAME and SUBTITLE are
indexed for free - so with the new subtitle "Youth basketball development",
the terms youth / basketball / development move there and every live phrase
stays reachable: basketball stats, stat tracker, player stats, youth
basketball, performance tracking. The freed budget adds growth, game,
insights, ratings, coach, kids, hoops, and AAU (high intent for this exact
parent audience). Nothing currently ranking is dropped.

### iOS + Play — full description (iOS 4,000 / Play 4,000)

> **See the player, not just the stats.**
>
> Courtside IQ turns the games you watch from the stands into a clear picture
> of how your young player is developing. Track a game with one hand, and get
> warm, plain-language insights about what clicked and what to work on next.
>
> **Growth IQ**
> One number for how your player is developing: how they score, create, and
> defend for their age, plus how much they are improving game to game.
> Improvement counts for real, so a player who keeps working sees it climb. It
> is never a ranking against other kids.
>
> **A development story, not a box score**
> After every few games, Courtside IQ writes your player's development story:
> what's working, where the room to grow is, and the one concrete thing to
> watch for in their next game.
>
> **A live tracker built for the stands**
> Log shots, rebounds, assists, steals, and blocks with one hand while the
> game is moving. No signal in the gym? Track anyway. The game saves and syncs
> when you are back online.
>
> **Every game, decoded**
> Each game you log gets its own insight: what your player did well, connected
> to how it helps them grow, never just numbers.
>
> Courtside IQ is built for parents of players ages 8 to 18. It is a
> development tool, not a stat tracker: every rating is measured against your
> player's own age group, and every level is a real place to grow from.
>
> Start free with one player. Go Premium to follow up to three.

### Play — short description (limit 80)

> `Turn every game into a clear picture of your young player's development.` (73)

---

## 3. Screenshots — Figma pass

**Store screenshots are designed frames, not raw captures**: real 2.0 screens
inside a device frame with one short headline each, on the brand ground.
Authored in the 2.0 Figma file on a dedicated "Store Assets" page (marketing
frames are not app screens, so they do not belong in the Screens-page flows).

Proposed set, in narrative order (one story across the gallery):

| # | Screen | Headline |
|---|---|---|
| 1 | Today with Growth IQ hero | `Know how your player is growing` |
| 2 | Player profile - Development story | `Every game becomes a story` |
| 3 | Live tracker mid-game | `Track with one hand from the stands` |
| 4 | Game detail with insight card | `Every game, decoded` |
| 5 | Games list | `The whole season in one place` |
| 6 | Add player / family angle | `Built for parents, ages 8 to 18` |

Rules for the pass: dot-burst motif and lime accent used with intent, ink
ground, Hanken Grotesk, no em dashes in headlines, every screen a REAL 2.0
frame (they are the shipped UI, so the stores' "show the actual app" rule is
satisfied by construction).

**Sizes** (confirm in the consoles at upload; stores adjust specs quietly):

| Store | What | Size |
|---|---|---|
| App Store (iPhone) | The one required set: 6.9-inch | 1320 x 2868 px portrait, exact; Apple scales it down. Up to 10 shots. |
| Google Play (phone) | 2-8 screenshots | 1080 x 1920 px (9:16); at least 4 at >=1080px qualifies promo placement |
| Google Play | Feature graphic (required) | 1024 x 500 px |

**The CURRENT live set (reviewed 2026-07-26) cannot ship with 2.0.** All four
frames show the v1 UI deleted in 4.24: the old tracker with FOULS / PF / +/-
/ EFF (stats 2.0 deliberately does not track), an insight card that speaks TO
the player ("You shot...") where 2.0 speaks to the parent (plus a typo,
"keep your team in controls"), and the v1 Players list / profile with the old
nav bar. The TEMPLATE (dark ball ground, big white headline, device frame)
is keepable; the screens inside and the stat-tracker headlines are not.
Current aspect (~2.17:1) matches the App Store size exactly; Play needs a
9:16 variant.

---

## Status — COMPLETE 2026-07-26, upload rides with 4.22

- [x] iOS keywords field captured and rebuilt (rationale above).
- [x] Release notes + listing copy APPROVED.
- [x] Six screenshots designed on the Figma "Store Screens" page (grounds:
      photo, lime ombre x2, ink+glow, lime wash, light gray; Hanken Grotesk
      ExtraBold headlines at the app's display metrics; shadow on S1 only),
      user-signed-off, exported:
      - `store-assets/appstore-6.9/` — 1320x2868, opaque RGB
      - `store-assets/play/` — 1080x1920 (rescaled clones of the approved
        set), plus `feature-graphic.png` 1024x500 (ink mark + wordmark +
        tagline on the lime ombre)
- [ ] AT UPLOAD (4.22): create the 2.0.0 version entries, paste copy, upload
      assets, fix the iOS display-name casing "CourtSide IQ" -> "Courtside IQ".
