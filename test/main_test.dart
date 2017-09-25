import 'package:flutter_test/flutter_test.dart';
import 'package:spotitem/ui/app.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('App launch, show login, login, show discover', (tester) async {
    final mock = new ApiRes({
      'success': true,
      'data': {
        'user': {
          '_id': '1234567890',
          'name': 'mock',
          'firstname': 'mock',
          'email': 'mock@spotitem.fr'
        },
        'exp': new DateTime.now().millisecondsSinceEpoch + 3000,
        'access_token': 'Bearer mock',
        'refresh_token': 'mock'
      }
    }, 200);
    await Services.setup(Origin.mock, mock);
    await tester.pumpWidget(new SpotItemApp(init: true));
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame

    expect(find.byKey(const Key('email')), findsOneWidget);

    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
    await tester.pump();
    await tester.enterText(find.byKey(const Key('password')), '123456789A');
    await tester.pump();

    await tester.longPress(find.byKey(const Key('login')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Discover'), findsOneWidget);
  });
}
