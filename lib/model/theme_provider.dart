import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blocparty/main.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = ThemeData();
  bool _isDarkMode = false;
  SharedPreferences? _prefs;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    // Initialize with default light theme
    // Use Future.microtask to defer initialization until after build
    Future.microtask(() => _loadThemePreference());
  }

  Future<void> _loadThemePreference() async {
    try {
      // Initialize SharedPreferences instance
      _prefs = await SharedPreferences.getInstance();

      // Retrieve saved theme preference using key 'isDarkMode' (defaults to false if not found)
      _isDarkMode = _prefs?.getBool('isDarkMode') ?? false;

      // Determine theme file name based on preference
      final themeFileName = _isDarkMode
          ? 'dark_blue_appainter_theme.json'
          : 'blue_appainter_theme.json';

      // Load theme using the existing loadThemeFromJson function
      _themeData = await loadThemeFromJson(themeFileName);

      // Update UI
      notifyListeners();
    } catch (e) {
      // If loading fails, use default light theme
      _isDarkMode = false;
      _themeData = await loadThemeFromJson('blue_appainter_theme.json');
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    try {
      // Toggle _isDarkMode boolean value
      _isDarkMode = !_isDarkMode;

      // Determine new theme file name based on toggled value
      final themeFileName = _isDarkMode
          ? 'dark_blue_appainter_theme.json'
          : 'blue_appainter_theme.json';

      // Load new theme using loadThemeFromJson
      _themeData = await loadThemeFromJson(themeFileName);

      // Save preference to SharedPreferences using key 'isDarkMode'
      await _prefs?.setBool('isDarkMode', _isDarkMode);

      // Update UI
      notifyListeners();
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      // Set _isDarkMode to the provided value
      _isDarkMode = isDark;

      // Determine theme file name based on provided value
      final themeFileName = _isDarkMode
          ? 'dark_blue_appainter_theme.json'
          : 'blue_appainter_theme.json';

      // Load new theme using loadThemeFromJson
      _themeData = await loadThemeFromJson(themeFileName);

      // Save preference to SharedPreferences using key 'isDarkMode'
      await _prefs?.setBool('isDarkMode', _isDarkMode);

      // Update UI
      notifyListeners();
    } catch (e) {
      print('Error setting theme: $e');
    }
  }
}

