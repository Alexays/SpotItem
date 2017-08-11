import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/profile_manager.dart';
import 'package:spotitems/ui/explorer_view.dart';
import 'package:spotitems/ui/profile_view.dart';
import 'package:spotitems/ui/items_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  HomeScreen(this._authManager, this._itemsManager);

  @override
  State createState() => new _HomeScreenState(_authManager, _itemsManager);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  int _currentIndex = 0;
  List<HomeScreenItem> _homeScreenItems;
  _HomeScreenState(this._authManager, this._itemsManager);
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
            new HomeScreenSubItem(
                "Discover", new ExplorerView(_itemsManager, 0)),
            new HomeScreenSubItem(
                "Nearest you", new ExplorerView(_itemsManager, 1)),
          ]),
      new HomeScreenItem(
        icon: const Icon(Icons.work),
        title: "Items",
        content: new ItemsView(),
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.map),
        title: "Maps",
        content: new ItemsView(),
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.person),
        title: "Profile",
        content: new ProfileView(
            new ProfileManager(_authManager, _authManager.user),
            _authManager.user),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(top: 50.0),
            ),
            new ClipRect(
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text('test 1'),
                  ),
                  new ListTile(
                    title: new Text('test 2'),
                  ),
                  new ListTile(
                    title: new Text('test 3'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
