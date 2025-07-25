import 'package:flutter/material.dart';

enum AppTheme { light, dark }

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();

  ThemeData get themeData => _themeData;

  void setTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        _themeData = ThemeData.light();
        break;
      case AppTheme.dark:
        _themeData = ThemeData.dark();
        break;
    }
    notifyListeners();
  }
}
