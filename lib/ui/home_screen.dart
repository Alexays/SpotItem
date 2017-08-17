import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/explorer_view.dart';
import 'package:spotitems/ui/discover_view.dart';
import 'package:spotitems/ui/map_view.dart';
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

  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<FractionalOffset> _drawerDetailsPosition;
  Animation<Size> _bottomSize;

  int _currentIndex = 0;
  List<HomeScreenItem> _homeScreenItems;

  Size size;

  bool _showDrawerContents = true;

  final TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;

  void _handleSearchBegin() {
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearching = false;
          _searchQuery.clear();
        });
      },
    ));
    setState(() {
      _isSearching = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _homeScreenItems = [
      new HomeScreenItem(
          icon: const Icon(Icons.explore),
          title: "Explorer",
          sub: [
            new HomeScreenSubItem("Discover",
                new DiscoverView(_itemsManager, _authManager, null)),
            new HomeScreenSubItem(
                "Nearest you",
                new ExplorerView(_itemsManager, _authManager, (items) {
                  items.sort((a, b) => a.dist.compareTo(b.dist));
                  return items;
                })),
            new HomeScreenSubItem(
                "Donated",
                new ExplorerView(_itemsManager, _authManager,
                    (List<Item> items) {
                  return items
                      .where((Item item) => item.tracks.contains('gift'))
                      .toList();
                })),
          ],
          fab: new FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: "Add new item",
            onPressed: () {
              Navigator.of(context).pushNamed('/addItem');
            },
          )),
      new HomeScreenItem(
          icon: const Icon(Icons.work),
          title: "Items",
          content: new ItemsView(_itemsManager, _authManager),
          fab: new FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: "Add new item",
            onPressed: () {
              Navigator.of(context).pushNamed('/addItem');
            },
          )),
      new HomeScreenItem(
        icon: const Icon(Icons.map),
        title: "Maps",
        content: new MapView(_itemsManager),
      ),
      new HomeScreenItem(
          icon: const Icon(Icons.nature_people),
          title: "Social",
          sub: [
            new HomeScreenSubItem(
              "Groups",
              new Center(
                child: new Text("Comming soon"),
              ),
            ),
            new HomeScreenSubItem(
              "Messages",
              new Center(
                child: new Text("Comming soon"),
              ),
            ),
          ],
          fab: new FloatingActionButton(
            child: const Icon(Icons.person_add),
            tooltip: "Add new groups",
            onPressed: () {},
          )),
    ];
    initAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initAnimation() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomSize = new SizeTween(
      begin: new Size.fromHeight(kTextTabBarHeight + 40.0),
      end: new Size.fromHeight(kTextTabBarHeight + 280.0),
    )
        .animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new FractionalOffsetTween(
      begin: const FractionalOffset(0.0, -1.0),
      end: const FractionalOffset(0.0, 0.0),
    )
        .animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void _navBarItemSelected(int selected) {
    setState(() {
      _currentIndex = selected;
    });
  }

  Widget _buildBottom() {
    if (_homeScreenItems[_currentIndex].sub == null) return null;
    return new TabBar(
      tabs: new List<Tab>.generate(_homeScreenItems[_currentIndex].sub?.length,
          (int index) {
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
                backgroundImage: _authManager.user?.avatar != 'null'
                    ? new NetworkImage(_authManager.user?.avatar)
                    : null),
            otherAccountsPictures: <Widget>[
              new IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {},
              ),
              //const CircleAvatar(backgroundImage: const AssetImage(_kAsset1)),
            ],
            onDetailsPressed: () {
              _showDrawerContents = !_showDrawerContents;
              if (_showDrawerContents)
                _controller.reverse();
              else
                _controller.forward();
            },
          ),
          new ClipRect(
            child: new Stack(
              children: <Widget>[
                new FadeTransition(
                  opacity: _drawerContentsOpacity,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                            debugPrint(
                                'Exception while dumping app:\n$e\n$stack');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                new SlideTransition(
                  position: _drawerDetailsPosition,
                  child: new FadeTransition(
                    opacity: new ReverseAnimation(_drawerContentsOpacity),
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        new ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit Profile'),
                          onTap: () {
                            Navigator.of(context).pushNamed('/user/edit');
                          },
                        ),
                        new ListTile(
                          leading: const Icon(Icons.exit_to_app),
                          title: const Text('Logout'),
                          onTap: () {
                            _authManager.logout().then((_) => Navigator
                                .pushReplacementNamed(context, '/login'));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildAppBar() {
    return new SliverAppBar(
      pinned: true,
      leading: _isSearching ? new BackButton() : null,
      floating: _homeScreenItems[_currentIndex].sub != null,
      title: _isSearching
          ? new TextField(
              key: new Key('search'),
              controller: _searchQuery,
              autofocus: true,
              style: new TextStyle(color: Colors.white70, fontSize: 16.0),
              decoration: new InputDecoration(
                  hintText: 'Search...',
                  hintStyle:
                      new TextStyle(color: Colors.white70, fontSize: 16.0),
                  hideDivider: true),
            )
          : _homeScreenItems[_currentIndex].item.title,
      actions: _isSearching
          ? null
          : <Widget>[
              new IconButton(
                icon: new Icon(Icons.search),
                onPressed: _handleSearchBegin,
              ),
            ],
      bottom: _buildBottom(),
    );
  }

  _buildFab() {
    if (_homeScreenItems[_currentIndex].fab == null) return null;
    return _homeScreenItems[_currentIndex].fab;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: _buildDrawer(context),
      floatingActionButton: _buildFab(),
      body: new DefaultTabController(
        length: _homeScreenItems[_currentIndex].sub?.length,
        child: new NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              new AnimatedBuilder(
                animation: _bottomSize,
                builder: (BuildContext context, Widget child) {
                  return _buildAppBar();
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
  final FloatingActionButton fab;

  HomeScreenItem(
      {Widget icon, String title, Widget content, this.sub, this.fab})
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
