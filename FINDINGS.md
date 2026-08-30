# FINDINGS — parity fixes from live UI review (customer page)

> Reviewed the built web app (`?page=order&table=demo`) against cp-pos screenshots. Overall the port is ~90% faithful (colors, Prompt font, hero gradient, promo, food cards, chips, centered 1120 layout all correct). But real parity bugs found — fix these, TDD, then re-verify in the browser.

## F1 — TextFields have no styling (theme missing `inputDecorationTheme`) — HIGH

**Symptom:** the search box renders as just a floating `⌕` icon with no visible field; note/promo/price inputs are bare underlines invisible on the cream background.
**Cause:** `lib/core/theme/phius_theme.dart` never sets `inputDecorationTheme`, so every `TextField` falls back to Material's underline default.
**Fix:** add `inputDecorationTheme` to `phiusTheme()` per cp-pos `Styles.html:75-77` — `filled: true`, `fillColor: surface`, 1px `border` outline, radius 13, focus border `primary` width 2, `contentPadding` 13/11, hint color `muted`. (The exact block is now in `plan.md` Task 1 Step 6 — copy it.)
**Search box extra** (`Styles.html:143`): radius **16** + `shadowSm` + left padding for the icon — override in `MenuToolbar`, don't rely on theme radius 13.
**Test:** add to `test/core/theme/*` a pump of a `TextField` under `phiusTheme()` asserting the decoration is filled with `surface` and an `OutlineInputBorder`. Then re-run the app and confirm the search box shows a bordered field.

**Use installed skills:** `flutter-add-widget-test` for the decoration test, `flutter-fix-layout-issues` if any field overflows, `dart-run-static-analysis` before commit. (Full skill list in `AGENTS.md §4`.)

## Re-verify after fixing
1. `flutter test && flutter analyze` green.
2. `flutter build web` → serve → open `?page=order&table=demo` → search box is a visible bordered field; item modal note + cart promo fields look like cp-pos.
3. Commit `fix(theme): port cp-pos input styling`; keep going with the plan.

## F2 — portal cards go nowhere (routing deferred to P4-T10) — MEDIUM

**Symptom:** on the home portal, tapping รวมงาน/ครัว/พนักงาน/แคชเชียร์/ผู้ดูแล just shows a "ส่วนนี้กำลังพัฒนา" snackbar (`home_page.dart:272`). Nothing navigates.
**Cause:** `_routeFor` (`app_router.dart:26`) only handles `page=='order'`; everything else falls to HomePage. Staff/admin routes are only wired in P4-T10 (the last task), so screens built in P4-T2..T9 aren't reachable yet.
**Fix (do this incrementally, don't wait for T10):** each time a staff/admin screen's task completes, wire its route in `_routeFor` AND make the matching home portal card `context.go('/?page=<x>')` instead of the snackbar. Map: `kitchen`→ops(KITCHEN), `staff`→ops(STAFF), `cashier`→ops(CASHIER), `operations`→ops(ALL), `admin`→AdminPage. Guard staff/admin routes behind login (show LoginPage if no token). So after P4-T4 (kitchen done) the ครัว card should already open the kitchen screen.
- Update the P4-T10 "routing" task to be a final *audit* (all cards reachable + login guard + breakpoints), since wiring now happens per-screen.
**Use skills:** `flutter-setup-declarative-routing`.
**Verify:** build web → from home, each finished role card opens its screen (or login first); unfinished ones may still stub, but ครัว must work now.

## Note on layout
The page IS centered (max-width 1120). On very wide screens it looks left-biased only because the single promo card + empty right gutter — that matches cp-pos mobile-first behavior. No change needed. If you later add a desktop-specific treatment, spec it first (don't改 silently).
