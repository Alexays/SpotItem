import 'dart:async';
import 'dart:io';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  final AuthManager _authManager;
  AddItemScreen(this._authManager);

  @override
  _AddItemScreenState createState() => new _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final AuthManager _authManager;
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();
  List<File> _imageFile = [];

  @override
  void initState() {
    super.initState();
    _imageFile.clear();
  }

  getImage() async {
    var _fileName = await ImagePicker.pickImage();
    setState(() {
      _imageFile.add(_fileName);
    });
  }

  Widget getImageGrid() {
    if (_imageFile == null || _imageFile.length < 1)
      return new Center(child: new Text("No Images"));
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
                right: 0.0,
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
                          });
                        },
                      ),
                    ])),
          ],
        ));
      }),
    );
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
                      child: new Column(
                    children: <Widget>[
                      new TextFormField(
                        key: new Key('name'),
                        decoration:
                            new InputDecoration.collapsed(hintText: "Name"),
                        autofocus: true,
                        controller: _usernameController,
                      ),
                      new TextFormField(
                        decoration: new InputDecoration.collapsed(
                            hintText: 'Description'),
                        controller: _passwordController,
                      ),
                      new RaisedButton(
                          child: new Text('Add'),
                          onPressed: () {
                            Scaffold.of(context).showSnackBar(
                                new SnackBar(content: new Text("test")));
                          })
                    ],
                  ))
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
