# FF Manual Changes

Items that require the FlutterFlow visual editor — cannot be fixed via code edits on generated files.
These accumulate during the design system overhaul and get addressed in a single manual FF session after all code phases are done.

---

## From Phase 1 — Theme color update visual review

### [FF-MANUAL-01] Generated card fills — canvas vs. surface
**Screens affected:** Players list, Games list, Menu, Game Stats
**Problem:** After `primaryBackground` changed from `#FFFFFF` → `#EFEFF1` (canvas), generated widgets that bind card fill to `primaryBackground` are now rendering gray instead of white.
**Fix:** In FF visual editor, rebind card container fills from `primaryBackground` → `secondaryBackground` (which is now `surface` / `#FFFFFF`).

### [FF-MANUAL-02] White border treatment on gray canvas
**Screens affected:** Games list, Game Stats
**Problem:** Card borders that were hairline-on-white now read as white-on-gray — wrong contrast direction.
**Fix:** In FF visual editor, rebind border colors from `primaryBackground` or white literal → `accent4` (hairline / `#E2E2E5`) or remove border and use elevation instead.

### [FF-MANUAL-03] Active tag color on Game Stats page
**Screens affected:** Game Stats
**Problem:** Active/selected tag background is not reflecting the updated `secondary` (jade500) or `alternate` (spark500) correctly.
**Fix:** In FF visual editor, verify tag active-state color binding and update to correct semantic token.

### [FF-MANUAL-04] Game insights + effort/disrupt cards lost on canvas
**Screens affected:** Game Stats
**Problem:** Insight and stat section containers have no fill or transparent fill — now invisible against the canvas background.
**Fix:** In FF visual editor, add `secondaryBackground` (surface) fill to these containers.

### [FF-MANUAL-05] Remove/delete button styling on Game Stats
**Screens affected:** Game Stats
**Problem:** Delete/remove action button needs destructive styling to match the design system (`accent1` = rose500 for destructive actions).
**Fix:** In FF visual editor, update the remove game button color binding to `accent1` (rose500) with white text.

---

## Template for future entries

```
### [FF-MANUAL-NN] Short description
**Screens affected:** ...
**Problem:** ...
**Fix:** ...
```
