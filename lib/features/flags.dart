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

/// Bottom navigation, rebuilt on the 2.0 design system.
///
/// Shared chrome across Home, Players, Games and Menu, so this is the flag
/// that makes those four stop looking half-migrated. It also FIXES A REAL
/// DEFECT: the v1 bar pushes tabs onto the stack instead of switching between
/// them.
const bool kUseNavBar2 = true;

/// Players list, rebuilt on the 2.0 design system (4.11a).
///
/// ON FOR REVIEW, NOT YET VERIFIED. The v1 PlayersListWidget stays reachable
/// by turning it off.
const bool kUsePlayers2 = true;

/// Splash (Dot Burst) and Onboarding x3.
///
/// ON FOR REVIEW, NOT YET VERIFIED. Also swaps the loading splash, so a
/// regression here is visible on every cold start.
const bool kUseEntry2 = true;
