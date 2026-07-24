// Courtside IQ 2.0 — screen flags (Phase 4C)
//
// One flag per 2.0 screen, all in one file, ALL DELETED IN 4.24.
//
// Why a registry rather than a const beside each screen: 4C replaces every v1
// screen, and 4.24 removes the coexistence scaffold entirely. A flag living
// next to its feature is fine when there is one of them; at nine it becomes a
// hunt, and the failure mode is a flag that survives the cutover and silently
// keeps a v1 page reachable in the shipped app. One file makes 4.24 a deletion
// instead of a search.
//
// Every flag here means the same thing: TRUE routes to the 2.0 screen, FALSE
// falls back to the FlutterFlow page. The fallback is what makes it safe to
// merge a half-finished flow - anything that regresses mid-phase gets switched
// off without a revert.
//
// Flags default to FALSE until their screen is device-verified. Flipping one
// on is the last step of building it, not the first.

/// Home / Today. Shipped and verified; the v1 HomeWidget is still reachable
/// behind it until 4.24.
const bool kUseDashboardV2 = true;

// --- 4.9 Entry/Auth ----------------------------------------------------------

/// Email Auth (Sign In / Sign Up / Validation Error).
///
/// Device-verified 2026-07-19: sign in and sign up both work end to end
/// against test Supabase.
const bool kUseAuth2 = true;

/// Auth Landing, including Google and Apple sign-in.
///
/// ON FOR REVIEW, NOT YET VERIFIED. The Google and Apple paths call the real
/// providers, so no test can exercise them - both have to be tapped on a
/// device. Turn this back off if either fails.
const bool kUseAuthLanding2 = true;

/// Forgot Password, Reset Password, Reset Successful.
///
/// ON FOR REVIEW, NOT YET VERIFIED. Needs a real recovery email opening the
/// app via courtsideiq://reset-password. Turn back off if the link does not
/// open the app - a half-working recovery flow is worse than none.
const bool kUsePasswordReset2 = true;

/// Today, rebuilt on the 2.0 design system (4.10a).
///
/// ON FOR REVIEW, NOT YET VERIFIED. The existing DashboardPage stays live
/// behind kUseDashboardV2 and is untouched, so flipping this back is a
/// one-line revert to a working screen.
const bool kUseToday2 = true;

/// Guided first-run (4.9). After a new parent signs up and confirms their
/// email, a two-step Welcome -> Add first player flow, shown ONCE (zero
/// players, not seen before) and skippable. It wraps the 2.0 Today via a gate,
/// so it only runs when [kUseToday2] is on; off falls straight through to
/// Today's own "add your first player" empty state, so this is a safe revert.
const bool kUseFirstRun = true;

/// "What's new in 2.0" upgrade sheet (4.19c). A one-time dark takeover shown to
/// EXISTING v1 users on their first 2.0 landing: a DotBurst hero and four rows
/// (data safe, Growth IQ, development story, faster tracker). Wraps Today via a
/// gate, mutually exclusive with the guided first-run, so a brand-new parent
/// never sees it. Off falls straight through to Today - a safe revert.
const bool kUseWhatsNew2 = true;

/// Bottom navigation, rebuilt on the 2.0 design system.
///
/// Shared chrome across Home, Players, Games and Menu, so this is the flag
/// that makes those four stop looking half-migrated. It also FIXES A REAL
/// DEFECT: the v1 bar pushes tabs onto the stack instead of switching between
/// them.
const bool kUseNavBar2 = true;

/// Persistent bottom-nav shell (4.19f).
///
/// Puts Home, Players, Games and Menu inside a StatefulShellRoute so ONE
/// CiNavBar survives a tab change instead of every screen rendering its own.
/// Before this, `goNamed` replaced the whole scaffold - bar included - so the
/// nav visibly reloaded and animated on every tab, which is the tell that made
/// the app feel like a web page rather than an app. The indexed stack also
/// keeps each tab's scroll position and state.
///
/// DERIVED, NOT SET BY HAND. The shell owns the bar for all four tabs at once,
/// so it can only be on when all four tabs are the 2.0 screens - a v1 fallback
/// renders its own FlutterFlow nav and would show a second bar under this one.
/// Reverting any one tab flag therefore disengages the shell automatically and
/// restores the per-screen bars.
const bool kUseNavShell =
    kUseToday2 && kUsePlayers2 && kUseGames2 && kUseMenu2;

/// Players list, rebuilt on the 2.0 design system (4.11a).
///
/// ON FOR REVIEW, NOT YET VERIFIED. The v1 PlayersListWidget stays reachable
/// by turning it off.
const bool kUsePlayers2 = true;

/// Player Profile, rebuilt on the 2.0 design system (4.11b).
///
/// DEVICE-VERIFIED 2026-07-21. All three tabs, Full Breakdown, both info
/// sheets, the age-band notice and the lapse strip are 2.0.
///
/// PlayerProfilePageV2 stays reachable by turning this off - which is also how
/// to get the Games tab's event filter and insight spark back, since neither
/// is in the 2.0 frame.
const bool kUseProfile2 = true;

/// Splash (Dot Burst) and Onboarding x3.
///
/// ON FOR REVIEW, NOT YET VERIFIED. Also swaps the loading splash, so a
/// regression here is visible on every cold start.
const bool kUseEntry2 = true;

/// Add Player, rebuilt on the 2.0 design system (4.11d).
///
/// ON FOR REVIEW, NOT YET VERIFIED. This one carries a DATA change as well as
/// a re-skin - last name is collected, birth date becomes optional - so
/// turning it off restores both the old UI and the old required-fields rule.
const bool kUseAddPlayer2 = true;

/// Edit Player, rebuilt on the 2.0 design system (4.11d).
///
/// ON FOR REVIEW, NOT YET VERIFIED. Covers identity, photo, delete, and teams
/// and events - the last two behind rows that open sheets. Nothing from the
/// v1 screen is left behind, so this flag is a pure rollback rather than a
/// feature trade.
const bool kUseEditPlayer2 = true;

/// Games list, rebuilt on the 2.0 design system (4.12).
///
/// ON FOR REVIEW, NOT YET VERIFIED. Also FIXES A REAL DEFECT: the v1 list
/// ordered created_at ASCENDING, so it opened on the oldest game a parent had
/// ever logged. Turning this off restores that.
const bool kUseGames2 = true;

/// New Game, rebuilt on the 2.0 design system (4.13).
///
/// DEVICE-VERIFIED 2026-07-22. Setup, the live tracker, pause, complete,
/// save, the offline queue, and resuming a game after a force-quit.
///
/// Turning it off returns to v1's setup AND tracker together, which is the
/// only safe rollback: the two halves do not mix. It also gives up resume -
/// v1 resumes through a client-state flag with no game id.
const bool kUseNewGame2 = true;

/// Game Detail, rebuilt on the 2.0 design system (4.14).
///
/// DEVICE-VERIFIED 2026-07-23 on iPhone: all three entry points, a
/// low-volume game correctly showing stats without ratings, and Remove Game.
///
/// Switched at the ROUTE rather than at the
/// five places that push it, so every entry point moves together and none can
/// be left behind - which is exactly how the AddPlayerSheet got lost between
/// 1.2 and 1.12.
///
/// It also carries a BEHAVIOUR CHANGE: Remove Game is offered to free users,
/// where v1 hid it for anyone without a subscription. Approved 2026-07-23 on
/// the reasoning that deleting games to stay under the free limit is already
/// working around the product rather than exploiting it. Turning this flag
/// off restores the v1 gate along with the v1 screen.
const bool kUseGameDetail2 = true;

/// Menu and Your Profile, rebuilt on the 2.0 design system (4.15a).
///
/// DEVICE-VERIFIED 2026-07-23 on iPhone: Menu, Your Profile, Edit Name, Edit
/// Email and Change Password, including a rejected current password and a
/// successful change.
///
/// 4.15c device-verified 2026-07-23: Help Center and Send Feedback, with a
/// note reaching the feedback table.
///
/// DEVICE-VERIFIED 2026-07-23 including Delete Account (4.15d), which deletes
/// via the delete_current_user rpc and was confirmed in the database: the
/// account and all its data gone, the feedback note kept with its email
/// nulled. The photo badge stays inert - public.users has no column for one.
const bool kUseMenu2 = true;

/// Paywall + gate sheet (4.16).
///
/// ON FOR REVIEW, NOT YET VERIFIED. Covers the carousel, its purchase states,
/// and the gate sheet. Off falls back to the v1 PaywallWidget bottom sheet.
/// A REAL PURCHASE is device + sandbox only; the flag gates the UI, not the
/// entitlement - server-side enforcement stays deferred to cutover.
const bool kUsePaywall2 = true;

// Premium locks on the player profile (4.17) have NO flag of their own: the
// lock rides on the entitlement the profile already reads, whose default is
// PREMIUM, so a subscriber never sees a lock flash while RevenueCat is still
// answering. Turning kUsePaywall2 off leaves the lock but sends its tap to
// the v1 paywall.
