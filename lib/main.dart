import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() {
  Services.setup().then((res) {
    enableFlutterDriverExtension();
    runApp(new SpotItemApp(res));
  });
}
