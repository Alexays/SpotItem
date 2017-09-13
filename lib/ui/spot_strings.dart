import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

import 'package:spotitem/i18n/spot_messages_all.dart';

// Information about how this file relates to i18n/stock_messages_all.dart and how the i18n files
// were generated can be found in i18n/regenerate.md.

class SpotL {
  SpotL(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  static Future<SpotL> load(Locale locale) {
    return initializeMessages(locale.toString()).then((Null _) {
      return new SpotL(locale);
    });
  }

  static SpotL of(BuildContext context) {
    return Localizations.of<SpotL>(context, SpotL);
  }

  String home() => Intl.message('<home>', name: 'home', locale: _localeName);
}