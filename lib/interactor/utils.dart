import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

final RegExp emailExp = new RegExp(r'[\w-]+@([\w-]+\.)+[\w-]+');
final RegExp nameExp =
    new RegExp(r"^[A-Za-z]+((\s)?((\'|\-|\.)?([A-Za-z])+))*$");

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
    return '${(dist * 1000).toStringAsFixed(0)}m';
  }
  return '${dist.toStringAsFixed(2)}km';
}

void showSnackBar(BuildContext context, String text) {
  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(text)));
}

String convertImage(File filePath) {
  final img.Image image = img.decodeImage(filePath.readAsBytesSync());
  final img.Image thumbnail = img.copyResize(image, 720);
  final List<int> data = img.encodeJpg(thumbnail);
  return 'data:image/${filePath.path.split('.').last};base64,${BASE64.encode(data)}';
}
