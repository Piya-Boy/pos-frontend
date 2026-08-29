import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

ThemeData phiusTheme() {
  final base = ThemeData(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: PhiusTokens.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: PhiusTokens.primary,
      surface: PhiusTokens.surface,
      onSurface: PhiusTokens.ink,
    ),
    textTheme: GoogleFonts.promptTextTheme(base.textTheme).apply(
      bodyColor: PhiusTokens.ink,
      displayColor: PhiusTokens.ink,
    ),
  );
}
