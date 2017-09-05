import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

class GroupsManager extends BasicService {
  List<Group> _myGroups = <Group>[];

  List<Group> _myGroupsInv = <Group>[];

  Future<dynamic> addGroup(Group group, List<String> users) async {
    final Client _client = new Client();
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = JSON.encode(users);
    groupJson['owner'] = Services.auth.user.id;
    final Response response = await _client
        .post('$apiUrl/groups',
            headers: getHeaders(Services.auth.oauthToken), body: groupJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    if (bodyJson['success']) {
      Services.auth.user.groups.add(bodyJson['group']['_id'].toString());
      await saveTokens(Services.auth.user.toString(), bodyJson['token']);
    }
    return bodyJson;
  }

  Future<dynamic> editGroup(Group group) async {
    final Client _client = new Client();
    group.users = null;
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = '';
    final Response response = await _client
        .post('$apiUrl/group/${group.id}',
            headers: getHeaders(Services.auth.oauthToken), body: groupJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<dynamic> getGroups() async {
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/groups', headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic groupJson = JSON.decode(response.body);
      return _myGroups = new List<Group>.generate(
          groupJson.length, (index) => new Group(groupJson[index]));
    }
    return _myGroups;
  }

  Future<dynamic> getGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/group/$groupId',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    return groupJson;
  }

  Future<dynamic> getGroupsInv(String userId) async {
    if (userId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/groups/inv',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic groupJson = JSON.decode(response.body);
      return _myGroupsInv = new List<Group>.generate(
          groupJson.length, (index) => new Group(groupJson[index]));
    }
    return _myGroupsInv;
  }

  Future<dynamic> delGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .delete('$apiUrl/group/$groupId',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
      await saveTokens(Services.auth.user.toString(), groupJson['token']);
    }
    return groupJson;
  }

  Future<dynamic> joinGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .put('$apiUrl/group/$groupId',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      Services.auth.user.groups.add(groupId);
      await saveTokens(Services.auth.user.toString(), groupJson['token']);
    }
    return groupJson;
  }

  Future<dynamic> leaveGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/group/$groupId/leave',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
      await saveTokens(Services.auth.user.toString(), groupJson['token']);
    }
    return groupJson;
  }

  Future<dynamic> kickUser(String groupId, String userId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .delete('$apiUrl/group/$groupId/$userId',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    return groupJson;
  }

  Future<dynamic> addUserToGroup(String groupId, String userId) async {
    if (groupId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .put('$apiUrl/group/$groupId/$userId',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    final dynamic groupJson = JSON.decode(response.body);
    return groupJson;
  }
}
