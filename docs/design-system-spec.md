# Courtside IQ — Design System Spec (v1.5)

Compact reference for the Courtside IQ design system. Source of truth lives in `docs/courtside-iq-design-system.html` (visual) and `lib/courtside_iq/design_tokens.dart` (code). This file is the grep-friendly summary for use during code work.

---

## Principles

1. **Development-first messaging.** Numbers earn their place by connecting to growth. Never surface a stat without a development frame.
2. **Tight, modular spacing.** Cards sit 8px apart. Inner padding is 16–20px. We are not Material.
3. **Hairlines over shadows.** Every card has a 1px hairline. Shadows are reserved for things that genuinely float.
4. **One hero color, four accents.** Jade is the dominant brand presence. Royal/Steel/Rose/Spark are moments — one per screen, max.
5. **Nested radius rule.** Child radius = parent radius − 2 to − 4. A 6px card contains 4px sub-pills, which contain 2px chips.
6. **Tier hierarchy stays consistent.** Solid → Good → Elite + Room to Grow. Solid is entry-level, never negative.
7. **The inversion.** Hero numerals at weight 400, labels at weight 700. The contrast does the work, not the thinness.

---

## Color tokens

### Brand
| Token | Hex | Role |
|---|---|---|
| `jade50` | `#E6F7F2` | Tag backgrounds, subtle fills |
| `jade500` | `#0FA889` | **HERO.** Primary brand. Default fills. |
| `jade600` | `#0C8C72` | Hover/pressed states |
| `jade700` | `#0A7058` | Tag text, dark accents |
| `royal50` | `#EFE9FB` | AI tag backgrounds |
| `royal500` | `#6B35C9` | **ACCENT.** AI insights only. 1×/screen. |
| `royal600` | `#5827A8` | Hover, dark accents |
| `steel500` | `#2558B8` | **ACCENT.** Backup data series. |
| `rose500` | `#E04867` | **ACCENT.** "Room to Grow" only. |
| `spark500` | `#F2A43A` | **ACCENT.** Elite tier only. Most restricted. |

### Surface
| Token | Hex | Role |
|---|---|---|
| `canvas` | `#EFEFF1` | Page background |
| `canvasSunk` | `#E5E5E8` | Sunken sections, hover states |
| `surface` | `#FFFFFF` | Default card background |
| `surfaceAlt` | `#F7F7F9` | Inner chips, secondary button fill |
| `hairline` | `#E2E2E5` | 1px borders |

### Ink
| Token | Hex | Role |
|---|---|---|
| `ink` | `#1B1D24` | Primary text |
| `ink2` | `#4A4D56` | Body, descriptions |
| `ink3` | `#797B85` | Captions, meta |
| `ink4` | `#ABADB5` | Disabled, placeholder |
| `inkOnBrand` | `#FFFFFF` | Text on brand-color backgrounds |

---

## Spacing (4px base, 8px rhythm)

| Token | Value | Use |
|---|---|---|
| `s1` | 4 | Icon-to-text gaps inside tags |
| `s2` | **8** | **DEFAULT card-to-card gap** |
| `s3` | 12 | Roomier card gap when sections need breathing |
| `s4` | 16 | Card inner padding (tight) |
| `s5` | 20 | Card inner padding (standard) |
| `s6` | 24 | Section breaks within a screen |
| `s8` | 32 | Major section breaks |
| `s10` | 40 | Top-of-screen padding |
| `s12` | 48 | Bottom safe-area + tab bar offset |

---

## Radius

| Token | Value | Use |
|---|---|---|
| `xs` | 2 | Status dots, micro-tags |
| `sm` | 4 | **Tags, chips, buttons, inner pills** |
| `md` | 6 | **Default card. Sub-cards.** |
| `lg` | 8 | Group containers, larger cards |
| `xl` | 12 | Sheets, modals, hero containers |
| `full` | 9999 | Avatars, tab bar pill, status dots |

**Nesting rule:** child = parent − 2 to − 4. A 6px card contains 4px elements which contain 2px elements.

---

## Typography (DM Sans)

| Token | Weight / Size / Line | Use |
|---|---|---|
| `displayLg` | 400 / 56 / 1.0 | Page hero stat (rare) |
| `displayMd` | 400 / 40 / 1.05 | Card hero number (most common) |
| `displaySm` | 400 / 28 / 1.1 | Section number, score |
| `h1` | 700 / 22 / 1.25 | Screen title |
| `h2` | 700 / 17 / 1.3 | Card title |
| `h3` | 600 / 14 / 1.35 | Group label, sub-card title |
| `body` | 400 / 14 / 1.5 | Body text |
| `bodyStrong` | 500 / 14 / 1.5 | Body, emphasized |
| `small` | 400 / 13 / 1.45 | Secondary copy, descriptions |
| `caption` | 500 / 11 / 1.3 | Tags, micro-meta |
| `eyebrow` | 700 / 10 / 1.2 | Uppercase, tracked labels |

**Numerals** (anything in `displayLg`, `displayMd`, `displaySm`, plus stat numbers in any size) use **tabular figures**: `fontFeatures: [FontFeature.tabularFigures()]`.

**Letter spacing**:
- Tight (`-0.02em`): hero numerals only
- Snug (`-0.015em`): headings
- Eyebrow (`+0.08em`): uppercase eyebrows and tags

---

## Elevation

| Token | Recipe | Use |
|---|---|---|
| `hairline` | 1px inset border | Inputs, sub-cards, list rows |
| `card` | 1px shadow + hairline | **DEFAULT for every card** |
| `pop` | 2 layered shadows | Bottom sheets, tooltips, dropdowns |
| `modal` | 2 deeper shadows | Full-screen sheets and modals |
| `hero` | Card + Royal-tinted shadow | Tier 5 cards only |

---

## Components

### Card hierarchy (5 tiers)
| Tier | Class | Use |
|---|---|---|
| 1 | `.ci-card` | Default white. 90% of cards. |
| 2 | `.ci-card-jade` | "This week's pattern" cards, weekly recaps. |
| 3 | `.ci-card-royal` | Development narrative, multi-game AI patterns. |
| 4 | `.ci-card-spark` | Personal best, milestone, peak moment. |
| 5 | `.ci-card-hero` | Headline takeover. Development snapshot. White text. |

**Hierarchy rule:** one climb per screen. Tier follows meaning, not preference.

### Buttons
| Class | Treatment |
|---|---|
| `ci-btn-primary` | **Ink (black)** background, white text. The decisive action. |
| `ci-btn-secondary` | `surfaceAlt` fill + hairline. Quiet peer to primary. |
| `ci-btn-ghost` | Transparent, `ink2` text. Cancel actions. |
| `ci-btn-ai` | RESERVED. No current use case. Held for future regeneration affordance. |

Button radius: `sm` (4px). Height: 44 default, 32 small.

### Tags
Single style at radius `sm` (4px). Variants: `solid`, `good`, `elite`, `grow`, `ai`, `muted`. Padding `4px 8px`. Caption-sized uppercase text.

### Tier dots (in metric tiles)
6px circle. Solid = `steel500`. Good = `jade500`. Elite = `spark500`. Grow = `rose500`.

---

## Tier-to-color mapping (semantic)

This mapping is invariant. Don't change without updating the system.

| Tier | Color | Tag bg | Tag text |
|---|---|---|---|
| Solid | Steel | `steel50` | `steel600` |
| Good | Jade | `jade50` | `jade700` |
| Elite | Spark | `spark50` | `spark600` |
| Room to Grow | Rose | `rose50` | `rose600` |
| AI Insight | Royal | `royal50` | `royal600` |

---

## Non-goals (do not violate during overhaul)

- No new components.
- No removed components.
- No layout changes.
- No functionality changes.
- Refactoring opportunities that aren't direct token swaps stay parked.

If you find code that *needs* refactoring beyond token application, add it to a `followups.md` file. Don't fix it in this pass.
