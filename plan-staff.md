# Phase 4 — Staff & Admin Frontend Plan (Flutter)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans. Same TDD + review + commit + PROGRESS loop as `AGENTS.md`. Runs in `` AFTER Phase 1 (customer UI) and Phase 2 (backend endpoints) exist. Login/Ops need a live or fake backend — reuse the `ApiClient` interface + a `FakeApiClient` staff/ops/admin seed (extend the Phase 1 fake).

**Goal:** Port the cp-pos staff-facing UI to Flutter, 100% parity: PIN login, role portals, Kitchen/Staff/Cashier ops, and the Admin console. Backend endpoints already exist (`back.md` §6.2-6.4).

**Architecture:** New routes (`?page=kitchen|staff|cashier|operations|admin`) alongside the existing customer route. Auth token stored via `shared_preferences` (⚠️ security.md §2.7 — token only, never PIN). New controllers: `OpsController`, `AdminController`, `AuthController` (Flutter-side, calling `ApiClient`). Reuse Phase 1 tokens/theme/shared widgets.

## Global Constraints
- Package `pos_frontend`; imports `package:pos_frontend/...`.
- Parity: tokens from `front.md §2`; Thai strings verbatim from `cp-pos/Pages.html` + `App.html`. All CSS classes already ported in `lib/core/theme` — reuse.
- `ApiClient` interface extended with staff/ops/admin methods (see below). `FakeApiClient` gains staff seed (4 roles, PIN `zaq1234`) + in-memory ops/admin state so widget tests run offline.
- Auth: login → token in `shared_preferences` key `pos-auth-{route}`; send as `token` in each staff request body (matches backend). On `AUTH_EXPIRED`/`AUTH_REQUIRED` → clear + show login.
- Same model-per-task, review-on-sol, commit, tick-PROGRESS loop.

## Reference (cp-pos source)
- Login: `renderLogin()` App.html:209, template `Pages.html:106`. Ops shell: `renderOpsShell/Content` App.html:684-720, template `Pages.html:126`. Kitchen: `renderKitchen/renderOrderCard` :722-739. Staff: `renderStaff` :741. Cashier: `renderCashier/openBill/submitPayment/showReceipt` :747-786. Admin: `loadAdmin/renderAdminTab` :805+ and `AdminUI.html`. CSS: ops `.ops-*/.kanban/.order-card/.task-card/.bill-card` Styles.html:232-267; admin `.admin-*/.data-table/.metric-*/.settings-*` :269-343.
- Backend contracts: `back.md §6.2` (auth), `§6.3` (ops), `§6.4` (admin).

---

### P4-T1: Extend ApiClient + FakeApiClient (auth/ops/admin)

**Files:** `lib/core/api/api_client.dart` (add methods), `lib/core/api/fake_api_client.dart` (staff/ops/admin seed + in-memory mutations), models for `StaffSession`, `OpsDashboard`, `Receipt`, `AdminData`.
**Add to `ApiClient`:** `login(pin, expectedRole)`, `logout(token)`, `changePin(token, newPin)`, `opsDashboard(token, view)`, `updateOrderItem(token, orderItemId, status, kitchenNote?)`, `updateCall(token, logId, status)`, `closeTable(token, sessionId, method, reference?, idempotencyKey)`, `adminData(token)`, `adminSaveSettings(token, settings)`, `adminSaveEntity(token, entity, data)`, `adminArchiveEntity(token, entity, id)`, `adminRotateToken(token, tableId)` — shapes per `back.md §6`.
- TDD: FakeApiClient test — login with `zaq1234`+role returns token; opsDashboard returns seeded kitchen items; updateOrderItem moves NEW→PREPARING. FAIL→implement→PASS→review→commit→tick.

### P4-T2: Auth — Login screen + token store + AuthController

**Files:** `lib/features/staff/login_page.dart`, `lib/state/auth_controller.dart`, `lib/features/staff/widgets/*`.
- Port `tpl-login` (`Pages.html:106`): back link, brand, role icon/kicker/title/description per `roleMeta` (App.html:34-40), PIN field (`^[A-Za-z0-9]{4,12}$`), submit, hint "PIN เริ่มต้น: zaq1234". CSS `.login-card/.pin-input/.role-icon` (Styles.html:83-100).
- AuthController: `login`, persist token, `mustChangePin` → force change-pin flow, `logout`, `resolveOnBoot` (restore token). Widget test: enter PIN → token stored, role screen shown.
- Review (sol — auth): token not logged, PIN never persisted, error messages verbatim.

### P4-T3: Ops shell + summary + tabs + polling

**Files:** `lib/features/staff/ops_page.dart`, `lib/state/ops_controller.dart`, `widgets/ops_summary.dart`, `ops_tabs.dart`.
- Port `tpl-ops-shell` (`Pages.html:126`) + `renderOpsShell/Content` (App.html:684): header (kicker/title/user + logout), summary grid (openTables/newOrders/preparing + ready|waitingCalls per role, App.html:699-704), tabs only for `operations` view (kitchen/staff/cashier). Poll `opsDashboard` every `max(5,pollSeconds)`; stop on hidden.
- Widget test: dashboard renders 4 summary cards; operations view shows 3 tabs.

### P4-T4: Kitchen board (kanban)

**Files:** `widgets/kitchen_board.dart`, `order_card.dart`.
- Port `renderKitchen/renderOrderCard` (App.html:722-739): 3 columns NEW/PREPARING/READY (`.kanban/.kanban-column/.order-card`), each card: table name, elapsed time, status pill, qty×item + options/addons, note, action button (NEW→"เริ่มทำ"→PREPARING primary; PREPARING→"พร้อมเสิร์ฟ"→READY secondary; READY→"รอพนักงานเสิร์ฟ" pill). Action → `updateOrderItem`. Empty col → "✓ ยังไม่มีรายการ".
- Widget test: seeded NEW item shows in first column; tapping "เริ่มทำ" moves it.

### P4-T5: Staff queue (calls + ready-to-serve)

**Files:** `widgets/staff_queue.dart`.
- Port `renderStaff` (App.html:741): "งานเรียกจากโต๊ะ" task cards (BILL="เรียกเก็บเงิน"/ASSISTANCE="เรียกพนักงาน", OPEN→"รับงานนี้"→ASSIGNED, ASSIGNED→"เสร็จเรียบร้อย"→DONE) + "อาหารพร้อมเสิร์ฟ" READY items → "ยืนยันว่าเสิร์ฟแล้ว"→SERVED. Empty states verbatim. Actions → `updateCall`/`updateOrderItem`.
- Widget test: open call renders + "รับงานนี้"; ready item renders + serve button.

### P4-T6: Cashier bills + bill modal + payment + receipt

**Files:** `widgets/cashier_bills.dart`, `bill_modal.dart`, `receipt_modal.dart`.
- Port `renderCashier/openBill/submitPayment/showReceipt` (App.html:747-786): bill cards (status pill กำลังรับประทาน/เรียกเก็บเงินแล้ว, total, item count, open time, "ตรวจบิล"); bill modal (receipt items + totals + method select CASH/TRANSFER/CARD/OTHER Thai labels + reference + "รับชำระเงินและรีเซตโต๊ะ"); confirm dialog; `closeTable` with idempotencyKey; receipt modal (restaurant/table/payment meta/items/totals + "✓ โต๊ะพร้อมรับลูกค้ารอบใหม่", print button). CSS `.bill-card/.receipt-*/.payment-meta`.
- Review (sol — money/idempotency): idempotencyKey generated once per bill, method required, amount from backend not client.
- Widget test: bill card → open modal → select method → submit → receipt shown (fake).

### P4-T7: Admin shell + nav + overview

**Files:** `lib/features/admin/admin_page.dart`, `lib/state/admin_controller.dart`, `widgets/admin_nav.dart`, `admin_overview.dart`.
- Port `tpl-admin`/`loadAdmin/renderAdminTab/renderAdminOverview` (App.html:805-845, AdminUI.html): sidebar nav (overview/tables/catalog/promotions/staff/settings, Thai titles App.html:820), mobile toggle, metric cards (tables/menuItems/activeSessions/todaySales), shortcuts. CSS `.admin-*/.metric-*`. Poll adminData (pause when editing).
- Widget test: nav renders 6 items; overview shows metric cards.

### P4-T8: Admin tables + catalog + promotions + staff (CRUD tables)

**Files:** `widgets/admin_tables.dart`, `admin_catalog.dart`, `admin_promotions.dart`, `admin_staff.dart`, `admin_entity_form.dart`.
- Port `renderAdminTables/Catalog/Promotions/Staff` + `openAdminForm/renderAdminField` (App.html:845-1094): data tables (`.data-table`), row actions (edit/archive/rotate-token for tables), entity forms per `ADMIN_ENTITIES` (Admin.js:1-10) with per-field types (text/number/select/color/textarea/image-url). Save→`adminSaveEntity`, archive→`adminArchiveEntity` (with guard messages verbatim), rotate→`adminRotateToken`. QR display for tables (`showTableQr` App.html:1094 — render order URL; QR image optional).
- Widget test: menu table renders seeded items; save form upserts (fake); archive category-in-use shows blocked message.

### P4-T9: Admin settings (brand/theme) + live preview

**Files:** `widgets/admin_settings.dart`, `brand_preview.dart`.
- Port `renderAdminSettings/renderSettingsAssetPreviews` (App.html:918-996): brand fields (AppName/RestaurantName/tagline/logo/hero*), color pickers (`.color-settings`), service-charge/VAT/polling, https-url validation client-side mirror, live brand preview panel (`.brand-preview-panel/.settings-hero-preview`). Save→`adminSaveSettings` (backend validates hex/percent/polling).
- Widget test: settings form renders; changing primary color updates preview.

### P4-T10: Staff/Admin routing + parity pass

**Files:** `lib/core/router/app_router.dart` (add staff/admin routes), responsive.
- Wire `?page=kitchen|staff|cashier|operations|admin` → guarded by login (token). Home portal (`tpl-home` `Pages.html:14`) links to each. Apply ops/admin breakpoints (Styles.html:347-396). Parity screenshot pass vs cp-pos.
- Full `flutter test` + `flutter analyze` green.

**Phase 4 done when:** login + all role screens + admin CRUD work against FakeApiClient (and, after Phase 3, against Laravel), parity holds, tests green, PROGRESS Phase-4 lines ✅.
