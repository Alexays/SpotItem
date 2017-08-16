import 'dart:io';
import 'dart:convert';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/model/item.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EditItemScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  final String _itemId;
  EditItemScreen(this._authManager, this._itemsManager, this._itemId);

  @override
  _EditItemScreenState createState() =>
      new _EditItemScreenState(_authManager, _itemsManager, _itemId);
}

class _EditItemScreenState extends State<EditItemScreen> {
  _EditItemScreenState(this._authManager, this._itemsManager, this._itemId);

  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  final String _itemId;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _name;
  TextEditingController _about;
  TextEditingController _location;

  List<File> _imageFile = [];

  String name;
  String about;
  String location;
  bool gift = false;
  bool private = false;
  List<String> images = [];

  Item item;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _itemsManager.getItem(_itemId).then((data) {
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

  getImage() async {
    var _fileName = await ImagePicker.pickImage();
    setState(() {
      _imageFile.add(_fileName);
      _fileName.readAsBytes().then((data) {
        images.add('data:image/' +
            _fileName.path.split('.').last +
            ';base64,' +
            BASE64.encode(data));
      });
    });
  }

  Widget getImageGrid() {
    if ((item.images.length + _imageFile.length) < 1) return new Center();
    return new GridView.count(
      primary: false,
      crossAxisCount: (item.images.length + _imageFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          (item.images.length + _imageFile.length), (index) {
        if (index < item.images.length) {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.network(item.images[index]),
              new Positioned(
                  top: 5.0,
                  left: 5.0,
                  child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new IconButton(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          icon: new Icon(Icons.delete),
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
              new Image.file(_imageFile[index - item.images.length]),
              new Positioned(
                  top: 5.0,
                  left: 5.0,
                  child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new IconButton(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          icon: new Icon(Icons.delete),
                          tooltip: 'Delete this image',
                          onPressed: () {
                            setState(() {
                              _imageFile.removeAt(index);
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

  editItem(BuildContext context) async {
    final FormState form = _formKey.currentState;
    form.save();
    List<String> tracks = [];
    if (gift) tracks.add('gift');
    if (private) tracks.add('private');
    List<String> finalImages = [];
    item.images.forEach((f) => finalImages.add(f));
    images.forEach((f) => finalImages.add(f));
    if (_authManager.user != null && _authManager.user.id != null) {
      var response = await _itemsManager.editItem(
          item.id,
          name,
          about,
          _authManager.user.id,
          _itemsManager.location['latitude'].toString(),
          _itemsManager.location['longitude'].toString(),
          finalImages,
          location,
          tracks);
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(response['msg'])));
      if (response['success']) {
        _itemsManager.getItems(true);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Not Connected")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(item != null ? 'Edit: ' + item.name : 'Loading...'),
          actions: <Widget>[
            new Builder(builder: (BuildContext context) {
              return new IconButton(
                icon: new Icon(Icons.save),
                onPressed: () {
                  editItem(context);
                },
              );
            })
          ]),
      body: _loading
          ? new Center(child: new CircularProgressIndicator())
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
                                key: new Key('name'),
                                decoration: new InputDecoration.collapsed(
                                    hintText: "Name"),
                                onSaved: (String value) {
                                  name = value;
                                },
                                controller: _name,
                              ),
                              new TextFormField(
                                key: new Key('about'),
                                decoration: new InputDecoration.collapsed(
                                    hintText: 'Description'),
                                onSaved: (String value) {
                                  about = value;
                                },
                                controller: _about,
                              ),
                              new TextFormField(
                                key: new Key('location'),
                                decoration: new InputDecoration.collapsed(
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
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
