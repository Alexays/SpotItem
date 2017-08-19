import 'dart:async';
import 'dart:convert';
import 'package:spotitems/keys.dart';
import 'package:spotitems/model/user.dart';
import 'package:spotitems/model/group.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String KEY_USER = 'KEY_USER';
  static const String KEY_OAUTH_TOKEN = 'KEY_AUTH_TOKEN';

  bool get initialized => _initialized;

  bool get loggedIn => _loggedIn;

  User get user => _user;

  String get oauthClient => _oauthToken;

  final String _clientSecret = CLIENT_SECRET;

  bool _initialized;

  bool _loggedIn;

  User _user;

  String _oauthToken;

  List<Group> _myGroups = [];

  List<Group> _myGroupsInv = [];

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = prefs.getString(KEY_USER);
    User user =
        new User.fromJson(JSON.decode(userData != null ? userData : '{}'));
    String oauthToken = prefs.getString(KEY_OAUTH_TOKEN);

    if (user == null || oauthToken == null) {
      _loggedIn = false;
      await logout();
    } else {
      _loggedIn = true;
      _user = user;
      _oauthToken = oauthToken;
    }

    _initialized = true;
  }

  Future<bool> login(String email, String password) async {
    final Client _client = new Client();
    final loginResponse = await _client.post(API_URL + '/login', headers: {
      'Authorization': 'Basic ${_clientSecret}'
    }, body: {
      'email': email,
      'password': password
    }).whenComplete(_client.close);

    if (loginResponse.statusCode == 200) {
      final bodyJson = JSON.decode(loginResponse.body);
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

  Future logout() async {
    await _saveTokens(null, null);
    _loggedIn = false;
  }

  Future<bool> register(User user, String password) async {
    final Client _client = new Client();
    var userJson = JSON.decode(user.toString());
    userJson['password'] = password;
    final response = await _client
        .put(API_URL + '/editUser',
            headers: {'Authorization': 'Basic ${_clientSecret}'},
            body: userJson)
        .whenComplete(_client.close);
    final bodyJson = JSON.decode(response.body);
    if (bodyJson['success']) return true;
    return false;
  }

  Future updateUser(User user, String password) async {
    final Client _client = new Client();
    var userJson = JSON.decode(user.toString());
    userJson['groups'] = "groups";
    if (password != null) userJson['password'] = password;
    final response = await _client
        .put(API_URL + '/user/edit',
            headers: {'Authorization': _oauthToken}, body: userJson)
        .whenComplete(_client.close);
    final bodyJson = JSON.decode(response.body);
    if (response.statusCode == 200 && bodyJson['success']) {
      _user = new User.fromJson(bodyJson['user']);
      await _saveTokens(_user.toString(), bodyJson['token']);
    }
    return bodyJson;
  }

  Future _saveTokens(String user, String oauthToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_USER, user);
    prefs.setString(KEY_OAUTH_TOKEN, oauthToken);
    await prefs.commit();
    _oauthToken = oauthToken;
  }

  Future addGroup(Group group, List<String> users) async {
    final Client _client = new Client();
    var groupJson = JSON.decode(group.toString());
    groupJson['users'] = JSON.encode(users);
    groupJson['owner'] = user.id;
    final response = await _client
        .post(API_URL + '/groups',
            headers: {'Authorization': _oauthToken}, body: groupJson)
        .whenComplete(_client.close);
    final bodyJson = JSON.decode(response.body);
    if (bodyJson['success']) {
      user.groups.add(bodyJson['group']['_id'].toString());
      _saveTokens(user.toString(), bodyJson['token']);
    }
    return bodyJson;
  }

  Future getGroups(String userId) async {
    if (userId == null) return null;
    final Client _client = new Client();
    final response = await _client.get(API_URL + '/groups',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    if (response.statusCode == 200) {
      var groupJson = JSON.decode(response.body);
      return _myGroups =
          new List<Group>.generate(groupJson.length, (int index) {
        return new Group.fromJson(groupJson[index]);
      });
    }
    return _myGroups;
  }

  Future getGroupsInv(String userId) async {
    if (userId == null) return null;
    final Client _client = new Client();
    final response = await _client.get(API_URL + '/groups/inv',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    if (response.statusCode == 200) {
      var groupJson = JSON.decode(response.body);
      return _myGroupsInv =
          new List<Group>.generate(groupJson.length, (int index) {
        return new Group.fromJson(groupJson[index]);
      });
    }
    return _myGroupsInv;
  }

  Future delGroup(String groupId) async {
    if (groupId == null) return null;
    final Client _client = new Client();
    final response = await _client.delete(API_URL + '/group/' + groupId,
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    if (response.statusCode == 200) {
      var groupJson = JSON.decode(response.body);
      user.groups.removeWhere((group) => group == groupId);
      _saveTokens(user.toString(), groupJson['token']);
    }
    return _myGroups;
  }

  Future joinGroup(String groupId) async {
    if (groupId == null) return null;
    final Client _client = new Client();
    final response = await _client.put(API_URL + '/group/' + groupId,
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    var groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      user.groups.add(groupId);
      _saveTokens(user.toString(), groupJson['token']);
    }
    return groupJson;
  }

  Future leaveGroup(String groupId) async {
    if (groupId == null) return null;
    final Client _client = new Client();
    final response = await _client.get('$API_URL/group/$groupId/leave',
        headers: {'Authorization': _oauthToken}).whenComplete(_client.close);
    var groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      user.groups.removeWhere((group) => group == groupId);
      _saveTokens(user.toString(), groupJson['token']);
    }
    return groupJson;
  }
}
