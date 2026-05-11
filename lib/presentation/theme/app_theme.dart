import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _seedLight = Color(0xFF5C6BC0); // indigo
  static const _seedDark = Color(0xFF7986CB);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedLight,
          brightness: Brightness.light,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          scrolledUnderElevation: 1,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedDark,
          brightness: Brightness.dark,
          surface: const Color(0xFF0F0F1A),
          onSurface: const Color(0xFFE8E8FF),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF13131F),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: _seedDark.withAlpha(60),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          scrolledUnderElevation: 1,
          shadowColor: Color(0x40000000),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A2A40),
        ),
      );

  static Color mbtiTypeColor(String type, Brightness brightness) {
    final t = type.toUpperCase();
    if (['INTJ', 'INTP', 'ENTJ', 'ENTP'].contains(t)) {
      return brightness == Brightness.dark
          ? const Color(0xFF4A90D9)
          : const Color(0xFF1565C0);
    }
    if (['INFJ', 'INFP', 'ENFJ', 'ENFP'].contains(t)) {
      return brightness == Brightness.dark
          ? const Color(0xFF82B366)
          : const Color(0xFF2E7D32);
    }
    if (['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'].contains(t)) {
      return brightness == Brightness.dark
          ? const Color(0xFFD4A843)
          : const Color(0xFFF57F17);
    }
    return brightness == Brightness.dark
        ? const Color(0xFFB07BC6)
        : const Color(0xFF6A1B9A);
  }
}
