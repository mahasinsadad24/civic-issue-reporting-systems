import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _enableNotifications = true;
  double _fontScale = 1.0;

  ThemeMode get themeMode => _themeMode;
  bool get enableNotifications => _enableNotifications;
  double get fontScale => _fontScale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Load Notifications
    _enableNotifications = prefs.getBool('enable_notifications') ?? true;

    // Load Font Scale
    _fontScale = prefs.getDouble('font_scale') ?? 1.0;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> setNotifications(bool enabled) async {
    if (_enableNotifications == enabled) return;

    _enableNotifications = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', enabled);
  }

  Future<void> setFontScale(double scale) async {
    if (_fontScale == scale) return;

    _fontScale = scale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', scale);
  }
}
