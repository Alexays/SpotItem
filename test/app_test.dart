import 'package:flutter_test/flutter_test.dart';

import 'package:spotitem/ui/app.dart';

void main() {
  testWidgets('app should start', (WidgetTester tester) async {
    tester.pumpWidget(new SpotItemApp(false));
  });
}
