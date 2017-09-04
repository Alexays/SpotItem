import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

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

  void handleWsData(data) {
    print(data);
  }

  void connectWs() {
    final channel = new IOWebSocketChannel.connect('ws://217.182.65.67:1337');
    channel.sink.add(
        JSON.encode({'type': 'CONNECTION', 'userId': Services.auth.user.id}));
    channel.stream.listen(handleWsData);
  }
}
