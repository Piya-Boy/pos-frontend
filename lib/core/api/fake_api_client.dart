export 'api_client.dart';

import '../../models/add_on.dart';
import '../../models/call_log.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../models/option.dart';
import '../../models/order_item.dart';
import '../../models/order_session.dart';
import '../../models/promotion.dart';
import '../../models/session_bundle.dart';
import '../../models/staff_models.dart';
import '../../models/totals.dart';
import '../utils/client_id.dart';
import 'api_client.dart';
import 'app_error.dart';

class FakeApiClient implements ApiClient {
  final Map<String, SubmitResult> _submissions = {};
  final Map<String, SessionBundle> _sessions = {};
  final Map<String, CallResult> _calls = {};
  final Map<String, StaffSession> _staffTokens = {};
  final Map<String, String> _staffPins = {};
  final Map<String, OpsOrderItem> _opsItems = {};
  final Map<String, OpsSession> _opsSessions = {};
  final Map<String, OpsCall> _opsCalls = {};
  final Map<String, Receipt> _receipts = {};
  final Map<String, List<Map<String, dynamic>>> _adminEntities = {};
  final Map<String, dynamic> _settings = {
    'AppName': 'Phius Order',
    'RestaurantName': 'Phius Thai Kitchen',
    'PrimaryColor': '#B7442B',
    'OrderPollingSeconds': '10',
  };

  FakeApiClient() {
    final now = DateTime.now().toUtc();
    const table = {
      'TableID': 'T01',
      'Name': 'โต๊ะ 01',
      'Zone': 'โซนด้านใน',
      'Status': 'OCCUPIED',
      'Token': 'tbl_demo',
      'CurrentSessionID': 'SES_DEMO',
    };
    const session = OrderSession(
      sessionId: 'SES_DEMO',
      tableId: 'T01',
      status: 'OPEN',
      subtotal: 85,
      discount: 0,
      serviceCharge: 0,
      vat: 0,
      total: 85,
      promoCode: '',
    );
    const item = OrderItem(
      orderItemId: 'ORD_DEMO',
      sessionId: 'SES_DEMO',
      itemId: 'M001',
      itemName: 'กะเพราหมูสับ',
      qty: 1,
      unitPrice: 85,
      lineTotal: 85,
      note: '',
      status: 'NEW',
      options: [],
      addOns: [],
    );
    final opsItem = OpsOrderItem(
      order: item,
      table: table,
      kitchenNote: '',
      createdAt: now,
      updatedAt: now,
    );
    _opsItems[item.orderItemId] = opsItem;
    _opsSessions[session.sessionId] = OpsSession(
      session: session,
      table: table,
      items: [opsItem],
      openTime: now,
      closeTime: null,
      paymentMethod: '',
    );
    const call = CallLog(
      logId: 'CALL_DEMO',
      tableId: 'T01',
      sessionId: 'SES_DEMO',
      type: 'ASSISTANCE',
      status: 'OPEN',
    );
    _opsCalls[call.logId] = OpsCall(
      call: call,
      table: table,
      createdAt: now,
      acceptedAt: null,
      completedAt: null,
    );
    _adminEntities.addAll({
      'Tables': [Map<String, dynamic>.from(table)],
      'Categories': _categories.map((item) => item.toJson()).toList(),
      'MenuItems': _menu.map((item) => item.toJson()).toList(),
      'Options': const [],
      'AddOns': const [],
      'Promotions': _promotions.map((item) => item.toJson()).toList(),
      'Staff': _staffSeed.map(Map<String, dynamic>.from).toList(),
    });
    for (final staff in _staffSeed) {
      _staffPins['${staff['StaffID']}'] = 'zaq1234';
    }
  }

  static const _staffSeed = [
    {
      'StaffID': 'STF_ADMIN',
      'Name': 'ผู้ดูแลระบบ',
      'Role': 'ADMIN',
      'MustChangePin': true,
      'Status': 'ACTIVE',
    },
    {
      'StaffID': 'STF_KITCHEN',
      'Name': 'ครัว',
      'Role': 'KITCHEN',
      'MustChangePin': true,
      'Status': 'ACTIVE',
    },
    {
      'StaffID': 'STF_STAFF',
      'Name': 'พนักงานเสิร์ฟ',
      'Role': 'STAFF',
      'MustChangePin': true,
      'Status': 'ACTIVE',
    },
    {
      'StaffID': 'STF_CASHIER',
      'Name': 'แคชเชียร์',
      'Role': 'CASHIER',
      'MustChangePin': true,
      'Status': 'ACTIVE',
    },
  ];

  static const _categories = [
    Category(
      categoryId: 'CAT_RICE',
      name: 'อาหารจานเดียว',
      icon: '🍚',
      sortOrder: 1,
    ),
    Category(
      categoryId: 'CAT_SHARED',
      name: 'กับข้าว',
      icon: '🥘',
      sortOrder: 2,
    ),
    Category(
      categoryId: 'CAT_NOODLE',
      name: 'เส้นและก๋วยเตี๋ยว',
      icon: '🍜',
      sortOrder: 3,
    ),
    Category(
      categoryId: 'CAT_DRINK',
      name: 'เครื่องดื่ม',
      icon: '🥤',
      sortOrder: 4,
    ),
    Category(
      categoryId: 'CAT_DESSERT',
      name: 'ของหวาน',
      icon: '🍨',
      sortOrder: 5,
    ),
  ];

  static const _riceAddOns = [
    AddOn(
      addOnId: 'ADD001',
      name: 'ไข่ดาว',
      price: 15,
      linkedItemId: '',
      linkedCategoryId: 'CAT_RICE',
    ),
    AddOn(
      addOnId: 'ADD002',
      name: 'ไข่เจียว',
      price: 20,
      linkedItemId: '',
      linkedCategoryId: 'CAT_RICE',
    ),
    AddOn(
      addOnId: 'ADD003',
      name: 'ข้าวเพิ่ม',
      price: 20,
      linkedItemId: '',
      linkedCategoryId: 'CAT_RICE',
    ),
  ];

  static const _menu = [
    MenuItem(
      itemId: 'M001',
      categoryId: 'CAT_RICE',
      name: 'กะเพราหมูสับ',
      price: 85,
      description: 'กะเพราหอมกระทะ เสิร์ฟพร้อมข้าวหอมมะลิ',
      imageUrl: 'https://images.unsplash.com/photo-1562565652-a0d8f0c59eb4?auto=format&fit=crop&w=900&q=80',
      isPopular: true,
      available: true,
      options: [
        Option(
          optionId: 'OPT001',
          itemId: 'M001',
          groupName: 'ระดับความเผ็ด',
          label: 'ไม่เผ็ด',
          price: 0,
          inputType: 'RADIO',
          isRequired: true,
        ),
        Option(
          optionId: 'OPT002',
          itemId: 'M001',
          groupName: 'ระดับความเผ็ด',
          label: 'เผ็ดปกติ',
          price: 0,
          inputType: 'RADIO',
          isRequired: true,
        ),
        Option(
          optionId: 'OPT003',
          itemId: 'M001',
          groupName: 'ระดับความเผ็ด',
          label: 'เผ็ดมาก',
          price: 0,
          inputType: 'RADIO',
          isRequired: true,
        ),
      ],
      addOns: _riceAddOns,
    ),
    MenuItem(
      itemId: 'M002',
      categoryId: 'CAT_RICE',
      name: 'ข้าวผัดกุ้ง',
      price: 110,
      description: 'ข้าวผัดหอมกระทะกับกุ้งสด',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=900&q=80',
      isPopular: true,
      available: true,
      options: [],
      addOns: _riceAddOns,
    ),
    MenuItem(
      itemId: 'M003',
      categoryId: 'CAT_SHARED',
      name: 'ต้มยำกุ้งน้ำข้น',
      price: 220,
      description: 'กุ้งสดและสมุนไพรไทย รสเปรี้ยวเผ็ดกลมกล่อม',
      imageUrl: 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?auto=format&fit=crop&w=900&q=80',
      isPopular: true,
      available: true,
      options: [],
      addOns: [],
    ),
    MenuItem(
      itemId: 'M004',
      categoryId: 'CAT_SHARED',
      name: 'แกงเขียวหวานไก่',
      price: 180,
      description: 'เครื่องแกงตำสด กะทิหอมและโหระพา',
      imageUrl: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&w=900&q=80',
      isPopular: false,
      available: true,
      options: [],
      addOns: [],
    ),
    MenuItem(
      itemId: 'M005',
      categoryId: 'CAT_NOODLE',
      name: 'ผัดไทยกุ้งสด',
      price: 125,
      description: 'เส้นเหนียวนุ่ม ซอสมะขามสูตรร้าน',
      imageUrl: 'https://images.unsplash.com/photo-1559314809-0d155014e29e?auto=format&fit=crop&w=900&q=80',
      isPopular: true,
      available: true,
      options: [
        Option(
          optionId: 'OPT004',
          itemId: 'M005',
          groupName: 'เครื่องเคียง',
          label: 'ไม่ใส่ถั่ว',
          price: 0,
          inputType: 'CHECKBOX',
          isRequired: false,
        ),
      ],
      addOns: [
        AddOn(
          addOnId: 'ADD004',
          name: 'กุ้งเพิ่ม',
          price: 45,
          linkedItemId: 'M005',
          linkedCategoryId: '',
        ),
      ],
    ),
    MenuItem(
      itemId: 'M006',
      categoryId: 'CAT_DRINK',
      name: 'ชาไทยเย็น',
      price: 55,
      description: 'ชาไทยเข้มข้น หวานมันกำลังดี',
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=900&q=80',
      isPopular: true,
      available: true,
      options: [],
      addOns: [],
    ),
    MenuItem(
      itemId: 'M007',
      categoryId: 'CAT_DRINK',
      name: 'น้ำมะนาวโซดา',
      price: 65,
      description: 'มะนาวสดและโซดาซ่า',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=900&q=80',
      isPopular: false,
      available: true,
      options: [],
      addOns: [],
    ),
    MenuItem(
      itemId: 'M008',
      categoryId: 'CAT_DESSERT',
      name: 'ข้าวเหนียวมะม่วง',
      price: 120,
      description: 'มะม่วงสุก ข้าวเหนียวมูนและกะทิสด',
      imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=80',
      isPopular: true,
      available: true,
      options: [],
      addOns: [],
    ),
  ];

  static const _promotions = [
    Promotion(
      promoId: 'PROMO_WELCOME',
      code: 'WELCOME10',
      name: 'Welcome Special',
      description: 'ลด 10% เมื่อสั่งครบ 500 บาท',
      discountType: 'PERCENT',
      discountValue: 10,
      minSpend: 500,
      bannerImage: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=1200&q=80',
    ),
  ];

  @override
  Future<Map<String, dynamic>> bootstrap({required String tableToken}) async =>
      {
        'setupRequired': false,
        'app': {
          'appName': 'Phius Order',
          'name': 'Phius Thai Kitchen',
          'restaurantName': 'Phius Thai Kitchen',
          'tagline': 'Modern Thai Vitality',
          'logoText': 'ผ',
          'logoUrl': '',
          'heroKicker': 'อิ่มอร่อยในแบบของคุณ',
          'heroTitle': 'เลือกเมนูโปรด\nแล้วส่งตรงถึงครัว',
          'heroBadgeText': 'อร่อย',
          'heroBadgeImageUrl': '',
          'primaryColor': '#B7442B',
          'currency': 'THB',
          'currencySymbol': '฿',
          'pollSeconds': 10,
        },
      };

  @override
  Future<CustomerData> getCustomerData({required String tableToken}) async =>
      CustomerData(
        table: const {
          'TableID': 'T01',
          'Name': 'โต๊ะ 01',
          'Zone': 'โซนด้านใน',
          'Status': 'AVAILABLE',
        },
        categories: _categories,
        menu: _menu,
        promotions: _promotions,
        session: _sessions.isEmpty ? null : _sessions.values.last,
      );

  @override
  Future<SubmitResult> submitOrder({
    required String tableToken,
    required String idempotencyKey,
    required String promoCode,
    required List<OrderRequestItem> items,
  }) async {
    final existing = _submissions[idempotencyKey];
    if (existing != null) return existing;

    final sessionId = clientId('ses');
    final orderItems = items
        .map((request) => _createOrderItem(sessionId, request))
        .toList();
    final totals = _calculateTotals(orderItems, promoCode);
    final session = OrderSession(
      sessionId: sessionId,
      tableId: 'T01',
      status: 'OPEN',
      subtotal: totals.subtotal,
      discount: totals.discount,
      serviceCharge: totals.serviceCharge,
      vat: totals.vat,
      total: totals.total,
      promoCode: totals.promo?.code ?? '',
    );
    final bundle = SessionBundle(
      session: session,
      items: orderItems,
      calls: const [],
    );
    _sessions[sessionId] = bundle;
    final result = SubmitResult(
      sessionId: sessionId,
      table: const {'TableID': 'T01', 'Name': 'โต๊ะ 01'},
      totals: totals,
      items: orderItems,
      submittedAt: DateTime.now(),
    );
    _submissions[idempotencyKey] = result;
    return result;
  }

  @override
  Future<SessionBundle> getOrderStatus({
    required String tableToken,
    required String sessionId,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) throw StateError('SESSION_NOT_FOUND');
    return session;
  }

  @override
  Future<CallResult> callStaff({
    required String tableToken,
    required String type,
    required String idempotencyKey,
  }) async {
    final key = '$tableToken:${type.toUpperCase()}';
    final existing = _calls[key];
    if (existing != null) {
      return CallResult(call: existing.call, duplicate: true);
    }

    final sessionId = _sessions.isEmpty ? '' : _sessions.keys.last;
    final call = CallLog(
      logId: clientId('call'),
      tableId: 'T01',
      sessionId: sessionId,
      type: type.toUpperCase(),
      status: 'OPEN',
    );
    final result = CallResult(call: call, duplicate: false);
    _calls[key] = result;
    final bundle = _sessions[sessionId];
    if (bundle != null) {
      _sessions[sessionId] = SessionBundle(
        session: bundle.session,
        items: bundle.items,
        calls: [...bundle.calls, call],
      );
    }
    return result;
  }

  @override
  Future<StaffSession> login({
    required String pin,
    String? expectedRole,
  }) async {
    final expected = expectedRole?.toUpperCase();
    final matches = _adminEntities['Staff']!
        .where(
          (entry) =>
              entry['Status'] == 'ACTIVE' &&
              _staffPins['${entry['StaffID']}'] == pin,
        )
        .toList();
    final staff = matches.firstWhere(
      (entry) => entry['Role'] == expected,
      orElse: () => matches.firstWhere(
        (entry) => entry['Role'] == 'ADMIN',
        orElse: () => <String, dynamic>{},
      ),
    );
    if (staff.isEmpty) throw StateError('LOGIN_FAILED');
    final session = StaffSession(
      token: clientId('auth'),
      staffId: '${staff['StaffID']}',
      name: '${staff['Name']}',
      role: '${staff['Role']}',
      issuedAt: DateTime.now().toUtc(),
      mustChangePin: staff['MustChangePin'] == true,
    );
    _staffTokens[session.token] = session;
    return session;
  }

  @override
  Future<void> logout({required String token}) async {
    _staffTokens.remove(token);
  }

  @override
  Future<void> changePin({
    required String token,
    required String newPin,
  }) async {
    final user = _requireStaff(token);
    if (!RegExp(r'^[A-Za-z0-9]{6,12}$').hasMatch(newPin) ||
        newPin == 'zaq1234') {
      throw StateError('INVALID_PIN');
    }
    final staff = _adminEntities['Staff']!.firstWhere(
      (entry) => entry['StaffID'] == user.staffId,
    );
    staff['MustChangePin'] = false;
    _staffPins[user.staffId] = newPin;
    _staffTokens[token] = StaffSession(
      token: user.token,
      staffId: user.staffId,
      name: user.name,
      role: user.role,
      issuedAt: user.issuedAt,
      mustChangePin: false,
    );
  }

  @override
  Future<OpsDashboard> opsDashboard({
    required String token,
    required String view,
  }) async {
    final user = _requireStaff(token);
    final normalizedView = view.toUpperCase();
    final requiredRole = switch (normalizedView) {
      'KITCHEN' => 'KITCHEN',
      'STAFF' => 'STAFF',
      'CASHIER' => 'CASHIER',
      'ALL' => 'ADMIN',
      _ => throw const AppError(
        code: 'INVALID_VIEW',
        message: 'ไม่พบหน้าการทำงานที่เลือก',
      ),
    };
    if (user.role != 'ADMIN' && user.role != requiredRole) {
      throw const AppError(
        code: 'PERMISSION_DENIED',
        message: 'คุณไม่มีสิทธิ์เข้าถึงหน้านี้',
      );
    }
    final activeSessionIds = _opsSessions.values
        .where(
          (session) =>
              session.session.status == 'OPEN' ||
              session.session.status == 'PAYMENT_PENDING',
        )
        .map((session) => session.session.sessionId)
        .toSet();
    final activeItems = _opsItems.values
        .where((item) => activeSessionIds.contains(item.order.sessionId))
        .toList();
    final activeSessions = _opsSessions.values
        .where(
          (session) => activeSessionIds.contains(session.session.sessionId),
        )
        .toList();
    final visibleItems = normalizedView == 'CASHIER'
        ? const <OpsOrderItem>[]
        : activeItems;
    final visibleSessions =
        normalizedView == 'KITCHEN' || normalizedView == 'STAFF'
        ? const <OpsSession>[]
        : activeSessions;
    final activeCalls = _opsCalls.values
        .where(
          (call) =>
              activeSessionIds.contains(call.call.sessionId) &&
              (call.status == 'OPEN' || call.status == 'ASSIGNED'),
        )
        .toList();
    final visibleCalls = normalizedView == 'STAFF' || normalizedView == 'ALL'
        ? activeCalls
        : const <OpsCall>[];
    return OpsDashboard(
      user: user,
      view: normalizedView,
      items: visibleItems,
      sessions: visibleSessions,
      calls: visibleCalls,
      summary: _opsSummary(),
    );
  }

  @override
  Future<OpsOrderItem> updateOrderItem({
    required String token,
    required String orderItemId,
    required String status,
    String? kitchenNote,
  }) async {
    final user = _requireStaff(token);
    final target = status.toUpperCase();
    final allowed = switch (user.role) {
      'KITCHEN' => const {'PREPARING', 'READY'},
      'STAFF' => const {'SERVED'},
      'ADMIN' => const {'NEW', 'PREPARING', 'READY', 'SERVED', 'CANCELLED'},
      _ => const <String>{},
    };
    if (!allowed.contains(target)) throw StateError('INVALID_STATUS');
    final existing = _opsItems[orderItemId];
    if (existing == null) throw StateError('ITEM_NOT_FOUND');
    final updated = OpsOrderItem(
      order: OrderItem(
        orderItemId: existing.order.orderItemId,
        sessionId: existing.order.sessionId,
        itemId: existing.order.itemId,
        itemName: existing.order.itemName,
        qty: existing.order.qty,
        unitPrice: existing.order.unitPrice,
        lineTotal: existing.order.lineTotal,
        note: existing.order.note,
        status: target,
        options: existing.order.options,
        addOns: existing.order.addOns,
      ),
      table: existing.table,
      kitchenNote: kitchenNote ?? existing.kitchenNote,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    _opsItems[orderItemId] = updated;
    final session = _opsSessions[updated.order.sessionId]!;
    _opsSessions[session.session.sessionId] = OpsSession(
      session: session.session,
      table: session.table,
      items: session.items
          .map((item) => item.orderItemId == orderItemId ? updated : item)
          .toList(),
      openTime: session.openTime,
      closeTime: session.closeTime,
      paymentMethod: session.paymentMethod,
    );
    return updated;
  }

  @override
  Future<OpsCall> updateCall({
    required String token,
    required String logId,
    required String status,
  }) async {
    _requireRole(token, const {'STAFF', 'CASHIER', 'ADMIN'});
    final current = _opsCalls[logId];
    final target = status.toUpperCase();
    if (current == null) {
      throw StateError('CALL_NOT_FOUND');
    }
    if (target != 'ASSIGNED' && target != 'DONE') {
      throw StateError('INVALID_STATUS');
    }
    final updated = OpsCall(
      call: CallLog(
        logId: current.call.logId,
        tableId: current.call.tableId,
        sessionId: current.call.sessionId,
        type: current.call.type,
        status: target,
      ),
      table: current.table,
      createdAt: current.createdAt,
      acceptedAt: target == 'ASSIGNED'
          ? DateTime.now().toUtc()
          : current.acceptedAt,
      completedAt: target == 'DONE'
          ? DateTime.now().toUtc()
          : current.completedAt,
    );
    _opsCalls[logId] = updated;
    return updated;
  }

  @override
  Future<Receipt> closeTable({
    required String token,
    required String sessionId,
    required String method,
    String? reference,
    required String idempotencyKey,
  }) async {
    _requireRole(token, const {'CASHIER', 'ADMIN'});
    if (idempotencyKey.isEmpty) {
      throw StateError('IDEMPOTENCY_REQUIRED');
    }
    final cached = _receipts[idempotencyKey];
    if (cached != null) {
      return cached;
    }
    const methods = {'CASH', 'TRANSFER', 'CARD', 'OTHER'};
    if (!methods.contains(method.toUpperCase())) {
      throw StateError('PAYMENT_METHOD_REQUIRED');
    }
    final current = _opsSessions[sessionId];
    if (current == null ||
        !{'OPEN', 'PAYMENT_PENDING'}.contains(current.session.status)) {
      throw StateError('SESSION_CLOSED');
    }
    final paidSession = OrderSession(
      sessionId: current.session.sessionId,
      tableId: current.session.tableId,
      status: 'PAID',
      subtotal: current.session.subtotal,
      discount: current.session.discount,
      serviceCharge: current.session.serviceCharge,
      vat: current.session.vat,
      total: current.session.total,
      promoCode: current.session.promoCode,
    );
    _opsSessions[sessionId] = OpsSession(
      session: paidSession,
      table: {...current.table, 'Status': 'AVAILABLE'},
      items: current.items,
      openTime: current.openTime,
      closeTime: DateTime.now().toUtc(),
      paymentMethod: method.toUpperCase(),
    );
    final tables = _adminEntities['Tables']!;
    final tableIndex = tables.indexWhere(
      (table) => '${table['TableID']}' == current.session.tableId,
    );
    if (tableIndex >= 0) {
      tables[tableIndex] = {
        ...tables[tableIndex],
        'Status': 'AVAILABLE',
        'CurrentSessionID': '',
      };
    }
    final closedAt = DateTime.now().toUtc();
    for (final entry in _opsCalls.entries.toList()) {
      if (entry.value.call.sessionId == sessionId &&
          (entry.value.status == 'OPEN' || entry.value.status == 'ASSIGNED')) {
        _opsCalls[entry.key] = OpsCall(
          call: CallLog(
            logId: entry.value.call.logId,
            tableId: entry.value.call.tableId,
            sessionId: entry.value.call.sessionId,
            type: entry.value.call.type,
            status: 'DONE',
          ),
          table: entry.value.table,
          createdAt: entry.value.createdAt,
          acceptedAt: entry.value.acceptedAt ?? closedAt,
          completedAt: closedAt,
        );
      }
    }
    final receipt = Receipt(
      restaurantName: '${_settings['RestaurantName']}',
      table: '${current.table['Name']}',
      session: paidSession,
      items: current.items.map((item) => item.order).toList(),
      payment: {
        'Amount': paidSession.total,
        'Method': method.toUpperCase(),
        'Reference': reference ?? '',
      },
      generatedAt: DateTime.now().toUtc(),
    );
    _receipts[idempotencyKey] = receipt;
    return receipt;
  }

  @override
  Future<AdminData> adminData({required String token}) async {
    final user = _requireRole(token, const {'ADMIN'});
    return AdminData(
      user: user,
      settings: Map<String, dynamic>.from(_settings),
      entities: {
        for (final entry in _adminEntities.entries)
          entry.key: entry.value.map(Map<String, dynamic>.from).toList(),
      },
      summary: {
        'tables': _adminEntities['Tables']!.length,
        'menuItems': _adminEntities['MenuItems']!.length,
        'activeSessions': _opsSessions.values
            .where((item) => item.session.status != 'PAID')
            .length,
        'todaySales': _receipts.values.fold<num>(
          0,
          (sum, item) => sum + item.session.total,
        ),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> adminSaveSettings({
    required String token,
    required Map<String, dynamic> settings,
  }) async {
    _requireRole(token, const {'ADMIN'});
    _settings.addAll(settings);
    return {'settings': Map<String, dynamic>.from(_settings)};
  }

  @override
  Future<Map<String, dynamic>> adminSaveEntity({
    required String token,
    required String entity,
    required Map<String, dynamic> data,
  }) async {
    _requireRole(token, const {'ADMIN'});
    final sheet = _sheetForEntity(entity);
    final rows = _adminEntities[sheet];
    if (rows == null) throw StateError('INVALID_ENTITY');
    final key = _entityKey(entity);
    final suppliedId = '${data[key] ?? ''}'.trim();
    final id = suppliedId.isEmpty
        ? clientId(_entityPrefix(entity))
        : suppliedId;
    final index = rows.indexWhere((row) => '${row[key]}' == id);
    final isNew = index < 0;
    final saved = <String, dynamic>{...data, key: id}..remove('PIN');
    if (isNew && entity.toLowerCase() == 'table') {
      saved['Token'] = clientId('tbl');
      saved['CurrentSessionID'] = '';
    }
    if (entity.toLowerCase() == 'staff') {
      final pin = '${data['PIN'] ?? ''}';
      if (pin.isNotEmpty) {
        if (!RegExp(r'^[A-Za-z0-9]{6,12}$').hasMatch(pin)) {
          throw StateError('INVALID_PIN');
        }
        _staffPins[id] = pin;
        saved['MustChangePin'] = true;
      } else if (isNew) {
        throw StateError('PIN_REQUIRED');
      }
    }
    if (isNew) {
      rows.add(saved);
    } else {
      rows[index] = {...rows[index], ...saved};
    }
    return saved;
  }

  @override
  Future<Map<String, dynamic>> adminArchiveEntity({
    required String token,
    required String entity,
    required String id,
  }) async {
    final user = _requireRole(token, const {'ADMIN'});
    final sheet = _sheetForEntity(entity);
    final key = _entityKey(entity);
    final rows = _adminEntities[sheet];
    final index = rows?.indexWhere((row) => '${row[key]}' == id) ?? -1;
    if (index < 0) throw StateError('NOT_FOUND');
    if (entity.toLowerCase() == 'staff' && id == user.staffId) {
      throw StateError('SELF_ARCHIVE_DENIED');
    }
    if (entity.toLowerCase() == 'category') {
      final menuInUse = _adminEntities['MenuItems']!.any(
        (row) => '${row['CategoryID']}' == id && row['Status'] != 'ARCHIVED',
      );
      if (menuInUse) {
        throw const AppError(
          code: 'CATEGORY_IN_USE',
          message: 'ย้ายหรือลบเมนูในหมวดนี้ก่อน แล้วจึงลบหมวดหมู่',
        );
      }
      final addOnInUse = _adminEntities['AddOns']!.any(
        (row) =>
            '${row['LinkedCategoryID']}' == id && row['Status'] != 'ARCHIVED',
      );
      if (addOnInUse) {
        throw const AppError(
          code: 'CATEGORY_ADDON_IN_USE',
          message: 'ย้ายหรือลบ Add-on ที่ผูกกับหมวดนี้ก่อน แล้วจึงลบหมวดหมู่',
        );
      }
    }
    final archived = {...rows![index], 'Status': 'ARCHIVED'};
    rows[index] = archived;
    return archived;
  }

  @override
  Future<Map<String, dynamic>> adminRotateToken({
    required String token,
    required String tableId,
  }) async {
    _requireRole(token, const {'ADMIN'});
    final rows = _adminEntities['Tables']!;
    final index = rows.indexWhere((row) => '${row['TableID']}' == tableId);
    if (index < 0) throw StateError('TABLE_NOT_FOUND');
    if (rows[index]['CurrentSessionID']?.toString().isNotEmpty == true) {
      throw StateError('TABLE_IN_USE');
    }
    final updated = {...rows[index], 'Token': clientId('tbl')};
    rows[index] = updated;
    return updated;
  }

  @override
  Future<String> adminUploadImage({
    required String token,
    required List<int> bytes,
    required String filename,
  }) async {
    _requireRole(token, const {'ADMIN'});
    // Offline stub: return a deterministic placeholder URL (no real Drive).
    return 'https://drive.google.com/uc?export=view&id=${clientId('img')}';
  }

  StaffSession _requireStaff(String token) {
    final user = _staffTokens[token];
    if (user == null) throw StateError('AUTH_REQUIRED');
    final matches = _adminEntities['Staff']!.where(
      (entry) => entry['StaffID'] == user.staffId,
    );
    if (matches.isEmpty || matches.first['Status'] != 'ACTIVE') {
      _staffTokens.remove(token);
      throw StateError('AUTH_EXPIRED');
    }
    final staff = matches.first;
    final refreshed = StaffSession(
      token: user.token,
      staffId: user.staffId,
      name: '${staff['Name'] ?? user.name}',
      role: '${staff['Role'] ?? user.role}',
      issuedAt: user.issuedAt,
      mustChangePin: staff['MustChangePin'] == true,
    );
    _staffTokens[token] = refreshed;
    return refreshed;
  }

  StaffSession _requireRole(String token, Set<String> roles) {
    final user = _requireStaff(token);
    if (user.role != 'ADMIN' && !roles.contains(user.role)) {
      throw StateError('PERMISSION_DENIED');
    }
    return user;
  }

  OpsSummary _opsSummary() {
    final activeSessionIds = _opsSessions.values
        .where(
          (session) =>
              session.session.status == 'OPEN' ||
              session.session.status == 'PAYMENT_PENDING',
        )
        .map((session) => session.session.sessionId)
        .toSet();
    final activeItems = _opsItems.values.where(
      (item) => activeSessionIds.contains(item.order.sessionId),
    );
    return OpsSummary(
      openTables: activeSessionIds.length,
      newOrders: activeItems.where((item) => item.status == 'NEW').length,
      preparing: activeItems.where((item) => item.status == 'PREPARING').length,
      ready: activeItems.where((item) => item.status == 'READY').length,
      waitingCalls: _opsCalls.values
          .where(
            (call) =>
                activeSessionIds.contains(call.call.sessionId) &&
                call.status == 'OPEN',
          )
          .length,
    );
  }

  String _sheetForEntity(String entity) => switch (entity.toLowerCase()) {
    'table' => 'Tables',
    'category' => 'Categories',
    'menu' => 'MenuItems',
    'option' => 'Options',
    'addon' => 'AddOns',
    'promotion' => 'Promotions',
    'staff' => 'Staff',
    _ => '',
  };

  String _entityKey(String entity) => switch (entity.toLowerCase()) {
    'table' => 'TableID',
    'category' => 'CategoryID',
    'menu' => 'ItemID',
    'option' => 'OptionID',
    'addon' => 'AddOnID',
    'promotion' => 'PromoID',
    'staff' => 'StaffID',
    _ => '',
  };

  String _entityPrefix(String entity) => switch (entity.toLowerCase()) {
    'table' => 'tbl',
    'category' => 'cat',
    'menu' => 'item',
    'option' => 'opt',
    'addon' => 'add',
    'promotion' => 'promo',
    'staff' => 'stf',
    _ => 'entity',
  };

  OrderItem _createOrderItem(String sessionId, OrderRequestItem request) {
    final item = _menu.firstWhere(
      (menuItem) => menuItem.itemId == request.itemId,
    );
    final options = item.options
        .where((option) => request.optionIds.contains(option.optionId))
        .toList();
    final addOns = item.addOns
        .where((addOn) => request.addOnIds.contains(addOn.addOnId))
        .toList();
    final unitPrice =
        item.price +
        options.fold<num>(0, (sum, option) => sum + option.price) +
        addOns.fold<num>(0, (sum, addOn) => sum + addOn.price);

    return OrderItem(
      orderItemId: clientId('ord'),
      sessionId: sessionId,
      itemId: item.itemId,
      itemName: item.name,
      qty: request.qty,
      unitPrice: unitPrice,
      lineTotal: unitPrice * request.qty,
      note: request.note,
      status: 'NEW',
      options: options
          .map(
            (option) => {
              'id': option.optionId,
              'group': option.groupName,
              'label': option.label,
              'price': option.price,
            },
          )
          .toList(),
      addOns: addOns
          .map(
            (addOn) => {
              'id': addOn.addOnId,
              'name': addOn.name,
              'price': addOn.price,
            },
          )
          .toList(),
    );
  }

  Totals _calculateTotals(List<OrderItem> items, String promoCode) {
    final subtotal = items.fold<num>(0, (sum, item) => sum + item.lineTotal);
    final promo = _promotions
        .where(
          (promotion) =>
              promotion.code == promoCode.toUpperCase() &&
              subtotal >= promotion.minSpend,
        )
        .firstOrNull;
    final discount = promo == null
        ? 0
        : promo.discountType == 'PERCENT'
        ? subtotal * promo.discountValue / 100
        : promo.discountValue.clamp(0, subtotal);
    return Totals(
      subtotal: subtotal,
      discount: discount,
      serviceCharge: 0,
      vat: 0,
      total: subtotal - discount,
      promo: promo,
    );
  }
}
