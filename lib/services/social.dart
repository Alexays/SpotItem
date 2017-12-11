import 'dart:async';
import 'dart:convert';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

/// Social class manager
class SocialManager extends BasicService {
  /// Conversations list
  List<Conversation> get conversations => _conversations;

  /// Private variables
  List<Conversation> _conversations = <Conversation>[];

  /// Get all conversations
  Future<List<Conversation>> getAll() async {
    final res = await iget('/messages', Services.auth.accessToken);
    if (res.success) {
      if (!(res.data is List)) {
        return <Conversation>[];
      }
      return _conversations = res.data.map((f) => new Conversation(f)).toList();
    }
    return _conversations;
  }

  /// Add a conversation
  Future<ApiRes> add(Map<String, String> conversation) async {
    assert(conversation != null);
    final res =
        await ipost('/messages', conversation, Services.auth.accessToken);
    if (res.success && res.data != null) {
      _conversations.add(new Conversation(res.data));
    }
    return res;
  }

  /// Add a conversation
  Future<Conversation> get(String id) async {
    assert(id != null);
    final res = await iget('/messages/$id', Services.auth.accessToken);
    if (res.success && res.data != null) {
      return new Conversation(res.data);
    }
    return null;
  }

  /// Subscribe to conversation
  Future<Null> connect(String id) async {
    assert(id != null);
    final header = await getWsHeader('sub');
    if (header == null) {
      return;
    }
    header['path'] = '/conv/$id';
    Services.auth.ws.add(JSON.encode(header));
  }

  /// Unsubscribe to conversation
  Future<Null> disconnect(String id) async {
    assert(id != null);
    final header = await getWsHeader('unsub');
    header['path'] = '/conv/$id';
    Services.auth.ws.add(JSON.encode(header));
  }

  /// Send message to conversation
  Future<Null> send(String id, String text) async {
    assert(id != null && text != null);
    final header = await getWsHeader('message');
    header['message'] = {
      'room': id,
      'sender': Services.auth.user.toString(),
      'message': text
    };
    Services.auth.ws.add(JSON.encode(header));
  }
}
