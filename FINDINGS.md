# FINDINGS — parity fixes from live UI review (customer page)

> Reviewed the built web app (`?page=order&table=demo`) against cp-pos screenshots. Overall the port is ~90% faithful (colors, Prompt font, hero gradient, promo, food cards, chips, centered 1120 layout all correct). But real parity bugs found — fix these, TDD, then re-verify in the browser.

## F1 — TextFields have no styling (theme missing `inputDecorationTheme`) — HIGH

**Symptom:** the search box renders as just a floating `⌕` icon with no visible field; note/promo/price inputs are bare underlines invisible on the cream background.
**Cause:** `lib/core/theme/phius_theme.dart` never sets `inputDecorationTheme`, so every `TextField` falls back to Material's underline default.
**Fix:** add `inputDecorationTheme` to `phiusTheme()` per cp-pos `Styles.html:75-77` — `filled: true`, `fillColor: surface`, 1px `border` outline, radius 13, focus border `primary` width 2, `contentPadding` 13/11, hint color `muted`. (The exact block is now in `plan.md` Task 1 Step 6 — copy it.)
**Search box extra** (`Styles.html:143`): radius **16** + `shadowSm` + left padding for the icon — override in `MenuToolbar`, don't rely on theme radius 13.
**Test:** add to `test/core/theme/*` a pump of a `TextField` under `phiusTheme()` asserting the decoration is filled with `surface` and an `OutlineInputBorder`. Then re-run the app and confirm the search box shows a bordered field.

## Re-verify after fixing
1. `flutter test && flutter analyze` green.
2. `flutter build web` → serve → open `?page=order&table=demo` → search box is a visible bordered field; item modal note + cart promo fields look like cp-pos.
3. Commit `fix(theme): port cp-pos input styling`; keep going with the plan.

## Note on layout
The page IS centered (max-width 1120). On very wide screens it looks left-biased only because the single promo card + empty right gutter — that matches cp-pos mobile-first behavior. No change needed. If you later add a desktop-specific treatment, spec it first (don't改 silently).
