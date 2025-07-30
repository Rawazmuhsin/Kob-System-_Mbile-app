// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  // App Preferences
  String _selectedLanguage = 'English';
  String _fontSize = 'Medium';
  bool _appNotificationsEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _hapticFeedbackEnabled = true;

  // Security & Privacy
  bool _biometricLoginEnabled = false;
  int _autoLogoutMinutes = 15;
  bool _screenLockEnabled = true;

  // Transaction Preferences
  String _transactionConfirmationMethod = 'PIN';
  bool _limitWarningsEnabled = true;
  String _receiptPreference = 'Email';
  bool _autoCategorizeEnabled = true;

  // Notifications
  bool _transactionAlertsEnabled = true;
  bool _lowBalanceWarningsEnabled = true;
  bool _securityAlertsEnabled = true;
  bool _marketingCommunicationsEnabled = false;

  // Backup & Data
  String _backupFrequency = 'Weekly';
  bool _dataSyncEnabled = true;

  bool _isLoading = false;

  // Getters
  String get selectedLanguage => _selectedLanguage;
  String get fontSize => _fontSize;
  bool get appNotificationsEnabled => _appNotificationsEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  bool get biometricLoginEnabled => _biometricLoginEnabled;
  int get autoLogoutMinutes => _autoLogoutMinutes;
  bool get screenLockEnabled => _screenLockEnabled;

  String get transactionConfirmationMethod => _transactionConfirmationMethod;
  bool get limitWarningsEnabled => _limitWarningsEnabled;
  String get receiptPreference => _receiptPreference;
  bool get autoCategorizeEnabled => _autoCategorizeEnabled;

  bool get transactionAlertsEnabled => _transactionAlertsEnabled;
  bool get lowBalanceWarningsEnabled => _lowBalanceWarningsEnabled;
  bool get securityAlertsEnabled => _securityAlertsEnabled;
  bool get marketingCommunicationsEnabled => _marketingCommunicationsEnabled;

  String get backupFrequency => _backupFrequency;
  bool get dataSyncEnabled => _dataSyncEnabled;

  bool get isLoading => _isLoading;

  // Load settings from storage
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      final settings = await _settingsService.loadSettings();

      _selectedLanguage = settings['selectedLanguage'] ?? 'English';
      _fontSize = settings['fontSize'] ?? 'Medium';
      _appNotificationsEnabled = settings['appNotificationsEnabled'] ?? true;
      _soundEffectsEnabled = settings['soundEffectsEnabled'] ?? true;
      _hapticFeedbackEnabled = settings['hapticFeedbackEnabled'] ?? true;

      _biometricLoginEnabled = settings['biometricLoginEnabled'] ?? false;
      _autoLogoutMinutes = settings['autoLogoutMinutes'] ?? 15;
      _screenLockEnabled = settings['screenLockEnabled'] ?? true;

      _transactionConfirmationMethod =
          settings['transactionConfirmationMethod'] ?? 'PIN';
      _limitWarningsEnabled = settings['limitWarningsEnabled'] ?? true;
      _receiptPreference = settings['receiptPreference'] ?? 'Email';
      _autoCategorizeEnabled = settings['autoCategorizeEnabled'] ?? true;

      _transactionAlertsEnabled = settings['transactionAlertsEnabled'] ?? true;
      _lowBalanceWarningsEnabled =
          settings['lowBalanceWarningsEnabled'] ?? true;
      _securityAlertsEnabled = settings['securityAlertsEnabled'] ?? true;
      _marketingCommunicationsEnabled =
          settings['marketingCommunicationsEnabled'] ?? false;

      _backupFrequency = settings['backupFrequency'] ?? 'Weekly';
      _dataSyncEnabled = settings['dataSyncEnabled'] ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final settings = {
        'selectedLanguage': _selectedLanguage,
        'fontSize': _fontSize,
        'appNotificationsEnabled': _appNotificationsEnabled,
        'soundEffectsEnabled': _soundEffectsEnabled,
        'hapticFeedbackEnabled': _hapticFeedbackEnabled,
        'biometricLoginEnabled': _biometricLoginEnabled,
        'autoLogoutMinutes': _autoLogoutMinutes,
        'screenLockEnabled': _screenLockEnabled,
        'transactionConfirmationMethod': _transactionConfirmationMethod,
        'limitWarningsEnabled': _limitWarningsEnabled,
        'receiptPreference': _receiptPreference,
        'autoCategorizeEnabled': _autoCategorizeEnabled,
        'transactionAlertsEnabled': _transactionAlertsEnabled,
        'lowBalanceWarningsEnabled': _lowBalanceWarningsEnabled,
        'securityAlertsEnabled': _securityAlertsEnabled,
        'marketingCommunicationsEnabled': _marketingCommunicationsEnabled,
        'backupFrequency': _backupFrequency,
        'dataSyncEnabled': _dataSyncEnabled,
      };

      await _settingsService.saveSettings(settings);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // App Preferences Methods
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setFontSize(String fontSize) async {
    _fontSize = fontSize;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleAppNotifications() async {
    _appNotificationsEnabled = !_appNotificationsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleSoundEffects() async {
    _soundEffectsEnabled = !_soundEffectsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleHapticFeedback() async {
    _hapticFeedbackEnabled = !_hapticFeedbackEnabled;
    notifyListeners();
    await _saveSettings();
  }

  // Security & Privacy Methods
  Future<void> toggleBiometricLogin() async {
    _biometricLoginEnabled = !_biometricLoginEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setAutoLogoutMinutes(int minutes) async {
    _autoLogoutMinutes = minutes;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleScreenLock() async {
    _screenLockEnabled = !_screenLockEnabled;
    notifyListeners();
    await _saveSettings();
  }

  // Transaction Preferences Methods
  Future<void> setTransactionConfirmationMethod(String method) async {
    _transactionConfirmationMethod = method;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleLimitWarnings() async {
    _limitWarningsEnabled = !_limitWarningsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setReceiptPreference(String preference) async {
    _receiptPreference = preference;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleAutoCategorize() async {
    _autoCategorizeEnabled = !_autoCategorizeEnabled;
    notifyListeners();
    await _saveSettings();
  }

  // Notifications Methods
  Future<void> toggleTransactionAlerts() async {
    _transactionAlertsEnabled = !_transactionAlertsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleLowBalanceWarnings() async {
    _lowBalanceWarningsEnabled = !_lowBalanceWarningsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleSecurityAlerts() async {
    _securityAlertsEnabled = !_securityAlertsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleMarketingCommunications() async {
    _marketingCommunicationsEnabled = !_marketingCommunicationsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  // Backup & Data Methods
  Future<void> setBackupFrequency(String frequency) async {
    _backupFrequency = frequency;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleDataSync() async {
    _dataSyncEnabled = !_dataSyncEnabled;
    notifyListeners();
    await _saveSettings();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _selectedLanguage = 'English';
    _fontSize = 'Medium';
    _appNotificationsEnabled = true;
    _soundEffectsEnabled = true;
    _hapticFeedbackEnabled = true;

    _biometricLoginEnabled = false;
    _autoLogoutMinutes = 15;
    _screenLockEnabled = true;

    _transactionConfirmationMethod = 'PIN';
    _limitWarningsEnabled = true;
    _receiptPreference = 'Email';
    _autoCategorizeEnabled = true;

    _transactionAlertsEnabled = true;
    _lowBalanceWarningsEnabled = true;
    _securityAlertsEnabled = true;
    _marketingCommunicationsEnabled = false;

    _backupFrequency = 'Weekly';
    _dataSyncEnabled = true;

    notifyListeners();
    await _saveSettings();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
