import "package:flutter/material.dart";

class AppTheme {
  static const primary = Color(0xFF1F3A5F);
  static const accent = Color(0xFFC2410C);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, secondary: accent),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
  );
}
