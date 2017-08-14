import 'dart:async';
import 'dart:io';
import 'dart:convert';

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
  List<File> _imageFile = [];

  String name;
  String about;
  String location;
  bool isGift = false;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    _imageFile.clear();
    images.clear();
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
    if (_imageFile == null || _imageFile.length < 1) return new Center();
    return new GridView.count(
      crossAxisCount: _imageFile.length,
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(_imageFile.length, (index) {
        return new GridTile(
            child: new Stack(
          children: <Widget>[
            new Image.file(_imageFile[index]),
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
      }),
    );
  }

  addItem(BuildContext context) async {
    final FormState form = _formKey.currentState;
    form.save();
    List<String> tracks = [];
    if (isGift) tracks.add('gift');
    if (_authManager.user != null && _authManager.user.id != null) {
      var response = await _itemsManager.addItem(
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
      appBar: new AppBar(title: new Text('Add Item')),
      body: new Builder(
        builder: (BuildContext context) {
          return new Container(
              margin: const EdgeInsets.all(20.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    flex: _imageFile.length > 0 ? 1 : 0,
                    child: getImageGrid(),
                  ),
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
                            decoration: new InputDecoration.collapsed(
                                hintText: 'Location'),
                            onSaved: (String value) {
                              location = value;
                            },
                          ),
                          new CheckboxListTile(
                              key: new Key('gift'),
                              title: new Text('Is a Gift ?'),
                              value: isGift,
                              onChanged: (bool value) {
                                setState(() {
                                  isGift = value;
                                });
                              }),
                          new RaisedButton(
                              child: new Text('Add'),
                              onPressed: () {
                                addItem(context);
                              })
                        ],
                      )),
                ],
              ));
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
