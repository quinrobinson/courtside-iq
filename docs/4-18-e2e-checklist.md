# 4.18 — End-to-end verification checklist

The roadmap states 4.18 as a paragraph. This is that paragraph turned into an
order you can actually work through on a device.

**Grouped by SETUP, not by feature.** Several of these need the app in a
specific state (fresh install, offline, a particular entitlement), and the
expensive part is getting into that state - not the tapping. Doing them in
feature order means rebuilding the same state four times.

## Before you start

- [ ] `lib/backend/supabase/supabase.dart` → `_kUseTestSupabase = true`.
      Everything below writes data. On prod it would write real parent data.
- [ ] Build with `--release`. FlutterFlow layouts throw debug-only asserts on
      iOS 26, so a debug run fails for reasons that are not the app.
- [ ] Run the whole list on **iOS and Android**. The nav, transitions, sheets
      and the back gesture differ; a pass on one is not a pass on both.
- [ ] **Turn email confirmation ON for the test project before starting.**
      Prod has it ON, and this pass exists to verify what SHIPS - with it off,
      signup auto-confirms and you are testing a flow no real parent gets.
      Reversible, and done once before (4.9b, 2026-07-19). Check the redirect
      URL is set while you are in there. Existing confirmed accounts are
      unaffected, so this only costs an email round-trip on new signups.

**Offline means genuinely offline.** Airplane mode does NOT cut wifi on iOS,
and on the simulator it cuts nothing at all - a "failed" request will quietly
succeed and the test silently passes. Turn wifi OFF explicitly, on a physical
device, and confirm with any web request before trusting an offline result.

---

## A. Fresh install (do first — this state is destroyed by everything else)

- [ ] Cold start → Splash → onboarding (all three slides) → auth landing.
- [ ] Sign UP with a new email. Confirm the "check your email" screen appears
      and names the address.
- [ ] **Open the confirmation link and land back in the app.** Worth its own
      line: this re-enters via a DEEP LINK straight to a route, with the
      first-run gate sitting on that landing - the exact mechanism the nav
      shell (4.19f) changed. Confirm the nav bar is present and first-run
      behaves.
- [ ] Guided first-run appears (Welcome → Add first player), is skippable, and
      does NOT appear again on the next launch.
- [ ] Confirm the "What's new in 2.0" sheet does **not** appear for this new
      user. If it does, the first-run/upgrade mutual exclusion is broken.

## B. Existing-user upgrade path

**The account you just created in A CANNOT test this, and that is correct.**
First-run marks `whatsNew2Seen` the moment it welcomes a new parent, so a
new-to-2.0 account is suppressed forever - What's New is for v1 UPGRADERS, not
new users. You need an account that already has a player AND whose flag is
unset on the test device.

- [ ] On a **fresh iOS Simulator, or Android with app data cleared**, SIGN IN
      (not sign up) with an account that already has ≥1 player. The account
      from section A now has one, so it works. A plain iPhone REINSTALL may not
      - iOS keeps `flutter_secure_storage` in the Keychain across reinstalls,
      so the `whatsNew2Seen` flag can survive. Simulator / Android-clear-data
      wipes it reliably.
- [x] The **What's new in 2.0** sheet appears once, over Today, and never again
      after dismissing (relaunch to confirm). Logic verified; the sheet was
      confirmed working on other accounts. `support@courtsideiq.app` is a
      first-run account, so its suppression on the test phone is correct.
- [ ] Confirm the guided first-run does NOT also fire (the account has a
      player, so it is not new).

## C. The core journey (online, premium-by-default)  — VERIFIED 2026-07-26

Fixes this pass: neutral (not orange) delta chips, a toast on Edit Player, a
tab tap lands on its section root, the saved game appears immediately, the New
Game setup guides player-first, and the Development tab loads fast (narrative
pre-generated on save) with a named skeleton for the wait.

- [x] Add a player, with and without a birth date.
- [x] New Game: setup → live tracker → complete → save → Game Detail.
- [x] Game Detail: insight card, tier badges, share sheet, Remove Game.
- [x] Player Profile: all three tabs, Full Breakdown, both info sheets, the
      age-band notice. (**View Trends is deferred to post-2.0.0** - roadmap 3.5.
      Its button is hidden on purpose; do NOT log its absence as a bug.)
- [x] Menu: edit name, edit email, change password (including a rejected
      current password), Help Center, Send Feedback.
- [x] Toasts: **account** Edit Name → success, **account** Edit Email →
      neutral, error → see D. Editing a PLAYER (Edit Player) now also shows a
      "Player updated." success toast.

## D. Offline (wifi OFF, physical device)  — VERIFIED 2026-07-26

Beyond the checklist, this pass added the app-wide OFFLINE BANNER (the app
needs a connection, like a social app; in-progress tracking is the exception)
and an offline notice on New Game setup.

- [x] Track a full game with the network down. Stats must keep recording.
- [x] Save it offline → confirm it is queued and the copy says it will sync.
- [x] Restore the network → confirm it syncs and appears in Games.
- [x] **Offline game DOES get its insight on sync** (was logged as a gap; that
      note was stale — closed 2026-07-22). `uploadPendingGame` upserts the rows
      then calls `generateGameInsight`, and the queue runs that same uploader on
      both the immediate save and the delayed flush, so a game synced days later
      gets its per-game insight. Verified on device 2026-07-26.
- [x] Error toast: with the network down, Send Feedback → orange dot, ~5s.

## E. Force-quit and resume  — VERIFIED 2026-07-26

- [x] Start a game, record several stats, force-quit mid-game.
- [x] Relaunch → the resume prompt offers the in-progress game and restores
      the stat line.
- [x] Resume, finish, save. Confirm no duplicate game is created.

## F. Growth IQ edge cases  — MOSTLY VERIFIED 2026-07-26

Needs seeded data, so expect to add games in bulk.

- [x] Fewer than 5 games → no score, the below-threshold state shows instead.
- [x] Exactly 5 games → the score activates.
- [x] A declining run → the delta reads down, and the copy stays encouraging.
- [~] Age-band change → the Growth IQ NUMBER re-normalizes to the new band.
      This is correct: product decision #4 is "freeze earned ratings, NORMALIZE
      trends," and Growth IQ is a trend. Verified on device 2026-07-26 (the
      number moved and the direction was right). OPEN: the other half of the
      rule — earned per-game tier badges must NOT retroactively downgrade, and
      the Age-Band Transition banner (Figma 687:2742) must mark the change. No
      freeze/snapshot-band logic found in code; banner not confirmed built.
      Track separately before cutover; not a blocker for the Growth IQ number.
- [~] A zero-performance game → NO impact on the rating. FIXED 2026-07-26
      (growth_iq.dart now drops all-null games before windowing; a zero game
      used to lift the score by evicting a real game from the window). Unit
      tests cover it; needs a device re-check (log a zero game, score unchanged).

## G. Entitlement states

**Read this before testing:** on test, the `subscriptions` table is EMPTY by
deliberate decision, so `is_premium()` returns false for everyone and the
paywall bypass is open. The RLS limit is built and verified but has no data to
act on. So "free" behaviour here is not what prod will do after the 4.20a
backfill — verify the UI, and treat enforcement as unverified until then.

- [x] Fresh / never subscribed → paywall entry points, gate sheet, upgrade
      banner. Verified 2026-07-26. NOTE two design gaps found and sent to a
      Figma pass (not blockers): the gate sheet omits the "Free includes 1
      player" reason, and the paywall lacks a static headline. See below.
- [x] Premium → no locks, no banners, paywall shows the Already-Premium state.
      Verified 2026-07-26 via `kDebugForceEntitlement = .premium`.
- [x] Lapsed → the lapse banner and its "Renew" wording. Verified 2026-07-26
      via `kDebugForceEntitlement = .lapsed` (all four surfaces: Today, Players
      list, Player profile, Menu "Expired").
- [N/A] Billing issue → NO dedicated state exists. `EntitlementStatus` is
      three-way (premium / lapsed / never); a billing grace period keeps the
      RevenueCat entitlement active (renders premium), and post-grace it lapses.
      Nothing distinct to verify.
- [x] A real sandbox purchase (device + sandbox account only). Completed
      2026-07-26 — subscription landed and the account reads Premium. TWO issues
      found (see below): the processing state is a full-screen swap not an
      overlay, and a purchase that granted the entitlement still showed the
      plans-load error screen.

**Design follow-ups from the G pass — BUILT + unit-tested 2026-07-26, device-verify pending:**
- [x] Gate sheet reason line → "You're at your 1 free player. Premium tracks up
  to 3." (uses kFreePlayerLimit/kPremiumPlayerLimit; replaces the generic line).
- [x] Paywall static headline "Go Premium" (h2 at 30pt, a little larger than
  the carousel headlines), left at the gutter, moved INTO the centred block so
  it sits snug above the feature shot (was floating with too much gap).
- [x] Delete-account confirm dialog shortened to "Delete forever?" /
  "This can't be undone." (reverses the old restate-the-loss decision).
- [x] Paywall Processing → scrim overlay (ModalBarrier + spinner) over the
  still-visible paywall, not a full-screen swap.
- [x] Paywall purchase-failure copy → "That didn't go through." /
  "You have not been charged.", distinct from the plans-load error.

DEVICE RE-CHECK for this batch: gate sheet copy when adding past the cap;
headline on the paywall; delete dialog; the processing overlay dims the paywall
rather than replacing it; a genuinely failed purchase reads "not charged".

**Bug found in G (sandbox purchase) — FIXED 2026-07-26 (logic, not design):**
- A purchase that GRANTS the entitlement can still return `PurchaseOutcome.failed`
  (sandbox "already subscribed" throws a code other than
  productAlreadyPurchasedError), sending the user to the error screen while the
  account is actually Premium. FIXED: `_buy()` now re-checks `isPremium()` on a
  `failed` outcome and hands off as success if premium. Covered by a new test
  ("a failed outcome that still granted premium hands off, no error").
  Undeployed code change; device re-check on a fresh build still worthwhile.

## H. Destructive, last  — VERIFIED 2026-07-26

- [x] Delete account. Confirmed via DB (throwaway qrobinson75154@gmail.com):
      auth.users row gone, players/games/stats all cascaded to 0, and the
      feedback row survived with its email nulled (row 26 exists, email null).
- [x] Confirm the app returns to a clean signed-out state, not a broken shell.
      Device-verified: landed on sign-in, no lingering nav bar, stayed signed
      out after relaunch.
- [ ] COPY (Figma-first, see design follow-ups): the confirm-dialog message
      restates the loss the page already explained and reads as redundant. Make
      it a crisp final gut-check ("Delete forever?" / "This can't be undone.")
      rather than a second explanation. NOTE this reverses the earlier
      deliberate choice in delete_account_page.dart:62-64 to restate the loss.

---

## Re-run triggers

Re-run the affected sections when any of these land, because each one changes
what "what ships" means:

- **4.19f (nav shell + transitions)** — re-run A, B, C. It changes navigation
  structure and every screen transition.
- **4.24 (delete `lib/pages/`)** — re-run EVERYTHING. A missed route surfaces
  as a crash, and that is the whole point of doing it again.
- **4.20a (prod subscriptions backfill)** — re-run G against real enforcement.
