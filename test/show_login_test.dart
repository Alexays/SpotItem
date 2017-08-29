import 'package:spotitem/ui/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('App show login page', (tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/6147

    await tester.pumpWidget(new SpotItemApp(false));
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame

    expect(find.text('Login'), findsOneWidget);
  });
}
