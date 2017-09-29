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
  static Future<SpotL> load(Locale locale) => initializeMessages(locale.toString()).then((_) => new SpotL(locale));

  /// Context
  static SpotL of(BuildContext context) => Localizations.of<SpotL>(context, SpotL);

  /// Home title
  String home() => Intl.message('<home>', name: 'home', locale: _localeName);

  /// Logout title
  String logout() => Intl.message('<logout>', name: 'logout', locale: _localeName);

  /// Search placeholder
  String search() => Intl.message('<search>', name: 'search', locale: _localeName);

  /// Search dialog
  String searchDialog() => Intl.message('<searchDialog>', name: 'searchDialog', locale: _localeName);

  /// Explorer title
  String explore() => Intl.message('<explore>', name: 'explore', locale: _localeName);

  /// Discover title
  String discover() => Intl.message('<discover>', name: 'discover', locale: _localeName);

  /// Items title
  String items() => Intl.message('<items>', name: 'items', locale: _localeName);

  /// Map title
  String map() => Intl.message('<map>', name: 'map', locale: _localeName);

  /// Map title
  String social() => Intl.message('<social>', name: 'social', locale: _localeName);

  /// Groups title
  String groups() => Intl.message('<groups>', name: 'groups', locale: _localeName);

  /// Messages title
  String messages() => Intl.message('<messages>', name: 'messages', locale: _localeName);

  /// Edit Profile title
  String editProfile() => Intl.message('<editProfile>', name: 'editProfile', locale: _localeName);

  /// Add Group title
  String addGroup() => Intl.message('<addGroup>', name: 'addGroup', locale: _localeName);

  /// Already added message
  String alreadyAdded() => Intl.message('<alreadyAdded>', name: 'alreadyAdded', locale: _localeName);

  /// Name title
  String name() => Intl.message('<name>', name: 'name', locale: _localeName);

  /// Name placeholder
  String namePh() => Intl.message('<namePh>', name: 'namePh', locale: _localeName);

  /// About title
  String about() => Intl.message('<about>', name: 'about', locale: _localeName);

  /// About placeholder
  String aboutPh() => Intl.message('<aboutPh>', name: 'aboutPh', locale: _localeName);

  /// Add someone title
  String addSomeone() => Intl.message('<addSomeone>', name: 'addSomeone', locale: _localeName);

  /// Recent items title
  String recentItems() => Intl.message('<recentItems>', name: 'recentItems', locale: _localeName);

  /// From your groups title
  String fromYourGroups() => Intl.message('<fromYourGroups>', name: 'fromYourGroups', locale: _localeName);

  /// No items title
  String noItems() => Intl.message('<noItems>', name: 'noItems', locale: _localeName);

  /// No groups title
  String noGroups() => Intl.message('<noGroups>', name: 'noGroups', locale: _localeName);

  /// No images title
  String noImages() => Intl.message('<noImages>', name: 'noImages', locale: _localeName);

  /// Add image title
  String addImage() => Intl.message('<addImage>', name: 'addImage', locale: _localeName);

  /// Images title
  String images() => Intl.message('<images>', name: 'images', locale: _localeName);

  /// Location title
  String location() => Intl.message('<location>', name: 'location', locale: _localeName);

  /// Location placeholder
  String locationPh() => Intl.message('<locationPh>', name: 'locationPh', locale: _localeName);

  /// Add item title
  String addItem() => Intl.message('<addItem>', name: 'addItem', locale: _localeName);

  /// Private title
  String private() => Intl.message('<private>', name: 'private', locale: _localeName);

  /// Donated title
  String gift() => Intl.message('<gift>', name: 'gift', locale: _localeName);

  /// No contacts title
  String noContacts() => Intl.message('<noContacts>', name: 'noContacts', locale: _localeName);

  /// Edit group title
  String editGroup() => Intl.message('<editGroup>', name: 'editGroup', locale: _localeName);

  /// Owner title
  String owner() => Intl.message('<owner>', name: 'owner', locale: _localeName);

  /// Save title
  String save() => Intl.message('<save>', name: 'save', locale: _localeName);

  /// Confirmation title
  String confirm() => Intl.message('<confirm>', name: 'confirm', locale: _localeName);

  /// Firstname title
  String firstname() => Intl.message('<firstname>', name: 'firstname', locale: _localeName);

  /// Firstname placeholder
  String firstnamePh() => Intl.message('<firstnamePh>', name: 'firstnamePh', locale: _localeName);

  /// Lastname title
  String lastname() => Intl.message('<lastname>', name: 'lastname', locale: _localeName);

  /// Lastname placeholder
  String lastnamePh() => Intl.message('<lastnamePh>', name: 'lastnamePh', locale: _localeName);

  /// Email title
  String email() => Intl.message('<email>', name: 'email', locale: _localeName);

  /// Email placeholder
  String emailPh() => Intl.message('<emailPh>', name: 'emailPh', locale: _localeName);

  /// Login title
  String login() => Intl.message('<login>', name: 'login', locale: _localeName);

  /// Register title
  String register() => Intl.message('<register>', name: 'register', locale: _localeName);

  /// Correct Error title
  String correctError() => Intl.message('<correctError>', name: 'correctError', locale: _localeName);

  /// Search contacts placeholder
  String searchContact() => Intl.message('<searchContact>', name: 'searchContact', locale: _localeName);

  /// Password title
  String password() => Intl.message('<password>', name: 'password', locale: _localeName);

  /// Password placeholder
  String passwordPh() => Intl.message('<passwordPh>', name: 'passwordPh', locale: _localeName);

  /// Password repeat title
  String passwordRepeat() => Intl.message('<passwordRepeat>', name: 'passwordRepeat', locale: _localeName);

  /// Password repeat placeholder
  String passwordRepeatPh() => Intl.message('<passwordRepeatPh>', name: 'passwordRepeatPh', locale: _localeName);

  /// No account title
  String noAccount() => Intl.message('<noAccount>', name: 'noAccount', locale: _localeName);

  /// I have an account title
  String haveAccount() => Intl.message('<haveAccount>', name: 'haveAccount', locale: _localeName);

  /// Login error title
  String loginError() => Intl.message('<loginError>', name: 'loginError', locale: _localeName);

  /// Unexpected error title
  String error() => Intl.message('<error>', name: 'error', locale: _localeName);

  /// Settings title
  String settings() => Intl.message('<settings>', name: 'settings', locale: _localeName);

  /// Max distance title
  String maxDistance() => Intl.message('<maxDistance>', name: 'maxDistance', locale: _localeName);

  /// No message title
  String noMessages() => Intl.message('<noMessages>', name: 'noMessages', locale: _localeName);

  /// Members title
  String members() => Intl.message('<members>', name: 'members', locale: _localeName);

  /// Leave group title
  String leaveGroup() => Intl.message('<leaveGroup>', name: 'leaveGroup', locale: _localeName);

  /// Leave group title
  String deleteGroup() => Intl.message('<deleteGroup>', name: 'deleteGroup', locale: _localeName);

  /// Leave group title
  String addOwner(String name) => Intl.message('<addOwner>', name: 'addOwner', args: [name], locale: _localeName);

  /// Leave group title
  String delOwner(String name) => Intl.message('<delOwner>', name: 'delOwner', args: [name], locale: _localeName);

  /// Add title
  String add() => Intl.message('<add>', name: 'add', locale: _localeName);

  /// Kick user title
  String kickUser(String name) => Intl.message('<kickUser>', name: 'kickUser', args: [name], locale: _localeName);

  /// Select group title
  String selectGroup() => Intl.message('<selectGroup>', name: 'selectGroup', locale: _localeName);

  /// Send title
  String send() => Intl.message('<send>', name: 'send', locale: _localeName);

  /// Password error title
  String passwordError() => Intl.message('<passwordError>', name: 'passwordError', locale: _localeName);

  /// Number invitation title
  String nbInv(String nb) => Intl.message('<nbInv>', name: 'nbInv', args: [nb], locale: _localeName);

  /// Number invitation title
  String joinGroup(String name) => Intl.message('<joinGroup>', name: 'joinGroup', args: [name], locale: _localeName);

  /// Dist title
  String dist() => Intl.message('<dist>', name: 'dist', locale: _localeName);

  /// Create conversation title
  String createConv() => Intl.message('<createConv>', name: 'createConv', locale: _localeName);

  /// Delete item title
  String delItem() => Intl.message('<delItem>', name: 'delItem', locale: _localeName);
}
