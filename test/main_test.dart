import 'package:flutter_test/flutter_test.dart';
import 'package:spotitem/ui/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

Future<String> mockUpdateUrlFetcher() {
  // A real implementation would connect to the network to retrieve this value
  return new Future<String>.value('http://www.example.com/');
}

void main() {
  SharedPreferences.setMockInitialValues({});
  new http.MockClient((http.BaseRequest request) {
    return new Future<http.Response>.value(
        new http.Response("Mocked: Unavailable.", 404, request: request));
  });
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // Regression test for https://github.com/flutter/flutter/pull/5168
  testWidgets('App launch and show login', (WidgetTester tester) async {
    await Services.setup();
    await tester.pumpWidget(new SpotItemApp(false));
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame
    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
