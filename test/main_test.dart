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

  group('Basic', () {
    final mockUser = new ApiRes({
      'success': true,
      'data': {
        'user': {
          '_id': '1234567890',
          'name': 'mock name',
          'firstname': 'mock firstname',
          'email': 'mock@spotitem.fr'
        },
        'exp': new DateTime.now().millisecondsSinceEpoch + 3000,
        'access_token': 'Bearer mock',
        'refresh_token': 'mock'
      }
    }, 200);
    final mockItems = new ApiRes({
      'success': true,
      'data': [
        {
          '_id': '59c40cadc4de467318e0cc23',
          'updatedAt': '2017-09-21T20:04:05.156Z',
          'createdAt': '2017-09-21T19:02:05.242Z',
          'name': 'Magnifique Nutella',
          'about': '40% de noisettes  !!',
          'owner': {
            '_id': '1234567890',
            'email': 'mock@spotitem.fr',
            'name': 'mock',
            'firstname': 'mock'
          },
          'lat': 47.2199094,
          'lng': -1.6881127,
          'location': 'Couëron-les-bains',
          'groups': [],
          'tracks': ['gift'],
          'calendar': [],
          'last_geo': '2017-09-21T19:02:05.240Z',
          'images': ['image_6ea936bade56ea9388fcbb76265ef011933f4e2d.jpg']
        }
      ]
    }, 200);
    testWidgets('Login appear', (tester) async {
      await Services.setup(Origin.mock);
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
      await tester.pump(); // triggers a frame

      expect(find.byKey(const Key('email')), findsOneWidget);

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Able to login and show Home', (tester) async {
      Services.mock = mockUser;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();

      await tester.enterText(
          find.byKey(const Key('email')), 'test@example.com');
      await tester.pump();
      await tester.enterText(find.byKey(const Key('password')), '123456789A');
      await tester.pump();

      await tester.longPress(find.byKey(const Key('login')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('Show discover', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(Services.items.items.length, 1);
    });

    testWidgets('Show explorer', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      await tester.tap(find.descendant(
          of: find.byType(TabBar), matching: find.text('Explore')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(Services.items.items.length, 1);
    });

    testWidgets('Show item page', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Magnifique Nutella'));
      await tester.pumpAndSettle();
      expect(find.text('40% de noisettes  !!'), findsOneWidget);
    });

    testWidgets('Show item edit page', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Magnifique Nutella'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.create));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('name')), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('Show my item tab with items, tracks', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.descendant(
          of: find.byType(BottomNavigationBar), matching: find.text('Items')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget); // View item
      expect(
          find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.icon(Icons.add)),
          findsOneWidget); // View fab add item
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
    });

    testWidgets('I able to view my user information in drawer', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('mock firstname mock name'), findsOneWidget);
      expect(find.text('mock@spotitem.fr'), findsOneWidget);
    });

    testWidgets('I able to view my user edit page', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('mock@spotitem.fr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('name')), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('I able to view settings page', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(
          find.text(
              'Maximal distance: ${Services.settings.value.maxDistance}km'),
          findsOneWidget);
    });
  });
}
