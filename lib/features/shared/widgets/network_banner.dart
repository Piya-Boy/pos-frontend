import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key, required this.offline});

  final bool offline;

  @override
  Widget build(BuildContext context) => offline
      ? Container(
          width: double.infinity,
          color: PhiusTokens.saffron,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: const Text('ออฟไลน์', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
        )
      : const SizedBox.shrink();
}
