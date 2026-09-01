import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

Future<T?> showPhiusModal<T>(BuildContext context, {required Widget child, String? className}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PhiusTokens.bg,
      // cp-pos ".modal-panel": width min(640,100%), top radius 26 (Styles.html:190).
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - 24),
        // cp-pos ".modal-body" padding 18 + bottom safe-area inset.
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 16 + MediaQuery.viewInsetsOf(context).bottom),
          child: child,
        ),
      ),
    );
