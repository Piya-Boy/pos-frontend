import 'package:flutter/material.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/models/session_bundle.dart';

bool isBillPending(SessionBundle? bundle) {
  if (bundle == null) return false;
  return bundle.session.status == 'PAYMENT_PENDING' ||
      bundle.calls.any(
        (call) =>
            call.type == 'BILL' &&
            const {'OPEN', 'ASSIGNED'}.contains(call.status),
      );
}

class BillStatusBanner extends StatelessWidget {
  const BillStatusBanner({super.key, required this.session});

  final SessionBundle? session;

  @override
  Widget build(BuildContext context) {
    if (!isBillPending(session)) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Material(
            color: PhiusTokens.surface,
            borderRadius: BorderRadius.circular(PhiusTokens.radius),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: PhiusTokens.primaryLight),
                borderRadius: BorderRadius.circular(PhiusTokens.radius),
                boxShadow: PhiusTokens.shadowSm,
              ),
              child: const Row(
                children: [
                  Text('🧾', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เรียกเก็บเงินแล้ว',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'พนักงานได้รับแจ้งแล้ว กรุณารอสักครู่',
                          style: TextStyle(color: PhiusTokens.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
