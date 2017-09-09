import 'package:flutter_test/flutter_test.dart';
import 'package:spotitem/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('App launch and show login', (tester) async {
    app.main(); // builds the app and schedules a frame but doesn't trigger one
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame

    expect(find.byKey(const Key('email')), findsOneWidget);

    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
    await tester.pump();
    await tester.enterText(find.byKey(const Key('password')), '123456789A');
    await tester.pump();

    await tester.longPress(find.byKey(const Key('login')));
  });
}
