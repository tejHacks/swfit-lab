import 'package:flutter/material.dart';

import '../config.dart';

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: AppConfig.seed, brightness: b);
  final bg = dark ? const Color(0xFF111111) : const Color(0xFFF7F7F5);
  final card = dark ? const Color(0xFF1A1A19) : Colors.white;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: card, indicatorColor: scheme.primaryContainer),
  );
}

/// Code editor colours (always dark).
class CodeColors {
  static const bg = Color(0xFF161B22);
  static const plain = Color(0xFFE6EDF3);
  static const keyword = Color(0xFFFF7B72);
  static const type = Color(0xFF79C0FF);
  static const string = Color(0xFFA5D6FF);
  static const number = Color(0xFFFFA657);
  static const comment = Color(0xFF8B949E);
  static const variable = Color(0xFFFFA657);
  static const attribute = Color(0xFFD2A8FF);
  static const function = Color(0xFFD2A8FF);
}
