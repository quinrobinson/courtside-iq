# FF Visual Editor — Radius Changes (v1.5 Design System)

All custom code surfaces (`lib/features/`, `lib/custom_code/`) have been migrated to
`CIRadius` tokens in code. The screens below live in `lib/pages/` (FlutterFlow-generated)
and must be updated in the FF visual editor.

## Token reference

| Token | Value | Use |
|---|---|---|
| `CIRadius.sm` | 4px | Tags, chips, inner pills |
| `CIRadius.md` | 6px | Default cards, sub-cards |
| `CIRadius.lg` | 8px | Group containers, larger cards |
| `CIRadius.xl` | 12px | Sheets, modals, hero containers |
| `CIRadius.full` | 9999px | Avatars, circular elements |

> **Nesting rule:** child radius = parent radius − 2. A card at 8px contains sub-tiles at 6px.

---

## Global components (used on every screen)

### Custom Nav Bar (`custom_nav_bar_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Floating pill container (330×60) | 18px | 12px | `xl` |

### Paywall sheet (`paywall_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Sheet container (top corners) | 18px | 12px | `xl` |
| Pro badge / icon container | 18px | 12px | `xl` |
| CTA button | 18px | 12px | `xl` |
| Plan toggle chip | 8px | 8px | `lg` ✓ (no change) |

---

## Players screens

### Players List (`players_list_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Player card container | 12px | 8px | `lg` |
| Stat tile (FG%, FT%, etc.) | 6px | 6px | `md` ✓ (no change) |
| Player avatar (46×46 circle) | 23px | 9999px | `full` |
| Filter chip / tag | 4px | 4px | `sm` ✓ (no change) |

### Player Profile — FF version (`players_profile_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Section card container | 12px | 8px | `lg` |
| Sub-card / stat tile | 6px | 6px | `md` ✓ (no change) |

### New Player sheet (`new_player_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Sheet container (top corners) | 24px | 12px | `xl` |
| Input field | 12px | 8px | `lg` |
| Avatar circle (handle bar) | 3px | 2px | `xs` |

---

## Games screens

### All Games (`all_games_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Game card container | 12px | 8px | `lg` |
| Stat tile | 6px | 6px | `md` ✓ (no change) |
| Player avatar circle | 23px | 9999px | `full` |
| Filter chip | 4px | 4px | `sm` ✓ (no change) |
| Event badge | 8px | 4px | `sm` |

### Game Stats (`game_stats_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Stat value tile | 6px | 6px | `md` ✓ (no change) |
| Section card | 12px | 8px | `lg` |
| Player avatar (80×80 circle) | 45px | 9999px | `full` |
| Metric gauge / pill container | 18px | 8px | `lg` |

### New Game sheet (`new_game_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Sheet container (top corners) | 12px | 12px | `xl` ✓ (no change) |
| Input field | 8px | 8px | `lg` ✓ (no change) |
| Player avatar circle | 23px | 9999px | `full` |

### Game Stat Tracker (`game_stat_tracker_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Stat button / tile | 12px | 8px | `lg` |
| Sub-element | 6px | 6px | `md` ✓ (no change) |
| Misc (5px) | 5px | 4px | `sm` |

### Game Stat Sheet (`game_stat_sheet_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Sheet card / container | 6px | 6px | `md` ✓ (no change) |
| Player avatar circle | 45px | 9999px | `full` |
| Sheet container (top) | 12px | 12px | `xl` ✓ (no change) |
| Handle bar | 3px | 2px | `xs` |

### Create New Game (`create_new_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Card / container | 12px | 8px | `lg` |

---

## Menu screens

### Menu (`menu_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Menu row card | 12px | 8px | `lg` |
| Icon container | 6px | 6px | `md` ✓ (no change) |
| Tag / chip | 4px | 4px | `sm` ✓ (no change) |

---

## Home screen (FF version — currently behind `kUseDashboardV2 = true`)

### Home (`home_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Player card | 12px | 8px | `lg` |
| Stat tile | 6px | 6px | `md` ✓ (no change) |
| Button | 8px | 8px | `lg` ✓ (no change) |
| Chip / filter | 4px | 4px | `sm` ✓ (no change) |

---

## Auth screens

### User Auth Email (`user_auth_email_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Input field | 12px | 8px | `lg` |
| Button | 8px | 8px | `lg` ✓ (no change) |
| Alert/info container | 18px | 12px | `xl` |
| Sub-element | 6px | 6px | `md` ✓ (no change) |

---

## Global dialogs / sheets

### Alert Confirm (`alert_confirm_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Dialog container | 12px | 12px | `xl` ✓ (no change) |
| Button | 24px | 12px | `xl` |

### New Live Game sheet (`new_live_game_widget`)
| Element | Current | → New | Token |
|---|---|---|---|
| Sheet container (top) | 12px | 12px | `xl` ✓ (no change) |
| Card / sub-container | 6px | 6px | `md` ✓ (no change) |
| Button | 24px | 12px | `xl` |
| Handle bar | 3px | 2px | `xs` |

---

## Summary of actual changes required

Rows marked `✓ (no change)` are already at the correct token value — skip them.

| Change | Screens affected |
|---|---|
| 24px → 12px (`xl`) | `new_player`, `alert_confirm`, `new_live_game` |
| 23px → 9999px (`full`) | `players_list`, `all_games`, `new_game` |
| 45px → 9999px (`full`) | `game_stats`, `game_stat_sheet` |
| 18px → 12px (`xl`) | `custom_nav_bar`, `paywall`, `user_auth_email`, `game_stats` |
| 12px → 8px (`lg`) | `players_list`, `players_profile`, `all_games`, `game_stats`, `game_stat_tracker`, `create_new`, `menu`, `home`, `user_auth_email` |
| 8px → 4px (`sm`) | `all_games` event badge |
| 5px → 4px (`sm`) | `game_stat_tracker` |
| 3px → 2px (`xs`) | `game_stat_sheet`, `new_player`, `new_live_game` handle bars |
