import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

import 'package:spotitem/i18n/spot_messages_all.dart';

// Information about how this file relates to i18n/stock_messages_all.dart and how the i18n files
// were generated can be found in i18n/regenerate.md.

class SpotStrings {
  SpotStrings(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  static Future<SpotStrings> load(Locale locale) {
    return initializeMessages(locale.toString()).then((Null _) {
      return new SpotStrings(locale);
    });
  }

  static SpotStrings of(BuildContext context) {
    return Localizations.of<SpotStrings>(context, SpotStrings);
  }

  String title() {
    return Intl.message(
      '<Stocks>',
      name: 'title',
      desc: 'Title for the Stocks application',
      locale: _localeName,
    );
  }

  String market() => Intl.message(
        'MARKET',
        name: 'market',
        desc: 'Label for the Market tab',
        locale: _localeName,
      );

  String portfolio() => Intl.message(
        'PORTFOLIO',
        name: 'portfolio',
        desc: 'Label for the Portfolio tab',
        locale: _localeName,
      );
}
