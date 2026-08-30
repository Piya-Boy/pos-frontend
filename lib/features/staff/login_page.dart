import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/tokens.dart';
import '../../features/shared/widgets/brand_mark.dart';
import '../../state/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onAuthenticated});

  final Widget Function() onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = auth.mustChangePin
        ? await auth.changePin(_pin.text)
        : await auth.login(_pin.text);
    if (!mounted || !success) return;
    if (auth.mustChangePin) {
      _pin.clear();
      return;
    }
    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final meta = _roleMeta(auth.route);
    final changingPin = auth.mustChangePin;
    return Scaffold(
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
                    if (!changingPin) ...[
                      TextButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Text('←'),
                        label: const Text('กลับหน้าหลัก'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Row(
                      children: [
                        BrandMark(small: true),
                        SizedBox(width: 10),
                        Text(
                          'Phius Order',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: PhiusTokens.surfaceSoft,
                        borderRadius: BorderRadius.circular(PhiusTokens.radius),
                      ),
                      child: Text(
                        meta.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      meta.kicker,
                      style: const TextStyle(
                        color: PhiusTokens.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      changingPin ? 'ตั้ง PIN ใหม่' : meta.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      changingPin
                          ? 'กรุณาตั้ง PIN ใหม่ที่ไม่ใช่รหัสเริ่มต้น'
                          : meta.description,
                      style: const TextStyle(color: PhiusTokens.muted),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _pin,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            maxLength: changingPin ? 12 : 12,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 25,
                              letterSpacing: 6,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'PIN',
                              hintText: '••••••',
                            ),
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              auth.error!,
                              style: const TextStyle(
                                color: PhiusTokens.primaryDark,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: auth.loading
                                ? null
                                : () => _submit(auth),
                            child: Text(
                              changingPin ? 'บันทึก PIN ใหม่' : 'เข้าสู่ระบบ',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!changingPin) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'PIN เริ่มต้น: zaq1234 · ระบบจะให้เปลี่ยนหลังเข้าสู่ระบบครั้งแรก',
                        style: TextStyle(
                          color: PhiusTokens.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_RoleMeta _roleMeta(StaffRoute route) => switch (route) {
  StaffRoute.kitchen => const _RoleMeta(
    '🔥',
    'Kitchen Display System',
    'หน้าครัว',
    'รับออเดอร์และอัปเดตสถานะการปรุง',
  ),
  StaffRoute.staff => const _RoleMeta(
    '🛎️',
    'Service Queue',
    'พนักงานเสิร์ฟ',
    'จัดการอาหารพร้อมเสิร์ฟและงานเรียกจากโต๊ะ',
  ),
  StaffRoute.cashier => const _RoleMeta(
    '🧾',
    'Billing & Checkout',
    'แคชเชียร์',
    'ตรวจสอบบิล รับชำระ และปิดโต๊ะ',
  ),
  StaffRoute.operations => const _RoleMeta(
    '🧭',
    'Small Team Operations',
    'รวมงานหน้าร้าน',
    'ดูงานครัว พนักงาน และแคชเชียร์ในหน้าเดียว',
  ),
  StaffRoute.admin => const _RoleMeta(
    '⚙️',
    'Admin Console',
    'ผู้ดูแลระบบ',
    'จัดการโต๊ะ เมนู โปรโมชั่น และพนักงาน',
  ),
};

class _RoleMeta {
  const _RoleMeta(this.icon, this.kicker, this.title, this.description);

  final String icon;
  final String kicker;
  final String title;
  final String description;
}
