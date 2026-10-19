import 'package:flutter/material.dart';

class DoudyColors {
  static const green = Color(0xFF0B6E4F);
  static const gold = Color(0xFFF4B400);
  static const ink = Color(0xFF1B1F23);
  static const bg = Color(0xFFF6F7F5);
}

ThemeData doudyTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: DoudyColors.green,
    primary: DoudyColors.green,
    secondary: DoudyColors.gold,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: DoudyColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: DoudyColors.bg,
      foregroundColor: DoudyColors.ink,
      elevation: 0,
      centerTitle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
