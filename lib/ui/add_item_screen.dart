import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
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

class _AddItemScreenState extends State<AddItemScreen> {
  _AddItemScreenState(this._authManager, this._itemsManager);
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  List<File> imageFile = <File>[];

  String name;
  String about;
  String location;
  bool gift = false;
  bool private = false;
  List<String> images = <String>[];

  @override
  void initState() {
    super.initState();
    imageFile.clear();
    images.clear();
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
      return const Center();
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

  Future<bool> addItem(BuildContext context) async {
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
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(response['msg'])));
      if (response['success']) {
        await _itemsManager.getItems(force: true);
        await Navigator.pushReplacementNamed(context, '/home');
        return true;
      }
      return false;
    } else {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: const Text('Not Connected')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: const Text('Add Item'),
          actions: <Widget>[
            new Builder(
                builder: (context) => new IconButton(
                      icon: new Column(
                        children: <Widget>[
                          const Icon(Icons.add_box),
                          const Text('Add')
                        ],
                      ),
                      onPressed: () {
                        addItem(context);
                      },
                    ))
          ],
        ),
        body: new SingleChildScrollView(
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
                        decoration:
                            const InputDecoration.collapsed(hintText: 'Name'),
                        autofocus: true,
                        onSaved: (value) {
                          name = value;
                        },
                      ),
                      new TextFormField(
                        key: const Key('about'),
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Description'),
                        onSaved: (value) {
                          about = value;
                        },
                      ),
                      new TextFormField(
                        key: const Key('location'),
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Location'),
                        onSaved: (value) {
                          location = value;
                        },
                      ),
                      new SwitchListTile(
                        title: const Text('Donated Item'),
                        value: gift,
                        onChanged: (value) {
                          setState(() {
                            gift = value;
                          });
                        },
                        secondary: const Icon(Icons.card_giftcard),
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
                      )
                    ],
                  )),
              new Container(
                height: 300.0,
                width: 300.0,
                child: getImageGrid(),
              ),
            ],
          ),
        )),
        floatingActionButton: new FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: const Icon(Icons.add_a_photo),
        ),
      );
}
