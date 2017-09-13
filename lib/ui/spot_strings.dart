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

  /// Edit Profile title
  String editProfile() =>
      Intl.message('<editProfile>', name: 'editProfile', locale: _localeName);

  /// Add Group title
  String addGroup() =>
      Intl.message('<addGroup>', name: 'addGroup', locale: _localeName);

  /// Already added message
  String alreadyAdded() =>
      Intl.message('<alreadyAdded>', name: 'alreadyAdded', locale: _localeName);

  /// Name title
  String name() => Intl.message('<name>', name: 'name', locale: _localeName);

  /// Name placeholder
  String namePh() =>
      Intl.message('<namePh>', name: 'namePh', locale: _localeName);

  /// About title
  String about() => Intl.message('<about>', name: 'about', locale: _localeName);

  /// About placeholder
  String aboutPh() =>
      Intl.message('<aboutPh>', name: 'aboutPh', locale: _localeName);

  /// Add someone title
  String addSomeone() =>
      Intl.message('<addSomeone>', name: 'addSomeone', locale: _localeName);

  /// Recent items title
  String recentItems() =>
      Intl.message('<recentItems>', name: 'recentItems', locale: _localeName);

  /// From your groups title
  String fromYourGroups() => Intl.message('<fromYourGroups>',
      name: 'fromYourGroups', locale: _localeName);

  /// No items title
  String noItems() =>
      Intl.message('<noItems>', name: 'noItems', locale: _localeName);
}
