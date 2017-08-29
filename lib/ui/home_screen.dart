import 'package:spotitem/interactor/services/services.dart';
import 'package:spotitem/ui/components/item.dart';
import 'package:spotitem/ui/components/filter.dart';
import 'package:spotitem/ui/explorer_view.dart';
import 'package:spotitem/ui/discover_view.dart';
import 'package:spotitem/ui/map_view.dart';
import 'package:spotitem/ui/items_view.dart';
import 'package:spotitem/ui/groups_view.dart';
import 'package:spotitem/model/item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static List<HomeScreenItem> _homeScreenItems;

  // Animation
  AnimationController _controller;
  AnimationController _filterController;
  Animation<double> _drawerContentsOpacity;
  Animation<FractionalOffset> _drawerDetailsPosition;
  Animation<Size> _bottomFilterSize;
  Animation<Size> _bottomSize;

  // Bool
  bool _isExpanded = false;
  bool _showDrawerContents = true;
  bool _isSearching = false;
  int _currentIndex = 0;

  // Search
  final TextEditingController _searchController = new TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    _homeScreenItems = <HomeScreenItem>[
      new HomeScreenItem(
        icon: const Icon(Icons.explore),
        title: 'Explorer',
        sub: <HomeScreenSubItem>[
          const HomeScreenSubItem('Discover', const DiscoverView()),
          const HomeScreenSubItem('Explore', const ExplorerView()),
        ],
      ),
      new HomeScreenItem(
          icon: const Icon(Icons.work),
          title: 'Items',
          content: const ItemsView(),
          fab: new FloatingActionButton(
              child: const Icon(Icons.add),
              tooltip: 'Add new item',
              onPressed: () {
                Navigator.of(context).pushNamed('/item/add');
              })),
      new HomeScreenItem(
        icon: const Icon(Icons.map),
        title: 'Maps',
        content: const MapView(),
      ),
      new HomeScreenItem(
          icon: const Icon(Icons.nature_people),
          title: 'Social',
          sub: <HomeScreenSubItem>[
            const HomeScreenSubItem(
              'Groups',
              const GroupsView(),
            ),
            const HomeScreenSubItem(
                'Messages',
                const Center(
                  child: const Text('Comming soon'),
                ))
          ],
          fab: new FloatingActionButton(
              child: const Icon(Icons.person_add),
              tooltip: 'Add new groups',
              onPressed: () {
                Navigator.of(context).pushNamed('/groups/add');
              })),
    ];
    initAnimation();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void initAnimation() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _filterController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomFilterSize = new SizeTween(
      begin: new Size.fromHeight(kTextTabBarHeight + 40.0),
      end: new Size.fromHeight(kTextTabBarHeight + 40.0),
    )
        .animate(new CurvedAnimation(
      parent: _filterController,
      curve: Curves.ease,
    ));
    _bottomSize = new SizeTween(
      begin: new Size.fromHeight(kTextTabBarHeight),
      end: new Size.fromHeight(kTextTabBarHeight),
    )
        .animate(new CurvedAnimation(
      parent: _filterController,
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

  void _showFilter() {
    showModalBottomSheet<Null>(
        context: context,
        builder: (context) => new Container(
                child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 75.0,
                  child: new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(20.0),
                      itemCount: Services.itemsManager.categories.length,
                      itemExtent: 75.0,
                      itemBuilder: (context, index) => new FlatButton(
                            child: new Image.asset(
                                'assets/${Services.itemsManager.categories[index]}.png'),
                            onPressed: () {
                              print('test');
                            },
                          )),
                ),
                new SwitchListTile(
                  title: const Text('From your groups only'),
                  value: true,
                  onChanged: (value) {
                    setState(() {});
                  },
                  secondary: const Icon(Icons.lock),
                ),
                new SwitchListTile(
                  title: const Text('Donated items only'),
                  value: true,
                  onChanged: (value) {
                    setState(() {});
                  },
                  secondary: const Icon(Icons.card_giftcard),
                ),
              ],
            ))).then((data) {
      setState(() {
        _isExpanded = false;
      });
    });
  }

  void _handleSearchBegin() {
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearching = false;
        });
      },
    ));
    setState(() {
      _isSearching = true;
    });
  }

  Widget _buildBottom() {
    if (_homeScreenItems[_currentIndex].sub == null) {
      return null;
    }
    final bool isMain = _currentIndex == 0;
    final List<Widget> bottom = []..add(new TabBar(
        tabs: new List<Tab>.generate(
            _homeScreenItems[_currentIndex].sub?.length,
            (index) => new Tab(
                text: _homeScreenItems[_currentIndex].sub[index].title)),
      ));
    if (isMain) {
      bottom.add(new FilterBar(
        onExpandedChanged: (value) async {
          if (value) {
            setState(() {
              _isExpanded = true;
              _showFilter();
            });
          } else if (!value) {
            setState(() {
              _isExpanded = false;
            });
          }
        },
        isExpanded: _isExpanded,
      ));
    }
    return new PreferredSize(
      child: new SizedBox(
        height:
            isMain ? _bottomFilterSize.value.height : _bottomSize.value.height,
        child: new Column(children: bottom),
      ),
      preferredSize: isMain ? _bottomFilterSize.value : _bottomSize.value,
    );
  }

  Widget _buildDrawer(BuildContext context) => new Drawer(
          child: new ListView(children: <Widget>[
        new UserAccountsDrawerHeader(
            accountName: new Text(
                '${Services.authManager.user?.firstname} ${Services.authManager.user?.name}'),
            accountEmail: new Text(Services.authManager.user?.email),
            currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: Services.authManager.user?.avatar != 'null'
                    ? new NetworkImage(Services.authManager.user?.avatar)
                    : null,
                child: new Text(
                    '${Services.authManager.user?.firstname[0]}${Services.authManager.user?.name[0]}')),
            otherAccountsPictures: <Widget>[
              new IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {},
              )
            ],
            onDetailsPressed: () {
              _showDrawerContents = !_showDrawerContents;
              if (_showDrawerContents)
                _controller.reverse();
              else
                _controller.forward();
            }),
        new ClipRect(
            child: new Stack(children: <Widget>[
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
                          debugDumpApp();
                          debugDumpRenderTree();
                          debugDumpLayerTree();
                        })
                  ])),
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
                            }),
                        new ListTile(
                            leading: const Icon(Icons.exit_to_app),
                            title: const Text('Logout'),
                            onTap: () {
                              Services.authManager.logout().then((_) =>
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/login', (route) => false));
                            })
                      ])))
        ]))
      ]));

  SliverAppBar _buildAppBar() => new SliverAppBar(
        pinned: true,
        leading: _isSearching ? const BackButton() : null,
        floating: _homeScreenItems[_currentIndex].sub != null && !_isSearching,
        title: _isSearching
            ? new TextField(
                key: const Key('search'),
                controller: _searchController,
                autofocus: true,
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),
                decoration: new InputDecoration(
                    hintText: 'Search...',
                    hintStyle: new TextStyle(
                      color: const Color.fromARGB(120, 255, 255, 255),
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                    hideDivider: true),
                keyboardType: TextInputType.text,
              )
            : _homeScreenItems[_currentIndex].item.title,
        actions: _isSearching
            ? null
            : <Widget>[
                new IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _handleSearchBegin,
                )
              ],
        bottom: _isSearching ? null : _buildBottom(),
      );

  FloatingActionButton _buildFab() {
    if (_homeScreenItems[_currentIndex].fab == null) {
      return null;
    }
    return _homeScreenItems[_currentIndex].fab;
  }

  List<Widget> _buildChild() {
    if (_isSearching) {
      if (_searchQuery.isEmpty) {
        return [new Container()];
      }
      List<Item> search = new List<Item>.from(Services.itemsManager.items);
      search = search
          .where((item) => item.name.toLowerCase().contains(_searchQuery))
          .toList();
      return [new ItemsList(search, 'search')];
    }
    return _homeScreenItems[_currentIndex].content;
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      floatingActionButton: _buildFab(),
      body: new DefaultTabController(
          length: _homeScreenItems[_currentIndex].sub?.length,
          child: new NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  <Widget>[_buildAppBar()],
              body: new TabBarView(children: _buildChild()))),
      bottomNavigationBar: _isSearching
          ? null
          : new BottomNavigationBar(
              currentIndex: _currentIndex,
              items: _homeScreenItems.map((data) => data.item).toList(),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ));
}

class HomeScreenItem {
  final BottomNavigationBarItem item;
  final List<Widget> content;
  final List<HomeScreenSubItem> sub;
  final FloatingActionButton fab;

  HomeScreenItem(
      {Widget icon, String title, Widget content, this.sub, this.fab})
      : item = new BottomNavigationBarItem(icon: icon, title: new Text(title)),
        content = sub != null
            ? new List<Widget>.generate(
                sub.length, (index) => sub[index].content)
            : <Widget>[content];
}

class HomeScreenSubItem {
  final String title;
  final Widget content;

  const HomeScreenSubItem(this.title, this.content);
}
