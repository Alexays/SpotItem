import 'package:flutter_test/flutter_test.dart';
import 'package:spotitem/ui/app.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:flutter/material.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding)
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Basic', () {
    final mockUser = new ApiRes({
      'success': true,
      'data': {
        'user': {'_id': '1234567890', 'name': 'mock name', 'firstname': 'mock firstname', 'email': 'mock@spotitem.fr'},
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
          'owner': {'_id': '1234567890', 'email': 'mock@spotitem.fr', 'name': 'mock', 'firstname': 'mock'},
          'lat': 47.2199094,
          'lng': -1.6881127,
          'location': 'Couëron-les-bains',
          'groups': [],
          'tracks': ['gift'],
          'calendar': [],
          'last_geo': '2017-09-21T19:02:05.240Z',
          'images': ['image_6ea936bade56ea9388fcbb76265ef011933f4e2d.jpg']
        },
        {
          '_id': '59c40cadc4df467318e0cc23',
          'updatedAt': '2017-09-21T20:04:05.156Z',
          'createdAt': '2017-09-21T19:02:05.242Z',
          'name': 'Amande',
          'about': '20% de noisettes  !!',
          'owner': {'_id': '1234567890', 'email': 'mock2@spotitem.fr', 'name': 'mock2', 'firstname': 'mock2'},
          'lat': 27.2199094,
          'lng': -1.6881127,
          'location': 'Couëron-les-bains',
          'groups': [],
          'tracks': ['group'],
          'calendar': [],
          'last_geo': '2017-09-21T19:02:05.240Z',
          'images': ['image_6ea936bade56ea9388fcbb76265ef011933f4e2d.jpg']
        }
      ]
    }, 200);
    final mockGroups = new ApiRes({
      'success': true,
      'data': [
        {
          '_id': '59dd36d275475a636e2162dc',
          'updatedAt': '2017-10-10T21:08:34.702Z',
          'createdAt': ' 2017-10-10T21:08:34.702Z',
          'name': 'test',
          'about': 'test about',
          'users': [
            {'_id': '1234567890', 'email': 'mock@spotitem.fr', 'name': 'mock name', 'firstname': 'mock firstname'}
          ],
          'owners': [
            {'_id': '1234567890', 'email': 'mock@spotitem.fr', 'name': 'mock name', 'firstname': 'mock firstname'}
          ]
        }
      ],
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

      await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
      await tester.pump();
      await tester.enterText(find.byKey(const Key('password')), '123456789A');
      await tester.pump();

      await tester.longPress(find.byKey(const Key('login')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('Show discover and group item', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('From your groups'), findsOneWidget);
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(find.text('Amande'), findsOneWidget);
      expect(Services.items.items.length, 2);
    });

    testWidgets('Show explorer', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text('Explore')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(Services.items.items.length, 2);
    });

    testWidgets('Sort item by name', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text('Explore')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(find.text('Amande'), findsOneWidget);
      expect(find.descendant(of: find.byType(ItemsListItem).first, matching: find.text('Magnifique Nutella')),
          findsOneWidget);
      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(CheckedPopupMenuItem), matching: find.text('Name')));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(ItemsListItem).first, matching: find.text('Amande')), findsOneWidget);
      expect(Services.items.items.length, 2);
    });

    testWidgets('Filter item by gift', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text('Explore')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(find.text('Amande'), findsOneWidget);
      expect(find.descendant(of: find.byType(ItemsListItem).first, matching: find.text('Amande')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(SwitchListTile), matching: find.text('Gift')));
      await tester.pumpAndSettle();
      expect(find.text('Amande'), findsNothing);
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(Services.items.items.length, 2);
      await tester.tap(find.descendant(of: find.byType(SwitchListTile), matching: find.text('Gift')));
      await tester.pumpAndSettle();
    });

    testWidgets('Filter item by group', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      expect(find.text('Discover'), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text('Explore')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget);
      expect(find.text('Amande'), findsOneWidget);
      expect(find.descendant(of: find.byType(ItemsListItem).first, matching: find.text('Amande')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(SwitchListTile), matching: find.text('From your groups')));
      await tester.pumpAndSettle();
      expect(find.text('Amande'), findsOneWidget);
      expect(find.text('Magnifique Nutella'), findsNothing);
      expect(Services.items.items.length, 2);
      await tester.tap(find.descendant(of: find.byType(SwitchListTile), matching: find.text('From your groups')));
      await tester.pumpAndSettle();
    });

    testWidgets('Able to search item', (tester) async {
      Services.mock = mockUser;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byKey(const Key('search')), 'Amande');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.text('Amande'), findsOneWidget);
      expect(find.text('Magnifique Nutella'), findsNothing);
      await tester.enterText(find.byKey(const Key('search')), 'nothing');
      await tester.pumpAndSettle();
      expect(find.text('No items'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('search')), '');
      await tester.pumpAndSettle();
      expect(find.text('Type something to search...'), findsOneWidget);
      await tester.tap(find.byWidget(const BackButton()));
      await tester.pumpAndSettle();
      expect(find.text('Discover'), findsOneWidget);
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
      await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Items')));
      await tester.pumpAndSettle();
      expect(find.text('Magnifique Nutella'), findsOneWidget); // View item
      expect(find.text('Amande'), findsOneWidget); // View item
      expect(find.descendant(of: find.byType(FloatingActionButton), matching: find.icon(Icons.add)),
          findsOneWidget); // View fab add item
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
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
      expect(find.text('Maximal distance: ${Services.settings.value.maxDistance}km'), findsOneWidget);
    });

    testWidgets('Show social tab with groups', (tester) async {
      Services.mock = mockGroups;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Social')));
      await tester.pumpAndSettle();
      expect(find.text('test'), findsOneWidget); // View group name
      expect(find.text('test about'), findsOneWidget); // View group about
      expect(find.text('1'), findsOneWidget); // View group user count
    });

    testWidgets('Show social tab with groups inv', (tester) async {
      Services.mock = mockGroups;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Social')));
      await tester.pumpAndSettle();
      expect(find.text('You have 1 invitation(s)'), findsOneWidget); // View group invitation number
      await tester.tap(find.text('You have 1 invitation(s)'));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(ExpansionTile), matching: find.text('test')),
          findsOneWidget); // View group name
      expect(find.descendant(of: find.byType(ExpansionTile), matching: find.text('test about')),
          findsOneWidget); // View group about
      expect(find.descendant(of: find.byType(ExpansionTile), matching: find.text('0')),
          findsOneWidget); // View group user count
    });

    testWidgets('I able to logout', (tester) async {
      Services.mock = mockItems;
      await tester.pumpWidget(new SpotItemApp(init: true));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('mock@spotitem.fr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login')), findsOneWidget);
      expect(find.byKey(const Key('email')), findsOneWidget);
      expect(find.byKey(const Key('password')), findsOneWidget);
    });
  });
}
