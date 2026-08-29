import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 24),
    child: Text(
      'Created by CodingPhius Creativities · alphaphius.tkh@gmail.com',
      textAlign: TextAlign.center,
      style: TextStyle(color: PhiusTokens.muted, fontSize: 10),
    ),
  );
}
