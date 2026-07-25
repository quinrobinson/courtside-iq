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

## C. The core journey (online, premium-by-default)

- [ ] Add a player, with and without a birth date.
- [ ] New Game: setup → live tracker → complete → save → Game Detail.
- [ ] Game Detail: insight card, tier badges, share sheet, Remove Game.
- [ ] Player Profile: all three tabs, Full Breakdown, both info sheets, the
      age-band notice. (**View Trends is NOT built** - scoped out of 4.11, its
      button is hidden on purpose. Pending a build/defer decision.)
- [ ] Menu: edit name, edit email, change password (including a rejected
      current password), Help Center, Send Feedback.
- [ ] Toasts: **account** Edit Name → success, **account** Edit Email →
      neutral, error → see D. Editing a PLAYER (Edit Player) now also shows a
      "Player updated." success toast.

## D. Offline (wifi OFF, physical device)

- [ ] Track a full game with the network down. Stats must keep recording.
- [ ] Save it offline → confirm it is queued and the copy says it will sync.
- [ ] Restore the network → confirm it syncs and appears in Games.
- [ ] **Known gap, do not log as new:** a game queued offline never receives
      its AI insight. Generation needs a server row, so it is skipped while
      offline and the later sync does not trigger it. Logged against 4C.
- [ ] Error toast: with the network down, Send Feedback → orange dot, ~5s.

## E. Force-quit and resume

- [ ] Start a game, record several stats, force-quit mid-game.
- [ ] Relaunch → the resume prompt offers the in-progress game and restores
      the stat line.
- [ ] Resume, finish, save. Confirm no duplicate game is created.

## F. Growth IQ edge cases

Needs seeded data, so expect to add games in bulk.

- [ ] Fewer than 5 games → no score, the below-threshold state shows instead.
- [ ] Exactly 5 games → the score activates.
- [ ] A declining run → the delta reads down, and the copy stays encouraging.
- [ ] Age-band crossing → ratings freeze per the product rule rather than
      silently re-rating history.
- [ ] A zero-performance game → NO rating at all, not a "zero" rating.

## G. Entitlement states

**Read this before testing:** on test, the `subscriptions` table is EMPTY by
deliberate decision, so `is_premium()` returns false for everyone and the
paywall bypass is open. The RLS limit is built and verified but has no data to
act on. So "free" behaviour here is not what prod will do after the 4.20a
backfill — verify the UI, and treat enforcement as unverified until then.

- [ ] Fresh / never subscribed → paywall entry points, gate sheet, upgrade
      banner.
- [ ] Premium → no locks, no banners, paywall shows the Already-Premium state.
- [ ] Lapsed → the lapse banner and its "Renew" wording.
- [ ] Billing issue → the correct state, not a generic error.
- [ ] A real sandbox purchase (device + sandbox account only). Restore
      purchases with nothing to restore → neutral toast.

## H. Destructive, last

- [ ] Delete account. Confirm the account and its data are gone, and that the
      feedback row survives with its email nulled.
- [ ] Confirm the app returns to a clean signed-out state, not a broken shell.

---

## Re-run triggers

Re-run the affected sections when any of these land, because each one changes
what "what ships" means:

- **4.19f (nav shell + transitions)** — re-run A, B, C. It changes navigation
  structure and every screen transition.
- **4.24 (delete `lib/pages/`)** — re-run EVERYTHING. A missed route surfaces
  as a crash, and that is the whole point of doing it again.
- **4.20a (prod subscriptions backfill)** — re-run G against real enforcement.
