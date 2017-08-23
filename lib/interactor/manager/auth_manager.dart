import 'dart:async';
import 'dart:convert';
import 'package:spotitems/keys.dart';
import 'package:spotitems/model/user.dart';
import 'package:spotitems/model/group.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String keyUser = 'KEY_USER';
  static const String keyOauthToken = 'KEY_AUTH_TOKEN';

  bool get initialized => _initialized;

  bool get loggedIn => _loggedIn;

  User get user => _user;

  String get oauthClient => _oauthToken;

  final String _clientSecret = clientSecret;

  bool _initialized;

  bool _loggedIn;

  User _user;

  String _oauthToken;

  List<Group> _myGroups = <Group>[];

  List<Group> _myGroupsInv = <Group>[];

  Future<bool> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = prefs.getString(keyUser);
    userData ??= '{}';
    final User user = new User.fromJson(JSON.decode(userData));
    final String oauthToken = prefs.getString(keyOauthToken);
    if (user == null || oauthToken == null) {
      _loggedIn = false;
      await logout();
    } else {
      _loggedIn = true;
      _user = user;
      _oauthToken = oauthToken;
    }
    return _initialized = true;
  }

  Future<bool> login(String email, String password) async {
    final Client _client = new Client();
    final Response response = await _client.post('$apiUrl/login', headers: {
      'Authorization': 'Basic $_clientSecret'
    }, body: {
      'email': email,
      'password': password
    }).whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        _user = new User.fromJson(bodyJson['user']);
        await _saveTokens(_user.toString(), bodyJson['token']);
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
    } else {
      _loggedIn = false;
    }
    return _loggedIn;
  }

  Future<Null> logout() async {
    await _saveTokens(null, null);
    _loggedIn = false;
  }

  Future<dynamic> register(User user, String password) async {
    final Client _client = new Client();
    final dynamic userJson = JSON.decode(user.toString());
    userJson['_id'] = 'null';
    userJson['groups'] = 'groups';
    userJson['password'] = password;
    final Response response = await _client
        .post('$apiUrl/signup',
            headers: {'Authorization': 'Basic $_clientSecret'}, body: userJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<dynamic> updateUser(User user, String password) async {
    final Client _client = new Client();
    final dynamic userJson = JSON.decode(user.toString());
    userJson['groups'] = 'groups';
    if (password != null) {
      userJson['password'] = password;
    }
    final Response response = await _client
        .put('$apiUrl/user/edit',
            headers: {'Authorization': _oauthToken}, body: userJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    if (response.statusCode == 200 && bodyJson['success']) {
      _user = new User.fromJson(bodyJson['user']);
      await _saveTokens(_user.toString(), bodyJson['token']);
    }
    return bodyJson;
  }

  Future<bool> _saveTokens(String user, String oauthToken) async {
    print(user);
    final SharedPreferences prefs = await SharedPreferences.getInstance()
      ..setString(keyUser, user)
      ..setString(keyOauthToken, oauthToken);
    await prefs.commit();
    _oauthToken = oauthToken;
    return true;
  }

  Future<dynamic> addGroup(Group group, List<String> users) async {
    final Client _client = new Client();
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = JSON.encode(users);
    groupJson['owner'] = user.id;
    final Response response = await _client
        .post('$apiUrl/groups',
            headers: {'Authorization': _oauthToken}, body: groupJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    if (bodyJson['success']) {
      user.groups.add(bodyJson['group']['_id'].toString());
      await _saveTokens(user.toString(), bodyJson['token']);
    }
    return bodyJson;
  }

  Future<dynamic> getGroups(String userId) async {
    if (userId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client.get('$apiUrl/groups',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic groupJson = JSON.decode(response.body);
      return _myGroups = new List<Group>.generate(
          groupJson.length, (index) => new Group.fromJson(groupJson[index]));
    }
    return _myGroups;
  }

  Future<dynamic> getGroupsInv(String userId) async {
    if (userId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client.get('$apiUrl/groups/inv',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic groupJson = JSON.decode(response.body);
      return _myGroupsInv = new List<Group>.generate(
          groupJson.length, (index) => new Group.fromJson(groupJson[index]));
    }
    return _myGroupsInv;
  }

  Future<dynamic> delGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client.delete('$apiUrl/group/$groupId',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      user.groups.removeWhere((group) => group == groupId);
      await _saveTokens(user.toString(), groupJson['token']);
    }
    return groupJson;
  }

  Future<dynamic> joinGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client.put('$apiUrl/group/$groupId',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      user.groups.add(groupId);
      await _saveTokens(user.toString(), groupJson['token']);
    }
    return groupJson;
  }

  Future<dynamic> leaveGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client.get('$apiUrl/group/$groupId/leave',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      user.groups.removeWhere((group) => group == groupId);
      await _saveTokens(user.toString(), groupJson['token']);
    }
    return groupJson;
  }
}
