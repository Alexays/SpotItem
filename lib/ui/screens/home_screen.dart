import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/ui/views/explorer_view.dart';
import 'package:spotitem/ui/views/discover_view.dart';
import 'package:spotitem/ui/views/map_view.dart';
import 'package:spotitem/ui/views/items_view.dart';
import 'package:spotitem/ui/views/holded_view.dart';
import 'package:spotitem/ui/views/groups_view.dart';
import 'package:spotitem/ui/views/social_view.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:qrcode_reader/QRCodeReader.dart';

/// Home screen class
class HomeScreen extends StatefulWidget {
  /// Home screen initializer
  const HomeScreen();

  @override
  State createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final List<HomeScreenItem> _homeScreenItems = <HomeScreenItem>[
    new HomeScreenItem(
      icon: const Icon(Icons.explore),
      title: SpotL.of(Services.loc).explore,
      sub: <HomeScreenSubItem>[
        new HomeScreenSubItem(SpotL.of(Services.loc).discover, discover),
        new HomeScreenSubItem(SpotL.of(Services.loc).explore, explore),
      ],
    ),
    new HomeScreenItem(
      icon: const Icon(Icons.work),
      title: SpotL.of(Services.loc).items,
      sub: <HomeScreenSubItem>[
        new HomeScreenSubItem(
          SpotL.of(Services.loc).items,
          const ItemsView(),
        ),
        new HomeScreenSubItem(
          SpotL.of(Services.loc).holded,
          const HoldedView(),
        ),
      ],
      fabs: [
        new FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: 'Add new item',
            onPressed: () =>
                Navigator.of(Services.context).pushNamed('/items/add/'))
      ],
    ),
    new HomeScreenItem(
      icon: const Icon(Icons.map),
      title: SpotL.of(Services.loc).map,
      content: const MapView(),
    ),
    new HomeScreenItem(
      icon: const Icon(Icons.nature_people),
      title: SpotL.of(Services.loc).social,
      sub: <HomeScreenSubItem>[
        new HomeScreenSubItem(
          SpotL.of(Services.loc).groups,
          const GroupsView(),
        ),
        new HomeScreenSubItem(
          SpotL.of(Services.loc).messages,
          const SocialView(),
        )
      ],
      fabs: [
        new FloatingActionButton(
          child: const Icon(Icons.person_add),
          tooltip: 'Add new groups',
          onPressed: () =>
              Navigator.of(Services.context).pushNamed('/groups/add/'),
        ),
        new FloatingActionButton(
          child: const Icon(Icons.sms),
          tooltip: 'Add new messages',
          onPressed: () =>
              Navigator.of(Services.context).pushNamed('/messages/add/'),
        )
      ],
    ),
  ];

  // Animation
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  // Bool
  bool _showDrawerContents = true;
  bool _isSearching = false;
  bool _filterAvailable = false;

  // Search
  final TextEditingController _searchController = new TextEditingController();
  String _searchQuery = '';

  //Explore
  List<TabController> tabsCtrl;
  int page = 0;
  static const Widget discover = const DiscoverView();
  static const Widget explore = const ExplorerView();
  FloatingActionButton get fab =>
      _homeScreenItems[page].fabs.length > tabsCtrl[page].index
          ? _homeScreenItems[page].fabs[tabsCtrl[page].index]
          : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Services.observer.subscribe(this, ModalRoute.of(context));
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    )
        .animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
    WidgetsBinding.instance.addObserver(this);
    tabsCtrl = _homeScreenItems
        .map((data) =>
            new TabController(vsync: this, length: data.sub?.length ?? 1))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
    Services.observer.unsubscribe(this);
    _controller?.dispose();
    _searchController?.dispose();
    tabsCtrl[page]?.removeListener(_checkFilter);
    for (var tab in tabsCtrl) {
      tab?.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      print('background');
    } else if (state == AppLifecycleState.resumed) {
      print('foreground');
    }
  }

  void _showFilter() {
    showModalBottomSheet<Null>(
      context: context,
      builder: (context) => new StatefulBuilder(
            builder: (context, switchSetState) => new Column(
                  children: <Widget>[
                    new Container(
                      height: 100.0,
                      child: new ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          itemCount: Services.items.categories.length,
                          itemExtent: 75.0,
                          itemBuilder: (context, index) => !Services
                                  .items.tracks.value
                                  .contains(Services.items.categories[index])
                              ? new FlatButton(
                                  child: new Image.asset(
                                      'assets/${Services.items.categories[index]}.png'),
                                  onPressed: () {
                                    Services.items.tracks.value = Services
                                        .items.tracks.value
                                        .where((f) => !Services.items.categories
                                            .any((d) => d == f))
                                        .toList();
                                    Services.items.tracks.value
                                        .add(Services.items.categories[index]);
                                    switchSetState(() {
                                      Services.items.tracks.value =
                                          new List<String>.from(
                                              Services.items.tracks.value);
                                    });
                                  },
                                )
                              : new RaisedButton(
                                  child: new Image.asset(
                                      'assets/${Services.items.categories[index]}.png'),
                                  onPressed: () {
                                    Services.items.tracks.value.remove(
                                        Services.items.categories[index]);
                                    switchSetState(() {
                                      Services.items.tracks.value =
                                          new List<String>.from(
                                              Services.items.tracks.value);
                                    });
                                  },
                                )),
                    ),
                    new SwitchListTile(
                      title: new Text(SpotL.of(Services.loc).fromYourGroups),
                      value: Services.items.tracks.value.contains('group'),
                      onChanged: (value) {
                        value
                            ? Services.items.tracks.value.add('group')
                            : Services.items.tracks.value.remove('group');
                        switchSetState(() {
                          Services.items.tracks.value = new List<String>.from(
                              Services.items.tracks.value);
                        });
                      },
                      secondary: const Icon(Icons.lock),
                    ),
                    new SwitchListTile(
                      title: new Text(SpotL.of(Services.loc).gift),
                      value: Services.items.tracks.value.contains('gift'),
                      onChanged: (value) {
                        value
                            ? Services.items.tracks.value.add('gift')
                            : Services.items.tracks.value.remove('gift');
                        switchSetState(() {
                          Services.items.tracks.value = new List<String>.from(
                              Services.items.tracks.value);
                        });
                      },
                      secondary: const Icon(Icons.card_giftcard),
                    )
                  ],
                ),
          ),
    );
  }

  void _searchCallback() {
    if (!mounted) {
      return;
    }
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _handleSearchBegin() {
    if (!mounted) {
      return;
    }
    _searchCallback();
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

  void _checkFilter([bool build = true]) {
    if (!mounted) {
      return;
    }
    if (!build) {
      _filterAvailable = (page == 0 && tabsCtrl[page].index == 1);
      return;
    }
    setState(() {
      _filterAvailable = (page == 0 && tabsCtrl[page].index == 1);
    });
  }

  void _qrReader() {
    new QRCodeReader().scan().then((data) {
      final itemId = Services.items.parseCode(data);
      Navigator.of(context).pushReplacementNamed('items/$itemId');
    });
  }

  PreferredSizeWidget _buildBottom() {
    if (_isSearching || _homeScreenItems[page].sub == null) {
      return null;
    }
    return new TabBar(
      controller: tabsCtrl[page],
      indicatorWeight: 4.0,
      tabs: _homeScreenItems[page]
          .sub
          .map((f) => new Tab(text: f.title))
          .toList(),
    );
  }

  Widget _buildDrawer(BuildContext context) => new Drawer(
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(
                '${Services.auth.user?.firstname} ${Services.auth.user?.name}',
                overflow: TextOverflow.ellipsis,
              ),
              accountEmail: new Text(
                Services.auth.user?.email ?? '',
                overflow: TextOverflow.ellipsis,
              ),
              currentAccountPicture: getAvatar(Services.auth.user),
              otherAccountsPictures: <Widget>[
                new IconButton(
                  icon: const Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                )
              ],
              onDetailsPressed: () {
                _showDrawerContents = !_showDrawerContents;
                _showDrawerContents
                    ? _controller.reverse()
                    : _controller.forward();
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
                        new ListTile(
                          leading: const Icon(Icons.home),
                          title: new Text(SpotL.of(Services.loc).home),
                          selected: true,
                        ),
                        new ListTile(
                          leading: const Icon(Icons.dvr),
                          title: const Text('Dump App to Console'),
                          onTap: () {
                            debugDumpApp();
                            debugDumpRenderTree();
                            debugDumpLayerTree();
                          },
                        ),
                        new ListTile(
                          leading: const Icon(Icons.developer_board),
                          title: const Text('Debug'),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/debug'),
                        ),
                        new AboutListTile(
                          icon: const Icon(Icons.info),
                          applicationVersion: version,
                          applicationIcon: const Icon(Icons.info),
                          applicationLegalese: '© 2017 Alexis Rouillard',
                          aboutBoxChildren: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: new RichText(
                                text: new TextSpan(
                                  children: <TextSpan>[
                                    new TextSpan(
                                      style: Theme.of(context).textTheme.body2,
                                      text:
                                          'Spotitem est un outil de pret de matériels, biens entre amis.\n'
                                          'En savoir plus a propos de Spotitem sur ',
                                    ),
                                    new LinkTextSpan(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                              color: Theme
                                                  .of(context)
                                                  .accentColor),
                                      url: 'https://spotitem.fr',
                                    ),
                                    new TextSpan(
                                      style: Theme.of(context).textTheme.body2,
                                      text: '.',
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
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
                              title:
                                  new Text(SpotL.of(Services.loc).editProfile),
                              onTap: () => Navigator
                                  .of(context)
                                  .pushNamed('/profile/edit/')),
                          new ListTile(
                            leading: const Icon(Icons.exit_to_app),
                            title: new Text(SpotL.of(Services.loc).logout),
                            onTap: () => Services.auth.logout().then(
                                  (_) => Navigator
                                      .of(context)
                                      .pushNamedAndRemoveUntil(
                                          '/', (route) => false),
                                ),
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

  List<Widget> _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    _checkFilter(false);
    if (page == 0 || (_homeScreenItems[page].fabs?.length ?? 0) > 0) {
      tabsCtrl[page].addListener(_checkFilter);
    } else {
      tabsCtrl[page].removeListener(_checkFilter);
    }
    final widgets = <Widget>[
      _isSearching
          ? const BackButton()
          : new IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),
      new Flexible(
        fit: FlexFit.tight,
        child: new TextField(
          key: const Key('search'),
          onSubmitted: (data) => _handleSearchBegin(),
          controller: _searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
          decoration: new InputDecoration(
            isDense: true,
            hideDivider: true,
            hintText: SpotL.of(Services.loc).search,
            hintStyle: const TextStyle(
              color: const Color.fromARGB(150, 255, 255, 255),
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    ];
    if (!_isSearching) {
      widgets.add(
        new IconButton(
          alignment:
              _filterAvailable ? const Alignment(1.5, 0.0) : Alignment.center,
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Icons.photo_camera),
          onPressed: _qrReader,
        ),
      );
    }
    if (_isSearching || _filterAvailable) {
      widgets.addAll(
        [
          new IconButton(
            padding: const EdgeInsets.all(0.0),
            alignment: Alignment.centerRight,
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(_showFilter);
            },
          ),
          new PopupMenuButton(
            padding: const EdgeInsets.all(0.0),
            itemBuilder: (context) => Services.items.sortMethod.map(
                  (f) {
                    switch (f) {
                      case 'name':
                        return new CheckedPopupMenuItem(
                            checked:
                                Services.items.tracks.value.contains('name'),
                            value: f,
                            child: new Text(SpotL.of(context).name));
                        break;
                      case 'dist':
                        return new CheckedPopupMenuItem(
                            checked:
                                Services.items.tracks.value.contains('dist') ||
                                    !Services.items.tracks.value.any((f) =>
                                        Services.items.sortMethod.contains(f)),
                            value: f,
                            child: new Text(SpotL.of(context).dist));
                        break;
                    }
                  },
                ).toList(),
            onSelected: (action) {
              setState(
                () {
                  Services.items.tracks.value = [
                    Services.items.tracks.value
                        .where((f) =>
                            !Services.items.sortMethod.any((d) => d == f))
                        .toList(),
                    [action]
                  ].expand((x) => x).toList();
                },
              );
            },
          )
        ],
      );
    }
    final haveTab = _homeScreenItems[page].sub != null && !_isSearching;
    return [
      new SliverAppBar(
        pinned: true,
        forceElevated: innerBoxIsScrolled,
        automaticallyImplyLeading: false,
        centerTitle: true,
        snap: haveTab,
        floating: haveTab,
        title: new DecoratedBox(
          decoration: new BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: const BorderRadius.all(
              const Radius.circular(3.0),
            ),
          ),
          child: new Row(children: widgets),
        ),
        bottom: _buildBottom(),
      )
    ];
  }

  Widget _buildChild(BuildContext context) {
    if (_isSearching) {
      if (_searchQuery.isEmpty) {
        return new Center(child: new Text(SpotL.of(Services.loc).searchDialog));
      }
      final _searchWord =
          _searchQuery.split(' ').where((f) => f.trim().isNotEmpty);
      return new ItemsList(
          Services.items.data
              .where((item) =>
                  _searchWord.any((f) => item.name.toLowerCase().contains(f)))
              .toList(),
          4);
    }
    return new TabBarView(
      controller: tabsCtrl[page],
      children: _homeScreenItems[page].content,
    );
  }

  @override
  Widget build(BuildContext context) => new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(context),
            floatingActionButton:
                _isSearching || _homeScreenItems[page].fabs == null
                    ? null
                    : fab,
            body: new Builder(builder: (context) {
              Services.context = context;
              return new NestedScrollView(
                headerSliverBuilder: _buildAppBar,
                body: _buildChild(context),
              );
            }),
            bottomNavigationBar: _isSearching
                ? null
                : new BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: page,
                    items: _homeScreenItems.map((data) => data.item).toList(),
                    onTap: (index) {
                      setState(() {
                        page = index;
                        // Services.observer.analytics.setCurrentScreen(
                        //   screenName: 'Home/tabpage',
                        // );
                      });
                    },
                  ),
          ),
          const Banner(
            message: 'BETA TEST',
            location: BannerLocation.bottomStart,
          ),
        ],
      );
}

/// Home screen item
class HomeScreenItem {
  /// Home screen item
  final BottomNavigationBarItem item;

  /// Home screen item content
  final List<Widget> content;

  /// Home screen item tabs
  final List<HomeScreenSubItem> sub;

  /// Home screen item fabs
  final List<FloatingActionButton> fabs;

  /// Home screen item title
  final String title;

  /// Home screen item initalizer
  HomeScreenItem(
      {_HomeScreenState parent,
      Widget icon,
      this.title,
      Widget content,
      this.sub,
      this.fabs})
      : item = new BottomNavigationBarItem(icon: icon, title: new Text(title)),
        content = sub != null
            ? sub.map((f) => f.content).toList()
            : <Widget>[content];
}

/// Home screen sub item
class HomeScreenSubItem {
  /// Home screen sub item title
  final String title;

  /// Home screen sub item content
  final Widget content;

  /// Home screen sub item initializer
  const HomeScreenSubItem(this.title, this.content);
}
