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
/// This one gates the only way an existing user gets into the app. It stays
/// false until sign-in, sign-up, and a real password reset have been run on a
/// device against test Supabase.
const bool kUseAuth2 = false;

/// Auth Landing, including Google and Apple sign-in.
const bool kUseAuthLanding2 = false;

/// Forgot Password, Reset Password, Reset Successful.
const bool kUsePasswordReset2 = false;

/// Splash (Dot Burst) and Onboarding x3.
const bool kUseEntry2 = false;
