import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/utils.dart';
import 'package:spotitems/model/group.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  const AddItemScreen(this._authManager, this._itemsManager);

  @override
  _AddItemScreenState createState() =>
      new _AddItemScreenState(_authManager, _itemsManager);
}

class _AddItemScreenState extends State<AddItemScreen>
    with TickerProviderStateMixin {
  _AddItemScreenState(this._authManager, this._itemsManager);
  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  AnimationController _controller;
  Animation<Size> _bottomSize;

  List<File> imageFile = <File>[];

  String name;
  String about;
  String location;
  bool gift = false;
  bool private = false;
  List<String> images = <String>[];

  bool _loading = true;

  List<Group> _myGroups;

  @override
  void initState() {
    super.initState();
    imageFile.clear();
    images.clear();
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
    _authManager.getGroups(widget._authManager.user.id).then((data) {
      setState(() {
        _myGroups = data;
        _loading = false;
      });
    });
  }

  Future<bool> getImage() async {
    final File _fileName = await ImagePicker.pickImage();
    setState(() {
      imageFile.add(_fileName);
      _fileName.readAsBytes().then((data) {
        images.add(
            'data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(data)}');
      });
    });
    return true;
  }

  Widget getImageGrid() {
    if (imageFile == null || imageFile.isEmpty) {
      return const Center(child: const Text('No images'));
    }
    return new GridView.count(
      primary: false,
      crossAxisCount: imageFile.length,
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          imageFile.length,
          (index) => new GridTile(
                  child: new Stack(
                children: <Widget>[
                  new Image.file(imageFile[index]),
                  new Positioned(
                      top: 5.0,
                      left: 5.0,
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new IconButton(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete this image',
                              onPressed: () {
                                setState(() {
                                  imageFile.removeAt(index);
                                  images.removeAt(index);
                                });
                              },
                            ),
                          ])),
                ],
              ))),
    );
  }

  Future<Null> addItem(BuildContext context) async {
    _formKey.currentState.save();
    final List<String> tracks = <String>[];
    if (gift) {
      tracks.add('gift');
    }
    if (private) {
      tracks.add('private');
    }
    if (_authManager.user != null &&
        _authManager.user.id != null &&
        _itemsManager.location != null) {
      final dynamic response = await _itemsManager.addItem(
          name,
          about,
          _authManager.user.id,
          _itemsManager.location['latitude'].toString(),
          _itemsManager.location['longitude'].toString(),
          images,
          location,
          tracks);
      showSnackBar(context, response['msg']);
      if (response['success']) {
        await _itemsManager.getItems(force: true);
        await Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      showSnackBar(context, 'Not Connected');
    }
  }

  Widget getGroups() {
    if (_loading) {
      return const Center(child: const CircularProgressIndicator());
    }
    return const Center(child: const Text('Comming soon !'));
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new DefaultTabController(
          length: 3,
          child: new NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
                    new AnimatedBuilder(
                        animation: _bottomSize,
                        builder: (context, child) => new SliverAppBar(
                            pinned: true,
                            title: const Text('Add Item'),
                            actions: <Widget>[
                              new Builder(
                                  builder: (context) => new IconButton(
                                      icon: new Column(children: <Widget>[
                                        const Icon(Icons.add_box),
                                        const Text('Add')
                                      ]),
                                      onPressed: () {
                                        addItem(context);
                                      }))
                            ],
                            bottom: new TabBar(tabs: <Tab>[
                              const Tab(text: 'Information'),
                              const Tab(text: 'Images'),
                              const Tab(text: 'Groups')
                            ])))
                  ],
              body: new Container(
                  margin: const EdgeInsets.all(20.0),
                  child: new Form(
                      key: _formKey,
                      child: new TabBarView(children: <Widget>[
                        new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Column(children: <Widget>[
                                new TextFormField(
                                    key: const Key('name'),
                                    decoration: const InputDecoration.collapsed(
                                        hintText: 'Name'),
                                    autofocus: true,
                                    onSaved: (value) {
                                      name = value;
                                    }),
                                new TextFormField(
                                    key: const Key('about'),
                                    decoration: const InputDecoration.collapsed(
                                        hintText: 'Description'),
                                    onSaved: (value) {
                                      about = value;
                                    }),
                                new TextFormField(
                                    key: const Key('location'),
                                    decoration: const InputDecoration.collapsed(
                                        hintText: 'Location'),
                                    onSaved: (value) {
                                      location = value;
                                    }),
                                new SwitchListTile(
                                    title: const Text('Donated Item'),
                                    value: gift,
                                    onChanged: (value) {
                                      setState(() {
                                        gift = value;
                                      });
                                    },
                                    secondary: const Icon(Icons.card_giftcard)),
                                new SwitchListTile(
                                    title: const Text('Private Item'),
                                    value: private,
                                    onChanged: (value) {
                                      setState(() {
                                        private = value;
                                      });
                                    },
                                    secondary: const Icon(Icons.lock))
                              ])
                            ]),
                        getImageGrid(),
                        getGroups(),
                      ])))),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: const Icon(Icons.add_a_photo),
        ),
      );
}
