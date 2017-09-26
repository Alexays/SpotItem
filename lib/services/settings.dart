import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/settings.dart';
import 'package:spotitem/services/basic.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings class manager
class SettingsManager extends BasicService {
  /// Settings Object
  Settings settings;
  @override
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      settings =
          new Settings(JSON.decode(prefs.getString(keySettings) ?? '{}'));
      if (!settings.isValid()) {
        settings = new Settings.classic();
      }
    } catch (err) {
      settings = new Settings.classic();
    }
    return true;
  }

  /// Delete Settings
  Future<Null> clearSettings() async {
    await SharedPreferences.getInstance()
      ..remove(keySettings);
  }
}
