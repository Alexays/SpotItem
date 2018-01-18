import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/models/home_items.dart';
import 'package:spotitem/ui/views/explorer_view.dart';
import 'package:spotitem/ui/views/discover_view.dart';
import 'package:spotitem/ui/views/map_view.dart';
import 'package:spotitem/ui/views/items_view.dart';
import 'package:spotitem/ui/views/holded_view.dart';
import 'package:spotitem/ui/views/groups_view.dart';
import 'package:spotitem/ui/views/social_view.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

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

  // Animation
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  // Bool
  bool _hideDrawerContents = false;
  bool _isSearching = false;

  // Search
  final TextEditingController _searchController = new TextEditingController();
  String _searchQuery;

  //Explore
  int page = 0;
  int filterIndex = 0;
  List<HomeScreenItem> _homeScreenItems;
  List<TabController> tabsCtrl;

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
    _homeScreenItems = <HomeScreenItem>[
      new HomeScreenItem(
        main: true,
        icon: const Icon(Icons.explore),
        title: SpotL.of(Services.context).explore,
        content: const DiscoverView(),
        filter: const ExplorerView(),
        fabs: [
          new FloatingActionButton(
            child: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () =>
                Navigator.of(Services.context).pushNamed('/filters'),
          )
        ],
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.work),
        title: SpotL.of(Services.context).items,
        sub: <HomeScreenSubItem>[
          new HomeScreenSubItem(
            SpotL.of(Services.context).items,
            const ItemsView(),
          ),
          new HomeScreenSubItem(
            SpotL.of(Services.context).holded,
            const HoldedView(),
          ),
        ],
        fabs: [
          new FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: 'Add new item',
            onPressed: () =>
                Navigator.of(Services.context).pushNamed('/items/add/'),
          )
        ],
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.map),
        title: SpotL.of(Services.context).map,
        content: const MapView(),
      ),
      new HomeScreenItem(
        icon: const Icon(Icons.nature_people),
        title: SpotL.of(Services.context).social,
        sub: <HomeScreenSubItem>[
          new HomeScreenSubItem(
            SpotL.of(Services.context).groups,
            const GroupsView(),
          ),
          new HomeScreenSubItem(
            SpotL.of(Services.context).messages,
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
    ModalRoute.of(context).addLocalHistoryEntry(
          new LocalHistoryEntry(
            onRemove: () => setState(() {
                  _searchController.removeListener(_searchCallback);
                  _isSearching = false;
                }),
          ),
        );
    setState(() {
      _searchController.addListener(_searchCallback);
      _isSearching = true;
    });
  }

  Widget _buildFilterBar(BuildContext context) {
    final tracks = Services.items.excludeTracks;
    final spotL = SpotL.of(context);
    final widgets = <Widget>[
      new Row(
        children: <Widget>[
          new MaterialButton(
            key: const Key('categories'),
            onPressed: () => Navigator.of(context).pushNamed('/categories'),
            child: new Chip(
              backgroundColor: Theme.of(context).canvasColor,
              label: new Text(spotL.categories),
            ),
          ),
        ],
      )
    ]..addAll(
        tracks.map((f) => new Chip(
              onDeleted: () => setState(() {
                    Services.items.tracks.value.remove(f);
                  }),
              backgroundColor: Theme.of(context).canvasColor,
              label: new Text(f),
            )),
      );
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        children: widgets,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (_homeScreenItems[page].filter != null || _isSearching) {
      return new PreferredSize(
        preferredSize: new Size.fromHeight(56.0),
        child: _buildFilterBar(context),
      );
    }
    if (_homeScreenItems[page].sub != null) {
      return new TabBar(
        controller: tabsCtrl[page],
        indicatorWeight: 4.0,
        tabs: _homeScreenItems[page]
            .sub
            .map((f) => new Tab(text: f.title))
            .toList(),
      );
    }
    return null;
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final drawerList = new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new ListTile(
          leading: const Icon(Icons.home),
          title: new Text(SpotL.of(context).home),
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
          onTap: () => Navigator.of(context).pushNamed('/debug'),
        ),
        new AboutListTile(
          icon: const Icon(Icons.info),
          applicationVersion: Services.settings.version,
          applicationIcon: const Icon(Icons.info),
          applicationLegalese: '© 2017 Alexis Rouillard',
          aboutBoxChildren: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: new RichText(
                text: new TextSpan(
                  children: <TextSpan>[
                    new TextSpan(
                      style: theme.textTheme.body2,
                      text:
                          'Spotitem est un outil de pret de matériels, biens entre amis.\n'
                          'En savoir plus a propos de Spotitem sur ',
                    ),
                    new LinkTextSpan(
                      style: theme.textTheme.body2
                          .copyWith(color: theme.accentColor),
                      url: 'https://spotitem.fr',
                    ),
                    new TextSpan(
                      style: theme.textTheme.body2,
                      text: '.',
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
    return new Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            accountName: new Text(
              '${Services.auth.user?.firstname} ${Services.auth.user?.name}',
            ),
            accountEmail: new Text(
              Services.auth.user?.email ?? '',
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
              _hideDrawerContents = !_hideDrawerContents;
              _hideDrawerContents
                  ? _controller.forward()
                  : _controller.reverse();
            },
          ),
          new MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: new Expanded(
              child: new ListView(
                padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      new FadeTransition(
                        opacity: _drawerContentsOpacity,
                        child: drawerList,
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
                                title: new Text(SpotL.of(context).editProfile),
                                onTap: () => Navigator
                                    .of(context)
                                    .pushNamed('/profile/edit/'),
                              ),
                              new ListTile(
                                leading: const Icon(Icons.exit_to_app),
                                title: new Text(SpotL.of(context).logout),
                                onTap: Services.auth.logout,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    final widgets = <Widget>[
      _isSearching
          ? const BackButton()
          : new IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),
      new Expanded(
        //TODO: check if it work's
        child: new OverflowBox(
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
              border: null,
              hintText: SpotL.of(context).search,
              hintStyle: const TextStyle(
                color: const Color.fromARGB(150, 255, 255, 255),
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      )
    ];
    if (!_isSearching) {
      //TODO: find a other way to enter search mode in test
      if (Services.debug) {
        widgets.add(new IconButton(
          icon: const Icon(Icons.search),
          onPressed: _handleSearchBegin,
        ));
      }
      widgets.add(
        new IconButton(
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Icons.photo_camera),
          onPressed: () => Services.items.qrReader(context),
        ),
      );
    }
    final bottomBar = _buildBottomBar(context);
    return [
      new SliverAppBar(
        pinned: true,
        forceElevated: innerBoxIsScrolled,
        automaticallyImplyLeading: false,
        centerTitle: true,
        snap: bottomBar != null,
        floating: bottomBar != null,
        title: new DecoratedBox(
          decoration: new BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: const BorderRadius.all(
              const Radius.circular(3.0),
            ),
          ),
          child: new Material(
            color: Colors.transparent,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgets,
            ),
          ),
        ),
        bottom: bottomBar,
      ),
    ];
  }

  Widget _buildChild(BuildContext context) {
    if (_isSearching) {
      if (_searchQuery.isEmpty) {
        return new Center(child: new Text(SpotL.of(context).searchDialog));
      }
      final _query = _searchQuery.split(' ').where((f) => f.trim().isNotEmpty);
      return new ItemsList(
          Services.items.data
              .where((item) =>
                  _query.any((f) => item.name.toLowerCase().contains(f)))
              .toList(),
          4);
    }
    if (tabsCtrl[page].length > 1) {
      return new TabBarView(
        key: _homeScreenItems[page].key,
        controller: tabsCtrl[page],
        children: _homeScreenItems[page].body,
      );
    }
    if (_homeScreenItems[page].filter != null &&
        Services.items.tracks.value.isNotEmpty) {
      return _homeScreenItems[page].filter;
    }
    return _homeScreenItems[page].body;
  }

  @override
  Widget build(BuildContext context) => new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(context),
            floatingActionButton: !_isSearching &&
                    ((_homeScreenItems[page].fabs?.length ?? 0) >
                        tabsCtrl[page].index)
                ? _homeScreenItems[page].fabs[tabsCtrl[page].index]
                : null,
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
                    onTap: (index) => setState(() {
                          page = index;
                          Services.observer.analytics.setCurrentScreen(
                            screenName: 'Home/tab$page',
                          );
                        }),
                  ),
          ),
          const Banner(
            message: 'BETA TEST',
            location: BannerLocation.bottomStart,
          ),
        ],
      );
}
