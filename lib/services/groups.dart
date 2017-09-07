import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

class GroupsManager extends BasicService {
  /// User groups data
  List<Group> get groups => _groups;

  /// User groups invitation data
  List<Group> get groupsInv => _groupsInv;

  /// Define private variables
  List<Group> _groups = <Group>[];
  List<Group> _groupsInv = <Group>[];

  /// Add group and push group to owner groups.
  ///
  /// @param group Group payload
  /// @param users Users list to add
  /// @returns Api body response
  Future<dynamic> addGroup(Group group, List<String> users) async {
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = JSON.encode(users);
    groupJson['owner'] = Services.auth.user.id;
    final Response response =
        await ipost('/groups', groupJson, Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    if (bodyJson['success']) {
      Services.auth.user.groups.add(bodyJson['group']['_id'].toString());
    }
    return bodyJson;
  }

  /// Edit group, not users in group.
  ///
  /// @param group Group payload
  /// @returns Api body response
  Future<dynamic> editGroup(Group group) async {
    group.users = null;
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = '';
    final Response response =
        await ipost('/group/${group.id}', groupJson, Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  /// Get user groups.
  ///
  /// @returns Groups list
  Future<dynamic> getGroups() async {
    final Response response = await iget('/groups', Services.auth.accessToken);
    if (response.statusCode == 200) {
      final dynamic groupJson = JSON.decode(response.body);
      return _groups = new List<Group>.generate(
          groupJson.length, (index) => new Group(groupJson[index]));
    }
    return _groups;
  }

  /// Get a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<dynamic> getGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Response response =
        await iget('/group/$groupId', Services.auth.accessToken);
    final dynamic groupJson = JSON.decode(response.body);
    return groupJson;
  }

  /// Get user groups invitation.
  ///
  /// @param userId User id
  /// @returns Invitation groups list
  Future<dynamic> getGroupsInv(String userId) async {
    if (userId == null) {
      return null;
    }
    final Response response =
        await iget('/groups/inv', Services.auth.accessToken);
    if (response.statusCode == 200) {
      final dynamic groupJson = JSON.decode(response.body);
      return _groupsInv = new List<Group>.generate(
          groupJson.length, (index) => new Group(groupJson[index]));
    }
    return _groupsInv;
  }

  /// Delete a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<dynamic> delGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Response response =
        await idelete('/group/$groupId', Services.auth.accessToken);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
    }
    return groupJson;
  }

  /// Join group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<dynamic> joinGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Response response =
        await iput('/group/$groupId', null, Services.auth.accessToken);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      Services.auth.user.groups.add(groupId);
    }
    return groupJson;
  }

  /// Leave a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<dynamic> leaveGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final Response response =
        await iget('/group/$groupId/leave', Services.auth.accessToken);
    final dynamic groupJson = JSON.decode(response.body);
    if (response.statusCode == 200) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
    }
    return groupJson;
  }

  /// Kick user of group by id's.
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<dynamic> kickUser(String groupId, String userId) async {
    if (groupId == null) {
      return null;
    }
    final Response response =
        await idelete('/group/$groupId/$userId', Services.auth.accessToken);
    final dynamic groupJson = JSON.decode(response.body);
    return groupJson;
  }

  /// Add a user to group by id's
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<dynamic> addUserToGroup(String groupId, String userId) async {
    if (groupId == null) {
      return null;
    }
    final Response response =
        await iput('/group/$groupId/$userId', null, Services.auth.accessToken);
    final dynamic groupJson = JSON.decode(response.body);
    return groupJson;
  }
}
