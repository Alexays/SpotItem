import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('App launch', () {
    FlutterDriver driver;

    setUpAll(() async {
      // Connect to a running Flutter application instance.
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Login appear', () async {
      // Finds the floating action button (fab) to tap on
      SerializableFinder inputEmail = find.byValueKey('email');
      await driver.waitFor(find.text('Login'));

      // Wait for the floating action button to appear
      await driver.waitFor(inputEmail);
    });

    test('Able to login', () async {
      // Finds the floating action button (fab) to tap on
      SerializableFinder inputEmail = find.byValueKey('email');
      await driver.waitFor(find.text('Login'));

      // Wait for the floating action button to appear
      await driver.waitFor(inputEmail);

      // Tap on the fab
      //await driver.tap(fab);

      // Wait for text to change to the desired value
      //print(driver.getRenderTree());
      //await driver.waitFor(find.text('Login'));
    });
  });
}
