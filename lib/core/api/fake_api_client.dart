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
import '../../models/totals.dart';
import '../utils/client_id.dart';
import 'api_client.dart';

class FakeApiClient implements ApiClient {
  final Map<String, SubmitResult> _submissions = {};
  final Map<String, SessionBundle> _sessions = {};
  final Map<String, CallResult> _calls = {};

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
