import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

import 'package:spotitem/i18n/spot_messages_all.dart';

/// Spotitem localization class
class SpotL {
  /// Spotitem localization initializer
  SpotL(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  /// Load langs files
  static Future<SpotL> load(Locale locale) =>
      initializeMessages(locale.toString()).then((_) => new SpotL(locale));

  /// Context
  static SpotL of(BuildContext context) =>
      Localizations.of<SpotL>(context, SpotL);

  /// Home title
  String home() => Intl.message('<home>', name: 'home', locale: _localeName);

  /// Logout title
  String logout() =>
      Intl.message('<logout>', name: 'logout', locale: _localeName);

  /// Search placeholder
  String search() =>
      Intl.message('<search>', name: 'search', locale: _localeName);

  /// Search dialog
  String searchDialog() =>
      Intl.message('<searchDialog>', name: 'searchDialog', locale: _localeName);

  /// Explorer title
  String explore() =>
      Intl.message('<explore>', name: 'explore', locale: _localeName);

  /// Discover title
  String discover() =>
      Intl.message('<discover>', name: 'discover', locale: _localeName);

  /// Edit Profile title
  String editProfile() =>
      Intl.message('<editProfile>', name: 'editProfile', locale: _localeName);

  /// Items title
  String items() => Intl.message('<items>', name: 'items', locale: _localeName);

  /// Map title
  String map() => Intl.message('<map>', name: 'map', locale: _localeName);

  /// Map title
  String social() =>
      Intl.message('<social>', name: 'social', locale: _localeName);

  /// Groups title
  String groups() =>
      Intl.message('<groups>', name: 'groups', locale: _localeName);

  /// Messages title
  String messages() =>
      Intl.message('<messages>', name: 'messages', locale: _localeName);
}
