# Store, site and FAQ copy for 3.8 (free tier: 1 player + 3 games)

Ships WITH the build that enforces the limit, never before. Supersedes the
"no game limits" tier line in `docs/store-assets-2-0.md` (point 3) and its
closing line "Start free with one player. Go Premium to follow up to three."

Rules held: no em dashes, "app store" lowercase in cross-platform copy, warm
parent voice, the free plan never promised Growth IQ.

**Why Growth IQ is not a free benefit.** Growth IQ and the development story
need five games before they show (roadmap 2.3). Free now stops at three, so a
free parent sees the "building" state and never the score unless they go
Premium. Every line below is written to that truth: free = track and read each
game; Premium = the season-long picture.

---

## App Store "What's New" (limit 4,000)

> Free accounts now include three games, so you can try everything Courtside
> IQ does for a game before you decide. Every game you have already logged is
> safe and stays right where it is.
>
> Premium adds unlimited games and up to three players, and keeps Growth IQ
> and your player's development story building all season.
>
> Tracked a game with no signal after your free games? It stays safe on your
> phone and is added the moment you go Premium.

## Play "What's new" (limit 500)

> Free accounts now include three games. Everything you have logged is safe.
> Premium adds unlimited games and up to three players, and keeps Growth IQ and
> the development story building all season. A game tracked offline after your
> free games stays safe on your phone until you go Premium. (306)

## Full description: replace the closing tier line

Old: `Start free with one player. Go Premium to follow up to three.`

> Start free with one player and three games. Go Premium for unlimited games,
> up to three players, and Growth IQ all season.

---

## Site (courtsideiq.app), pricing section

Live only once this build is in the stores.

- **Heading:** `Start free. Three games on us.`
- **Lede:** `Track one player's first three games at no cost, with a read on every one. Go Premium to keep going all season.`
- **Free card**
  - Price: `$0` / `for one player, three games`
  - Features: `Track three games from the stands, even offline` · `An insight after every game you save`
  - Button: `Get the app, free` (unchanged)
- **Premium card**
  - Features to add above the plan picker: `Unlimited games every season` · `Up to three players` · `Growth IQ and the development story`
  - Small print (monthly): `Unlimited games, up to three players. 7-day free trial, then $5.99/mo. You start it in the app.`
  - Small print (weekly): `Unlimited games, up to three players. $1.99 a week, no trial. You start it in the app.`
- **FAQ, new answer** (paragraph form): **What does the free plan include?**
  `One player and three games, each with its full read, so you can see exactly
  what Courtside IQ does with a game. Growth IQ needs five games to mean
  something, so it arrives with Premium, along with unlimited games and up to
  three players.`
- **FAQ, existing "Why can't I see a Growth IQ yet?"**: add one sentence:
  `On the free plan, Premium unlocks the games that get you there.`

## In the app (already built on `phase-3-8-free-game-limit`)

- Help: "How does my subscription work?" now opens with the free plan and the
  offline promise (`lib/courtside_iq/help_content.dart`). Kept to eight topics
  to match the Help frame (507:1964).
- Gate, offline-held sheet, New Game hint, Create sheet and paywall line: see
  roadmap 3.8 and the approved Figma frames.
