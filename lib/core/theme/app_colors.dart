import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Mode Sleek Glassmorphism Palette
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B);    // Slate 800
  static const Color surfaceLight = Color(0xFF334155); // Slate 700

  // Brand Colors
  static const Color primary = Color(0xFF6366F1);      // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDisabled = Color(0x806366F1); // Indigo 500 with 50% opacity
  static const Color secondary = Color(0xFFEC4899);    // Pink 500

  // Interaction Colors
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color error = Color(0xFFEF4444);        // Red 500

  // Neutral Colors
  static const Color textPrimary = Color(0xFFF8FAFC);  // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFF475569);        // Slate 600

  // Brand-Specific Absolute Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
