import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/profile_manager.dart';
import 'package:spotitems/ui/explorer_view.dart';
import 'package:spotitems/ui/profile_view.dart';
import 'package:spotitems/ui/items_view.dart';
import 'package:spotitems/model/item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  HomeScreen(this._authManager, this._itemsManager);

  @override
  State createState() => new _HomeScreenState(_authManager, _itemsManager);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  _HomeScreenState(this._authManager, this._itemsManager);

  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  int _currentIndex = 0;
  List<HomeScreenItem> _homeScreenItems;
  AnimationController _expandAnimationController;
  Animation<Size> _bottomSize;

  @override
  void initState() {
    super.initState();
    _homeScreenItems = [
      new HomeScreenItem(
          icon: const Icon(Icons.explore),
          title: "Explorer",
          sub: [
            new HomeScreenSubItem("Discover",
                new ExplorerView(_itemsManager, _authManager, null)),
            new HomeScreenSubItem(
                "Nearest you",
                new ExplorerView(_itemsManager, _authManager, (items) {
                  items.sort((a, b) => a.dist.compareTo(b.dist));
                  return items;
                })),
            new HomeScreenSubItem(
                "Gift",
                new ExplorerView(_itemsManager, _authManager,
                    (List<Item> items) {
                  return items
                      .where((Item item) => item.tracks.contains('gift'))
                      .toList();
                })),
          ]),
      new HomeScreenItem(
        icon: const Icon(Icons.work),
        title: "Items",
        content: new ItemsView(_itemsManager, _authManager),
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.map),
        title: "Maps",
        content: new Center(
          child: new Text("Comming soon"),
        ),
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.sms),
        title: "Message",
        content: new Center(
          child: new Text("Comming soon"),
        ),
      )
    ];
    _expandAnimationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomSize = new SizeTween(
      begin: new Size.fromHeight(kTextTabBarHeight + 40.0),
      end: new Size.fromHeight(kTextTabBarHeight + 280.0),
    )
        .animate(new CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.ease,
    ));
  }

  void _navBarItemSelected(int selected) {
    setState(() {
      _currentIndex = selected;
    });
  }

  void _overflow(OverflowItem selected) {
    switch (selected) {
      case OverflowItem.Settings:
        break;
      case OverflowItem.LogOut:
        _authManager
            .logout()
            .then((_) => Navigator.pushReplacementNamed(context, '/login'));
        break;
    }
  }

  Widget _buildBottom() {
    return new TabBar(
      tabs: new List<Tab>.generate(
          _homeScreenItems[_currentIndex].sub != null
              ? _homeScreenItems[_currentIndex].sub.length
              : 0, (int index) {
        return new Tab(
          text: _homeScreenItems[_currentIndex].sub[index].title,
        );
      }),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(
                _authManager.user?.firstname + ' ' + _authManager.user?.name),
            accountEmail: new Text(_authManager.user?.email),
            currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: _authManager.user?.avatar != null &&
                        _authManager.user?.avatar != 'null'
                    ? new NetworkImage(_authManager.user?.avatar)
                    : null),
            // otherAccountsPictures: const <Widget>[
            //   const CircleAvatar(backgroundImage: const AssetImage(_kAsset1)),
            //   const CircleAvatar(backgroundImage: const AssetImage(_kAsset2)),
            // ],
            onDetailsPressed: () {},
          ),
          const ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: true,
          ),
          const ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('test'),
            enabled: false,
          ),
          new ListTile(
            leading: const Icon(Icons.dvr),
            title: const Text('Dump App to Console'),
            onTap: () {
              try {
                debugDumpApp();
                debugDumpRenderTree();
                debugDumpLayerTree();
              } catch (e, stack) {
                debugPrint('Exception while dumping app:\n$e\n$stack');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: _buildDrawer(context),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add),
        tooltip: "Add new item",
        onPressed: () {
          Navigator.of(context).pushNamed('/addItem');
        },
      ),
      body: new DefaultTabController(
        length: _homeScreenItems[_currentIndex].sub != null
            ? _homeScreenItems[_currentIndex].sub.length
            : 1,
        child: new NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              new AnimatedBuilder(
                animation: _bottomSize,
                builder: (BuildContext context, Widget child) {
                  return new SliverAppBar(
                    pinned: true,
                    floating: _homeScreenItems[_currentIndex].sub != null,
                    title: _homeScreenItems[_currentIndex].item.title,
                    actions: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.search),
                        onPressed: () {},
                      ),
                      new PopupMenuButton(
                          onSelected: _overflow,
                          itemBuilder: (BuildContext context) {
                            return [
                              new PopupMenuItem(
                                  value: OverflowItem.Settings,
                                  child: new Text('Settings')),
                              new PopupMenuItem<OverflowItem>(
                                  value: OverflowItem.LogOut,
                                  child: new Text('Log out'))
                            ];
                          }),
                    ],
                    bottom: _homeScreenItems[_currentIndex].sub != null
                        ? _buildBottom()
                        : null,
                  );
                },
              ),
            ];
          },
          body: new TabBarView(
            children: _homeScreenItems[_currentIndex].content,
          ),
        ),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _currentIndex,
        items:
            _homeScreenItems.map((HomeScreenItem item) => item.item).toList(),
        onTap: _navBarItemSelected,
      ),
    );
  }
}

enum OverflowItem { Settings, LogOut }

class HomeScreenItem {
  final BottomNavigationBarItem item;
  final List<Widget> content;
  final List<HomeScreenSubItem> sub;

  HomeScreenItem({Widget icon, String title, Widget content, this.sub})
      : item = new BottomNavigationBarItem(icon: icon, title: new Text(title)),
        content = sub != null
            ? new List<Widget>.generate(sub.length, (int index) {
                return sub[index].content;
              })
            : [content];
}

class HomeScreenSubItem {
  final String title;
  final Widget content;

  HomeScreenSubItem(this.title, this.content);
}
