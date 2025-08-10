import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark }

class ThemeProvider with ChangeNotifier {
  static const _prefKey = 'app_theme';

  ThemeData _themeData = ThemeData.light();
  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored == 'dark') {
      _themeData = ThemeData.dark();
    } else {
      _themeData = ThemeData.light();
    }
    notifyListeners();
  }

  void setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    switch (theme) {
      case AppTheme.light:
        _themeData = ThemeData.light();
        prefs.setString(_prefKey, 'light');
        break;
      case AppTheme.dark:
        _themeData = ThemeData.dark();
        prefs.setString(_prefKey, 'dark');
        break;
    }
    notifyListeners();
  }
}
