import 'dart:convert';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/models/group.dart';

/// Conversation Model
class Conversation {
  /// Conversation class initializer
  Conversation(Map<String, dynamic> data)
      : id = data['_id'],
        users = data['users'],
        group = new Group(data['group']),
        conversation = data['conversation'] is List
            ? new List<Message>.generate(
                data['conversation'].length, (index) => new Message(data['conversation'][index]))
            : <Message>[];

  /// Conversation id
  final String id;

  /// Conversation users
  final List<String> users;

  /// Conversation group
  Group group;

  /// Messages
  List<Message> conversation;

  /// Create item from JSON object
  factory Conversation.from(Conversation conversation) => new Conversation(JSON.decode(conversation.toString()));

  /// Check if item is valid
  bool isValid() => id != null && (users != null || group != null);

  @override
  String toString() {
    final messages = conversation.map((message) => message.toString()).toList();
    return '{"_id": "$id", "users": $users, "group": "$group", "messages": $messages}';
  }
}

/// Message model
class Message {
  /// Message class initializer
  Message(Map<String, dynamic> data)
      : sender = data['sender'] is Map<String, dynamic> ? new User(data['sender']) : new User({'_id': data['sender']}),
        message = data['message'];

  /// Sender of message
  User sender;

  /// Message data
  String message;

  @override
  String toString() => '{"sender": $sender, "message": "$message"}';
}
