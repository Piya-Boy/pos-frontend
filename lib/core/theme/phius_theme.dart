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
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PhiusTokens.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      hintStyle: const TextStyle(color: PhiusTokens.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PhiusTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PhiusTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PhiusTokens.primary, width: 2),
      ),
    ),
  );
}
