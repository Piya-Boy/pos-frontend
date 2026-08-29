# Customer Frontend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter customer order flow as a 100% visual/behavioral port of `cp-pos/` (Apps Script POS), backed by a fake API, ready to swap to Laravel later.

**Architecture:** Single Flutter app targeting Web + Mobile. `provider`/`ChangeNotifier` state (`CustomerController`) mirrors the old `state{}` object. UI talks only to an `ApiClient` interface; this phase ships a `FakeApiClient` seeded from `cp-pos/Database.js`. Widgets map 1:1 to CSS blocks in `cp-pos/Styles.html`.

**Tech Stack:** Flutter, provider, go_router, http, google_fonts (Prompt), intl, shared_preferences, cached_network_image.

**Spec:** `front.md` (this repo root). Read it before starting — every task references its section numbers.

## Global Constraints

- Flutter SDK floor: `^3.13.2` (existing `pos-frontend/pubspec.yaml`).
- **Dart package name = `pos_frontend`** (set in `pubspec.yaml`; Dart names use `_`, never `-`). All intra-project imports are `package:pos_frontend/...`. In Task 1 confirm `pubspec.yaml` has `name: pos_frontend` before running any test (the default scaffold shipped `name: frontend`; it was renamed). The stale `test/widget_test.dart` (imports `package:frontend/main.dart`) is deleted in T1 Step 7 — until then, only run the specific test file each step names, not the whole suite.
- Working dir for all Flutter commands: `pos-frontend/`.
- Thai UI strings copied **verbatim** from `cp-pos/Pages.html` + `App.html`. Never translate/edit. All code/comments in English.
- Design tokens copied **exactly** from `cp-pos/Styles.html:2-24` (see `front.md` §2). No guessed values.
- No Apps Script (`google.script.run`) anywhere. All backend access through `ApiClient`.
- Money format: `NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0)` → matches `฿85`, `฿1,234` (source `App.html:1288`).
- Poll interval: `max(5, pollSeconds)` seconds (source `App.html:1217`).
- Commit style: Conventional Commits (`feat:`/`test:`/`chore:`). Branch off non-main. No `Co-Authored-By`.
- **This repo lives in `pos-frontend/` (separate from backend).** git AND flutter both run from `pos-frontend/`. All paths are relative to `pos-frontend/`. Task bodies below sometimes write `pos-frontend/lib/...` for clarity — when running commands you are already inside `pos-frontend/`, so `git add lib test` (drop the `pos-frontend/` prefix). Never `cd` to a parent repo; there isn't one.
- Each task: write failing test → confirm fail → implement → confirm pass → commit.
- **When unsure about any Flutter/Dart API, widget, or package usage, look it up at https://docs.flutter.dev/ (and pub.dev for package APIs).** Do not guess API signatures.

---

### Task 0: Git branch (repo already inited)

**This is a SEPARATE git repo living in `pos-frontend/`.** It was already `git init`'d (main branch) with a Flutter `.gitignore`. Do NOT init at repo parent — frontend and backend are two independent repos.

**Paths in every task below are relative to `pos-frontend/`** (this repo's root). git + flutter both run from `pos-frontend/`. So `git add lib test pubspec.yaml` — NOT `pos-frontend/lib`.

**Files:** none new (`.gitignore` already present).

**Interfaces:** none.

- [ ] **Step 1: Create working branch**
```bash
cd "E:/Develop/CODING/POS/pos-frontend"
git checkout -b feature/customer-frontend
```
Never commit on `main`.

- [ ] **Step 2: Baseline commit (Flutter scaffold as-is)**
```bash
cd "E:/Develop/CODING/POS/pos-frontend"
git add .gitignore pubspec.yaml pubspec.lock analysis_options.yaml lib test web android ios linux macos windows README.md .metadata
git commit -m "chore: baseline Flutter scaffold"
```
(`.dart_tool/`, `build/`, `.idea/` are gitignored — fine if some dirs are absent.)

---

### Task 1: Project setup — deps, folders, tokens, theme, font

**Files:**
- Modify: `pos-frontend/pubspec.yaml`
- Create: `pos-frontend/lib/core/theme/tokens.dart`
- Create: `pos-frontend/lib/core/theme/phius_theme.dart`
- Create: `pos-frontend/lib/app.dart`
- Modify: `pos-frontend/lib/main.dart`
- Test: `pos-frontend/test/core/theme/tokens_test.dart`

**Interfaces:**
- Produces: `PhiusTokens` (static color/double consts), `phiusTheme()` → `ThemeData`, `PhiusApp` widget.

- [ ] **Step 1: Add dependencies**

Edit `pos-frontend/pubspec.yaml` `dependencies:` block (keep `flutter`, `cupertino_icons`):
```yaml
  provider: ^6.1.2
  go_router: ^14.0.0
  http: ^1.2.0
  google_fonts: ^6.2.1
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  cached_network_image: ^3.3.1
```
Run: `cd pos-frontend && flutter pub get`
Expected: resolves, no version conflict.

- [ ] **Step 2: Write failing test for tokens**

Create `pos-frontend/test/core/theme/tokens_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/theme/tokens.dart';

void main() {
  test('core colors match cp-pos Styles.html :root', () {
    expect(PhiusTokens.primary, const Color(0xFFB7442B));
    expect(PhiusTokens.primaryDark, const Color(0xFF8F301E));
    expect(PhiusTokens.bg, const Color(0xFFFBF7F0));
    expect(PhiusTokens.green, const Color(0xFF2F6B4F));
    expect(PhiusTokens.ink, const Color(0xFF211E1B));
  });

  test('radius + typography constants', () {
    expect(PhiusTokens.radiusSm, 12.0);
    expect(PhiusTokens.radius, 18.0);
    expect(PhiusTokens.radiusLg, 24.0);
    expect(PhiusTokens.baseFontSize, 15.0);
  });
}
```

- [ ] **Step 3: Run test, verify fail**

Run: `cd pos-frontend && flutter test test/core/theme/tokens_test.dart`
Expected: FAIL — `tokens.dart` / `PhiusTokens` not found.

- [ ] **Step 4: Implement tokens**

Create `pos-frontend/lib/core/theme/tokens.dart` (values from `Styles.html:2-24`):
```dart
import 'package:flutter/material.dart';

/// Design tokens ported verbatim from cp-pos/Styles.html :root.
class PhiusTokens {
  PhiusTokens._();

  // colors
  static const bg = Color(0xFFFBF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF4EEE5);
  static const ink = Color(0xFF211E1B);
  static const muted = Color(0xFF706A63);
  static const primary = Color(0xFFB7442B);
  static const primaryDark = Color(0xFF8F301E);
  static const primaryLight = Color(0xFFCE735C);
  static const green = Color(0xFF2F6B4F);
  static const greenSoft = Color(0xFFE1EEE7);
  static const saffron = Color(0xFFD9911D);
  static const saffronSoft = Color(0xFFFFF0D2);
  static const redSoft = Color(0xFFFBE5DE);
  static const border = Color(0xFFE7DED2);

  // shadows (box-shadow → BoxShadow)
  static const shadowSm = [
    BoxShadow(offset: Offset(0, 3), blurRadius: 12, color: Color(0x123A271C)),
  ];
  static const shadowMd = [
    BoxShadow(offset: Offset(0, 14), blurRadius: 40, color: Color(0x213A271C)),
  ];

  // radius
  static const radiusSm = 12.0;
  static const radius = 18.0;
  static const radiusLg = 24.0;

  // typography
  static const baseFontSize = 15.0;
  static const lineHeight = 1.55;
}
```
Note: `rgba(58,39,28,.07)` → `Color(0x123A271C)` (alpha .07≈0x12, RGB 3A271C). `.13`≈0x21.

- [ ] **Step 5: Run test, verify pass**

Run: `cd pos-frontend && flutter test test/core/theme/tokens_test.dart`
Expected: PASS.

- [ ] **Step 6: Implement theme + app shell**

Create `pos-frontend/lib/core/theme/phius_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

ThemeData phiusTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: PhiusTokens.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: PhiusTokens.primary,
      surface: PhiusTokens.surface,
      onSurface: PhiusTokens.ink,
    ),
    textTheme: GoogleFonts.promptTextTheme(base.textTheme).apply(
      bodyColor: PhiusTokens.ink,
      displayColor: PhiusTokens.ink,
    ),
  );
}
```

Create `pos-frontend/lib/app.dart` (router wired in Task 4; temporary home for now):
```dart
import 'package:flutter/material.dart';
import 'core/theme/phius_theme.dart';

class PhiusApp extends StatelessWidget {
  const PhiusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phius Order',
      debugShowCheckedModeBanner: false,
      theme: phiusTheme(),
      home: const Scaffold(body: Center(child: Text('Phius Order'))),
    );
  }
}
```

Replace `pos-frontend/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() => runApp(const PhiusApp());
```

- [ ] **Step 7: Verify build + delete stale default test**

Delete `pos-frontend/test/widget_test.dart` (references removed counter demo).
Run: `cd pos-frontend && flutter analyze && flutter test`
Expected: analyze clean, tokens test passes.

- [ ] **Step 8: Commit**
```bash
git add pos-frontend/pubspec.yaml pos-frontend/lib pos-frontend/test
git commit -m "chore: setup Flutter deps, design tokens, Prompt theme"
```

---

### Task 2: Models + API interface + FakeApiClient

**Files:**
- Create: `pos-frontend/lib/models/` — `app_config.dart`, `category.dart`, `option.dart`, `add_on.dart`, `menu_item.dart`, `promotion.dart`, `cart_line.dart`, `order_session.dart`, `order_item.dart`, `call_log.dart`, `session_bundle.dart`, `totals.dart`
- Create: `pos-frontend/lib/core/api/app_error.dart`, `api_result.dart`, `api_client.dart`, `fake_api_client.dart`
- Create: `pos-frontend/lib/core/utils/client_id.dart`
- Test: `pos-frontend/test/models/menu_item_test.dart`, `pos-frontend/test/core/api/fake_api_client_test.dart`

**Interfaces:**
- Produces:
  - Models with `fromJson(Map)` / `toJson()`. **Dart getters = camelCase; JSON keys = sheet-header PascalCase** (`Code`→`code`, `SessionID`→`sessionId`, `DiscountValue`→`discountValue`, etc.). `fromJson` reads PascalCase keys, `toJson` writes them back. `SubmitResult.sessionId` reads json `SessionID`. Never expose a PascalCase getter.
  - `AppError({required String code, required String message, Object? details})`.
  - `ApiResult<T>({required bool ok, T? data, AppError? error})`.
  - `abstract class ApiClient` with:
    - `Future<Map<String,dynamic>> bootstrap({required String tableToken})`
    - `Future<CustomerData> getCustomerData({required String tableToken})`
    - `Future<SubmitResult> submitOrder({required String tableToken, required String idempotencyKey, required String promoCode, required List<OrderRequestItem> items})`
    - `Future<SessionBundle> getOrderStatus({required String tableToken, required String sessionId})`
    - `Future<CallResult> callStaff({required String tableToken, required String type, required String idempotencyKey})`
  - `CustomerData({table, categories, menu, promotions, session})`, `OrderRequestItem({itemId, qty, optionIds, addOnIds, note})`, `SubmitResult`, `CallResult({call, duplicate})`.
  - `clientId(String prefix)` → `"{prefix}_{ms}_{rand}"` (source `App.html:1285`).

- [ ] **Step 1: Write failing model test**

Create `pos-frontend/test/models/menu_item_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/menu_item.dart';

void main() {
  test('MenuItem.fromJson maps sheet headers + nested', () {
    final item = MenuItem.fromJson({
      'ItemID': 'M001',
      'CategoryID': 'CAT_RICE',
      'Name': 'กะเพราหมูสับ',
      'Price': 85,
      'IsPopular': true,
      'available': true,
      'options': [
        {'OptionID': 'OPT001', 'ItemID': 'M001', 'GroupName': 'ระดับความเผ็ด', 'Label': 'ไม่เผ็ด', 'Price': 0, 'InputType': 'RADIO', 'IsRequired': true},
      ],
      'addOns': [
        {'AddOnID': 'ADD001', 'Name': 'ไข่ดาว', 'Price': 15},
      ],
    });
    expect(item.itemId, 'M001');
    expect(item.name, 'กะเพราหมูสับ');
    expect(item.price, 85);
    expect(item.isPopular, true);
    expect(item.available, true);
    expect(item.options.single.groupName, 'ระดับความเผ็ด');
    expect(item.addOns.single.price, 15);
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/models/menu_item_test.dart`
Expected: FAIL — `menu_item.dart` not found.

- [ ] **Step 3: Implement models**

Create each model. Example `pos-frontend/lib/models/option.dart`:
```dart
class Option {
  final String optionId;
  final String itemId;
  final String groupName;
  final String label;
  final num price;
  final String inputType; // RADIO | CHECKBOX
  final bool isRequired;

  const Option({
    required this.optionId,
    required this.itemId,
    required this.groupName,
    required this.label,
    required this.price,
    required this.inputType,
    required this.isRequired,
  });

  factory Option.fromJson(Map<String, dynamic> j) => Option(
        optionId: '${j['OptionID'] ?? ''}',
        itemId: '${j['ItemID'] ?? ''}',
        groupName: '${j['GroupName'] ?? 'ตัวเลือก'}',
        label: '${j['Label'] ?? ''}',
        price: (j['Price'] ?? 0) as num,
        inputType: '${j['InputType'] ?? 'CHECKBOX'}'.toUpperCase(),
        isRequired: _truthy(j['IsRequired']),
      );
}

bool _truthy(Object? v) =>
    v == true || '$v'.toLowerCase() == 'true' || '$v' == '1';
```
Create `add_on.dart` (AddOnID/Name/Price/LinkedItemID/LinkedCategoryID), `category.dart` (CategoryID/Name/Icon/SortOrder), `promotion.dart` (PromoID/Code/Name/Description/DiscountType/DiscountValue/MinSpend/BannerImage), `app_config.dart` (name/tagline/heroKicker/heroTitle/heroBadgeText/heroBadgeImageUrl/primaryColor/currency/currencySymbol/pollSeconds — from `Services.js:11-31`).
Create `menu_item.dart`:
```dart
import 'option.dart';
import 'add_on.dart';

class MenuItem {
  final String itemId, categoryId, name, description, imageUrl;
  final num price;
  final bool isPopular, available;
  final List<Option> options;
  final List<AddOn> addOns;

  const MenuItem({
    required this.itemId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isPopular,
    required this.available,
    required this.options,
    required this.addOns,
  });

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
        itemId: '${j['ItemID'] ?? ''}',
        categoryId: '${j['CategoryID'] ?? ''}',
        name: '${j['Name'] ?? ''}',
        description: '${j['Description'] ?? ''}',
        imageUrl: '${j['ImageURL'] ?? ''}',
        price: (j['Price'] ?? 0) as num,
        isPopular: _truthy(j['IsPopular']),
        available: j['available'] == null ? true : _truthy(j['available']),
        options: ((j['options'] as List?) ?? [])
            .map((e) => Option.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        addOns: ((j['addOns'] as List?) ?? [])
            .map((e) => AddOn.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

bool _truthy(Object? v) =>
    v == true || '$v'.toLowerCase() == 'true' || '$v' == '1';
```
Create `order_session.dart` (SessionID/TableID/Status/Subtotal/Discount/ServiceCharge/Vat/Total/PromoCode), `order_item.dart` (OrderItemID/SessionID/ItemID/ItemName/Qty/UnitPrice/LineTotal/Note/Status + parsed `options`/`addOns` from OptionsJSON/AddOnsJSON — see `Services.js:345-352`), `call_log.dart` (LogID/TableID/SessionID/Type/Status), `session_bundle.dart` (`{OrderSession session, List<OrderItem> items, List<CallLog> calls}`), `totals.dart` (subtotal/discount/serviceCharge/vat/total + `Promotion? promo`), `cart_line.dart` (lineId/itemId/name/image/basePrice/qty/optionIds/addOnIds/`List<Option> options`/`List<AddOn> addOns`/note/unitPrice + `toJson`/`fromJson` for shared_preferences).

- [ ] **Step 4: Run model test, verify pass**

Run: `cd pos-frontend && flutter test test/models/menu_item_test.dart`
Expected: PASS.

- [ ] **Step 5: Write failing FakeApiClient test**

Create `pos-frontend/test/core/api/fake_api_client_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';

void main() {
  test('getCustomerData returns seeded catalog', () async {
    final api = FakeApiClient();
    final data = await api.getCustomerData(tableToken: 'any');
    expect(data.menu.length, 8);
    expect(data.categories.length, 5);
    expect(data.menu.any((m) => m.name == 'กะเพราหมูสับ'), true);
    expect(data.promotions.single.code, 'WELCOME10');
  });

  test('submitOrder is idempotent per key', () async {
    final api = FakeApiClient();
    final items = [const OrderRequestItem(itemId: 'M001', qty: 2, optionIds: ['OPT002'], addOnIds: [], note: '')];
    final a = await api.submitOrder(tableToken: 't', idempotencyKey: 'k1', promoCode: '', items: items);
    final b = await api.submitOrder(tableToken: 't', idempotencyKey: 'k1', promoCode: '', items: items);
    expect(a.sessionId, b.sessionId);
  });
}
```

- [ ] **Step 6: Run, verify fail**

Run: `cd pos-frontend && flutter test test/core/api/fake_api_client_test.dart`
Expected: FAIL — `fake_api_client.dart` not found.

- [ ] **Step 7: Implement api layer + fake**

Create `app_error.dart`, `api_result.dart`, `client_id.dart`:
```dart
// client_id.dart — port of App.html:1285
int _seq = 0;
String clientId(String prefix) {
  final ms = DateTime.now().millisecondsSinceEpoch;
  final rand = (ms ^ (_seq++ << 8)).toRadixString(36);
  return '${prefix}_${ms}_$rand';
}
```
Create `api_client.dart` with the abstract class + DTOs listed in Interfaces.
Create `fake_api_client.dart` implementing `ApiClient`. Seed from `cp-pos/Database.js:270-319` (`seedCatalog_`): 5 categories (CAT_RICE/SHARED/NOODLE/DRINK/DESSERT), 8 menu items (M001–M008 with exact Thai names/prices/ImageURL), options (OPT001-004), add-ons (ADD001-004 with LinkedCategoryID/LinkedItemID scope), promotion WELCOME10 (PERCENT 10, MinSpend 500). Build each `MenuItem` with joined `options` (match ItemID) + `addOns` (global + item + category scope, per `Services.js:87-124`). `available = Status == 'ACTIVE'`.
Implement `submitOrder`: keep an in-memory `Map<String,SubmitResult>` keyed by `idempotencyKey`; compute totals like `recalculateSessionTotals_` (`Services.js:357`): subtotal = Σ lineTotal, promo discount if subtotal≥MinSpend, serviceCharge/vat = 0 (seed settings), total. Store an in-memory session; `getOrderStatus` returns its bundle. `callStaff` returns `CallResult(call: ..., duplicate: false)` first time, `duplicate: true` on repeat same type.

- [ ] **Step 8: Run fake test, verify pass**

Run: `cd pos-frontend && flutter test test/core/api/fake_api_client_test.dart`
Expected: PASS.

- [ ] **Step 9: Commit**
```bash
git add pos-frontend/lib/models pos-frontend/lib/core pos-frontend/test
git commit -m "feat: models, ApiClient interface, seeded FakeApiClient"
```

---

### Task 3: Shared widgets

**Files:**
- Create: `pos-frontend/lib/features/shared/widgets/` — `brand_mark.dart`, `app_buttons.dart`, `status_capsule.dart`, `network_banner.dart`, `modal_sheet.dart`, `eyebrow_text.dart`, `app_footer.dart`
- Create: `pos-frontend/lib/core/utils/formatters.dart`
- Test: `pos-frontend/test/core/utils/formatters_test.dart`, `pos-frontend/test/features/shared/brand_mark_test.dart`

**Interfaces:**
- Produces: `formatMoney(num)` → String; `placeholderImage(String label)` → String URL; `BrandMark({small, logoUrl, logoText})`; `PrimaryButton`/`SecondaryButton`/`OutlineButton`/`GhostButton`/`AppIconButton`; `showPhiusModal(context, {child, className})` → bottom-sheet; `StatusCapsule` + `showToast(context, msg, {isError})`; `NetworkBanner`; `EyebrowText`; `AppFooter`.

- [ ] **Step 1: Write failing formatter test**

Create `pos-frontend/test/core/utils/formatters_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/utils/formatters.dart';

void main() {
  test('formatMoney matches th-TH baht (maxFractionDigits 2)', () {
    expect(formatMoney(85), '฿85');
    expect(formatMoney(1234), '฿1,234');
    expect(formatMoney(0), '฿0');
    expect(formatMoney(12.5), '฿12.50'); // shows decimals only when present
    expect(formatMoney(12), '฿12');
  });

  test('placeholderImage builds placehold.co url', () {
    expect(placeholderImage('อาหารไทย'),
        startsWith('https://placehold.co/900x700/F4EEE5/706A63?text='));
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/core/utils/formatters_test.dart`
Expected: FAIL — `formatters.dart` not found.

- [ ] **Step 3: Implement formatters**

Create `pos-frontend/lib/core/utils/formatters.dart`:
```dart
import 'package:intl/intl.dart';

// Ports App.html:1288 — Intl th-TH currency, maximumFractionDigits: 2.
// JS drops trailing zeros (85 → ฿85) but keeps real decimals (12.5 → ฿12.50).
final _moneyInt = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);
final _moneyDec = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 2);

String formatMoney(num value) =>
    value == value.roundToDouble() ? _moneyInt.format(value) : _moneyDec.format(value);

String placeholderImage(String label) {
  final text = Uri.encodeComponent(label.isEmpty ? 'Menu' : label);
  return 'https://placehold.co/900x700/F4EEE5/706A63?text=$text';
}
```

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/core/utils/formatters_test.dart`
Expected: PASS. (If locale data missing, first line of test file: call is fine — `intl` bundles th_TH.)

- [ ] **Step 5: Write failing BrandMark widget test**

Create `pos-frontend/test/features/shared/brand_mark_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/features/shared/widgets/brand_mark.dart';

void main() {
  testWidgets('BrandMark shows logo text when no image', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BrandMark(logoText: 'ผ')),
    ));
    expect(find.text('ผ'), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/shared/brand_mark_test.dart`
Expected: FAIL — not found.

- [ ] **Step 7: Implement shared widgets**

Create `brand_mark.dart` (`.brand-mark` `Styles.html:47-50`): 64×64 (small 44×44) rounded 22 (small 14), primary bg white text centered; if `logoUrl` non-empty → `CachedNetworkImage` contain on surface bg, fallback to text on error.
Create `app_buttons.dart` (`.btn*` `Styles.html:61-73`): min-height 44, radius 14, weight 600; PrimaryButton primary bg white + shadow; SecondaryButton green; OutlineButton primary border transparent bg; GhostButton border+surface; AppIconButton 44×44 border surface. All accept `onPressed`, `child`/`label`, `disabled`.
Create `modal_sheet.dart` (`.modal-*` `Styles.html:189-195`, `App.html:1175`): `showPhiusModal` = `showModalBottomSheet` isScrollControlled, bg `PhiusTokens.bg`, top radius 26, max-height `mediaQuery.height - 24`, child with sticky header/footer support.
Create `status_capsule.dart` (`.status-capsule` `Styles.html:56-58`): `showToast(context, msg, {isError})` → overlay pill bottom-center, ink bg (success green, error primaryDark), auto-dismiss `isError ? 5200ms : 3200ms` (source `App.html:1199`).
Create `network_banner.dart` (`.network-banner` `Styles.html:55`): saffron top banner "ออฟไลน์" when offline.
Create `eyebrow_text.dart` (`.eyebrow` `:60`): uppercase 11px primary weight 700 letterSpacing .12em.
Create `app_footer.dart` (`.app-footer` `:344`): muted 10px centered "Created by CodingPhius Creativities · alphaphius.tkh@gmail.com" (verbatim `Pages.html:30`).

- [ ] **Step 8: Run, verify pass + analyze**

Run: `cd pos-frontend && flutter test test/features/shared/ && flutter analyze`
Expected: PASS, analyze clean.

- [ ] **Step 9: Commit**
```bash
git add pos-frontend/lib/features/shared pos-frontend/lib/core/utils pos-frontend/test
git commit -m "feat: shared widgets (brand, buttons, modal, toast, banner)"
```

---

### Task 4: Router + CustomerController + persistence

**Files:**
- Create: `pos-frontend/lib/core/router/app_router.dart`
- Create: `pos-frontend/lib/state/customer_controller.dart`
- Modify: `pos-frontend/lib/app.dart`, `pos-frontend/lib/main.dart`
- Test: `pos-frontend/test/state/customer_controller_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, models (Task 2).
- Produces: `CustomerController extends ChangeNotifier` with fields `search`, `activeCategory` (default `'ALL'`), `List<CartLine> cart`, `SessionBundle? session`, `bool paymentComplete`, `AppConfig? app`, `CustomerData? data`; methods `load()`, `setSearch(String)`, `setCategory(String)`, `List<MenuItem> filteredMenu()`, `addToCart(CartLine)`, `removeLine(String lineId)`, `changeQty(String lineId, int delta)`, `num cartCount()`, `num cartSubtotal()`, `Future<void> submit(String promoCode)`, `Future<void> callStaff(String type)`, `Future<void> refreshStatus()`, `startPolling()`, `stopPolling()`. `appRouter(ApiClient)` → `GoRouter`.

- [ ] **Step 1: Write failing controller test**

Create `pos-frontend/test/state/customer_controller_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/state/customer_controller.dart';
import 'package:pos_frontend/models/cart_line.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('filteredMenu respects category + search', () async {
    final c = CustomerController(api: FakeApiClient(), tableToken: 't');
    await c.load();
    expect(c.filteredMenu().length, 8);
    c.setCategory('CAT_DRINK');
    expect(c.filteredMenu().every((m) => m.categoryId == 'CAT_DRINK'), true);
    c.setCategory('ALL');
    c.setSearch('ผัดไทย');
    expect(c.filteredMenu().any((m) => m.name.contains('ผัดไทย')), true);
  });

  test('addToCart + changeQty + subtotal', () async {
    final c = CustomerController(api: FakeApiClient(), tableToken: 't');
    await c.load();
    c.addToCart(CartLine(
      lineId: 'l1', itemId: 'M001', name: 'กะเพราหมูสับ', image: '',
      basePrice: 85, qty: 1, optionIds: const [], addOnIds: const [],
      options: const [], addOns: const [], note: '', unitPrice: 85));
    expect(c.cartCount(), 1);
    c.changeQty('l1', 1);
    expect(c.cartSubtotal(), 170);
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/state/customer_controller_test.dart`
Expected: FAIL — `customer_controller.dart` not found.

- [ ] **Step 3: Implement controller**

Create `pos-frontend/lib/state/customer_controller.dart`. Port logic from `App.html`:
- `filteredMenu()` = `App.html:402` (category match + lowercase search in name+description).
- `addToCart`/`removeLine`/`changeQty` mutate `cart`, then `_saveCart()` + `notifyListeners()`.
- persistence: `shared_preferences` keys `phius-cart-$tableToken`, `phius-session-$tableToken` (`App.html:672-673`); on `load()`, restore cart filtered to available items (`App.html:667`).
- `submit(promoCode)`: guard `_submitting`/empty cart; gen `checkoutKey` once via `clientId('order')`; call `api.submitOrder`; on success clear cart, store sessionId, `refreshStatus()`, `startPolling()`.
- `refreshStatus()`: `api.getOrderStatus`; if status in {PAID,CLOSED,CANCELLED} → clear cart/session, `paymentComplete = (status=='PAID')`, `stopPolling()`; else set `session`.
- `callStaff(type)`: guard BILL needs session; call api; `refreshStatus()`.
- `startPolling()`: `Timer.periodic(Duration(seconds: max(5, app.pollSeconds)), ...)` calling `refreshStatus()`; only when a sessionId exists (`App.html:1217`). `stopPolling()` cancels.

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/state/customer_controller_test.dart`
Expected: PASS.

- [ ] **Step 5: Implement router + wire app**

Create `pos-frontend/lib/core/router/app_router.dart`:
```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'api/api_client.dart';
// CustomerPage import added in Task 5; placeholder until then.

GoRouter appRouter(ApiClient api) => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final page = state.uri.queryParameters['page'] ?? 'home';
            final table = state.uri.queryParameters['table'] ?? '';
            // page=='order' → CustomerPage(api, table). Others → Phase 2.
            return _routeFor(api, page, table);
          },
        ),
      ],
    );

Widget _routeFor(ApiClient api, String page, String table) {
  // Task 5 replaces this with CustomerPage for 'order'.
  return const Scaffold(body: Center(child: Text('Phius Order')));
}
```
Update `app.dart` to `MaterialApp.router(routerConfig: appRouter(api), theme: phiusTheme())`, taking an injected `ApiClient` (default `FakeApiClient()`). Update `main.dart` to build `PhiusApp(api: FakeApiClient())`.

- [ ] **Step 6: Verify build**

Run: `cd pos-frontend && flutter analyze && flutter test`
Expected: analyze clean, all tests pass.

- [ ] **Step 7: Commit**
```bash
git add pos-frontend/lib pos-frontend/test
git commit -m "feat: go_router + CustomerController with persistence"
```

---

### Task 5: CustomerPage shell — Header, Guide, Hero

**Files:**
- Create: `pos-frontend/lib/features/customer/customer_page.dart`
- Create: `pos-frontend/lib/features/customer/widgets/customer_header.dart`, `customer_guide.dart`, `customer_hero.dart`
- Modify: `pos-frontend/lib/core/router/app_router.dart`
- Test: `pos-frontend/test/features/customer/customer_page_test.dart`

**Interfaces:**
- Consumes: `CustomerController`, `AppConfig`, shared widgets.
- Produces: `CustomerPage({required ApiClient api, required String tableToken})` — provides its own `CustomerController` via `ChangeNotifierProvider`.

- [ ] **Step 1: Write failing widget test**

Create `pos-frontend/test/features/customer/customer_page_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders restaurant name + guide steps', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('วิธีสั่งอาหาร'), findsOneWidget);
    expect(find.textContaining('เลือกเมนูโปรด'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/customer/customer_page_test.dart`
Expected: FAIL — `customer_page.dart` not found.

- [ ] **Step 3: Implement header/guide/hero + page shell**

Create `customer_header.dart` (§4.2, `Pages.html:36-45`): Row — BrandMark(small) + Column(EyebrowText tagline, restaurant name h1 21px) | TablePill ("โต๊ะ" 10px muted over table name 14px bold, border+shadow, min 76×48).
Create `customer_guide.dart` (§4.3, `Pages.html:47-54`): custom ExpansionTile collapsed; summary "ⓘ วิธีสั่งอาหาร / แตะเพื่อดูขั้นตอน"; 3 numbered steps verbatim: (1)"เลือกเมนู"/"เลือกตัวเลือกและส่วนเพิ่มที่ต้องการ" (2)"ตรวจตะกร้าและส่งออเดอร์"/"ราคาแต่ละรายการและยอดรวมจะแสดงก่อนยืนยัน" (3)"ติดตามสถานะและเรียกเก็บเงิน"/"ดูรายการของโต๊ะได้ตลอดจนชำระเสร็จ".
Create `customer_hero.dart` (§4.5, `Pages.html:60-67`): gradient container (§2), left = hero-kicker + heroTitle (pre-line `\n`, `เลือกเมนูโปรด\nแล้วส่งตรงถึงครัว`), right = HeroEmblem (circular, rotate -9°, text `อร่อย` or image w/ fallback).
Create `customer_page.dart` (§4.1): `ChangeNotifierProvider(create: (_) => CustomerController(api, tableToken)..load())`; `Consumer` builds a `Stack`: scrollable `Column` (Header, Guide, Hero, then placeholders for Menu/Tracking added in T6/T9) + AppFooter, plus overlay slots for CartBar (T8) and BillBanner (T9). Center content max-width 1120, padding per breakpoint.
Update `app_router.dart` `_routeFor`: `if (page == 'order') return CustomerPage(api: api, tableToken: table);`.

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/features/customer/customer_page_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add pos-frontend/lib/features/customer pos-frontend/lib/core/router pos-frontend/test
git commit -m "feat: customer page shell (header, guide, hero)"
```

---

### Task 6: Menu — PromotionStrip, MenuToolbar, MenuSection, FoodCard

**Files:**
- Create: `pos-frontend/lib/features/customer/widgets/promotion_strip.dart`, `menu_toolbar.dart`, `menu_section.dart`, `food_card.dart`
- Modify: `pos-frontend/lib/features/customer/customer_page.dart`
- Test: `pos-frontend/test/features/customer/menu_test.dart`

**Interfaces:**
- Consumes: `CustomerController` (filteredMenu, search, activeCategory), `MenuItem`, `Promotion`, `Category`.
- Produces: `PromotionStrip`, `MenuToolbar`, `MenuSection`, `FoodCard({required MenuItem item, required VoidCallback onQuickAdd})`. `int menuColumns(double width)` helper (2/3/4).

- [ ] **Step 1: Write failing test**

Create `pos-frontend/test/features/customer/menu_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';
import 'package:pos_frontend/features/customer/widgets/menu_section.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('menu shows count and food cards', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('8 เมนู'), findsOneWidget);
    expect(find.text('กะเพราหมูสับ'), findsWidgets);
  });

  test('menuColumns breakpoints', () {
    expect(menuColumns(400), 2);
    expect(menuColumns(700), 3);
    expect(menuColumns(1000), 4);
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/customer/menu_test.dart`
Expected: FAIL — widgets not found.

- [ ] **Step 3: Implement menu widgets**

Create `food_card.dart` (§4.9, `App.html:407-418`): Card border+radius 19+shadowSm; image `AspectRatio(1.15)` `CachedNetworkImage` cover, errorWidget→`placeholderImage('อาหารไทย')`; badge top-left ("เมนูยอดนิยม" green if available+popular / "หมดชั่วคราว" ink if !available); body: name h3, 2-line description clamp, footer Row(price primaryDark bold, quick-add `+` 40×40 primary). If !available: opacity .66 + quick-add disabled.
Create `promotion_strip.dart` (§4.6, `App.html:381`): horizontal `ListView` scroll-snap; hide if empty; PromoCard = bg image + dark left-gradient overlay + Code/Name/Description; image error → drop image.
Create `menu_toolbar.dart` (§4.7, `App.html:392`): sticky; search field ("ค้นหาเมนูที่อยากทาน", icon ⌕) → `controller.setSearch`; chip row categories prepend "ทั้งหมด" 🍽️ id ALL; active chip primary bg white.
Create `menu_section.dart` (§4.8, `App.html:399`): heading (eyebrow "เมนูของร้าน" + h2 "เลือกอาหาร" + count "{n} เมนู"); wrap grid in `LayoutBuilder`, use `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: menuColumns(constraints.maxWidth))` (must be this delegate type — Task 10 test casts it) of FoodCard; `shrinkWrap: true`, `physics: NeverScrollableScrollPhysics()` (page scrolls); empty state "🍽️ ยังไม่พบเมนู / ลองเปลี่ยนคำค้นหรือเลือกหมวดอื่น" when 0. `onQuickAdd` opens ItemDetailModal (T7 — wire as callback, stub `() {}` until then).
Add `int menuColumns(double w) => w >= 900 ? 4 : w >= 640 ? 3 : 2;` in `menu_section.dart`.
Insert PromotionStrip + MenuToolbar + MenuSection into `customer_page.dart` Column between Hero and Tracking placeholder.

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/features/customer/menu_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add pos-frontend/lib/features/customer pos-frontend/test
git commit -m "feat: menu (promotions, toolbar, grid, food card)"
```

---

### Task 7: ItemDetailModal

**Files:**
- Create: `pos-frontend/lib/features/customer/widgets/item_detail_modal.dart`
- Modify: `pos-frontend/lib/features/customer/widgets/menu_section.dart` (wire onQuickAdd)
- Test: `pos-frontend/test/features/customer/item_modal_test.dart`

**Interfaces:**
- Consumes: `MenuItem`, `CustomerController.addToCart`, `showPhiusModal`, `showToast`.
- Produces: `openItemModal(BuildContext, MenuItem, CustomerController)` → shows modal; on confirm builds a `CartLine` and calls `addToCart`.

- [ ] **Step 1: Write failing test**

Create `pos-frontend/test/features/customer/item_modal_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('quick-add opens modal with options + live total', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    // M001 กะเพราหมูสับ has required RADIO group ระดับความเผ็ด
    await tester.tap(find.byTooltip('เลือก กะเพราหมูสับ').first);
    await tester.pumpAndSettle();
    expect(find.text('ระดับความเผ็ด'), findsOneWidget);
    expect(find.textContaining('เพิ่มลงตะกร้า'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/customer/item_modal_test.dart`
Expected: FAIL — modal/tooltip not present.

- [ ] **Step 3: Implement modal**

Create `item_detail_modal.dart` (§4.10, `App.html:423-491`):
- Group `item.options` by `groupName`. Per group: if any option `isRequired` → required; render RADIO (if first option InputType RADIO) else CHECKBOX; header shows group name + "จำเป็นต้องเลือก" (required) / "เลือกได้". RADIO required → first option pre-selected (`App.html:432`).
- Add-ons section "เพิ่มความอร่อย" / "เลือกได้หลายรายการ" (CHECKBOX) when `item.addOns` non-empty.
- Note `TextField` "หมายเหตุถึงครัว", maxLength 300, placeholder "เช่น ไม่ใส่ผัก แยกน้ำ".
- Qty stepper (min 1), footer PrimaryButton "เพิ่มลงตะกร้า · {liveTotal}".
- Live total (`App.html:452`): `(basePrice + Σ selected option.price + Σ selected addOn.price) × qty`, recompute on any change via `StatefulBuilder`/local state.
- Confirm (`App.html:467`): validate every required group has a selection; else `showToast(context, 'กรุณาเลือก {groupName}', isError:true)` and abort. Build `CartLine(lineId: clientId('line'), itemId, name, image, basePrice, qty, optionIds, addOnIds, options(selected), addOns(selected), note, unitPrice)`, call `controller.addToCart`, close, `showToast('เพิ่ม {name} ลงตะกร้าแล้ว')`.
Wire `menu_section.dart` `onQuickAdd` → `openItemModal(context, item, controller)`. FoodCard quick-add `Tooltip(message: 'เลือก ${item.name}')` so the test can find it.

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/features/customer/item_modal_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add pos-frontend/lib/features/customer pos-frontend/test
git commit -m "feat: item detail modal (options, addons, note, qty, live price)"
```

---

### Task 8: Cart — CartBar + CartModal + submit

**Files:**
- Create: `pos-frontend/lib/features/customer/widgets/cart_bar.dart`, `cart_modal.dart`
- Modify: `pos-frontend/lib/features/customer/customer_page.dart`
- Test: `pos-frontend/test/features/customer/cart_test.dart`

**Interfaces:**
- Consumes: `CustomerController` (cart, cartCount, cartSubtotal, session, submit, removeLine, changeQty), `Promotion`.
- Produces: `CartBar`, `openCartModal(BuildContext, CustomerController)`.

- [ ] **Step 1: Write failing test**

Create `pos-frontend/test/features/customer/cart_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('add item then cart bar appears and opens cart', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('เลือก ชาไทยเย็น').first); // M006 no required options
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('เพิ่มลงตะกร้า'));
    await tester.pumpAndSettle();
    expect(find.text('ดูตะกร้า →'), findsOneWidget);
    await tester.tap(find.text('ดูตะกร้า →'));
    await tester.pumpAndSettle();
    expect(find.text('ตะกร้าของคุณ'), findsOneWidget);
    expect(find.text('ยืนยันการสั่งอาหาร'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/customer/cart_test.dart`
Expected: FAIL — cart bar/modal not present.

- [ ] **Step 3: Implement cart**

Create `cart_bar.dart` (§4.11, `App.html:493`): 3 states — items>0 ("{n} รายการในตะกร้า" + subtotal + "ดูตะกร้า →" → openCartModal); else session open with items ("{n} รายการของโต๊ะ" + session.Total + "ดูรายละเอียด"/"รอชำระเงิน" if PAYMENT_PENDING → scroll to tracking); else hidden. Fixed bottom center overlay in the page Stack.
Create `cart_modal.dart` (§4.12, `App.html:525-575`): header "ตรวจสอบก่อนส่ง / ตะกร้าของคุณ"; list each line (name×qty, "{unitPrice} ต่อรายการ", options/addons/note, "นำออก" button, stepper) → removeLine/changeQty; promo `TextField` "โค้ดโปรโมชั่น" placeholder "เช่น WELCOME10", helper "ระบบจะตรวจสิทธิ์และยอดขั้นต่ำอีกครั้งก่อนยืนยัน"; totals card ("ยอดสินค้าโดยประมาณ" subtotal, "ส่วนลดโดยประมาณ" if promo valid & subtotal≥MinSpend, grand "ประมาณการ"); footer PrimaryButton "ยืนยันการสั่งอาหาร" → `controller.submit(promoCode)`; on success close + `showToast('ส่งออเดอร์เข้าครัวแล้ว')` + scroll to tracking. Promo estimate math per `App.html:528-530`.
Insert CartBar into `customer_page.dart` Stack overlay.

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/features/customer/cart_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add pos-frontend/lib/features/customer pos-frontend/test
git commit -m "feat: cart bar + cart modal + order submit"
```

---

### Task 9: OrderTrackingSection + BillStatusBanner + status meta + polling

**Files:**
- Create: `pos-frontend/lib/features/customer/widgets/order_tracking_section.dart`, `bill_status_banner.dart`, `status_meta.dart`
- Modify: `pos-frontend/lib/features/customer/customer_page.dart`
- Test: `pos-frontend/test/features/customer/tracking_test.dart`, `pos-frontend/test/features/customer/status_meta_test.dart`

**Interfaces:**
- Consumes: `CustomerController` (session, paymentComplete, callStaff, refreshStatus), `OrderItem`, `SessionBundle`.
- Produces: `OrderTrackingSection`, `BillStatusBanner`, `StatusMeta statusMeta(String status)` → `{label, icon, dotColor, pillFg, pillBg}`.

- [ ] **Step 1: Write failing status meta test**

Create `pos-frontend/test/features/customer/status_meta_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/features/customer/widgets/status_meta.dart';

void main() {
  test('statusMeta ports App.html:1295 customer states', () {
    expect(statusMeta('NEW').label, 'ออเดอร์ใหม่');
    expect(statusMeta('PREPARING').label, 'กำลังปรุง');
    expect(statusMeta('READY').label, 'พร้อมเสิร์ฟ');
    expect(statusMeta('SERVED').label, 'เสิร์ฟแล้ว');
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/customer/status_meta_test.dart`
Expected: FAIL — not found.

- [ ] **Step 3: Implement status meta**

Create `status_meta.dart` (source `App.html:1295-1303`, customer subset):
```dart
import 'package:flutter/material.dart';
import 'core/theme/tokens.dart';

class StatusMeta {
  final String label, icon;
  final Color dotColor, pillFg, pillBg;
  const StatusMeta(this.label, this.icon, this.dotColor, this.pillFg, this.pillBg);
}

StatusMeta statusMeta(String status) {
  switch (status) {
    case 'PREPARING':
      return const StatusMeta('กำลังปรุง', '🔥', PhiusTokens.primary, PhiusTokens.primaryDark, PhiusTokens.redSoft);
    case 'READY':
      return const StatusMeta('พร้อมเสิร์ฟ', '✓', PhiusTokens.green, PhiusTokens.green, PhiusTokens.greenSoft);
    case 'SERVED':
      return const StatusMeta('เสิร์ฟแล้ว', '✓', PhiusTokens.green, PhiusTokens.green, PhiusTokens.greenSoft);
    case 'NEW':
    default:
      return const StatusMeta('ออเดอร์ใหม่', '●', PhiusTokens.saffron, Color(0xFF754707), PhiusTokens.saffronSoft);
  }
}
```

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test test/features/customer/status_meta_test.dart`
Expected: PASS.

- [ ] **Step 5: Write failing tracking widget test**

Create `pos-frontend/test/features/customer/tracking_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('empty tracking + service actions render', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('พร้อมรับออเดอร์'), findsOneWidget);
    expect(find.text('เรียกพนักงาน'), findsOneWidget);
    expect(find.text('เรียกเก็บเงิน'), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run, verify fail**

Run: `cd pos-frontend && flutter test test/features/customer/tracking_test.dart`
Expected: FAIL — tracking section not present.

- [ ] **Step 7: Implement tracking + bill banner + polling**

Create `order_tracking_section.dart` (§4.13, `App.html:618-661`): heading (eyebrow "อัปเดตล่าสุด" + h2 "ออเดอร์ของโต๊ะ" + "รีเฟรช" ghost button → refreshStatus); content states:
- no items → empty state "🥢 พร้อมรับออเดอร์ / เลือกรายการที่ต้องการแล้วกดดูตะกร้า"; if `paymentComplete` → info box "✓ ชำระเงินเรียบร้อยแล้ว / โต๊ะถูกรีเซตและพร้อมสำหรับการสั่งรอบใหม่".
- has items → per item Row(status-dot `statusMeta.dotColor`, main: title(name×qty + lineTotal), "{unitPrice} ต่อรายการ", options/addons/note, status-pill `icon label` colors); then totals card (ยอดก่อนส่วนลด / ส่วนลด / ค่าบริการ / VAT / ยอดรวมทั้งหมด — show non-zero rows only, `App.html:660`).
- bill pending → inline banner "🧾 แจ้งเรียกเก็บเงินแล้ว / คุณยังตรวจสอบยอดและรายการทั้งหมดได้ระหว่างรอ".
- service-actions Row: SecondaryButton "🛎️ เรียกพนักงาน" (→ callStaff ASSISTANCE), OutlineButton "🧾 {billLabel}" (→ callStaff BILL); disable when closed / bill pending; BILL label → "เรียกเก็บเงินแล้ว" when pending (`App.html:641`).
Create `bill_status_banner.dart` (§4.4): top-center overlay, visible when `isBillPending(session)`; "🧾 เรียกเก็บเงินแล้ว / พนักงานได้รับแจ้งแล้ว กรุณารอสักครู่". Add `bool isBillPending(SessionBundle?)` per `App.html:648`.
Insert OrderTrackingSection into page Column, BillStatusBanner into Stack overlay. In `CustomerController`, start polling after load if a session exists; stop on `AppLifecycleState.paused`.

- [ ] **Step 8: Run, verify pass**

Run: `cd pos-frontend && flutter test test/features/customer/tracking_test.dart`
Expected: PASS.

- [ ] **Step 9: Commit**
```bash
git add pos-frontend/lib/features/customer pos-frontend/test
git commit -m "feat: order tracking, bill banner, status meta, polling"
```

---

### Task 10: Responsive + parity pass

**Files:**
- Modify: customer widgets as needed for breakpoints.
- Create: `pos-frontend/test/features/customer/responsive_test.dart`

**Interfaces:**
- Consumes: all prior. No new public API.

- [ ] **Step 1: Write failing responsive test**

Create `pos-frontend/test/features/customer/responsive_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('menu grid is 4 cols on wide screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    final grid = tester.widget<GridView>(find.byType(GridView).first);
    final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });
}
```

- [ ] **Step 2: Run, verify fail (or pass)**

Run: `cd pos-frontend && flutter test test/features/customer/responsive_test.dart`
Expected: FAIL if grid not yet width-driven; if already correct from Task 6, proceed to parity fixes.

- [ ] **Step 3: Apply breakpoints**

Ensure `menu_section.dart` uses `LayoutBuilder` width → `menuColumns`. Apply §3: customer-page horizontal padding 16 (<640) / 24 (≥640) / 32 (≥900); hero-emblem smaller ≤430; service-actions 1 col ≤430; promo card width per breakpoint. Use `MediaQuery.sizeOf(context).width`.

- [ ] **Step 4: Run, verify pass**

Run: `cd pos-frontend && flutter test`
Expected: all tests pass.

- [ ] **Step 5: Manual parity check**

Run: `cd pos-frontend && flutter run -d chrome --web-port 5599` then open `http://localhost:5599/?page=order&table=demo`.
Compare side-by-side with the cp-pos customer screen (open old deployment or `App.html`). Verify: colors, spacing, hero gradient, menu grid, food cards, item modal, cart, tracking. Fix any pixel diffs in the relevant widget.

- [ ] **Step 6: Final analyze + commit**
```bash
cd pos-frontend && flutter analyze
git add pos-frontend/lib pos-frontend/test
git commit -m "feat: responsive breakpoints + parity pass for customer flow"
```

---

## Self-Review notes

- **Spec coverage**: front.md §4.1–4.14 → Tasks 5–9; §5 models → Task 2; §6 API → Task 2; §7 state → Task 4; §2 tokens → Task 1; §3 responsive → Task 10. Login/Ops/Admin explicitly Phase 2 (front.md §10) — out of scope, no task.
- **Not in this plan** (deferred): real Laravel wiring, WebSocket realtime (polling used per front.md §7), font bundling decision (front.md §10 — `google_fonts` used here; revisit for offline).
- **Types**: `CartLine`, `MenuItem`, `Option`, `AddOn`, `SessionBundle`, `OrderRequestItem`, `StatusMeta` used consistently across tasks as defined in Task 2 / Task 9 Interfaces.
```
