import 'dart:async';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

/// Groups class manager
class GroupsManager extends BasicService {
  /// User groups data
  List<Group> get data => _data;

  /// User groups invitation data
  List<Group> get invitation => _invitation;

  /// Private variables
  List<Group> _data = <Group>[];
  List<Group> _invitation = <Group>[];

  /// Add group and push group to owner groups.
  ///
  /// @param group Group payload
  /// @param users Users list to add
  /// @returns Api body response
  Future<ApiRes> add(Map<String, dynamic> payload) async {
    assert(payload != null);
    final res = await ipost('/groups', payload, Services.auth.accessToken);
    if (res.success && res.data != null) {
      Services.auth.user.groups.add(res.data);
    }
    return res;
  }

  /// Edit group, not users in group.
  ///
  /// @param group Group payload
  /// @returns Api body response
  Future<ApiRes> edit(String groupId, Map<String, dynamic> payload) async {
    assert(groupId != null && payload != null);
    final res =
        await iput('/groups/$groupId', payload, Services.auth.accessToken);
    return res;
  }

  /// Get user groups.
  ///
  /// @returns Groups list
  Future<List<Group>> getAll() async {
    final res = await iget('/groups', Services.auth.accessToken);
    if (res.success) {
      if (!(res.data is List)) {
        return <Group>[];
      }
      return _data = res.data.map((f) => new Group(f)).toList();
    }
    return _data;
  }

  /// Get a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> get(String groupId) async {
    assert(groupId != null);
    final res = await iget('/groups/$groupId', Services.auth.accessToken);
    return res;
  }

  /// Get user groups invitation.
  ///
  /// @returns Invitation groups list
  Future<List<Group>> getInv() async {
    final res = await iget('/groups/inv', Services.auth.accessToken);
    if (res.success) {
      if (!(res.data is List)) {
        return <Group>[];
      }
      return _invitation = res.data.map((f) => new Group(f)).toList();
    }
    return _invitation;
  }

  /// Delete a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<dynamic> delete(String groupId) async {
    assert(groupId != null);
    final res = await idelete('/groups/$groupId', Services.auth.accessToken);
    if (res.success) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
    }
    return res;
  }

  /// Join group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> join(String groupId) async {
    assert(groupId != null);
    final res = await iget('/groups/$groupId/join', Services.auth.accessToken);
    if (res.success) {
      Services.auth.user.groups.add(groupId);
    }
    return res;
  }

  /// Leave a group by id.
  ///
  /// @param groupId Group id
  /// @returns Api body response
  Future<ApiRes> leave(String groupId) async {
    assert(groupId != null);
    final res = await iget('/groups/leave/$groupId', Services.auth.accessToken);
    if (res.success) {
      Services.auth.user.groups.removeWhere((group) => group == groupId);
    }
    return res;
  }

  /// Kick user of group by id's.
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> kickUser(String groupId, String userId) async {
    assert(groupId != null && userId != null);
    final res =
        await idelete('/groups/$groupId/$userId', Services.auth.accessToken);
    return res;
  }

  /// Add a user to group by id's
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> addUser(String groupId, String userId) async {
    assert(groupId != null && userId != null);
    final res =
        await iput('/groups/$groupId/$userId', null, Services.auth.accessToken);
    return res;
  }

  /// Remove a owner of group by id's.
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> removeOwner(String groupId, String userId) async {
    assert(groupId != null && userId != null);
    final res = await idelete(
        '/groups/$groupId/owners/$userId', Services.auth.accessToken);
    return res;
  }

  /// Add a owner to group by id's
  ///
  /// @param groupId Group id
  /// @param userId User id
  /// @returns Api body response
  Future<ApiRes> addOwner(String groupId, String userId) async {
    assert(groupId != null && userId != null);
    final res = await iput(
        '/groups/$groupId/owners', {'id': userId}, Services.auth.accessToken);
    return res;
  }
}
