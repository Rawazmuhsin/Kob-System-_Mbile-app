import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSystemMode = true;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;
  bool get isSystemMode => _isSystemMode;

  ThemeMode get themeMode {
    if (_isSystemMode) {
      return ThemeMode.system;
    }
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> setTheme(bool isDark, {bool isSystem = false}) async {
    _isDarkMode = isDark;
    _isSystemMode = isSystem;

    await _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_isSystemMode) {
      // If in system mode, switch to light mode
      await setTheme(false);
    } else if (!_isDarkMode) {
      // If in light mode, switch to dark mode
      await setTheme(true);
    } else {
      // If in dark mode, switch to system mode
      await setTheme(false, isSystem: true);
    }
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
      _isSystemMode = _prefs.getBool('isSystemMode') ?? true;

      // If this is the first time, set default based on system
      if (!_prefs.containsKey('isSystemMode') &&
          !_prefs.containsKey('isDarkMode')) {
        _isSystemMode = true;
        await _saveThemeToPrefs();
      }

      notifyListeners();
    } catch (e) {
      // Default values if there's an error loading preferences
      _isDarkMode = false;
      _isSystemMode = true;
      notifyListeners();
    }
  }

  Future<void> _saveThemeToPrefs() async {
    try {
      await _prefs.setBool('isDarkMode', _isDarkMode);
      await _prefs.setBool('isSystemMode', _isSystemMode);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  // Method to get current brightness for immediate use
  Brightness getCurrentBrightness(BuildContext context) {
    if (_isSystemMode) {
      return MediaQuery.of(context).platformBrightness;
    }
    return _isDarkMode ? Brightness.dark : Brightness.light;
  }

  // Reset to system default
  Future<void> resetToSystem() async {
    await setTheme(false, isSystem: true);
  }
}
