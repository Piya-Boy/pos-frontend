# front.md — Flutter Frontend Spec (port cp-pos 100%)

> **Status**: Spec for coding AI. Claude = PM (plan/spec/task).
> **Goal**: Port `cp-pos/` (HTML/CSS/JS on Google Apps Script) → Flutter Web + Mobile, **100% identical** — layout, color, spacing, Thai wording, flow, interaction.
> **This phase**: Customer order flow (full). Ops/Admin = next phase (scaffold reserved).
> **Note**: Thai UI strings stay verbatim (parity). All other text = English.

---

## 0. Porting rules (read before coding)

1. **Pixel-parity**: every value from `cp-pos/Styles.html` ports exactly — hex color, radius, padding, font-size, shadow, gap. No guessing. See token table §2.
2. **Verbatim Thai wording**: every Thai UI string copied exactly from `cp-pos/Pages.html` + `App.html`. Do NOT translate/edit.
3. **One component per CSS block**: each `.class` in Styles.html → one Flutter widget, own file. Name maps to CSS.
4. **Source of truth**: compute/state logic references `cp-pos/App.html` (render functions) + `cp-pos/Services.js` (business rules). `file:line` cited per component below.
5. **No real backend yet**: this phase wires API via interface (`ApiClient`) + fake. Laravel comes later. Never hardcode Apps Script `google.script.run`.
6. **When unsure about any Flutter/Dart API, widget, or package**: look it up at https://docs.flutter.dev/ (and pub.dev for package APIs). Do not guess.

---

## 1. Stack + project structure

| Area | Choice | Reason |
|---|---|---|
| Framework | Flutter (exists at ``) | locked |
| Target | Web + Mobile (responsive) | requirement |
| State | `provider` + `ChangeNotifier` | light, maps to old `state` object directly, easy for AI |
| Routing | `go_router` | supports `?page=&table=` (QR deep link), URL-based like original |
| HTTP | `http` (behind `ApiClient` interface) | swap backend later without touching UI |
| Font | `google_fonts` → **Prompt** | must be 100% identical (`font-family: 'Prompt'`) |
| Money format | `intl` | `฿1,234` |
| Local storage | `shared_preferences` | replaces `localStorage`/`sessionStorage` (cart, session) |

### pubspec additions
```yaml
dependencies:
  provider: ^6.1.2
  go_router: ^14.0.0
  http: ^1.2.0
  google_fonts: ^6.2.1
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  cached_network_image: ^3.3.1   # menu images + placeholder + onerror fallback
```

### File tree `lib/`
```
lib/
  main.dart                      # runApp + MultiProvider + router
  app.dart                       # MaterialApp.router + PhiusTheme
  core/
    theme/
      tokens.dart                # ★ all CSS :root vars → const (color/radius/shadow/spacing)
      phius_theme.dart           # ThemeData from tokens (Prompt font, color, input, button)
    router/
      app_router.dart            # go_router: /?page=order&table=xxx → CustomerPage; home/login/ops/admin
    api/
      api_client.dart            # abstract: bootstrap/getCustomerData/submitOrder/getOrderStatus/callStaff
      api_result.dart            # {ok, data, error{code,message}} — maps App.html api()
      app_error.dart             # code+message+details (App.html appError)
      fake_api_client.dart       # mock from cp-pos/Database.js seed (dev before Laravel)
    utils/
      formatters.dart            # formatMoney, placeholderImage
      client_id.dart             # clientId() idempotency key
  models/                        # map cp-pos/Database.js SHEET_SCHEMAS
    app_config.dart              # brand (name/tagline/hero/color/currency) from getPublicBootstrap
    category.dart  menu_item.dart  option.dart  add_on.dart  promotion.dart
    cart_line.dart               # state.cart element (App.html:482)
    order_session.dart  order_item.dart  call_log.dart
    session_bundle.dart          # {session, items, calls} (Services.js getSessionBundle_)
    totals.dart                  # {subtotal,discount,serviceCharge,vat,total,promo}
  state/
    customer_controller.dart     # ★ port of state{} + render logic (cart/search/category/session/polling)
  features/
    customer/
      customer_page.dart         # tpl-customer (Pages.html:34)
      widgets/                   # ← §4 (component list)
    shared/
      widgets/                   # brand_mark, primary_button, status_capsule, network_banner, modal_sheet...
```

---

## 2. Design tokens (from `cp-pos/Styles.html:2-24`) — port exactly

`core/theme/tokens.dart` — **do NOT change these**:

```
// colors (:root)
bg          = #FBF7F0   surface     = #FFFFFF   surfaceSoft = #F4EEE5
ink         = #211E1B   muted       = #706A63
primary     = #B7442B   primaryDark = #8F301E   primaryLight= #CE735C
green       = #2F6B4F   greenSoft   = #E1EEE7
saffron     = #D9911D   saffronSoft = #FFF0D2
redSoft     = #FBE5DE   border      = #E7DED2

// shadow
shadowSm = 0 3px 12px rgba(58,39,28,.07)
shadowMd = 0 14px 40px rgba(58,39,28,.13)

// radius
radiusSm = 12   radius = 18   radiusLg = 24

// typography
font = 'Prompt'   baseSize = 15   lineHeight = 1.55
h1/h2/h3: line-height 1.25, letter-spacing -.025em
```

**Shadow convert**: CSS `box-shadow: 0 Y Blur color` → `BoxShadow(offset: Offset(0,Y), blurRadius: Blur, color: color)`.
**Hero gradient** (`Styles.html:126`): `linear-gradient(120deg, primaryDark, primary 60%, primaryLight)` → `LinearGradient(begin: topLeft, end: bottomRight, colors:[primaryDark, primary, primaryLight], stops:[0,.6,1])`.

---

## 3. Responsive breakpoints (from Styles.html media queries)

| Point | Condition | Effect on customer UI |
|---|---|---|
| mobile | < 640 | menu-grid = 2 cols |
| ≥ 640 | tablet | menu-grid = 3, hero padding up, promo card wider |
| ≥ 900 | desktop | menu-grid = 4 |
| ≤ 430 | tiny | hero-emblem smaller, service-actions = 1 col |

`customer-page` max-width = 1120, centered (`Styles.html:102`). Padding shifts per breakpoint (16→24→32). Use `LayoutBuilder`/`MediaQuery` to compute grid columns.

---

## 4. Component list — customer frontend (this phase)

Each: **file · CSS map · source map · props/state · parity notes**.
All under `features/customer/widgets/` unless marked `shared/`.

### 4.1 CustomerPage
- **file**: `customer/customer_page.dart`
- **CSS**: `.customer-page` (`Styles.html:102`)
- **source**: `renderCustomer()` `App.html:342` · template `Pages.html:34`
- **layout** (top→bottom): CustomerHeader → CustomerGuide → BillStatusBanner(overlay) → CustomerHero → PromotionStrip → MenuToolbar → MenuSection → OrderTrackingSection → AppFooter → CartBar(fixed bottom)
- **state**: reads `CustomerController` (search, category, cart, session, paymentComplete)
- **notes**: whole page scrolls; CartBar + BillBanner float (Stack overlay); MenuToolbar sticky top.

### 4.2 CustomerHeader
- **CSS**: `.customer-header .customer-brand .table-pill` (`103-109`)
- **source**: `Pages.html:36-45`
- **props**: restaurantName, tagline, tableName, onTapTablePill(→ scroll to tracking)
- **build**: BrandMark(small) + tagline(eyebrow) + h1 restaurant name | TablePill ("โต๊ะ" + table name)

### 4.3 CustomerGuide (how-to accordion)
- **CSS**: `.customer-guide` (`110-121`)
- **source**: `Pages.html:47-54`
- **content**: 3 steps (fixed Thai) — "เลือกเมนู / ตรวจตะกร้าและส่งออเดอร์ / ติดตามสถานะและเรียกเก็บเงิน"
- **notes**: custom `ExpansionTile` (numbered 1-2-3 primary circles). Default collapsed.

### 4.4 BillStatusBanner (overlay)
- **CSS**: `.bill-status-banner` (`122-125`)
- **source**: `Pages.html:56-58` · toggled in `renderTracking()` `App.html:636`
- **props**: visible (from `isBillPending()` `App.html:648`)
- **notes**: fixed top center, blur backdrop, primaryDark/redSoft. Text "เรียกเก็บเงินแล้ว / พนักงานได้รับแจ้งแล้ว กรุณารอสักครู่".

### 4.5 CustomerHero
- **CSS**: `.customer-hero .hero-kicker .hero-emblem` (`126-131`)
- **source**: `Pages.html:60-67` · `renderHeroEmblem()` `App.html:361`
- **props**: heroKicker, heroTitle(`\n` → pre-line), emblem(text OR image + onerror fallback)
- **notes**: gradient (§2). Emblem `rotate(-9deg)`, circular; if image → thick border + cover.

### 4.6 PromotionStrip + PromoCard
- **CSS**: `.promotion-strip .promo-card` (`132-139`)
- **source**: `renderPromotions()` `App.html:381` · `Pages.html:69`
- **props**: `List<Promotion>`; hidden if empty
- **notes**: horizontal scroll-snap; card = bg image + left→right gradient overlay; shows Code/Name/Description. Image error → drop image (green bg remains).

### 4.7 MenuToolbar (SearchBox + CategoryChips)
- **CSS**: `.menu-toolbar .search-box .chip-row .chip` (`140-146`)
- **source**: `renderCategories()` `App.html:392` · `Pages.html:71-78`
- **props**: searchText, categories(prepend "ทั้งหมด" 🍽️ id=`ALL`), activeCategory, onSearch, onSelectCategory
- **notes**: sticky top blur; active chip = primary bg white text; search icon `⌕` left.

### 4.8 MenuSection (heading + grid + empty)
- **CSS**: `.section-block .section-heading .menu-grid .empty-state` (`147-167`)
- **source**: `renderMenu()` `App.html:399` · `Pages.html:80-87`
- **props**: filteredItems, count ("{n} เมนู"), showEmpty
- **filter logic** (`App.html:402`): category match + search in `Name + Description` (lowercase). Port exactly.
- **grid cols**: 2/3/4 per breakpoint (§3). `menu-empty` = "ยังไม่พบเมนู / ลองเปลี่ยนคำค้นหรือเลือกหมวดอื่น".

### 4.9 FoodCard
- **CSS**: `.food-card .food-image-wrap .food-image .food-badge .food-body .food-price .quick-add` (`152-164`)
- **source**: `App.html:407-418`
- **props**: item(MenuItem), onQuickAdd
- **notes**:
  - image `aspect-ratio 1.15`, cover, hover zoom (web); onerror → `placeholderImage('อาหารไทย')`.
  - badge: available+IsPopular → "เมนูยอดนิยม" (green); not available → "หมดชั่วคราว" (ink) + card opacity .66 + quick-add disabled.
  - h3 min-height 39, description 2-line clamp min-height 36.
  - quick-add = `+` button 40×40 primary.

### 4.10 ItemDetailModal (options/addons/note/qty)
- **file**: `item_detail_modal.dart`
- **CSS**: `.modal-*, .item-detail-*, .choice-*, .quantity-row, .stepper` (`189-212`)
- **source**: `openItemModal()` `App.html:423` · `updateItemModalPrice()` `:452` · `addItemToCart()` `:467`
- **props**: item(options grouped by GroupName, addOns), onAddToCart(cartLine)
- **modal layout**: image → title(name+desc+price) → [option groups: RADIO/CHECKBOX per GroupName, required badge "จำเป็นต้องเลือก" / "เลือกได้"] → [add-ons "เพิ่มความอร่อย" checkbox] → note textarea("หมายเหตุถึงครัว", max 300) → qty stepper → footer button "เพิ่มลงตะกร้า · {total}"
- **price logic** (`:452`): total = (basePrice + Σ selected option price + Σ selected addon price) × qty. Live update on select / qty change.
- **required validate** (`:469`): required group not selected → scroll to it + toast error "กรุณาเลือก {GroupName}". Block add.
- **RADIO required**: first option default checked (`App.html:432`).
- **notes**: bottom-sheet (align end, top radius 26, max-height 100dvh-24, body scroll, sticky header/footer). See `showModal()` `App.html:1175`.

### 4.11 CartBar (fixed bottom)
- **CSS**: `.cart-bar` (`185-187`)
- **source**: `renderCartBar()` `App.html:493` · `Pages.html:99-102`
- **3 states** (port exactly):
  1. cart has items (cartCount>0): "{n} รายการในตะกร้า" + total + button "ดูตะกร้า →" (open cart)
  2. cart empty but session open (sessionCount>0): "{n} รายการของโต๊ะ" + session.Total + button "ดูรายละเอียด" or "รอชำระเงิน"(if PAYMENT_PENDING) → scroll tracking
  3. both empty → hide
- **notes**: fixed bottom center, primary bg, safe-area bottom.

### 4.12 CartModal (cart + promo + totals)
- **file**: `cart_modal.dart`
- **CSS**: `.cart-list .cart-item .cart-controls .totals-card .total-row` (`213-221`)
- **source**: `openCart()` `App.html:525` · `submitCart()` `:550`
- **layout**: header("ตรวจสอบก่อนส่ง / ตะกร้าของคุณ") → cart items(name×qty, price/item, options/addons/note, remove button, stepper) → promo code input("โค้ดโปรโมชั่น", placeholder WELCOME10) → totals(ยอดสินค้าโดยประมาณ / ส่วนลดโดยประมาณ / ประมาณการ) → footer "ยืนยันการสั่งอาหาร"
- **promo estimate** (`:528`): find promo by code; if subtotal≥MinSpend → compute discount (PERCENT/FIXED). Shown as "โดยประมาณ" (backend computes real on submit).
- **submit** (`:550`): check online, gen idempotencyKey once/round (`checkoutKey`), call `submitOrder`, clear cart, store SessionID, refresh tracking, scroll to tracking, toast "ส่งออเดอร์เข้าครัวแล้ว".

### 4.13 OrderTrackingSection
- **CSS**: `.tracking-section .tracking-list .tracking-item .status-dot .status-pill .inline-bill-status .service-actions` (`168-184`)
- **source**: `renderTracking()` `App.html:618` · `renderItemSelections()` `:654` · `renderTotals()` `:660` · `Pages.html:89-96`
- **display states**:
  - no session/items → empty state "🥢 พร้อมรับออเดอร์ / เลือกรายการที่ต้องการแล้วกดดูตะกร้า"; if `paymentComplete` → "✓ ชำระเงินเรียบร้อยแล้ว / โต๊ะถูกรีเซตและพร้อมสำหรับการสั่งรอบใหม่".
  - has items → list per item (status-dot color + status-pill icon/label per `statusMeta(Status)`) + options/addons/note + totals card.
  - bill pending → inline banner "🧾 แจ้งเรียกเก็บเงินแล้ว / คุณยังตรวจสอบยอดและรายการทั้งหมดได้ระหว่างรอ".
- **service-actions**: 2 buttons — "🛎️ เรียกพนักงาน" (ASSISTANCE, green) / "🧾 เรียกเก็บเงิน" (BILL, outline). Disable per state (closed / bill pending). BILL label → "เรียกเก็บเงินแล้ว" when pending. → `requestService()` `App.html:577`.
- **statusMeta** (`App.html:1295`) — status → {label, icon, dot class, pill class}. Port (customer-facing only):
  | Status | label | icon | dot class | pill class |
  |---|---|---|---|---|
  | NEW | ออเดอร์ใหม่ | ● | (none=saffron) | (none=saffron) |
  | PREPARING | กำลังปรุง | 🔥 | preparing | red |
  | READY | พร้อมเสิร์ฟ | ✓ | ready(green) | green |
  | SERVED | เสิร์ฟแล้ว | ✓ | served(green) | green |
  - dot default = saffron (`status-dot` base); `.ready/.served` = green (`Styles.html:172-173`). pill default = saffronSoft; `.green` green-soft; `.red` red-soft (`:181-183`).

### 4.14 shared widgets (app-wide)
- `BrandMark` — `.brand-mark` (+ `.small` `.has-image`) `Styles.html:47-50`
- `PrimaryButton` / `SecondaryButton` / `OutlineButton` / `GhostButton` / `IconButton` — `.btn-*` `:61-73`
- `StatusCapsule` (toast) — `.status-capsule` (success/error) `:56-58` · `notify()` App.html
- `NetworkBanner` (offline) — `.network-banner` `:55` · `updateNetworkState()`
- `ModalSheet` (bottom-sheet wrapper) — `.modal-*` `:189-195` · `showModal()` `App.html:1175`
- `EyebrowText`, `AppFooter`, `SkeletonLine`

---

## 5. Models — schema map (from `cp-pos/Database.js:1-15` + Services.js responses)

Each model has `fromJson`/`toJson`. Field names match sheet headers (keep PascalCase or map via json key).

| Model | source schema | notes |
|---|---|---|
| AppConfig | `getPublicBootstrap` resp `Services.js:9-32` | brand/theme/currency/pollSeconds |
| Category | `Categories` | UI prepends "ทั้งหมด" |
| MenuItem | `MenuItems` + `.available` + `.options[]` + `.addOns[]` | catalog joined by `getPublicCatalog_` |
| Option | `Options` | grouped by GroupName, InputType RADIO/CHECKBOX |
| AddOn | `AddOns` | |
| Promotion | `Promotions` | |
| CartLine | `App.html:482` (client-only) | lineId/itemId/name/qty/options/addOns/note/unitPrice |
| OrderSession | `OrderSessions` | Status: OPEN/PAYMENT_PENDING/PAID/CLOSED/CANCELLED |
| OrderItem | `OrderItems` | OptionsJSON/AddOnsJSON → parsed |
| CallLog | `CallLogs` | Type ASSISTANCE/BILL |
| SessionBundle | `getSessionBundle_` `Services.js:334` | {session, items[], calls[]} |
| Totals | `recalculateSessionTotals_` `Services.js:357` | subtotal/discount/serviceCharge/vat/total/promo |

---

## 6. API contract (interface — not bound to Laravel yet)

`ApiClient` (abstract) — methods map from Apps Script (`App.html` api calls):

| method | payload | return | source |
|---|---|---|---|
| `bootstrap({tableToken})` | tableToken | `{setupRequired, app, customer?}` | `getPublicBootstrap` |
| `getCustomerData({tableToken})` | | `{table, categories, menu, promotions, session}` | `getCustomerData` |
| `submitOrder({tableToken, idempotencyKey, promoCode, items[]})` | | `{SessionID, table, totals, items, submittedAt}` | `submitOrder` `Services.js:159` |
| `getOrderStatus({tableToken, sessionId})` | | SessionBundle | `getOrderStatus` `Services.js:147` |
| `callStaff({tableToken, type, idempotencyKey})` | type=ASSISTANCE/BILL | `{call, duplicate}` | `callStaff` `Services.js:292` |

- Every response wraps `{ok, data, error{code,message,details}}` (port from `App.html:113`).
- `FakeApiClient`: seed from `Database.js` seed functions (8 menu items, 5 categories, options/addons/promo WELCOME10) → dev UI before backend.

---

## 7. State/behavior to port (CustomerController)

From `state{}` `App.html:12-32` + render/logic functions:

- **cart**: add/remove line, qty +/-, persist `shared_preferences` key `phius-cart-{tableToken}` (`App.html:664-672`). On reload, keep only still-available items.
- **search / activeCategory**: filter menu (`App.html:402`).
- **promoCode / checkoutKey**: idempotency, 1 key/submit round.
- **session**: store SessionID `phius-session-{tableToken}` (sessionStorage → shared_preferences).
- **polling**: refresh order status every `pollSeconds` (from AppConfig, default 3s) — **this phase keeps polling per cp-pos**; WebSocket realtime done when wiring Laravel Reverb (see main design). Stop poll on session closed / tab hidden (`visibilitychange` → `AppLifecycleState`).
- **paymentComplete**: session → PAID → clear cart/session, show paid state (`App.html:595`).
- **network**: online/offline banner (`connectivity_plus` or web `navigator.onLine`).

---

## 8. Definition of Done (customer phase)

1. All §4 components built, tokens match §2, wording matches cp-pos.
2. Open `/?page=order&table={token}` → see menu (FakeApiClient), add item to cart, submit → see tracking.
3. Responsive: 2/3/4 cols per breakpoint; test mobile + web.
4. Interactions complete: search, category filter, item modal (required validate + live price), cart (qty/remove/promo estimate), call staff, bill banner.
5. Side-by-side vs cp-pos (screenshot) — layout/color match.
6. No Apps Script hardcode; all through `ApiClient` interface.

---

## 9. Task breakdown (for coding AI)

> Ordered by dependency. Each task = 1 small PR.

- **T1 — Setup**: add deps (§1), create folder tree (§1), `tokens.dart` + `phius_theme.dart` (§2), Prompt font.
- **T2 — Models + API interface**: models §5, `ApiClient`/`ApiResult`/`AppError` §6, `FakeApiClient` seed from Database.js.
- **T3 — Shared widgets**: §4.14 (BrandMark, buttons, StatusCapsule, NetworkBanner, ModalSheet, AppFooter).
- **T4 — Router + CustomerController**: `app_router.dart` (parse `page`/`table`), `customer_controller.dart` (state §7) + persistence.
- **T5 — CustomerPage shell + Header + Guide + Hero**: 4.1–4.3, 4.5.
- **T6 — Menu**: PromotionStrip 4.6, MenuToolbar 4.7, MenuSection 4.8, FoodCard 4.9.
- **T7 — Item modal**: ItemDetailModal 4.10 (options/addons/note/qty + live price + validate).
- **T8 — Cart**: CartBar 4.11, CartModal 4.12 (promo estimate + submit).
- **T9 — Tracking**: OrderTrackingSection 4.13 (status meta, service actions, bill banner 4.4) + polling.
- **T10 — Responsive + parity pass**: breakpoints §3, screenshot diff, fix pixels.

---

## 10. Resolved refs / check on implement

- `statusMeta` = `App.html:1295` (table §4.13).
- `placeholderImage` = `App.html:1292` → `https://placehold.co/900x700/F4EEE5/706A63?text={label}` (use in `cached_network_image` errorWidget/placeholder, default label "อาหารไทย").
- `formatMoney` = `App.html:1288` → `Intl.NumberFormat('th-TH', currency: THB, maxFractionDigits: 2)`. Dart has no `maxFractionDigits`, so switch: integer value → `decimalDigits: 0`, else `decimalDigits: 2`. Matches `฿85` / `฿1,234` / `฿12.50` (see plan.md Task 3).
- [ ] Font Prompt: `google_fonts` (needs net) OR bundle `.ttf` in assets (offline-safe). Recommend bundle.
- [ ] Login/Ops/Admin (`Pages.html:106+`, ops shell, admin) = **Phase 2** — router/theme/shared scaffold reserved.
```
