import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/ui/views/explorer_view.dart';
import 'package:spotitem/ui/views/discover_view.dart';
import 'package:spotitem/ui/views/map_view.dart';
import 'package:spotitem/ui/views/items_view.dart';
import 'package:spotitem/ui/views/groups_view.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/item.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Home screen class
class HomeScreen extends StatefulWidget {
  /// Home screen initializer
  const HomeScreen();

  @override
  State createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static List<HomeScreenItem> _homeScreenItems;

  // Animation
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<FractionalOffset> _drawerDetailsPosition;

  // Bool
  bool _showDrawerContents = true;
  bool _isSearching = false;
  bool _filterAvailable = false;

  // Search
  final TextEditingController _searchController = new TextEditingController();
  String _searchQuery = '';

  //Explore
  static PageController pageCtrl = new PageController();
  static int get page => pageCtrl.hasClients ? pageCtrl.page.ceil() : 0;
  static const Widget discover = const DiscoverView();
  static const Widget explore = const ExplorerView();

  @override
  void initState() {
    _homeScreenItems = [
      new HomeScreenItem(
        parent: this,
        icon: const Icon(Icons.explore),
        title: 'Explore',
        sub: <HomeScreenSubItem>[
          new HomeScreenSubItem(SpotL.of(Services.loc).discover(), discover),
          new HomeScreenSubItem(SpotL.of(Services.loc).explore(), explore),
        ],
      ),
      new HomeScreenItem(
          parent: this,
          icon: const Icon(Icons.work),
          title: SpotL.of(Services.loc).items(),
          content: const ItemsView(),
          fabs: [
            new FloatingActionButton(
                child: const Icon(Icons.add),
                tooltip: 'Add new item',
                onPressed: () {
                  Navigator.of(context).pushNamed('/item/add');
                })
          ]),
      new HomeScreenItem(
        parent: this,
        icon: const Icon(Icons.map),
        title: SpotL.of(Services.loc).map(),
        content: const MapView(),
      ),
      new HomeScreenItem(
          parent: this,
          icon: const Icon(Icons.nature_people),
          title: SpotL.of(Services.loc).social(),
          sub: <HomeScreenSubItem>[
            new HomeScreenSubItem(
              SpotL.of(Services.loc).groups(),
              const GroupsView(),
            ),
            new HomeScreenSubItem(
                SpotL.of(Services.loc).messages(),
                const Center(
                  child: const Text('Comming soon'),
                ))
          ],
          fabs: [
            new FloatingActionButton(
                child: const Icon(Icons.person_add),
                tooltip: 'Add new groups',
                onPressed: () {
                  Navigator.of(context).pushNamed('/groups/add');
                }),
            new FloatingActionButton(
                child: const Icon(Icons.sms),
                tooltip: 'Add new messages',
                onPressed: () {})
          ]),
    ];
    _initAnimation();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController?.dispose();
    _homeScreenItems[page].tab?.removeListener(_checkFilter);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  void _initAnimation() {
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
                            onPressed: () {},
                          )),
                ),
                new StatefulBuilder(
                    builder: (context, switchSetState) => new SwitchListTile(
                          title:
                              new Text(SpotL.of(Services.loc).fromYourGroups()),
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
                          title: new Text(SpotL.of(Services.loc).gift()),
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
            ));
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
    if (_isSearching || _homeScreenItems[page].sub == null) {
      return null;
    }
    return new TabBar(
      controller: _homeScreenItems[page].tab,
      indicatorWeight: 4.0,
      tabs: new List<Tab>.generate(_homeScreenItems[page].sub?.length,
          (index) => new Tab(text: _homeScreenItems[page].sub[index].title)),
    );
  }

  Widget _buildDrawer(BuildContext context) => new Drawer(
          child: new ListView(children: <Widget>[
        new UserAccountsDrawerHeader(
            accountName: new Text(
                '${Services.auth.user?.firstname} ${Services.auth.user?.name}'),
            accountEmail: new Text(Services.auth.user?.email),
            currentAccountPicture: getAvatar(Services.auth.user),
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
                    new ListTile(
                      leading: const Icon(Icons.home),
                      title: new Text(SpotL.of(Services.loc).home()),
                      selected: true,
                    ),
                    new ListTile(
                        leading: const Icon(Icons.dvr),
                        title: const Text('Dump App to Console'),
                        onTap: () {
                          debugDumpApp();
                          debugDumpRenderTree();
                          debugDumpLayerTree();
                        }),
                    new ListTile(
                        leading: const Icon(Icons.developer_board),
                        title: const Text('Debug'),
                        onTap: () {
                          Navigator.of(context).pushNamed('/debug');
                        }),
                    new AboutListTile(
                        icon: const Icon(Icons.info),
                        applicationVersion: version,
                        applicationIcon: const Icon(Icons.info),
                        applicationLegalese: '© 2017 Alexis Rouillard',
                        aboutBoxChildren: <Widget>[
                          new Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: new RichText(
                                  text: new TextSpan(children: <TextSpan>[
                                new TextSpan(
                                    style: Theme.of(context).textTheme.body2,
                                    text:
                                        'Spotitem est un outil de pret de matériels, biens entre amis.\n'
                                        'En savoir plus a propos de Spotitem sur '),
                                new LinkTextSpan(
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(
                                            color:
                                                Theme.of(context).accentColor),
                                    url: 'https://spotitem.fr'),
                                new TextSpan(
                                    style: Theme.of(context).textTheme.body2,
                                    text: '.')
                              ])))
                        ])
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
                            title:
                                new Text(SpotL.of(Services.loc).editProfile()),
                            onTap: () {
                              Navigator.of(context).pushNamed('/profile/edit/');
                            }),
                        new ListTile(
                            leading: const Icon(Icons.exit_to_app),
                            title: new Text(SpotL.of(Services.loc).logout()),
                            onTap: () {
                              Services.auth.logout().then((_) => Navigator
                                  .of(context)
                                  .pushNamedAndRemoveUntil(
                                      '/', (route) => false));
                            })
                      ])))
        ]))
      ]));

  void _checkFilter() {
    if (!mounted) {
      return;
    }
    setState(() {
      _filterAvailable = (page == 0 && _homeScreenItems[page].tab.index == 1);
    });
  }

  List<Widget> _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    if (page == 0 || (_homeScreenItems[page].fabs?.length ?? 0) > 0)
      _homeScreenItems[page].tab.addListener(_checkFilter);
    else {
      _homeScreenItems[page].tab.removeListener(_checkFilter);
    }
    final widgets = <Widget>[
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
          controller: _searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
          decoration: new InputDecoration(
              isDense: true,
              hintText: SpotL.of(Services.loc).search(),
              hintStyle: const TextStyle(
                color: const Color.fromARGB(150, 255, 255, 255),
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
              hideDivider: true),
          keyboardType: TextInputType.text,
        ),
      ),
    ];
    if (!_isSearching) {
      widgets.add(new IconButton(
        alignment: _filterAvailable
            ? FractionalOffset.centerRight
            : FractionalOffset.center,
        padding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.search),
        onPressed: _handleSearchBegin,
      ));
    }
    if (_isSearching || _filterAvailable) {
      widgets.add(new IconButton(
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            setState(_showFilter);
          }));
    }
    return [
      new SliverAppBar(
        pinned: true,
        forceElevated: innerBoxIsScrolled,
        automaticallyImplyLeading: false,
        centerTitle: true,
        floating: _homeScreenItems[page].sub != null && !_isSearching,
        title: new Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius:
                    const BorderRadius.all(const Radius.circular(3.0))),
            child: new Row(children: widgets)),
        bottom: _buildBottom(),
      )
    ];
  }

  List<Widget> _buildChild(BuildContext context, int index) {
    if (_isSearching) {
      if (_searchQuery.isEmpty) {
        return [
          new Center(child: new Text(SpotL.of(Services.loc).searchDialog()))
        ];
      }
      var search = new List<Item>.from(Services.items.items);
      final _searchWord =
          _searchQuery.split(' ').where((f) => f.trim().isNotEmpty);
      search = search
          .where((item) =>
              _searchWord.any((f) => item.name.toLowerCase().contains(f)))
          .toList();
      return [new ItemsList(search, 'search')];
    }
    return _homeScreenItems[index].content;
  }

  @override
  Widget build(BuildContext context) =>
      new Stack(fit: StackFit.expand, children: <Widget>[
        new Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(context),
            floatingActionButton:
                _isSearching || _homeScreenItems[page].fabs == null
                    ? null
                    : _homeScreenItems[page].fab,
            body: new Builder(builder: (context) {
              Services.context = context;
              return new NestedScrollView(
                  headerSliverBuilder: _buildAppBar,
                  body: new PageView.builder(
                      controller: pageCtrl,
                      itemCount: _homeScreenItems.length,
                      itemBuilder: (context, index) => new TabBarView(
                          key: _homeScreenItems[index].key,
                          controller: _homeScreenItems[index].tab,
                          children: _buildChild(context, index))));
            }),
            bottomNavigationBar: _isSearching
                ? null
                : new BottomNavigationBar(
                    currentIndex: page,
                    items: _homeScreenItems.map((data) => data.item).toList(),
                    onTap: (index) {
                      setState(() {
                        pageCtrl.jumpToPage(index);
                      });
                    },
                  )),
        const Banner(
          message: 'BETA TEST',
          location: BannerLocation.bottomStart,
        ),
      ]);
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

  /// Home screen item Tab controller
  final TabController tab;

  /// Home item key
  final Key key;

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
            ? new List<Widget>.generate(
                sub.length, (index) => sub[index].content)
            : <Widget>[content],
        tab = new TabController(vsync: parent, length: sub?.length ?? 1),
        key = new PageStorageKey<String>(title);

  /// Home item actual fab
  FloatingActionButton get fab =>
      fabs.length > tab.index ? fabs[tab.index] : null;
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
