import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

final RegExp emailExp = new RegExp(r'[\w-]+@([\w-]+\.)+[\w-]+');
final RegExp nameExp =
    new RegExp(r"^[A-Za-z]+((\s)?((\'|\-|\.)?([A-Za-z])+))*$");

String capitalize(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

String validateEmail(String value) {
  if (value.isEmpty) {
    return 'Email is required.';
  }
  if (!emailExp.hasMatch(value)) {
    return 'Email must be valid';
  }
  return null;
}

String validateName(String value) {
  if (value.isEmpty) {
    return 'Name is required.';
  }
  if (!nameExp.hasMatch(value)) {
    return 'Name must be valid';
  }
  return null;
}

String validatePassword(String value) {
  if (value == null || value.isEmpty) {
    return 'Please choose a password.';
  }
  if (value != value) {
    return 'Passwords don\'t match';
  }
  return null;
}

String distString(double dist) {
  if (dist < 1) {
    return '< 1km';
  }
  return '${dist.toStringAsFixed(1)}km';
}

void showSnackBar(BuildContext context, String text) {
  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(text)));
}

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

class LinkTextSpan extends TextSpan {
  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.

  LinkTextSpan({TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              });
}
