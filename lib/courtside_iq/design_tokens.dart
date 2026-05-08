// =============================================================================
// COURTSIDE IQ — DESIGN SYSTEM TOKENS
// Version: 1.5 (April 2026)
//
// Source of truth for colors, spacing, typography, radius, and elevation
// across the Courtside IQ app. Mirrors the canonical HTML design system at
// docs/courtside-iq-design-system.html.
//
// Token names map 1:1 to Figma Variables. Names use camelCase here to match
// Dart conventions; the underlying values match the CSS variables exactly.
//
// USAGE
// -----
// import 'package:courtside_iq/courtside_iq/design_tokens.dart';
//
// Container(
//   color: CIColors.canvas,
//   padding: EdgeInsets.all(CISpacing.s5),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(CIRadius.md),
//   ),
//   child: Text('Hello', style: CIType.h2),
// )
//
// PRINCIPLES (do not violate without updating the system)
// -------------------------------------------------------
// 1. Cards sit 8px apart (CISpacing.s2). Never 16+.
// 2. All non-circular elements use 6px radius (CIRadius.md). Circles/pills use CIRadius.full.
// 3. Hero numerals: weight 400. Labels: weight 700. The inversion is the rule.
// 4. Numbers in columns use tabular figures: TextStyle(fontFeatures: [FontFeature.tabularFigures()]).
// 5. Jade is hero. Royal/Steel/Rose/Spark are accents (one per screen, max).
// 6. Primary buttons are Ink (black). Not Jade.
// =============================================================================

import 'package:flutter/material.dart';

// =============================================================================
// COLORS
// =============================================================================

/// Color tokens. Five brand colors (Jade hero + 4 accents) and a cool-neutral
/// surface system. See [CIColorRoles] for semantic usage rules.
class CIColors {
  CIColors._();

  // ---- BRAND ---------------------------------------------------------------

  // Jade — HERO color. Primary actions, brand mark, default chart fills,
  // default trend-up indicator, "Solid" tier dot, success states.
  static const Color jade50 = Color(0xFFE6F7F2);
  static const Color jade100 = Color(0xFFC2EDDF);
  static const Color jade200 = Color(0xFF8FDBC2);
  static const Color jade500 = Color(0xFF0FA889); // primary brand
  static const Color jade600 = Color(0xFF0C8C72); // hover/pressed
  static const Color jade700 = Color(0xFF0A7058); // text on jade50

  // Royal — ACCENT. AI insights only. ONE per screen, max.
  static const Color royal50 = Color(0xFFEFE9FB);
  static const Color royal100 = Color(0xFFDCCEF6);
  static const Color royal500 = Color(0xFF6B35C9);
  static const Color royal600 = Color(0xFF5827A8);

  // Steel — ACCENT. Backup data color. Use only when Jade is already in use
  // on the same chart (e.g. multi-series comparisons).
  static const Color steel50 = Color(0xFFE7EEFA);
  static const Color steel100 = Color(0xFFC7D6F2);
  static const Color steel500 = Color(0xFF2558B8);
  static const Color steel600 = Color(0xFF1D4595);

  // Rose — ACCENT. "Room to Grow" framing only. Apply with restraint
  // so the tone stays encouraging, not alarming.
  static const Color rose50 = Color(0xFFFCE9ED);
  static const Color rose100 = Color(0xFFF7C9D2);
  static const Color rose500 = Color(0xFFE04867);
  static const Color rose600 = Color(0xFFB83954);

  // Spark — ACCENT. Elite tier and peak performances ONLY.
  // Most restricted color in the system.
  static const Color spark50 = Color(0xFFFDF1E0);
  static const Color spark100 = Color(0xFFFADFB7);
  static const Color spark500 = Color(0xFFF2A43A);
  static const Color spark600 = Color(0xFFC9852A);

  // ---- SURFACE -------------------------------------------------------------

  /// Page background. Cool neutral. Reads precise and dashboard-like.
  static const Color canvas = Color(0xFFF3F3F5);

  /// Sub-grouping inside cards. Tracks, sliders, hover states.
  static const Color canvasSunk = Color(0xFFE5E5E8);

  /// Default card background. Always carries a hairline.
  static const Color surface = Color(0xFFFFFFFF);

  /// Inner chips, sub-cards, secondary button fill.
  static const Color surfaceAlt = Color(0xFFF7F7F9);

  /// 1px borders. Use as inset border or 1px BoxDecoration border.
  static const Color hairline = Color(0xFFE2E2E5);

  // ---- INK (TEXT) ----------------------------------------------------------

  /// Primary text. Numbers, headlines, body copy.
  static const Color ink = Color(0xFF1B1D24);

  /// Secondary text. Body copy, descriptions.
  static const Color ink2 = Color(0xFF4A4D56);

  /// Tertiary text. Captions, meta.
  static const Color ink3 = Color(0xFF797B85);

  /// Disabled, placeholder.
  static const Color ink4 = Color(0xFFABADB5);

  /// Text on jade/royal/steel/rose/spark backgrounds + primary button.
  static const Color inkOnBrand = Color(0xFFFFFFFF);
}

/// Semantic color routing — describes WHERE each brand color is allowed.
/// Code that picks between brand colors should reason against this enum.
enum CIColorRoles {
  /// Jade — anywhere a screen needs life. Default fills, brand presence.
  hero,

  /// Royal — AI insight blocks only. ONE per screen.
  aiAccent,

  /// Steel — backup data color when Jade is already on the same chart.
  dataBackup,

  /// Rose — "Room to Grow" tier framing. Sparing.
  growEdge,

  /// Spark — Elite tier and personal-best moments only.
  peakMoment,
}

// =============================================================================
// SPACING
// =============================================================================

/// Spacing scale. 4px base, 8px rhythm. The signature: cards sit 8px apart
/// (s2) with 16-20px inner padding (s4 / s5).
class CISpacing {
  CISpacing._();

  static const double s1 = 4.0;
  static const double s2 = 8.0;   // DEFAULT card-to-card gap
  static const double s3 = 12.0;
  static const double s4 = 16.0;  // Tight card inner padding
  static const double s5 = 20.0;  // Standard card inner padding
  static const double s6 = 24.0;  // Section breaks within a screen
  static const double s8 = 32.0;  // Major section breaks
  static const double s10 = 40.0; // Top-of-screen padding
  static const double s12 = 48.0; // Bottom safe-area + tab bar offset
}

// =============================================================================
// RADIUS
// =============================================================================

/// Radius scale. Tight by design — matches reference shots and reads
/// dashboard-like rather than consumer-app-like.
///
/// Nesting rule: child radius = parent radius − 2 to − 4.
/// A 6px card contains 4px sub-pills, which contain 2px chips.
class CIRadius {
  CIRadius._();

  static const double xs = 6.0;   // (unified — all non-circular elements use 6px)
  static const double sm = 6.0;   // (unified — all non-circular elements use 6px)
  static const double md = 6.0;   // Universal non-circular radius
  static const double lg = 6.0;   // (unified — all non-circular elements use 6px)
  static const double xl = 6.0;   // (unified — all non-circular elements use 6px)

  // For circular elements (avatars, tab bar pill, status dots)
  static const double full = 9999.0;

  // Pre-built BorderRadius constants for convenience
  static final BorderRadius brXs = BorderRadius.circular(xs);
  static final BorderRadius brSm = BorderRadius.circular(sm);
  static final BorderRadius brMd = BorderRadius.circular(md);
  static final BorderRadius brLg = BorderRadius.circular(lg);
  static final BorderRadius brXl = BorderRadius.circular(xl);
}

// =============================================================================
// ELEVATION
// =============================================================================

/// Elevation tokens. Hairlines do most of the work in this system.
/// Shadows are reserved for things that genuinely float (modals, sheets,
/// the tab bar). Cards do not float — they sit.
class CIElevation {
  CIElevation._();

  /// 1px hairline, no shadow. Use for inputs, sub-cards, list rows.
  static List<BoxShadow> get hairline => [
        const BoxShadow(
          color: CIColors.hairline,
          spreadRadius: 1,
          blurRadius: 0,
          offset: Offset.zero,
        ),
      ];

  /// Default card elevation. Subtle shadow + hairline. Use for every card.
  static List<BoxShadow> get card => [
        const BoxShadow(
          color: Color(0x0A1B1D24), // rgba(27,29,36,0.04)
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];

  /// Pop elevation. For bottom sheets, tooltips, dropdowns, popovers.
  static List<BoxShadow> get pop => [
        const BoxShadow(
          color: Color(0x141B1D24), // rgba(27,29,36,0.08)
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
        const BoxShadow(
          color: Color(0x261B1D24), // rgba(27,29,36,0.10)
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

  /// Modal elevation. Full-screen sheets and modals.
  static List<BoxShadow> get modal => [
        const BoxShadow(
          color: Color(0x0F1B1D24), // rgba(27,29,36,0.06)
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
        const BoxShadow(
          color: Color(0x291B1D24), // rgba(27,29,36,0.16)
          blurRadius: 48,
          offset: Offset(0, 24),
        ),
      ];

  /// Hero card elevation. Used by Tier 5 (hero) cards only.
  /// Royal-tinted shadow for lift on the gradient surface.
  static List<BoxShadow> get hero => [
        const BoxShadow(
          color: Color(0x0A1B1D24),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
        const BoxShadow(
          color: Color(0x2E6B35C9), // rgba(107,53,201,0.18)
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];
}

// =============================================================================
// TYPOGRAPHY
// =============================================================================

/// Typography scale. DM Sans across the system.
///
/// THE INVERSION: Hero numerals at weight 400, labels at weight 700.
/// Numbers feel light RELATIVE TO bold labels. Don't break this rhythm —
/// it's the single most important typographic decision in the system.
///
/// All numeric styles include tabular figures so columns line up.
class CIType {
  CIType._();

  static const String fontFamily = 'DM Sans';

  // Numeral and label weights — referenced for clarity in custom builds
  static const FontWeight weightNumeral = FontWeight.w400;
  static const FontWeight weightLabel = FontWeight.w700;

  // Tabular figures — applied to all display/numeric styles
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ---- DISPLAY (light hero numerals) ---------------------------------------

  /// Page hero stat. Use sparingly — once per screen.
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: weightNumeral,
    height: 1.0,
    letterSpacing: -1.12, // -0.02em of 56
    color: CIColors.ink,
    fontFeatures: _tabular,
  );

  /// Card hero number. Most common display style.
  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: weightNumeral,
    height: 1.05,
    letterSpacing: -0.80, // -0.02em of 40
    color: CIColors.ink,
    fontFeatures: _tabular,
  );

  /// Section number, score.
  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: weightNumeral,
    height: 1.1,
    letterSpacing: -0.56, // -0.02em of 28
    color: CIColors.ink,
    fontFeatures: _tabular,
  );

  // ---- HEADINGS (heavy, anchors layout) ------------------------------------

  /// Screen title.
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: weightLabel,
    height: 1.25,
    letterSpacing: -0.33, // -0.015em of 22
    color: CIColors.ink,
  );

  /// Card title.
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: weightLabel,
    height: 1.3,
    letterSpacing: -0.26, // -0.015em of 17
    color: CIColors.ink,
  );

  /// Group label, sub-card title.
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: CIColors.ink,
  );

  // ---- BODY ----------------------------------------------------------------

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: CIColors.ink2,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: CIColors.ink,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: CIColors.ink2,
  );

  /// Tags, micro-meta. Uppercase via TextStyle is fine for short strings;
  /// for longer text, use Text(value.toUpperCase()).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: CIColors.ink3,
  );

  /// Eyebrow labels. Always uppercase, tracked.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.8, // 0.08em of 10
    color: CIColors.ink3,
  );
}

// =============================================================================
// CARD HIERARCHY (Tier 1-5 reference)
// =============================================================================

/// Card emphasis tiers. The white default (tier 1) handles 90% of cards.
/// Each tier above maps to a specific kind of moment. Tier follows meaning,
/// not preference.
///
/// To apply a tier, use the corresponding background gradient in BoxDecoration.
/// See CICardDecorations for pre-built BoxDecoration values.
enum CICardTier {
  /// Default white card. 90% of usage.
  defaultTier,

  /// "This week's pattern" cards, weekly recap moments.
  jadeGlow,

  /// Development narrative card, multi-game pattern AI insights.
  royalGlow,

  /// Personal best, milestone, peak moment.
  sparkGlow,

  /// Elite-level performance. Best-in-tier metric result.
  steelGlow,

  /// Headline takeover. Development snapshot. ONE per screen, often zero.
  hero,
}
