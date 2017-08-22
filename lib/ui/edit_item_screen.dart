import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/model/item.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/keys.dart';

class EditItemScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  final String _itemId;
  const EditItemScreen(this._authManager, this._itemsManager, this._itemId);

  @override
  _EditItemScreenState createState() => new _EditItemScreenState(_itemId);
}

class _EditItemScreenState extends State<EditItemScreen> {
  _EditItemScreenState(this._itemId);

  final String _itemId;

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget._itemsManager.getItem(_itemId).then((Item data) {
      setState(() {
        item = data;
        if (item != null) {
          name = item.name;
          about = item.about;
          location = item.location;
          _name = new TextEditingController(text: name);
          _about = new TextEditingController(text: about);
          _location = new TextEditingController(text: location);
          gift = item.tracks.contains('gift');
          private = item.tracks.contains('private');
          _loading = false;
        }
      });
    });
  }

  Future<bool> getImage() async {
    final File _fileName = await ImagePicker.pickImage();
    if (_fileName != null) {
      setState(() {
        imageFile.add(_fileName);
        _fileName.readAsBytes().then((List<int> data) {
          images.add(
              'data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(data)}');
        });
      });
      return true;
    }
    return false;
  }

  Widget getImageGrid() {
    if ((item.images.length + imageFile.length) < 1) {
      return new Container();
    }
    return new GridView.count(
      primary: false,
      crossAxisCount: (item.images.length + imageFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          (item.images.length + imageFile.length), (int index) {
        if (index < item.images.length) {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.network('$API_IMG_URL${item.images[index]}'),
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

  Future<bool> editItem(BuildContext context) async {
    final List<String> finalImages = <String>[];
    final List<String> tracks = <String>[];

    _formKey.currentState.save();
    if (gift) {
      tracks.add('gift');
    }
    if (private) {
      tracks.add('private');
    }
    item.images.forEach((String f) => finalImages.add);
    images.forEach((String f) => finalImages.add);
    if (widget._authManager.user != null &&
        widget._authManager.user.id != null) {
      final dynamic response = await widget._itemsManager.editItem(
          item.id,
          name,
          about,
          widget._authManager.user.id,
          widget._itemsManager.location['latitude'].toString(),
          widget._itemsManager.location['longitude'].toString(),
          finalImages,
          location,
          tracks);
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(response['msg'])));
      if (response['success']) {
        widget._itemsManager.getItems(true);
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      }
      return false;
    }
    Scaffold
        .of(context)
        .showSnackBar(new SnackBar(content: const Text('Not Connected')));
    return false;
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
            title: new Text(item != null ? 'Edit: ${item.name}' : 'Loading...'),
            actions: <Widget>[
              new Builder(
                  builder: (BuildContext context) => new IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          editItem(context);
                        },
                      ))
            ]),
        body: _loading
            ? new Center(child: const CircularProgressIndicator())
            : new SingleChildScrollView(
                child: new Container(
                    margin: const EdgeInsets.all(20.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Form(
                            key: _formKey,
                            child: new Column(
                              children: <Widget>[
                                new TextFormField(
                                  key: const Key('name'),
                                  decoration: const InputDecoration.collapsed(
                                      hintText: 'Name'),
                                  onSaved: (String value) {
                                    name = value;
                                  },
                                  controller: _name,
                                ),
                                new TextFormField(
                                  key: const Key('about'),
                                  decoration: const InputDecoration.collapsed(
                                      hintText: 'Description'),
                                  onSaved: (String value) {
                                    about = value;
                                  },
                                  controller: _about,
                                ),
                                new TextFormField(
                                  key: const Key('location'),
                                  decoration: const InputDecoration.collapsed(
                                      hintText: 'Location'),
                                  onSaved: (String value) {
                                    location = value;
                                  },
                                  controller: _location,
                                ),
                                new SwitchListTile(
                                  title: const Text('Donated Item'),
                                  value: gift,
                                  onChanged: (bool value) {
                                    setState(() {
                                      gift = value;
                                    });
                                  },
                                  secondary: const Icon(Icons.card_giftcard),
                                ),
                                new SwitchListTile(
                                  title: const Text('Private Item'),
                                  value: private,
                                  onChanged: (bool value) {
                                    setState(() {
                                      private = value;
                                    });
                                  },
                                  secondary: const Icon(Icons.lock),
                                ),
                              ],
                            )),
                        new Container(
                          height: 300.0,
                          width: 300.0,
                          child: getImageGrid(),
                        ),
                      ],
                    ))),
        floatingActionButton: new FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: const Icon(Icons.add_a_photo),
        ),
      );
}
