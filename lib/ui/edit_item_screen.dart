import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitems/interactor/services/services.dart';
import 'package:spotitems/interactor/utils.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/model/group.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/keys.dart';

class EditItemScreen extends StatefulWidget {
  final String _itemId;
  const EditItemScreen(this._itemId);

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

  TextEditingController _name;
  TextEditingController _about;
  TextEditingController _location;

  List<File> imageFile = <File>[];

  String name;
  String about;
  String location;
  bool gift = false;
  bool private = false;
  List<String> images = <String>[];

  Item item;
  List<String> _groups;
  List<bool> _checked;

  List<Group> _myGroups;

  bool _loading = true;

  @override
  void initState() {
    Services.itemsManager.getItem(_itemId).then((data) {
      setState(() {
        item = data;
        if (item != null) {
          name = item.name;
          about = item.about;
          location = item.location;
          _name = new TextEditingController(text: name);
          _about = new TextEditingController(text: about);
          _location = new TextEditingController(text: location);
          _groups = item.groups;
          gift = item.tracks.contains('gift');
          private = item.tracks.contains('private');
          Services.authManager
              .getGroups(Services.authManager.user.id)
              .then((data) {
            _myGroups = data;
            _checked = new List<bool>.generate(_myGroups.length, (index) {
              if (_groups != null && _groups.contains(_myGroups[index].id)) {
                return true;
              }
              return false;
            });
            setState(() {
              _loading = false;
            });
          });
        }
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
        imageFile.add(_fileName);
        _fileName.readAsBytes().then((data) {
          images.add(
              'data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(data)}');
        });
      });
    }
  }

  Widget getImageGrid() {
    if ((item.images.length + imageFile.length) < 1) {
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
      crossAxisCount: (item.images.length + imageFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          (item.images.length + imageFile.length), (index) {
        if (index < item.images.length) {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.network('$apiImgUrl${item.images[index]}'),
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
                              item.images.removeAt(index);
                            });
                          },
                        ),
                      ])),
            ],
          ));
        } else {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.file(imageFile[index - item.images.length]),
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
          ));
        }
      }),
    );
  }

  Future<Null> editItem(BuildContext context) async {
    final List<String> finalImages = <String>[];
    final List<String> tracks = <String>[];
    final List<String> groups = <String>[];
    _formKey.currentState.save();
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      child: new AlertDialog(
        title: const Text('Loading...'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              const Center(child: const CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
    int i = 0;
    _checked.forEach((f) {
      if (f) {
        groups.add(_myGroups[i].id);
      }
      i++;
    });
    if (gift) {
      tracks.add('gift');
    }
    if (private) {
      tracks.add('private');
    }
    item.images.forEach((f) => finalImages.add(f));
    images.forEach((f) => finalImages.add(f));
    if (Services.authManager.user != null &&
        Services.authManager.user.id != null) {
      final dynamic response = await Services.itemsManager.editItem(
          item.id,
          name,
          about,
          Services.authManager.user.id,
          Services.itemsManager.location['latitude'].toString(),
          Services.itemsManager.location['longitude'].toString(),
          finalImages,
          location,
          tracks,
          groups);
      Navigator.of(context).pop();
      showSnackBar(context, response['msg']);
      if (response['success']) {
        await Services.itemsManager.getItems(force: true);
        await Navigator
            .of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
    showSnackBar(context, 'Not Connected');
  }

  Widget getGroups() {
    if (_loading) {
      return const Center(child: const CircularProgressIndicator());
    }
    return new Column(
      children: new List<Widget>.generate(
          _myGroups.length,
          (index) => new CheckboxListTile(
                title: new Text(_myGroups[index].name),
                value: _checked[index] == true,
                onChanged: (value) {
                  setState(() {
                    _checked[index] = value;
                  });
                },
                secondary: const Icon(Icons.people),
              )),
    );
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
                              title: new Text(item != null
                                  ? 'Edit: ${item.name}'
                                  : 'Loading...'),
                              actions: <Widget>[
                                new Builder(
                                    builder: (context) => new IconButton(
                                        icon: new Column(children: <Widget>[
                                          const Icon(Icons.save),
                                          const Text('Save')
                                        ]),
                                        onPressed: () {
                                          editItem(context);
                                        }))
                              ],
                              bottom: new TabBar(tabs: <Tab>[
                                const Tab(text: 'Informations'),
                                const Tab(text: 'Images'),
                                const Tab(text: 'Groups')
                              ])))
                    ],
                body: _loading
                    ? const Center(child: const CircularProgressIndicator())
                    : new Form(
                        key: _formKey,
                        child: new TabBarView(children: <Widget>[
                          new Container(
                              margin: const EdgeInsets.all(20.0),
                              child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new TextFormField(
                                      key: const Key('name'),
                                      decoration: const InputDecoration(
                                          hintText: 'Ex: Pencil',
                                          labelText: 'Name'),
                                      onSaved: (value) {
                                        name = value.trim();
                                      },
                                      controller: _name,
                                    ),
                                    new TextFormField(
                                      key: const Key('about'),
                                      decoration: const InputDecoration(
                                          hintText: 'Ex: It\'s a pencil !',
                                          labelText: 'Description'),
                                      onSaved: (value) {
                                        about = value.trim();
                                      },
                                      controller: _about,
                                    ),
                                    new TextFormField(
                                      key: const Key('location'),
                                      decoration: const InputDecoration(
                                          hintText: 'Ex: Nantes',
                                          labelText: 'Location'),
                                      onSaved: (value) {
                                        location = value.trim();
                                      },
                                      controller: _location,
                                    ),
                                    new SwitchListTile(
                                      title: const Text('Donated Item'),
                                      value: gift,
                                      onChanged: (value) {
                                        setState(() {
                                          gift = value;
                                        });
                                      },
                                      secondary:
                                          const Icon(Icons.card_giftcard),
                                    ),
                                    new SwitchListTile(
                                      title: const Text('Private Item'),
                                      value: private,
                                      onChanged: (value) {
                                        setState(() {
                                          private = value;
                                        });
                                      },
                                      secondary: const Icon(Icons.lock),
                                    ),
                                  ])),
                          new Container(
                              margin: const EdgeInsets.all(20.0),
                              child: getImageGrid()),
                          new Container(
                              margin: const EdgeInsets.all(20.0),
                              child: getGroups()),
                        ])))),
        floatingActionButton: new FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: const Icon(Icons.add_a_photo),
        ),
      );
}
