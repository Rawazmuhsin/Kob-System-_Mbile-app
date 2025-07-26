import 'package:flutter/material.dart';

// App Constants
class AppConstants {
  // App Info
  static const String appName = 'KOB ';
  static const String appSubtitle = 'Kurdish-O-Banking';
  static const String appTagline = 'Your Future, Your Bank';
  static const String appVersion = 'Version 1.0 | © 2025 Kurdish-O-Banking';

  // App Logo
  static const String appLogo = 'KÖB';

  // Messages
  static const Map<String, String> biometricMessages = {
    'fingerprint': 'Touch ID activated - Place your finger on the sensor',
    'face': 'Face ID activated - Look at your device',
    'pin': 'PIN entry - Enter your secure PIN',
  };

  static const String loginMessage = 'Redirecting to secure login...';
  static const String createAccountMessage = 'Starting account creation...';
  static const String welcomeMessage =
      'Experience secure, convenient banking with our user-friendly platform. '
      'Manage your finances anywhere, anytime.';

  // Feature Items
  static const List<Map<String, dynamic>> features = [
    {'icon': '🔒', 'text': 'Secure', 'color': Color(0xFF1F2937)},
    {'icon': '🌐', 'text': '24/7 Access', 'color': Color(0xFF10B981)},
    {'icon': '⚡', 'text': 'Fast Transfer', 'color': Color(0xFFF59E0B)},
  ];
}

// App Colors
class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF1F2937);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryAmber = Color(0xFFF59E0B);

  // Gradient Colors
  static const List<Color> darkGradient = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];
  static const List<Color> lightGradient = [
    Color(0xFFF1F5F9),
    Color(0xFFE2E8F0),
  ];

  // Text Colors
  static const Color lightText = Color(0xFF64748B);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color lightSurface = Color(0xFFF1F5F9);
  static const Color darkText = Color(0xFF1E293B);
}

// Color Schemes
final darkColorScheme = ColorScheme.dark(
  primary: AppColors.primaryDark,
  secondary: AppColors.primaryGreen,
  surface: AppColors.darkSurface,
  onSurface: Colors.white,
);

final lightColorScheme = ColorScheme.light(
  primary: AppColors.primaryDark,
  secondary: AppColors.primaryGreen,
  surface: AppColors.lightSurface,
  onSurface: AppColors.darkText,
);

// Text Themes
final darkTextTheme = const TextTheme(
  bodyMedium: TextStyle(color: Colors.white),
  bodySmall: TextStyle(color: Colors.white70),
);

final lightTextTheme = const TextTheme(
  bodyMedium: TextStyle(color: AppColors.darkText),
  bodySmall: TextStyle(color: AppColors.lightText),
);
