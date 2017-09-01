import 'dart:async';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicService {
  bool get initialized => _initialized;

  bool _initialized;

  Future<bool> init() async => true;

  Future<Null> saveTokens(String user, String oauthToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance()
      ..setString(keyUser, user)
      ..setString(keyOauthToken, oauthToken);
    await prefs.commit();
    Services.auth.oauthToken = oauthToken;
  }
}
