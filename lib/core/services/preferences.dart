import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Preferences {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void removeAllPreferences() {
    _prefs.clear();
  }

  static Future<void> removePreference(String preferenceName) async {
    await _prefs.remove(preferenceName);
  }

  static User get user {
    String? jsonStr = _prefs.getString('user');

    if (jsonStr == null) {
      return User();
    }
    return User.fromJson(json.decode(jsonStr));
  }

  static set user(User value) {
    _prefs.setString('user', json.encode(value.toJson()));
  }

  static Future<T?> get<T>(String key) async {
    final prefs = _prefs;

    if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    } else {
      throw Exception('Unsupported type');
    }
  }

  static Future set<T>(String key, T value) async {
    final prefs = _prefs;

    if (T == int) {
      prefs.setInt(key, value as int);
    } else if (T == double) {
      prefs.setDouble(key, value as double);
    } else if (T == String) {
      prefs.setString(key, value as String);
    } else if (T == bool) {
      prefs.setBool(key, value as bool);
    } else {
      throw Exception('Unsupported type');
    }
  }
}
