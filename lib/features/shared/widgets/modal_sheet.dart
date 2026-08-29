import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

Future<T?> showPhiusModal<T>(BuildContext context, {required Widget child, String? className}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PhiusTokens.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - 24),
        child: child,
      ),
    );
