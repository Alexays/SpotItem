import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:flutter/services.dart';
import 'package:spotitem/models/settings.dart';
import 'package:spotitem/services/basic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart' as package_info;

/// Settings class manager
class SettingsManager extends BasicService {
  /// Settings Object
  Settings value;

  /// Spotitem versio
  String version;

  @override
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      value = new Settings(JSON.decode(prefs.getString(keySettings) ?? '{}'));
      if (!value.isValid()) {
        value = new Settings.classic();
      }
    } catch (err) {
      value = new Settings.classic();
    }
    try {
      version = await package_info.version;
    } on PlatformException {
      return false;
    }
    return true;
  }

  /// Save settings
  Future<Null> saveSettings() async {
    await SharedPreferences.getInstance()
      ..setString(keySettings, JSON.encode(value.toString()));
  }

  /// Delete settings
  Future<Null> clearSettings() async {
    await SharedPreferences.getInstance()
      ..remove(keySettings);
  }
}
