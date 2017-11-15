import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:spotitem/i18n/localizations.dart';

/// Spotitem localization delegate
class SpotLDelegate extends LocalizationsDelegate<SpotL> {
  @override
  Future<SpotL> load(Locale locale) => SpotL.load(locale);

  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(SpotLDelegate old) => false;
}

/// Spotitem localization class
class SpotL {
  /// Spotitem localization initializer
  SpotL(Locale locale)
      : assert(locale != null),
        this._localeName = _computeLocaleName(locale) {
    if (localizations.containsKey(locale.languageCode)) {
      _nameToValue.addAll(localizations[locale.languageCode]);
    }
    if (localizations.containsKey(_localeName)) {
      _nameToValue.addAll(localizations[_localeName]);
    }
  }

  final String _localeName;

  final Map<String, String> _nameToValue = <String, String>{};

  static String _computeLocaleName(Locale locale) =>
      locale.countryCode.isEmpty ? locale.languageCode : locale.toString();

  /// Load langs files
  static Future<SpotL> load(Locale locale) =>
      new SynchronousFuture(new SpotL(locale));

  /// Context
  static SpotL of(BuildContext context) =>
      Localizations.of<SpotL>(context, SpotL);

  /// Home title
  String get home => _nameToValue['home'];

  /// Logout title
  String get logout => _nameToValue['logout'];

  /// Search placeholder
  String get search => _nameToValue['search'];

  /// Search dialog
  String get searchDialog => _nameToValue['searchDialog'];

  /// Explorer title
  String get explore => _nameToValue['explore'];

  /// Discover title
  String get discover => _nameToValue['discover'];

  /// Items title
  String get items => _nameToValue['items'];

  /// Map title
  String get map => _nameToValue['map'];

  /// Map title
  String get social => _nameToValue['social'];

  /// Groups title
  String get groups => _nameToValue['groups'];

  /// Messages title
  String get messages => _nameToValue['messages'];

  /// Edit Profile title
  String get editProfile => _nameToValue['editProfile'];

  /// Add Group title
  String get addGroup => _nameToValue['addGroup'];

  /// Already added message
  String get alreadyAdded => _nameToValue['alreadyAdded'];

  /// Name title
  String get name => _nameToValue['name'];

  /// Name placeholder
  String get namePh => _nameToValue['namePh'];

  /// About title
  String get about => _nameToValue['about'];

  /// About placeholder
  String get aboutPh => _nameToValue['aboutPh'];

  /// Add someone title
  String get addSomeone => _nameToValue['addSomeone'];

  /// Recent items title
  String get recentItems => _nameToValue['recentItems'];

  /// From your groups title
  String get fromYourGroups => _nameToValue['fromYourGroups'];

  /// No items title
  String get noItems => _nameToValue['noItems'];

  /// No groups title
  String get noGroups => _nameToValue['noGroups'];

  /// No images title
  String get noImages => _nameToValue['noImages'];

  /// Add image title
  String get addImage => _nameToValue['addImage'];

  /// Images title
  String get images => _nameToValue['images'];

  /// Location title
  String get location => _nameToValue['location'];

  /// Location placeholder
  String get locationPh => _nameToValue['locationPh'];

  /// Add item title
  String get addItem => _nameToValue['addItem'];

  /// Private title
  String get private => _nameToValue['private'];

  /// Donated title
  String get gift => _nameToValue['gift'];

  /// No contacts title
  String get noContacts => _nameToValue['noContacts'];

  /// Edit group title
  String get editGroup => _nameToValue['editGroup'];

  /// Owner title
  String get owner => _nameToValue['owner'];

  /// Save title
  String get save => _nameToValue['save'];

  /// Confirmation title
  String get confirm => _nameToValue['confirm'];

  /// Firstname title
  String get firstname => _nameToValue['firstname'];

  /// Firstname placeholder
  String get firstnamePh => _nameToValue['firstnamePh'];

  /// Lastname title
  String get lastname => _nameToValue['lastname'];

  /// Lastname placeholder
  String get lastnamePh => _nameToValue['lastnamePh'];

  /// Email title
  String get email => _nameToValue['email'];

  /// Email placeholder
  String get emailPh => _nameToValue['emailPh'];

  /// Login title
  String get login => _nameToValue['login'];

  /// Register title
  String get register => _nameToValue['register'];

  /// Correct Error title
  String get correctError => _nameToValue['correctError'];

  /// Search contacts placeholder
  String get searchContact => _nameToValue['searchContact'];

  /// Password title
  String get password => _nameToValue['password'];

  /// Password placeholder
  String get passwordPh => _nameToValue['passwordPh'];

  /// Password repeat title
  String get passwordRepeat => _nameToValue['passwordRepeat'];

  /// Password repeat placeholder
  String get passwordRepeatPh => _nameToValue['passwordRepeatPh'];

  /// No account title
  String get noAccount => _nameToValue['noAccount'];

  /// I have an account title
  String get haveAccount => _nameToValue['haveAccount'];

  /// Login error title
  String get loginError => _nameToValue['loginError'];

  /// Unexpected error title
  String get error => _nameToValue['error'];

  /// Settings title
  String get settings => _nameToValue['settings'];

  /// Max distance title
  String get maxDistance => _nameToValue['maxDistance'];

  /// No message title
  String get noMessages => _nameToValue['noMessages'];

  /// Members title
  String get members => _nameToValue['members'];

  /// Leave group title
  String get leaveGroup => _nameToValue['leaveGroup'];

  /// Leave group title
  String get deleteGroup => _nameToValue['deleteGroup'];

  /// Leave group title
  String addOwner(String name) =>
      _nameToValue['addOwner'].replaceFirst(r'$name', name);

  /// Leave group title
  String delOwner(String name) =>
      _nameToValue['delOwner'].replaceFirst(r'$name', name);

  /// Add title
  String get add => _nameToValue['add'];

  /// Kick user title
  String kickUser(String name) =>
      _nameToValue['kickUser'].replaceFirst(r'$name', name);

  /// Select group title
  String get selectGroup => _nameToValue['selectGroup'];

  /// Send title
  String get send => _nameToValue['send'];

  /// Password error title
  String get passwordError => _nameToValue['passwordError'];

  /// Number invitation title
  String nbInv(String nb) => _nameToValue['nbInv'].replaceFirst(r'$nb', nb);

  /// Number invitation title
  String joinGroup(String name) =>
      _nameToValue['joinGroup'].replaceFirst(r'$name', name);

  /// Dist title
  String get dist => _nameToValue['dist'];

  /// Create conversation title
  String get createConv => _nameToValue['createConv'];

  /// Delete item title
  String get delItem => _nameToValue['delItem'];

  /// Loading title
  String get loading => _nameToValue['loading'];

  /// Delete title
  String get delete => _nameToValue['delete'];

  /// Calendar title
  String get calendar => _nameToValue['calendar'];

  /// Book title
  String get book => _nameToValue['book'];

  /// Holded title
  String get holded => _nameToValue['holded'];
}
