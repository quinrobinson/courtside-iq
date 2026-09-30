// The one-line game summary shown on game rows (Today, Games, a player's
// Games tab). Quin, 2026-09-30: the row must be a headline, not the insight
// cut short. The full insight stays on Game Detail.
//
// RULES, mirrored in lib/courtside_iq/game_row_meaning.dart (kSummaryMaxChars
// and cleanSummary). Change both together.
//   - at most SUMMARY_MAX_CHARS characters: two lines on the narrowest phone,
//     so the row never truncates
//   - no player name and no leading "He/She/You": the rows stack, and the name
//     on every one was redundant
//   - sentence case, no closing period, no em dash

// Measured in the app at 360pt (test/game_row_summary_fit_test.dart): the
// hard limit is 52. The model is asked for SUMMARY_TARGET_CHARS to leave room.
export const SUMMARY_MAX_CHARS = 52;
export const SUMMARY_TARGET_CHARS = 50;

/// Cleans a model-written summary. Null when nothing usable is left or it is
/// still over the limit, in which case the app derives a line itself.
export function cleanSummary(
  raw: unknown,
  firstName: string | null,
): string | null {
  if (typeof raw !== "string") return null;
  let s = raw.trim().replace(/\s*—\s*/g, ", ");
  if (firstName) {
    const name = firstName.trim();
    if (name) {
      const esc = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      s = s.replace(new RegExp(`^${esc}(?:['’]s)?\\s+`, "i"), "");
    }
  }
  s = s.replace(/[.!\s]+$/, "").trim();
  if (!s) return null;
  s = s[0].toUpperCase() + s.slice(1);
  return s.length <= SUMMARY_MAX_CHARS ? s : null;
}
