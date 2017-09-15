import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/models/group.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/keys.dart';

/// Edit item screen
class EditItemScreen extends StatefulWidget {
  /// Edit item screen initializer
  const EditItemScreen(this._itemId);

  final String _itemId;

  @override
  _EditItemScreenState createState() => new _EditItemScreenState(_itemId);
}

class _EditItemScreenState extends State<EditItemScreen>
    with TickerProviderStateMixin {
  _EditItemScreenState(this._itemId);

  final String _itemId;

  AnimationController _controller;
  Animation<Size> _bottomSize;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Item name
  String _name;
  TextEditingController _nameCtrl;

  /// Item Description
  String _about;
  TextEditingController _aboutCtrl;

  /// Item location
  String _location;
  TextEditingController _locationCtrl;

  /// Images file
  final List<File> _imagesFile = [];

  /// Item tracks
  List<String> _tracks = [];

  /// Base64 images
  final List<String> _images = [];

  /// Item data
  Item item;

  /// User groups
  List<Group> _groups = [];

  /// Item groups
  List<String> _groupsId = [];

  @override
  void initState() {
    Services.items.getItem(_itemId).then((data) {
      setState(() {
        item = data;
        if (item != null) {
          _nameCtrl = new TextEditingController(text: item.name);
          _aboutCtrl = new TextEditingController(text: item.about);
          _locationCtrl = new TextEditingController(text: item.location);
          _groupsId = item.groups;
          _tracks = item.tracks;
        }
      });
    });
    Services.groups.getGroups().then((data) {
      setState(() {
        _groups = data;
      });
    });
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
    super.initState();
  }

  Future<Null> getImage() async {
    final File _fileName = await ImagePicker.pickImage();
    if (_fileName != null) {
      setState(() {
        _imagesFile.add(_fileName);
        _fileName.readAsBytes().then((data) {
          _images.add(
              'data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(data)}');
        });
      });
    }
  }

  Widget getImageGrid() {
    if ((item.images.length + _imagesFile.length) < 1) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text('No images'),
          const Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          new RaisedButton(
            child: const Text('Add image'),
            onPressed: getImage,
          )
        ],
      );
    }
    return new GridView.count(
      primary: false,
      crossAxisCount: (item.images.length + _imagesFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          (item.images.length + _imagesFile.length), (index) {
        if (index < item.images.length) {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.network('$apiImgUrl${item.images[index]}'),
              new Positioned(
                top: 2.5,
                left: 2.5,
                child: new IconButton(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete this image',
                  onPressed: () {
                    setState(() {
                      item.images.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ));
        } else {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.file(_imagesFile[index - item.images.length]),
              new Positioned(
                top: 2.5,
                left: 2.5,
                child: new IconButton(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete this image',
                  onPressed: () {
                    setState(() {
                      _imagesFile.removeAt(index);
                      _images.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ));
        }
      }),
    );
  }

  Future<Null> editItem(BuildContext context) async {
    final List<String> finalImages = <String>[];
    final List<String> groups = <String>[];
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      showSnackBar(context, 'Please correct error !');
      return;
    }
    showLoading(context);
    item.images.forEach((f) => finalImages.add(f));
    _images.forEach((f) => finalImages.add(f));
    if (Services.auth.user != null &&
        Services.auth.user.id != null &&
        Services.users.location != null) {
      final dynamic response = await Services.items.editItem({
        'id': item.id,
        'name': _name,
        'about': _about,
        'owner': Services.auth.user.id,
        'holder': Services.auth.user.id,
        'lat': Services.users.location['latitude'].toString(),
        'lng': Services.users.location['longitude'].toString(),
        'images': JSON.encode(finalImages),
        'location': _location,
        'tracks': JSON.encode(_tracks),
        'groups': JSON.encode(groups)
      });
      Navigator.of(context).pop();
      showSnackBar(context, response['msg']);
      if (response['success']) {
        await Services.items.getItems(force: true);
        await Navigator
            .of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else {
      showSnackBar(context, 'Auth error !');
    }
  }

  Widget getGroups() {
    if (_groups == null) {
      return const Center(child: const CircularProgressIndicator());
    }
    return new Column(
      children: new List<Widget>.generate(
          _groups.length,
          (index) => new CheckboxListTile(
                title: new Text(_groups[index].name),
                value: _groupsId.contains(_groups[index].id),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _groupsId.add(_groups[index].id);
                    } else {
                      _groupsId.remove(_groups[index].id);
                    }
                  });
                },
                secondary: const Icon(Icons.people),
              )),
    );
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      body: new Builder(
          builder: (context) => new Column(
                children: <Widget>[
                  new Expanded(
                      child: new DefaultTabController(
                          length: 3,
                          child: new NestedScrollView(
                              headerSliverBuilder: (context,
                                      innerBoxIsScrolled) =>
                                  <Widget>[
                                    new AnimatedBuilder(
                                        animation: _bottomSize,
                                        builder: (context, child) =>
                                            new SliverAppBar(
                                                pinned: true,
                                                title: new Text(item != null
                                                    ? 'Edit: ${item.name}'
                                                    : 'Loading...'),
                                                bottom: new TabBar(tabs: <Tab>[
                                                  const Tab(
                                                      text: 'Informations'),
                                                  const Tab(text: 'Images'),
                                                  const Tab(text: 'Groups')
                                                ])))
                                  ],
                              body: item == null || _groups == null
                                  ? const Center(
                                      child: const CircularProgressIndicator())
                                  : new Form(
                                      key: _formKey,
                                      child: new TabBarView(children: <Widget>[
                                        new Container(
                                            margin: const EdgeInsets.all(20.0),
                                            child: new Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  new TextFormField(
                                                    key: const Key('name'),
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                'Ex: Pencil',
                                                            labelText: 'Name'),
                                                    validator: validateName,
                                                    controller: _nameCtrl,
                                                    onSaved: (data) {
                                                      _name = data;
                                                    },
                                                  ),
                                                  new TextFormField(
                                                    key: const Key('about'),
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                'Ex: It\'s a pencil !',
                                                            labelText:
                                                                'Description'),
                                                    controller: _aboutCtrl,
                                                    onSaved: (data) {
                                                      _about = data;
                                                    },
                                                  ),
                                                  new TextFormField(
                                                    key: const Key('location'),
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                'Ex: Nantes',
                                                            labelText:
                                                                'Location'),
                                                    validator: validateString,
                                                    controller: _locationCtrl,
                                                    onSaved: (data) {
                                                      _location = data;
                                                    },
                                                  ),
                                                  new SwitchListTile(
                                                    title: const Text(
                                                        'Donated Item'),
                                                    value: _tracks
                                                        .contains('gift'),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value) {
                                                          _tracks.add('gift');
                                                        } else {
                                                          _tracks
                                                              .remove('gift');
                                                        }
                                                      });
                                                    },
                                                    secondary: const Icon(
                                                        Icons.card_giftcard),
                                                  ),
                                                  new SwitchListTile(
                                                    title: const Text(
                                                        'Private Item'),
                                                    value: _tracks
                                                        .contains('private'),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value) {
                                                          _tracks
                                                              .add('private');
                                                        } else {
                                                          _tracks.remove(
                                                              'private');
                                                        }
                                                      });
                                                    },
                                                    secondary:
                                                        const Icon(Icons.lock),
                                                  ),
                                                ])),
                                        new Container(
                                            margin: const EdgeInsets.all(20.0),
                                            child: getImageGrid()),
                                        new Container(
                                            margin: const EdgeInsets.all(20.0),
                                            child: getGroups()),
                                      ]))))),
                  new Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 48.0),
                      child: new Center(
                          child: new RaisedButton(
                        onPressed: () {
                          editItem(context);
                        },
                        child: const Text('SAVE ITEM'),
                      )),
                    ),
                  )
                ],
              )));
}
