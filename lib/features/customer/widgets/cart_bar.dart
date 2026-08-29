import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/core/utils/formatters.dart';

class CartBar extends StatelessWidget {
  const CartBar({
    super.key,
    required this.count,
    required this.subtotal,
    required this.onTap,
    this.sessionCount = 0,
    this.sessionTotal = 0,
  });
  final num count;
  final num subtotal;
  final VoidCallback onTap;
  final int sessionCount;
  final num sessionTotal;

  @override
  Widget build(BuildContext context) => count == 0 && sessionCount == 0
      ? const SizedBox.shrink()
      : Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Material(
                color: PhiusTokens.primary,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                count > 0
                                    ? '$count รายการในตะกร้า'
                                    : '$sessionCount รายการของโต๊ะ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                formatMoney(
                                  count > 0 ? subtotal : sessionTotal,
                                ),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          count > 0 ? 'ดูตะกร้า →' : 'ดูรายละเอียด',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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

@Preview(name: 'Pending cart', group: 'Customer order', size: Size(600, 160))
Widget cartBarPreview() => MaterialApp(
  home: Scaffold(
    body: Stack(
      children: [CartBar(count: 2, subtotal: 140, onTap: cartBarPreviewTap)],
    ),
  ),
);

void cartBarPreviewTap() {}
