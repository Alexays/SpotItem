final RegExp emailExp = new RegExp(r'[\w-]+@([\w-]+\.)+[\w-]+');
final RegExp nameExp =
    new RegExp(r"^[A-Za-z]+((\s)?((\'|\-|\.)?([A-Za-z])+))*$");

String validateEmail(String value) {
  if (value.isEmpty) return 'Email is required.';
  if (!emailExp.hasMatch(value)) return 'Email must be valid';
  return null;
}

String validateName(String value) {
  if (value.isEmpty) return 'Name is required.';
  if (!nameExp.hasMatch(value)) return 'Name must be valid';
  return null;
}

String validatePassword(String value) {
  if (value == null || value.isEmpty) return 'Please choose a password.';
  if (value != value) return 'Passwords don\'t match';
  return null;
}

String distString(double dist) {
  if (dist < 1) {
    return (dist * 1000).toStringAsFixed(0) + 'm';
  }
  return dist.toStringAsFixed(2) + 'km';
}
