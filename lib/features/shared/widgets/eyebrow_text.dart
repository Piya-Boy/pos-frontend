import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(color: PhiusTokens.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.32),
  );
}
