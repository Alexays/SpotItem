import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicService {
  bool get initialized => _initialized;

  bool _initialized;

  Future<bool> init() async => true;

  Future<Null> saveTokens(
      String user, String oauthToken, String provider) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance()
      ..setString(keyUser, user)
      ..setString(keyOauthToken, oauthToken)
      ..setString(keyProvider, provider);
    await prefs.commit();
    Services.auth.oauthToken = oauthToken;
  }

  void handleWsData(res) {
    final dynamic data = JSON.decode(res);
    if (data['type'] == 'NOTIFICATION') {
      print(data['data']);
    }
  }

  void connectWs() {
    final channel = new IOWebSocketChannel.connect('ws://217.182.65.67:1337');
    channel.sink.add(
        JSON.encode({'type': 'CONNECTION', 'userId': Services.auth.user.id}));
    channel.stream.listen(handleWsData);
  }
}
