import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/tokens.dart';
import '../../models/app_config.dart';
import '../shared/widgets/brand_mark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api});

  final ApiClient api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = widget.api.bootstrap(tableToken: '');
  }

  void _reload() => setState(() {
    _bootstrap = widget.api.bootstrap(tableToken: '');
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _bootstrap,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _StartupState(
          eyebrow: 'ไม่สามารถเปิดระบบ',
          title: 'เกิดข้อผิดพลาด',
          description: 'ตรวจสอบการเชื่อมต่อหรือรัน setupSystem() แล้วลองใหม่',
          buttonLabel: 'ลองอีกครั้ง',
          onPressed: _reload,
        );
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.data!['setupRequired'] == true) {
        return _StartupState(
          eyebrow: 'ตั้งค่าครั้งแรก',
          title: 'Phius Order ยังไม่พร้อมใช้งาน',
          description: 'เปิด Apps Script แล้วรันฟังก์ชัน setupSystem() หนึ่งครั้ง ระบบจะสร้าง Google Sheets, โฟลเดอร์ Drive และ PIN เริ่มต้นให้โดยอัตโนมัติ',
          detailTitle: 'หลังตั้งค่าแล้ว',
          detail: 'โหลดหน้านี้ใหม่เพื่อเริ่มใช้งาน',
          buttonLabel: 'โหลดหน้าใหม่',
          onPressed: _reload,
        );
      }
      final app = snapshot.hasData
          ? AppConfig.fromJson(
              Map<String, dynamic>.from(
                snapshot.data!['app'] as Map? ?? const {},
              ),
            )
          : null;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _PortalCard(app: app),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _StartupState extends StatelessWidget {
  const _StartupState({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.detailTitle,
    this.detail,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final String? detailTitle;
  final String? detail;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: PhiusTokens.surface,
                border: Border.all(color: PhiusTokens.border),
                borderRadius: BorderRadius.circular(28),
                boxShadow: PhiusTokens.shadowMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: BrandMark()),
                  const SizedBox(height: 20),
                  Text(
                    eyebrow,
                    style: const TextStyle(
                      color: PhiusTokens.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: PhiusTokens.muted),
                  ),
                  if (detailTitle != null && detail != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PhiusTokens.surfaceSoft,
                        borderRadius: BorderRadius.circular(PhiusTokens.radius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detailTitle!,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detail!,
                            style: const TextStyle(color: PhiusTokens.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onPressed,
                      child: Text(buttonLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({this.app});

  final AppConfig? app;

  @override
  Widget build(BuildContext context) {
    final appName = app?.appName.isNotEmpty == true
        ? app!.appName
        : 'Phius Order';
    final restaurantName = app?.restaurantName.isNotEmpty == true
        ? app!.restaurantName
        : 'Phius Thai Kitchen';
    final tagline = app?.tagline.isNotEmpty == true
        ? app!.tagline
        : 'ระบบสั่งอาหารและจัดการหน้าร้าน';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: PhiusTokens.surface,
        border: Border.all(color: PhiusTokens.border),
        borderRadius: BorderRadius.circular(28),
        boxShadow: PhiusTokens.shadowMd,
      ),
      child: Column(
        children: [
          BrandMark(
            logoText: app?.logoText.isNotEmpty == true ? app!.logoText : 'ผ',
            logoUrl: app?.logoUrl ?? '',
          ),
          const SizedBox(height: 18),
          Text(
            tagline.toUpperCase(),
            style: const TextStyle(
              color: PhiusTokens.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            appName,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(restaurantName, style: TextStyle(color: PhiusTokens.muted)),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) => GridView.count(
              crossAxisCount: constraints.maxWidth < 430 ? 1 : 2,
              childAspectRatio: constraints.maxWidth < 430 ? 2.75 : 2.35,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _portalEntries
                  .map((entry) => _PortalLink(entry: entry))
                  .toList(),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'หน้าลูกค้าต้องเปิดผ่าน QR ประจำโต๊ะ',
            style: TextStyle(color: PhiusTokens.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PortalLink extends StatelessWidget {
  const _PortalLink({required this.entry});

  final _PortalEntry entry;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: entry.title,
    child: Material(
      color: entry.featured ? PhiusTokens.redSoft : PhiusTokens.surfaceSoft,
      borderRadius: BorderRadius.circular(PhiusTokens.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(PhiusTokens.radius),
        onTap: () => context.go('/?page=${entry.page}'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(
              color: entry.featured
                  ? const Color(0x47B7442B)
                  : PhiusTokens.border,
            ),
            borderRadius: BorderRadius.circular(PhiusTokens.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                entry.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                entry.description,
                style: const TextStyle(color: PhiusTokens.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PortalEntry {
  const _PortalEntry(
    this.icon,
    this.title,
    this.description, {
    required this.page,
    this.featured = false,
  });

  final String icon;
  final String title;
  final String description;
  final String page;
  final bool featured;
}

const _portalEntries = [
  _PortalEntry(
    '🧭',
    'รวมงานหน้าร้าน',
    'ครัว พนักงาน และแคชเชียร์ในหน้าเดียว',
    page: 'operations',
    featured: true,
  ),
  _PortalEntry('🔥', 'หน้าครัว', 'รับและอัปเดตออเดอร์', page: 'kitchen'),
  _PortalEntry('🛎️', 'พนักงาน', 'งานเสิร์ฟและลูกค้าเรียก', page: 'staff'),
  _PortalEntry('🧾', 'แคชเชียร์', 'ตรวจบิลและรับชำระ', page: 'cashier'),
  _PortalEntry('⚙️', 'ผู้ดูแล', 'เมนู โต๊ะ และตั้งค่า', page: 'admin'),
];
