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
            ? data['conversation'].map((f) => new Message(f)).toList()
            : <Message>[];

  /// Conversation id
  final String id;

  /// Conversation users
  final List<String> users;

  /// Conversation group
  final Group group;

  /// Messages
  final List<Message> conversation;

  /// Create item from JSON object
  factory Conversation.from(Conversation conversation) =>
      new Conversation(JSON.decode(conversation.toString()));

  /// Check if item is valid
  bool isValid() => id != null && (users != null || group != null);

  /// Convert class to json
  Map<String, dynamic> toJson() => {
        '_id': id,
        'users': users,
        'group': group,
        'messages': conversation.map((f) => f.toJson()).toList(),
      };

  @override
  String toString() => JSON.encode(toJson());
}

/// Message model
class Message {
  /// Message class initializer
  Message(Map<String, dynamic> data)
      : sender = data['sender'] is Map<String, dynamic>
            ? new User(data['sender'])
            : new User({'_id': data['sender']}),
        message = data['message'];

  /// Sender of message
  User sender;

  /// Message data
  String message;

  /// Convert class to json
  Map<String, dynamic> toJson() => {
        'sender': sender,
        'message': message,
      };

  @override
  String toString() => JSON.encode(toJson());
}
