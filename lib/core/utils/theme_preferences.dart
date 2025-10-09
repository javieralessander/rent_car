import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const _themeKey = 'isDarkMode';

  // Guardar el estado del tema
  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool(_themeKey, isDarkMode);
    if (!success) {
      throw Exception('No se pudo guardar el estado del tema.');
    }
  }

  // Cargar el estado del tema
  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true; // Por defecto: Dark Mode
  }
}
