import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/admin_controller.dart';
import '../../state/auth_controller.dart';
import '../staff/login_page.dart';
import 'widgets/admin_catalog.dart';
import 'widgets/admin_nav.dart';
import 'widgets/admin_overview.dart';
import 'widgets/admin_promotions.dart';
import 'widgets/admin_settings.dart';
import 'widgets/admin_staff.dart';
import 'widgets/admin_tables.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, this.enablePolling = true});

  final bool enablePolling;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with WidgetsBindingObserver {
  AdminController? _controller;
  String _tab = 'overview';
  bool _mobileNavOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndPoll());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AdminController>();
    if (!identical(_controller, controller)) {
      _controller?.stopPolling();
      _controller = controller;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndPoll());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.enablePolling) {
      _loadAndPoll();
    } else if (state != AppLifecycleState.resumed) {
      _controller?.stopPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<AdminController>();
    if (auth.session == null || auth.mustChangePin) {
      return LoginPage(onAuthenticated: _authenticatedPage);
    }
    if (controller.loading && controller.data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = controller.data;
    if (data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.error ?? 'เกิดข้อผิดพลาด'),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('← กลับหน้าหลัก'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final nav = AdminNav(selected: _tab, onSelected: _selectTab);
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact) SizedBox(width: 190, child: nav),
                  if (!compact) const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (compact)
                              IconButton(
                                onPressed: () => setState(
                                  () => _mobileNavOpen = !_mobileNavOpen,
                                ),
                                icon: const Icon(Icons.menu),
                                tooltip: 'เปิดเมนู',
                              ),
                            Expanded(
                              child: Text(
                                _titleFor(_tab),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/'),
                              child: const Text('← กลับหน้าหลัก'),
                            ),
                            TextButton.icon(
                              onPressed: auth.loading
                                  ? null
                                  : () => _logout(auth),
                              icon: const Icon(Icons.logout),
                              label: const Text('ออกจากระบบ'),
                            ),
                          ],
                        ),
                        if (compact && _mobileNavOpen) ...[
                          const SizedBox(height: 12),
                          nav,
                        ],
                        const SizedBox(height: 20),
                        Expanded(
                          child: switch (_tab) {
                            'tables' => AdminTables(
                              rows: data.entity('Tables'),
                              controller: controller,
                            ),
                            'catalog' => AdminCatalog(
                              categories: data.entity('Categories'),
                              menu: data.entity('MenuItems'),
                              options: data.entity('Options'),
                              addOns: data.entity('AddOns'),
                              controller: controller,
                            ),
                            'promotions' => AdminPromotions(
                              rows: data.entity('Promotions'),
                              controller: controller,
                            ),
                            'staff' => AdminStaff(
                              rows: data.entity('Staff'),
                              controller: controller,
                            ),
                            'settings' => AdminSettings(
                              settings: data.settings,
                              controller: controller,
                            ),
                            _ => AdminOverview(data: data),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectTab(String tab) => setState(() {
    _tab = tab;
    _mobileNavOpen = false;
  });

  Future<void> _logout(AuthController auth) async {
    _controller?.stopPolling();
    await auth.logout();
  }

  void _loadAndPoll() {
    final auth = context.read<AuthController>();
    if (auth.session == null || auth.mustChangePin) {
      _controller?.stopPolling();
      return;
    }
    _controller?.load();
    if (widget.enablePolling) _controller?.startPolling();
  }

  Widget _authenticatedPage() {
    final session = context.read<AuthController>().session;
    if (session != null) {
      _controller?.useToken(session.token);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadAndPoll();
      });
    }
    return AdminPage(enablePolling: widget.enablePolling);
  }
}

String _titleFor(String tab) => switch (tab) {
  'tables' => 'โต๊ะและ QR',
  'catalog' => 'เมนูอาหาร',
  'promotions' => 'โปรโมชั่น',
  'staff' => 'พนักงาน',
  'settings' => 'ตั้งค่าร้าน',
  _ => 'ภาพรวมร้าน',
};
