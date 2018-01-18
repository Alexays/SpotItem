/// ApiRes model
class ApiRes {
  /// ApiRes class initializer
  ApiRes(Map<String, dynamic> data, this.statusCode)
      : success = data['success'] ?? false,
        data = data['data'],
        msg = data['message'],
        error = data['error'];

  /// Create classic ApiRes with failed status
  factory ApiRes.classic() =>
      new ApiRes(<String, dynamic>{'error': 'An Unexpected error !'}, 500);

  /// Response success
  final bool success;

  /// Response status code
  final int statusCode;

  /// Response data
  final dynamic data;

  /// Response msg
  final String msg;

  /// Response error msg
  final String error;
}
