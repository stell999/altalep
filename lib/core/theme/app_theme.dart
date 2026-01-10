import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Global logo asset used throughout the application (e.g., splash/sidebar).
  static const String logoAsset = 'assets/logo.png';

  static ThemeData build() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F70C1),
      brightness: Brightness.light,
    );
    final colorScheme = baseScheme.copyWith(
      surface: const Color(0xFFF5F5F7),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      textTheme: GoogleFonts.cairoTextTheme(),
      fontFamily: GoogleFonts.cairo().fontFamily,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
