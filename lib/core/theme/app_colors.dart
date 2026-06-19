import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Mutable Theme-dependent Colors (Starts with Light Mode by default!)
  static Color background = const Color(0xFFF8FAFC);
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceLight = const Color(0xFFF1F5F9);
  static Color textPrimary = const Color(0xFF0F172A);
  static Color textSecondary = const Color(0xFF475569);
  static Color border = const Color(0xFFE2E8F0);

  // Constant Brand Colors
  static const Color primary = Color(0xFF6366F1);      // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDisabled = Color(0x806366F1); // Indigo 500 with 50% opacity
  static const Color secondary = Color(0xFFEC4899);    // Pink 500

  // Interaction Colors
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color error = Color(0xFFEF4444);        // Red 500

  // Brand-Specific Absolute Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static void setToDark() {
    background = const Color(0xFF0F172A); // Slate 900
    surface = const Color(0xFF1E293B);    // Slate 800
    surfaceLight = const Color(0xFF334155); // Slate 700
    textPrimary = const Color(0xFFF8FAFC);  // Slate 50
    textSecondary = const Color(0xFF94A3B8); // Slate 400
    border = const Color(0xFF475569);        // Slate 600
  }

  static void setToLight() {
    background = const Color(0xFFF8FAFC);   // Soft white / off-white
    surface = const Color(0xFFFFFFFF);      // White card
    surfaceLight = const Color(0xFFF1F5F9); // Slate 100
    textPrimary = const Color(0xFF0F172A);   // Dark slate text
    textSecondary = const Color(0xFF475569); // Slate 600 text
    border = const Color(0xFFE2E8F0);        // Slate 200 border
  }
}
