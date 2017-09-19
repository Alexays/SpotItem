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

import 'package:spotitem/ui/spot_strings.dart';

/// Edit item screen
class EditItemScreen extends StatefulWidget {
  /// Edit item screen initializer
  const EditItemScreen({Key key, this.itemId, this.item})
      : assert(itemId != null || item != null),
        super(key: key);

  /// Item id
  final String itemId;

  /// Item data
  final Item item;

  @override
  _EditItemScreenState createState() => new _EditItemScreenState(itemId, item);
}

class _EditItemScreenState extends State<EditItemScreen>
    with TickerProviderStateMixin {
  _EditItemScreenState(this._itemId, this._item);

  final String _itemId;

  Item _item;

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

  /// User groups
  List<Group> _groups = [];

  /// Item groups
  List<String> _groupsId = [];

  @override
  void initState() {
    if (_item == null) {
      Services.items.getItem(_itemId).then((data) {
        setState(() {
          _item = data;
          _initForm();
        });
      });
    } else {
      _initForm();
    }
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

  void _initForm() {
    if (_item != null) {
      setState(() {
        _nameCtrl = new TextEditingController(text: _item.name);
        _aboutCtrl = new TextEditingController(text: _item.about);
        _locationCtrl = new TextEditingController(text: _item.location);
        _groupsId = _item.groups ?? [];
        _tracks = _item.tracks ?? [];
      });
    }
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
    if ((_item.images.length + _imagesFile.length) < 1) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(SpotL.of(context).noImages()),
          const Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          new RaisedButton(
            child: new Text(SpotL.of(context).addImage()),
            onPressed: getImage,
          )
        ],
      );
    }
    return new GridView.count(
      primary: false,
      crossAxisCount: (_item.images.length + _imagesFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          (_item.images.length + _imagesFile.length), (index) {
        if (index < _item.images.length) {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.network('$apiImgUrl${_item.images[index]}'),
              new Positioned(
                top: 2.5,
                left: 2.5,
                child: new IconButton(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete this image',
                  onPressed: () {
                    setState(() {
                      _item.images.removeAt(index);
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
              new Image.file(_imagesFile[index - _item.images.length]),
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
      return showSnackBar(context, SpotL.of(context).correctError());
    }
    showLoading(context);
    _item.images.forEach((f) => finalImages.add(f));
    _images.forEach((f) => finalImages.add(f));
    if (Services.auth.user != null &&
        Services.auth.user.id != null &&
        Services.users.location != null) {
      final dynamic response = await Services.items.editItem({
        'id': _item.id,
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
      if (resValid(response)) {
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
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) => <Widget>[
                                        new AnimatedBuilder(
                                            animation: _bottomSize,
                                            builder: (context, child) =>
                                                new SliverAppBar(
                                                    pinned: true,
                                                    title: new Text(
                                                        _item != null
                                                            ? '${_item.name}'
                                                            : ''),
                                                    bottom: new TabBar(
                                                        indicatorWeight: 4.0,
                                                        tabs: <Tab>[
                                                          new Tab(
                                                              text: SpotL
                                                                  .of(context)
                                                                  .about()),
                                                          new Tab(
                                                              text: SpotL
                                                                  .of(context)
                                                                  .images()),
                                                          new Tab(
                                                              text: SpotL
                                                                  .of(context)
                                                                  .groups())
                                                        ])))
                                      ],
                              body: _item == null
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
                                                        new InputDecoration(
                                                            hintText:
                                                                SpotL
                                                                    .of(context)
                                                                    .namePh(),
                                                            labelText: SpotL
                                                                .of(context)
                                                                .name()),
                                                    validator: validateName,
                                                    controller: _nameCtrl,
                                                    onSaved: (data) {
                                                      _name = data;
                                                    },
                                                  ),
                                                  new TextFormField(
                                                    key: const Key('about'),
                                                    decoration:
                                                        new InputDecoration(
                                                            hintText:
                                                                SpotL
                                                                    .of(context)
                                                                    .aboutPh(),
                                                            labelText: SpotL
                                                                .of(context)
                                                                .about()),
                                                    controller: _aboutCtrl,
                                                    onSaved: (data) {
                                                      _about = data;
                                                    },
                                                  ),
                                                  new TextFormField(
                                                    key: const Key('location'),
                                                    decoration:
                                                        new InputDecoration(
                                                            hintText:
                                                                SpotL
                                                                    .of(context)
                                                                    .locationPh(),
                                                            labelText: SpotL
                                                                .of(context)
                                                                .location()),
                                                    validator: validateString,
                                                    controller: _locationCtrl,
                                                    onSaved: (data) {
                                                      _location = data;
                                                    },
                                                  ),
                                                  new SwitchListTile(
                                                    title: new Text(SpotL
                                                        .of(context)
                                                        .gift()),
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
                                                    title: new Text(SpotL
                                                        .of(context)
                                                        .private()),
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
                                        _groups != null
                                            ? new Container(
                                                margin:
                                                    const EdgeInsets.all(20.0),
                                                child: getGroups())
                                            : const Center(
                                                child:
                                                    const CircularProgressIndicator()),
                                      ]))))),
                  new Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                        constraints: new BoxConstraints.tightFor(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width),
                        child: new RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            editItem(context);
                          },
                          child: new Text(
                            SpotL.of(context).save().toUpperCase(),
                            style: new TextStyle(
                                color: Theme.of(context).canvasColor),
                          ),
                        )),
                  ),
                ],
              )));
}
