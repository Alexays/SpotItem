import 'dart:async';
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
  Future<List<Conversation>> getConversations() async {
    final response = await iget('/messages', Services.auth.accessToken);
    if (response.success && response.data != null && response.data is List) {
      _conversations =
          new List<Conversation>.generate(response.data.length, (index) => new Conversation(response.data[index]));
    }
    return _conversations;
  }

  /// Add a conversation
  Future<ApiRes> addConversation(Map<String, String> conversation) async {
    final response = await ipost('/messages', conversation, Services.auth.accessToken);
    if (response.success && response.data != null) {
      _conversations.add(new Conversation(response.data));
    }
    return response;
  }

  /// Add a conversation
  Future<Conversation> getConversation(String id) async {
    final response = await iget('/messages/$id', Services.auth.accessToken);
    if (response.success && response.data != null) {
      print(response.data);
      return new Conversation(response.data);
    }
    return null;
  }
}
