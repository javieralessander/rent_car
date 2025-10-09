import 'package:flutter/material.dart';
import '../utils/theme_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemePreferences _preferences = ThemePreferences();
  bool _isDarkMode = false; // Cambiar el valor inicial a true
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    try {
      await _preferences.saveTheme(_isDarkMode);
      notifyListeners();
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _loadThemeFromPreferences() async {
    try {
      _isDarkMode = await _preferences.loadTheme();

      // ignore: empty_catches
    } catch (error) {}
    _isLoading = false;
    notifyListeners(); // Notificar cambios después de cargar
  }
}
