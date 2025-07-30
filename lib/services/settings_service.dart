// lib/services/settings_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  // Load settings from SharedPreferences
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        return Map<String, dynamic>.from(json.decode(settingsJson));
      }

      // Return default settings if none exist
      return _getDefaultSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return _getDefaultSettings();
    }
  }

  // Save settings to SharedPreferences
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings);
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    }
  }

  // Clear all settings
  Future<bool> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_settingsKey);
    } catch (e) {
      debugPrint('Error clearing settings: $e');
      return false;
    }
  }

  // Get default settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      // App Preferences
      'selectedLanguage': 'English',
      'fontSize': 'Medium',
      'appNotificationsEnabled': true,
      'soundEffectsEnabled': true,
      'hapticFeedbackEnabled': true,

      // Security & Privacy
      'biometricLoginEnabled': false,
      'autoLogoutMinutes': 15,
      'screenLockEnabled': true,

      // Transaction Preferences
      'transactionConfirmationMethod': 'PIN',
      'limitWarningsEnabled': true,
      'receiptPreference': 'Email',
      'autoCategorizeEnabled': true,

      // Notifications
      'transactionAlertsEnabled': true,
      'lowBalanceWarningsEnabled': true,
      'securityAlertsEnabled': true,
      'marketingCommunicationsEnabled': false,

      // Backup & Data
      'backupFrequency': 'Weekly',
      'dataSyncEnabled': true,
    };
  }

  // Get specific setting
  Future<T?> getSetting<T>(String key) async {
    try {
      final settings = await loadSettings();
      return settings[key] as T?;
    } catch (e) {
      debugPrint('Error getting setting $key: $e');
      return null;
    }
  }

  // Update specific setting
  Future<bool> updateSetting(String key, dynamic value) async {
    try {
      final settings = await loadSettings();
      settings[key] = value;
      return await saveSettings(settings);
    } catch (e) {
      debugPrint('Error updating setting $key: $e');
      return false;
    }
  }

  // Validate settings data
  bool _validateSettings(Map<String, dynamic> settings) {
    try {
      // Check required fields exist
      final requiredFields = [
        'selectedLanguage',
        'fontSize',
        'transactionConfirmationMethod',
        'receiptPreference',
        'backupFrequency',
      ];

      for (String field in requiredFields) {
        if (!settings.containsKey(field)) {
          return false;
        }
      }

      // Validate specific values
      final validLanguages = ['English', 'Kurdish', 'Arabic'];
      if (!validLanguages.contains(settings['selectedLanguage'])) {
        return false;
      }

      final validFontSizes = ['Small', 'Medium', 'Large'];
      if (!validFontSizes.contains(settings['fontSize'])) {
        return false;
      }

      final validConfirmationMethods = ['PIN', 'Biometric', 'Both'];
      if (!validConfirmationMethods.contains(
        settings['transactionConfirmationMethod'],
      )) {
        return false;
      }

      final validReceiptPreferences = ['Email', 'SMS', 'Both', 'None'];
      if (!validReceiptPreferences.contains(settings['receiptPreference'])) {
        return false;
      }

      final validBackupFrequencies = ['Daily', 'Weekly', 'Monthly', 'Manual'];
      if (!validBackupFrequencies.contains(settings['backupFrequency'])) {
        return false;
      }

      // Validate auto logout minutes
      final autoLogoutMinutes = settings['autoLogoutMinutes'];
      if (autoLogoutMinutes is! int ||
          autoLogoutMinutes < 1 ||
          autoLogoutMinutes > 120) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating settings: $e');
      return false;
    }
  }

  // Export settings as JSON
  Future<String?> exportSettings() async {
    try {
      final settings = await loadSettings();
      return json.encode(settings);
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      return null;
    }
  }

  // Import settings from JSON
  Future<bool> importSettings(String settingsJson) async {
    try {
      final settings = Map<String, dynamic>.from(json.decode(settingsJson));

      if (_validateSettings(settings)) {
        return await saveSettings(settings);
      } else {
        debugPrint('Invalid settings data');
        return false;
      }
    } catch (e) {
      debugPrint('Error importing settings: $e');
      return false;
    }
  }

  // Check if settings exist
  Future<bool> hasSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_settingsKey);
    } catch (e) {
      debugPrint('Error checking settings existence: $e');
      return false;
    }
  }

  // Get settings size (for storage management)
  Future<int> getSettingsSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      return settingsJson?.length ?? 0;
    } catch (e) {
      debugPrint('Error getting settings size: $e');
      return 0;
    }
  }

  // Migration methods for future versions
  Future<bool> migrateSettings(int fromVersion, int toVersion) async {
    try {
      debugPrint('Migrating settings from version $fromVersion to $toVersion');

      // Add migration logic here when needed
      // For now, just return true as no migration is needed
      return true;
    } catch (e) {
      debugPrint('Error migrating settings: $e');
      return false;
    }
  }
}
