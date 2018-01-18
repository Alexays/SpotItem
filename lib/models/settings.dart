import 'dart:convert';

/// ApiRes model
class Settings {
  /// ApiRes class initializer
  Settings(Map<String, dynamic> data) : maxDistance = data['maxDistance'];

  /// Create classic ApiRes with failed status
  factory Settings.classic() =>
      new Settings(<String, dynamic>{'maxDistance': 50});

  /// Response success
  int maxDistance;

  /// Check if item is valid
  bool isValid() => maxDistance != null;

  /// Convert class to json
  Map<String, dynamic> toJson() => {
        'maxDistance': maxDistance,
      };

  @override
  String toString() => JSON.encode(toJson());
}
