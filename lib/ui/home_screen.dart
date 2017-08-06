import 'package:spot_items/interactor/manager/auth_manager.dart';
import 'package:spot_items/interactor/manager/profile_manager.dart';
import 'package:spot_items/ui/explorer_view.dart';
import 'package:spot_items/ui/profile_view.dart';
import 'package:spot_items/ui/items_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final AuthManager _authManager;

  HomeScreen(this._authManager);

  @override
  State createState() => new _HomeScreenState(_authManager);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthManager _authManager;
  int _currentIndex = 0;
  List<HomeScreenItem> _homeScreenItems;
  _HomeScreenState(this._authManager);
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
            new HomeScreenSubItem("Discover", new ExplorerView()),
            new HomeScreenSubItem("Nearest you", new ExplorerView()),
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
            new ProfileManager(_authManager, _authManager.email),
            _authManager.email),
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
      drawer: new Container(),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add),
        tooltip: "Add new item",
        onPressed: () {},
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
            children: _homeScreenItems[_currentIndex].sub != null
                ? new List<Widget>.generate(
                    _homeScreenItems[_currentIndex].sub.length, (int index) {
                    return _homeScreenItems[_currentIndex].sub[index].content;
                  })
                : <Widget>[_homeScreenItems[_currentIndex].content],
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
  // return new Scaffold(
  //   appBar: new AppBar(
  //     title: new Text('SpotItems'),
  //     actions: [
  //       new PopupMenuButton<OverflowItem>(
  //           onSelected: _overflow,
  //           itemBuilder: (BuildContext context) {
  //             return [
  //               new PopupMenuItem(
  //                   value: OverflowItem.Settings,
  //                   child: new Text('Settings')),
  //               new PopupMenuItem<OverflowItem>(
  //                   value: OverflowItem.LogOut, child: new Text('Log out'))
  //             ];
  //           })
  //     ],
  //   ),
  //   body: _homeScreenItems[_currentIndex].content,
  //   bottomNavigationBar: new BottomNavigationBar(
  //     currentIndex: _currentIndex,
  //     items:
  //         _homeScreenItems.map((HomeScreenItem item) => item.item).toList(),
  //     onTap: _navBarItemSelected,
  //   ),
  // );
}

enum OverflowItem { Settings, LogOut }

class HomeScreenItem {
  final BottomNavigationBarItem item;
  final Widget content;
  final List<HomeScreenSubItem> sub;

  HomeScreenItem({Widget icon, String title, Widget content, this.sub})
      : item = new BottomNavigationBarItem(icon: icon, title: new Text(title)),
        content = content;
}

class HomeScreenSubItem {
  final String title;
  final Widget content;

  HomeScreenSubItem(this.title, this.content);
}
