import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';

/// Email RegExp
final RegExp emailExp = new RegExp(r'[\w-]+@([\w-]+\.)+[\w-]+');

/// Name RegExp
final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');

/// Capitalize first letter of String
String capitalize(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

/// Placeholder of item
const AssetImage placeholder = const AssetImage('assets/placeholder.png');

/// Return Circle avatar of images or initial
Widget getAvatar(User user, [double radius = 30.0]) {
  final image = user?.avatar?.contains('.') != null
      ? new NetworkImage(user.avatar)
      : null;
  return new CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey,
      backgroundImage: image,
      child: image == null
          ? new Text(
              '${user?.firstname?.substring(0, 1) ?? '?'}${user?.name?.substring(0, 1)}')
          : null);
}

/// Show a loading popup
void showLoading(BuildContext context) {
  showDialog<Null>(
    context: context,
    barrierDismissible: false,
    child: const Dialog(
      child: const LinearProgressIndicator(),
    ),
  );
}

/// Check if json response is valid
bool resValid(BuildContext context, ApiRes response) {
  if (response == null) {
    return false;
  }
  if (!response.success) {
    if (response.error != null) {
      showSnackBar(context, response.error);
    } else {
      showSnackBar(context, SpotL.of(context).error);
    }
    return false;
  }
  return true;
}

/// Validate Email input
String validateEmail(String value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return 'Email is required.';
  }
  if (!emailExp.hasMatch(value)) {
    return 'Email must be valid';
  }
  return null;
}

/// Validate Name input
String validateName(String value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return 'Name is required.';
  }
  if (!nameExp.hasMatch(value)) {
    return 'Name must be valid';
  }
  return null;
}

/// Validate other required input
String validateString(String value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return 'Value is required.';
  }
  return null;
}

/// Validate password input
String validatePassword(String value) {
  if (value == null || value.isEmpty) {
    return 'Please choose a password.';
  }
  if (value != value) {
    return 'Passwords don\'t match';
  }
  return null;
}

/// Return a String of provided double dist
String distString(double dist) {
  if (dist < 1) {
    return '< 1km';
  }
  return '${dist.toStringAsFixed(1)}km';
}

/// Show a snackbar in current context with text
void showSnackBar(BuildContext context, String text) {
  if (text != null) {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(text)));
  }
}

/// Return icon tracks
Widget getIcon(String tracks, [Color color]) {
  switch (tracks) {
    case 'private':
      return new Icon(Icons.lock, color: color);
    case 'gift':
      return new Icon(Icons.card_giftcard, color: color);
    case 'group':
      return new Icon(Icons.group, color: color);
    default:
      return const Text('');
  }
}

/// Get headers for Api
Map<String, String> getHeaders({
  String key,
  contentType type: contentType.json,
}) {
  final _contentType = <contentType, String>{
    contentType.image: 'image/jpg',
    contentType.json: 'application/json',
  };
  return <String, String>{
    'Authorization': key,
    'Spotkey': 'Basic $clientSecret-${Services.settings.version}',
    'Accept': 'application/json',
    'Content-Type': _contentType[type],
  };
}

/// Compare Dates (Year, Month, Day)
bool compareDates(DateTime d1, DateTime d2) =>
    d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

/// Limit length of string
String limitString(String str, int lenght) {
  if (str.length > lenght) {
    final sup = str.substring(lenght);
    if (sup.length > 3) {
      return '${str.substring(0, lenght)}...';
    }
  }
  return str;
}

/// Clickable link
class LinkTextSpan extends TextSpan {
  /// LinkTextSpan initializer
  LinkTextSpan({TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: new TapGestureRecognizer()..onTap = () => launch(url));
}
