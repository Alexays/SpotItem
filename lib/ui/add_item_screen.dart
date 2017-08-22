import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  AddItemScreen(this._authManager, this._itemsManager);

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
    File _fileName = await ImagePicker.pickImage();
    setState(() {
      imageFile.add(_fileName);
      _fileName.readAsBytes().then((List<int> data) {
        images.add('data:image/' +
            _fileName.path.split('.').last +
            ';base64,' +
            BASE64.encode(data));
      });
    });
    return true;
  }

  Widget getImageGrid() {
    if (imageFile == null || imageFile.length < 1) return new Center();
    return new GridView.count(
      primary: false,
      crossAxisCount: imageFile.length,
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(imageFile.length, (int index) {
        return new GridTile(
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
                        icon: new Icon(Icons.delete),
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
      }),
    );
  }

  Future<bool> addItem(BuildContext context) async {
    final FormState form = _formKey.currentState;
    form.save();
    List<String> tracks = <String>[];
    if (gift) tracks.add('gift');
    if (private) tracks.add('private');
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
        _itemsManager.getItems(true);
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      }
      return false;
    } else {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Not Connected")));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Add Item'),
        actions: <Widget>[
          new Builder(builder: (BuildContext context) {
            return new IconButton(
              icon: new Column(
                children: <Widget>[new Icon(Icons.add_box), new Text("Add")],
              ),
              onPressed: () {
                addItem(context);
              },
            );
          })
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
                      key: new Key('name'),
                      decoration:
                          new InputDecoration.collapsed(hintText: "Name"),
                      autofocus: true,
                      onSaved: (String value) {
                        name = value;
                      },
                    ),
                    new TextFormField(
                      key: new Key('about'),
                      decoration: new InputDecoration.collapsed(
                          hintText: 'Description'),
                      onSaved: (String value) {
                        about = value;
                      },
                    ),
                    new TextFormField(
                      key: new Key('location'),
                      decoration:
                          new InputDecoration.collapsed(hintText: 'Location'),
                      onSaved: (String value) {
                        location = value;
                      },
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
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
