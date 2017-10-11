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
    final groupJson = JSON.decode(group.toString());
    groupJson['users'] = JSON.encode(users);
    groupJson['owners'] = JSON.encode([Services.auth.user.id]);
    final response = await ipost('/groups', groupJson, Services.auth.accessToken);
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
    final Map<String, dynamic> groupJson = JSON.decode(group.toString())..remove('users')..remove('owners');
    final response = await iput('/groups/${group.id}', groupJson, Services.auth.accessToken);
    return response;
  }

  /// Get user groups.
  ///
  /// @returns Groups list
  Future<List<Group>> getGroups() async {
    final response = await iget('/groups', Services.auth.accessToken);
    if (response.success) {
      if (!(response.data is List)) {
        return <Group>[];
      }
      return _groups = response.data.map((f) => new Group(f)).toList();
    }
    return _groups;
  }

  /// Get a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> getGroup(String groupId) async {
    if (groupId == null) {
      return null;
    }
    final response = await iget('/groups/$groupId', Services.auth.accessToken);
    return response;
  }

  /// Get user groups invitation.
  ///
  /// @returns Invitation groups list
  Future<List<Group>> getGroupsInv() async {
    final response = await iget('/groups/inv', Services.auth.accessToken);
    if (response.success) {
      if (!(response.data is List)) {
        return <Group>[];
      }
      return _groupsInv = response.data.map((f) {
        f['owners'] = [];
        return new Group(f);
      }).toList();
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
    final response = await idelete('/groups/$groupId', Services.auth.accessToken);
    if (response.success) {
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
    final response = await ipost('/groups/$groupId', null, Services.auth.accessToken);
    if (response.success) {
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
    final response = await iget('/groups/leave/$groupId', Services.auth.accessToken);
    if (response.success) {
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
    final response = await idelete('/groups/$groupId/$userId', Services.auth.accessToken);
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
    final response = await iput('/groups/$groupId/$userId', null, Services.auth.accessToken);
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
    final response = await idelete('/groups/$groupId/owner/$userId', Services.auth.accessToken);
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
    final response = await iput('/groups/$groupId/owner/$userId', null, Services.auth.accessToken);
    return response;
  }
}
