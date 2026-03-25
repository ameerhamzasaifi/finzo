import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6C63FF);
  static const incomeColor = Color(0xFF2ECC71);
  static const expenseColor = Color(0xFFE74C3C);
  static const surfaceColor = Color(0xFF1E1E2E);
  static const cardColor = Color(0xFF252535);
  static const backgroundColor = Color(0xFF12121F);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: Color(0xFF03DAC6),
        surface: surfaceColor,
        onSurface: Colors.white,
        error: expenseColor,
      ),
      cardColor: cardColor,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: primaryColor.withAlpha(77),
        labelStyle: const TextStyle(color: Colors.white),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class AppConstants {
  static const List<String> accountIcons = [
    '💵',
    '🏦',
    '💳',
    '🏧',
    '💰',
    '🪙',
    '📊',
  ];

  static const List<String> categoryIcons = [
    '🍔',
    '🍕',
    '☕',
    '🚗',
    '✈️',
    '🏠',
    '🛍️',
    '💡',
    '🏥',
    '🎮',
    '📚',
    '💼',
    '💻',
    '🎁',
    '💰',
    '📈',
    '🎵',
    '🏋️',
    '💄',
    '🐾',
    '⛽',
    '📱',
    '🍷',
    '🎬',
    '🌐',
    '📦',
  ];

  static const List<int> colorOptions = [
    0xFF6C63FF,
    0xFF2ECC71,
    0xFFE74C3C,
    0xFF3498DB,
    0xFFF39C12,
    0xFF9B59B6,
    0xFF1ABC9C,
    0xFFE91E63,
    0xFF4ECDC4,
    0xFFFF6B6B,
    0xFF45B7D1,
    0xFFBB8FCE,
    0xFF82E0AA,
    0xFFF7DC6F,
    0xFFFF8C42,
    0xFF95A5A6,
  ];
}
