import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/app.dart';
import 'package:flutter/material.dart';

void main() {
  Services.setup(Origin.prod).then((res) {
    runApp(new SpotItemApp(init: res));
  });
}
