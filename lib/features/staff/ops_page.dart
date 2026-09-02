import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/tokens.dart';
import '../../models/staff_models.dart';
import '../../state/auth_controller.dart';
import '../../state/ops_controller.dart';
import 'login_page.dart';
import 'widgets/cashier_bills.dart';
import 'widgets/kitchen_board.dart';
import 'widgets/staff_queue.dart';

class OpsPage extends StatefulWidget {
  const OpsPage({super.key, required this.route, this.enablePolling = true});

  final StaffRoute route;
  final bool enablePolling;

  @override
  State<OpsPage> createState() => _OpsPageState();
}

class _OpsPageState extends State<OpsPage> with WidgetsBindingObserver {
  String _tab = 'KITCHEN';
  OpsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = context.read<OpsController>();
    if (!identical(_controller, nextController)) {
      _controller?.stopPolling();
      _controller = nextController;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !identical(_controller, nextController)) return;
        _loadAndPoll();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAndPoll();
    });
  }

  @override
  void didUpdateWidget(covariant OpsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enablePolling) {
      _controller?.stopPolling();
    } else if (!oldWidget.enablePolling) {
      _loadAndPoll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopPolling();
    super.dispose();
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
  Widget build(BuildContext context) {
    final controller = context.watch<OpsController>();
    final auth = context.watch<AuthController>();
    if (auth.session == null || auth.mustChangePin) {
      return LoginPage(onAuthenticated: _authenticatedPage);
    }
    final dashboard = controller.dashboard;
    if (controller.loading && dashboard == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (dashboard == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.error ?? 'เกิดข้อผิดพลาด'),
              TextButton.icon(
                onPressed: () => context.go('/'),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Text('←'),
                label: const Text('กลับหน้าหลัก'),
              ),
            ],
          ),
        ),
      );
    }
    final operations = widget.route == StaffRoute.operations;
    final kitchenView =
        widget.route == StaffRoute.kitchen || (operations && _tab == 'KITCHEN');
    final staffView =
        widget.route == StaffRoute.staff || (operations && _tab == 'STAFF');
    final cashierView =
        widget.route == StaffRoute.cashier || (operations && _tab == 'CASHIER');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _roleMeta(widget.route).kicker,
                style: const TextStyle(
                  color: PhiusTokens.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _roleMeta(widget.route).title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('← กลับหน้าหลัก'),
                  ),
                  TextButton.icon(
                    onPressed: auth.loading ? null : () => _logout(auth),
                    icon: const Icon(Icons.logout),
                    label: const Text('ออกจากระบบ'),
                  ),
                ],
              ),
              Text(
                dashboard.user.name.isEmpty
                    ? dashboard.user.role
                    : dashboard.user.name,
                style: const TextStyle(color: PhiusTokens.muted),
              ),
              const SizedBox(height: 20),
              _SummaryGrid(dashboard: dashboard, route: widget.route),
              if (operations) ...[
                const SizedBox(height: 20),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'KITCHEN', label: Text('ครัว')),
                    ButtonSegment(value: 'STAFF', label: Text('พนักงาน')),
                    ButtonSegment(value: 'CASHIER', label: Text('แคชเชียร์')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (values) =>
                      setState(() => _tab = values.single),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: kitchenView
                    ? KitchenBoard(
                        items: dashboard.items,
                        onUpdateStatus: controller.updateOrderStatus,
                      )
                    : staffView
                    ? StaffQueue(
                        calls: dashboard.calls,
                        items: dashboard.items,
                        onUpdateCall: controller.updateCallStatus,
                        onUpdateItem: controller.updateOrderStatus,
                      )
                    : cashierView
                    ? CashierBills(
                        sessions: dashboard.sessions,
                        onClose: controller.closeTable,
                      )
                    : Center(child: Text(operations ? _tab : dashboard.view)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(AuthController auth) async {
    _controller?.stopPolling();
    await auth.logout();
  }

  void _loadAndPoll() {
    final auth = context.read<AuthController>();
    if (auth.session == null) {
      _controller?.stopPolling();
      return;
    }
    _controller?.load();
    if (widget.enablePolling) {
      _controller?.startPolling();
      _controller?.startRealtime();
    }
  }

  Widget _authenticatedPage() {
    final session = context.read<AuthController>().session;
    if (session != null) {
      _controller?.useToken(session.token);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadAndPoll();
      });
    }
    return OpsPage(route: widget.route, enablePolling: widget.enablePolling);
  }
}

class _OpsRoleMeta {
  const _OpsRoleMeta(this.kicker, this.title);

  final String kicker;
  final String title;
}

_OpsRoleMeta _roleMeta(StaffRoute route) => switch (route) {
  StaffRoute.kitchen => const _OpsRoleMeta(
    'Kitchen Display System',
    'หน้าครัว',
  ),
  StaffRoute.staff => const _OpsRoleMeta('Service Queue', 'พนักงานเสิร์ฟ'),
  StaffRoute.cashier => const _OpsRoleMeta('Billing & Checkout', 'แคชเชียร์'),
  StaffRoute.operations => const _OpsRoleMeta(
    'Small Team Operations',
    'รวมงานหน้าร้าน',
  ),
  StaffRoute.admin => const _OpsRoleMeta('Admin Console', 'ผู้ดูแลระบบ'),
};

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.dashboard, required this.route});

  final OpsDashboard dashboard;
  final StaffRoute route;

  @override
  Widget build(BuildContext context) {
    final waitingCalls =
        route == StaffRoute.staff || route == StaffRoute.operations;
    final cards = [
      ('🍽️ โต๊ะเปิดอยู่', dashboard.summary.openTables),
      ('🔔 ออเดอร์ใหม่', dashboard.summary.newOrders),
      ('🔥 กำลังทำ', dashboard.summary.preparing),
      (
        waitingCalls ? '🛎️ งานรอรับ' : '✅ พร้อมเสิร์ฟ',
        waitingCalls ? dashboard.summary.waitingCalls : dashboard.summary.ready,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 640 ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 96,
        ),
        itemBuilder: (_, index) =>
            _SummaryCard(label: cards[index].$1, value: cards[index].$2),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: PhiusTokens.surface,
      border: Border.all(color: PhiusTokens.border),
      borderRadius: BorderRadius.circular(PhiusTokens.radiusSm),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: PhiusTokens.muted, fontSize: 12),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 27),
        ),
      ],
    ),
  );
}
