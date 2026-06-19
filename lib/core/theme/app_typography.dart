import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextStyle headingLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle headingMedium = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static TextStyle headingSmall = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle buttonText = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}
