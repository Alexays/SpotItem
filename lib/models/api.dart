/// ApiRes model
class ApiRes {
  /// ApiRes class initializer
  ApiRes(data, this.statusCode)
      : success = data['success'] ?? false,
        data = data['data'],
        msg = data['msg'],
        error = data['error'];

  /// Create classic ApiRes with failed status
  factory ApiRes.classic() => new ApiRes(null, 500);

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
