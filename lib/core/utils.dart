import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppUtils {
  // Show snackbar helper
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Biometric feedback helper
  static void showBiometricFeedback(BuildContext context, String type) {
    final Map<String, String> messages = {
      'fingerprint': 'Touch ID activated - Place your finger on the sensor',
      'face': 'Face ID activated - Look at your device',
      'pin': 'PIN entry - Enter your secure PIN',
    };

    showSnackBar(context, messages[type] ?? 'Unknown biometric type');
  }

  // Navigation helpers
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  // Responsive design helpers
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // Theme helpers
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  static bool isStrongPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  // Path resolver utility for profile images
  static Future<String?> resolveImagePath(
    String? storedPath,
    int accountId,
  ) async {
    if (storedPath == null || storedPath.isEmpty) return null;

    // Check if the stored path exists
    final storedFile = File(storedPath);
    if (await storedFile.exists()) return storedPath;

    // Try to find by pattern in the profile_images directory
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_images');

      if (await profileDir.exists()) {
        // Look for files matching this account ID
        final recoveredFilePath = '${profileDir.path}/profile_$accountId.jpg';
        final recoveredFile = File(recoveredFilePath);

        if (await recoveredFile.exists()) return recoveredFilePath;

        // As a last resort, look for any profile image for this account
        final dir = Directory(profileDir.path);
        final List<FileSystemEntity> entities = await dir.list().toList();
        for (var entity in entities) {
          if (entity is File && entity.path.contains('profile_$accountId')) {
            return entity.path;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error resolving image path: $e');
      return null;
    }
  }
}
