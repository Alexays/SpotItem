import 'package:flutter/material.dart';
import 'package:spotitem/ui/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Flutter gallery button example code displays',
      (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/6147

    await tester.pumpWidget(new SpotItemApp(false));
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame

    // Launch the buttons demo and then prove that showing the example
    // code dialog does not crash.

    await tester.tap(find.text('Login'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // end animation

    await tester.tap(find.text('RAISED'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // end animation

    await tester.tap(find.byTooltip('Show example code'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // end animation

    expect(find.text('Example code'), findsOneWidget);
  });
}
