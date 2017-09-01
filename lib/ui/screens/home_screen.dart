import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/ui/widgets/filter_bar.dart';
import 'package:spotitem/ui/views/explorer_view.dart';
import 'package:spotitem/ui/views/discover_view.dart';
import 'package:spotitem/ui/views/map_view.dart';
import 'package:spotitem/ui/views/items_view.dart';
import 'package:spotitem/ui/views/groups_view.dart';
import 'package:spotitem/models/item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Key _searchKey = const Key('search');
  static List<HomeScreenItem> _homeScreenItems;

  // Animation
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<FractionalOffset> _drawerDetailsPosition;

  // Bool
  bool _isExpanded = false;
  bool _showDrawerContents = true;
  bool _isSearching = false;
  int _currentIndex = 0;

  // Search
  final TextEditingController _searchController = new TextEditingController();
  String _searchQuery = '';

  //Explore
  static const Widget discover = const DiscoverView();
  static const Widget explore = const ExplorerView();

  @override
  void initState() {
    _homeScreenItems = <HomeScreenItem>[
      new HomeScreenItem(
        icon: const Icon(Icons.explore),
        title: 'Explorer',
        sub: <HomeScreenSubItem>[
          const HomeScreenSubItem('Discover', discover),
          const HomeScreenSubItem('Explore', explore),
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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void initAnimation() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
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
        builder: (context) => new Column(
              children: <Widget>[
                new Container(
                  height: 100.0,
                  child: new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15.0),
                      itemCount: Services.items.categories.length,
                      itemExtent: 75.0,
                      itemBuilder: (context, index) => new FlatButton(
                            child: new Image.asset(
                                'assets/${Services.items.categories[index]}.png'),
                            onPressed: () {
                              print('test');
                            },
                          )),
                ),
                new StatefulBuilder(
                    builder: (context, switchSetState) => new SwitchListTile(
                          title: const Text('From your groups'),
                          value: Services.items.tracks.value.contains('group'),
                          onChanged: (value) {
                            if (value) {
                              Services.items.tracks.value.add('group');
                            } else {
                              Services.items.tracks.value.remove('group');
                            }
                            Services.items.tracks.value = new List<String>.from(
                                Services.items.tracks.value);
                            switchSetState(() {});
                          },
                          secondary: const Icon(Icons.lock),
                        )),
                new StatefulBuilder(
                    builder: (context, switchSetState) => new SwitchListTile(
                          title: const Text('Donated items'),
                          value: Services.items.tracks.value.contains('gift'),
                          onChanged: (value) {
                            if (value) {
                              Services.items.tracks.value.add('gift');
                            } else {
                              Services.items.tracks.value.remove('gift');
                            }
                            Services.items.tracks.value = new List<String>.from(
                                Services.items.tracks.value);
                            switchSetState(() {});
                          },
                          secondary: const Icon(Icons.card_giftcard),
                        ))
              ],
            )).then((data) {
      setState(() {
        _isExpanded = false;
      });
    });
  }

  void _searchCallback() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _handleSearchBegin() {
    if (!mounted) {
      return;
    }
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _searchController.removeListener(_searchCallback);
          _isSearching = false;
        });
      },
    ));
    setState(() {
      _searchController.addListener(_searchCallback);
      _isSearching = true;
    });
  }

  Widget _buildBottom() {
    if (_homeScreenItems[_currentIndex].sub == null) {
      return null;
    }
    final bool isMain = _currentIndex == 0;
    final List<Widget> bottom = []..add(new TabBar(
        indicatorColor: Colors.white,
        indicatorWeight: 4.0,
        tabs: new List<Tab>.generate(
            _homeScreenItems[_currentIndex].sub?.length,
            (index) => new Tab(
                text: _homeScreenItems[_currentIndex].sub[index].title)),
      ));
    if (isMain) {
      bottom.add(new FilterBar(
        onExpandedChanged: (value) async {
          setState(() {
            if (value) {
              _isExpanded = true;
              _showFilter();
            } else if (!value) {
              _isExpanded = false;
            }
          });
        },
        isExpanded: _isExpanded,
      ));
    }
    return new PreferredSize(
      child: new Column(children: bottom),
      preferredSize: isMain
          ? const Size.fromHeight(kTextTabBarHeight + 34.0)
          : const Size.fromHeight(kTextTabBarHeight),
    );
  }

  Widget _buildDrawer(BuildContext context) => new Drawer(
          child: new ListView(children: <Widget>[
        new UserAccountsDrawerHeader(
            accountName: new Text(
                '${Services.auth.user?.firstname} ${Services.auth.user?.name}'),
            accountEmail: new Text(Services.auth.user?.email),
            currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: Services.auth.user?.avatar != null &&
                        Services.auth.user?.avatar != 'null'
                    ? new NetworkImage(Services.auth.user?.avatar)
                    : null,
                child: new Text(
                    '${Services.auth.user?.firstname[0]}${Services.auth.user?.name[0]}')),
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
                              Services.auth.logout().then((_) => Navigator
                                  .of(context)
                                  .pushNamedAndRemoveUntil(
                                      '/login', (route) => false));
                            })
                      ])))
        ]))
      ]));

  SliverAppBar _buildAppBar() => new SliverAppBar(
        pinned: true,
        automaticallyImplyLeading: false,
        floating: _homeScreenItems[_currentIndex].sub != null && !_isSearching,
        title: new Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius:
                    const BorderRadius.all(const Radius.circular(3.0))),
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(children: <Widget>[
              _isSearching
                  ? const BackButton()
                  : new IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
              new Expanded(
                child: new TextField(
                  onSubmitted: (data) {
                    _handleSearchBegin();
                  },
                  key: _searchKey,
                  controller: _searchController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Search...',
                      hintStyle: const TextStyle(
                        color: const Color.fromARGB(150, 255, 255, 255),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                      hideDivider: true),
                  keyboardType: TextInputType.text,
                ),
              ),
              _isSearching
                  ? const Text('')
                  : new IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _handleSearchBegin();
                      },
                    )
            ])),
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
        return [
          const Center(
            child: const Text('Type something to search...'),
          )
        ];
      }
      List<Item> search = new List<Item>.from(Services.items.items);
      search = search
          .where((item) => item.name.toLowerCase().contains(_searchQuery))
          .toList();
      return [new ItemsList(search, 'search')];
    }
    return _homeScreenItems[_currentIndex].content;
  }

  @override
  Widget build(BuildContext context) {
    final cur = _homeScreenItems[_currentIndex];
    return new Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(context),
        floatingActionButton: _buildFab(),
        body: new DefaultTabController(
            key: new Key(cur.title),
            length: cur.sub?.length ?? 1,
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
}

class HomeScreenItem {
  final BottomNavigationBarItem item;
  final List<Widget> content;
  final List<HomeScreenSubItem> sub;
  final FloatingActionButton fab;
  final String title;

  HomeScreenItem({Widget icon, this.title, Widget content, this.sub, this.fab})
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
