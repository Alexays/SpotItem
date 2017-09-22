import 'dart:async';
import 'dart:convert';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

/// Groups class manager
class GroupsManager extends BasicService {
  /// User groups data
  List<Group> get groups => _groups;

  /// User groups invitation data
  List<Group> get groupsInv => _groupsInv;

  /// Private variables
  List<Group> _groups = <Group>[];
  List<Group> _groupsInv = <Group>[];

  /// Add group and push group to owner groups.
  ///
  /// @param group Group payload
  /// @param users Users list to add
  /// @returns Api body response
  Future<ApiRes> addGroup(Group group, List<String> users) async {
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = JSON.encode(users);
    groupJson['owners'] = JSON.encode([Services.auth.user.id]);
    final ApiRes response =
        await ipost('/groups', groupJson, Services.auth.accessToken);
    if (response.success && response.data != null) {
      Services.auth.user.groups.add(response.data);
    }
    return response;
  }

  /// Edit group, not users in group.
  ///
  /// @param group Group payload
  /// @returns Api body response
  Future<ApiRes> editGroup(Group group) async {
    group.users = null;
    final dynamic groupJson = JSON.decode(group.toString());
    groupJson['users'] = '';
    groupJson['owners'] = '';
    final ApiRes response =
        await iput('/group/${group.id}', groupJson, Services.auth.accessToken);
    return response;
  }

  /// Get user groups.
  ///
  /// @returns Groups list
  Future<dynamic> getGroups() async {
    final ApiRes response = await iget('/groups', Services.auth.accessToken);
    return _groups = new List<Group>.generate(
        response.data?.length ?? 0, (index) => new Group(response.data[index]));
  }

  /// Get a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> getGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final ApiRes response =
        await iget('/group/$groupId', Services.auth.accessToken);
    return response;
  }

  /// Get user groups invitation.
  ///
  /// @returns Invitation groups list
  Future<List<Group>> getGroupsInv() async {
    final ApiRes response =
        await iget('/groups/inv', Services.auth.accessToken);
    if (response.statusCode == 200 && response.success) {
      return _groupsInv =
          new List<Group>.generate(response.data?.length ?? 0, (index) {
        // Owners is not populated here, not need for invitations
        response.data[index]['owners'] = [];
        return new Group(response.data[index]);
      });
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
    final ApiRes response =
        await idelete('/group/$groupId', Services.auth.accessToken);
    if (response.statusCode == 200 && response.success) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
    }
    return response;
  }

  /// Join group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> joinGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final ApiRes response =
        await ipost('/group/$groupId', null, Services.auth.accessToken);
    if (response.statusCode == 200 && response.success) {
      Services.auth.user.groups.add(groupId);
    }
    return response;
  }

  /// Leave a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> leaveGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final ApiRes response =
        await iget('/group/$groupId/leave', Services.auth.accessToken);
    if (response.statusCode == 200 && response.success) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
    }
    return response;
  }

  /// Kick user of group by id's.
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> kickUser(String groupId, String userId) async {
    if (groupId == null || userId == null) {
      return null;
    }
    final ApiRes response =
        await idelete('/group/$groupId/$userId', Services.auth.accessToken);
    return response;
  }

  /// Add a user to group by id's
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> addUser(String groupId, String userId) async {
    if (groupId == null || userId == null) {
      return null;
    }
    final ApiRes response =
        await iput('/group/$groupId/$userId', null, Services.auth.accessToken);
    return response;
  }

  /// Remove a owner of group by id's.
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> removeOwner(String groupId, String userId) async {
    if (groupId == null || userId == null) {
      return null;
    }
    final ApiRes response = await idelete(
        '/group/$groupId/$userId/owner', Services.auth.accessToken);
    return response;
  }

  /// Add a owner to group by id's
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> addOwner(String groupId, String userId) async {
    if (groupId == null || userId == null) {
      return null;
    }
    final ApiRes response = await iput(
        '/group/$groupId/$userId/owner', null, Services.auth.accessToken);
    return response;
  }
}
