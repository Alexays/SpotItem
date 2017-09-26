import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/basic.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings class manager
class SettingsManager extends BasicService {
  /// Settings Object
  dynamic get settings => _settings;

  /// Private varibles
  dynamic _settings;
  @override
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _settings = JSON.decode(prefs.getString(keySettings) ?? '{}');
    } catch (err) {
      return false;
    }
    return true;
  }

  /// Delete Settings
  Future<Null> clearSettings() async {
    await SharedPreferences.getInstance()
      ..remove(keySettings);
  }
}
