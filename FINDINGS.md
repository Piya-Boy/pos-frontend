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

## F3 — ops screen shows "เกิดข้อผิดพลาด" right after login — HIGH (real, live-repro)

**Repro:** build web → `?page=kitchen` → login `zaq1234` → instead of the kitchen board you get a blank page with "เกิดข้อผิดพลาด".
**Cause:** `OpsPage` renders `LoginPage` inline while `auth.session == null` (`ops_page.dart:81`). Its dashboard load runs in `initState`/`didChangeDependencies` postFrame, but `_loadAndPoll` early-returns when `auth.session == null` (`ops_page.dart:186-192`). After a successful inline login the session flips null→set and the widget rebuilds, but **nothing re-triggers the load** — so `dashboard` stays null, `loading` is false, `error` is null → the `dashboard == null` branch shows the generic fallback (`ops_page.dart:88-90`).
**Fix:** when `auth.session` transitions from null to non-null, trigger `_loadAndPoll()` (e.g. listen to AuthController, or in `build` detect the transition and schedule a postFrame load; or have LoginPage's `onAuthenticated` callback kick the load). Also: `FakeApiClient.opsDashboard` throws `StateError('PERMISSION_DENIED'/'INVALID_VIEW')` — throw `AppError` with those codes instead so the controller's catch surfaces a real message, not a generic one.
**Test gap:** existing widget tests seed a session + dashboard up front, so they never exercise the login→load transition. Add a widget test: pump OpsPage with NO session → enter PIN → submit → assert the kitchen board (not the error text) appears.
**Use skills:** `flutter-add-widget-test`, `flutter-fix-runtime-errors` (dart-fix-runtime-errors) to trace, `superpowers:systematic-debugging`.
**Verify:** rebuild → login to kitchen → board renders with seeded orders.

## F4 — can't leave a staff/error screen; browser back doesn't work — HIGH

**Repro:** land on the ops error page (F3) or any staff screen → there's no way back to the home portal; the browser Back button does nothing.
**Causes:**
1. **No back affordance on non-login staff screens.** LoginPage has "← กลับหน้าหลัก" (`login_page.dart:68`), but the ops error branch (`ops_page.dart:88-90`) and the ops shell header have none. cp-pos shows a back/logout on every staff screen. Add "← กลับหน้าหลัก" (→ `context.go('/')`) to the ops error state AND keep the logout in the ops header working.
2. **Browser Back is dead** because every navigation is `context.go('/?page=X')` — a single route `/` with a query param, and `go` *replaces* rather than pushes, so no history entry is created and same-path query changes may not rebuild. Options (pick one, keep it simple):
   - Give each page its own path (`/order`, `/kitchen`, `/staff`, `/cashier`, `/operations`, `/admin`) as GoRoutes so `go` builds real history and Back works; keep `?table=` for order. OR
   - Keep the query-param scheme but use `context.push` for portal→screen (so Back pops) and ensure the router rebuilds on query change (include `state.uri` in a `key`).
   Prefer per-path routes — cleaner, real deep links, Back/forward just work.
**Also:** unfinished pages (admin/cashier before their tasks land) fall back to HomePage silently — that's why "กดหน้าอื่นไม่ได้". That's expected until P4-T6..T9 wire them; F2 says wire each route as its screen completes. Just make sure every reachable screen has a visible way home.
**Use skills:** `flutter-setup-declarative-routing`.
**Verify:** from home → kitchen → back to home (via on-screen back AND browser Back); repeat for each finished role.

## F4a — 4px vertical overflow after adding back link (fix, don't skip)

Adding the back link pushed the ops header past the test viewport by 4px (RenderFlex overflow). This is exactly what **`flutter-fix-layout-issues`** is for — invoke it. Likely fixes: wrap the header row/column so it can shrink (`Flexible`/`Expanded`, or make the outer body scrollable with `SingleChildScrollView`/`CustomScrollView`), reduce header vertical padding, or put back-link + title in a compact `AppBar`/row that fits. Do NOT silence the test by enlarging the test viewport or removing the overflow assertion — fix the layout so it fits real small screens (cp-pos ops header is compact). Re-run the widget test until green, then commit F3+F4 together.

## F5 — Kitchen layout wrong: summary cards huge, kanban board missing — HIGH (live-repro)

**Repro:** login to kitchen → you see FOUR giant summary cards (โต๊ะเปิด/ออเดอร์ใหม่/กำลังทำ/พร้อมเสิร์ฟ) filling the whole screen in a 2×2 grid; the actual kanban board (3 columns of order cards) is not visible even though "ออเดอร์ใหม่ 1" says there's an order.
**cp-pos reference** (`renderOpsContent`/`renderKitchen` App.html:693-732, CSS `.summary-grid` Styles.html:237/356, `.kanban` :246/378):
- Summary is a **compact top strip** — 4 short cards, 2 cols on mobile, **4 cols ≥640px**, each just a small `.summary-card` (padding 16, number 27px). NOT full-height.
- The **kanban is the main content**: 3 columns (NEW/PREPARING/READY), each a `.kanban-column` holding `.order-card`s (table name, elapsed, qty×item, action button). 1 col mobile, 3 cols ≥900px.
**Bugs in `ops_page.dart`:**
1. `_SummaryGrid` uses `GridView.count(crossAxisCount: 2, childAspectRatio: 2.4)` always → on wide screens 2 huge cards per row. Make it 4 cols ≥640 (2 on mobile) and give cards a small fixed height, `shrinkWrap: true`, `NeverScrollableScrollPhysics`, NOT `Expanded`.
2. The summary seems to be taking an `Expanded`/large slice while the KitchenBoard (line ~183) gets squeezed. Summary must be intrinsic-height at the top; the kanban gets the remaining space (`Expanded`).
3. Order card not showing — once the board has room, verify the seeded NEW order renders in the first column.
**Use skills:** `flutter-fix-layout-issues`, `flutter-build-responsive-layout`, `flutter-add-widget-test` (assert summary is 4-wide ≥640 and the order card is present).
**Verify:** login kitchen → compact summary strip on top + a 3-column board with the seeded order card below.

## Note on layout
The page IS centered (max-width 1120). On very wide screens it looks left-biased only because the single promo card + empty right gutter — that matches cp-pos mobile-first behavior. No change needed. If you later add a desktop-specific treatment, spec it first (don't改 silently).
