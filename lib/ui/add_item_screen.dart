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
  File _imageFile;

  getImage() async {
    var _fileName = await ImagePicker.pickImage();
    setState(() {
      _imageFile = _fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Add Item')),
      body: new Builder(
        builder: (BuildContext context) {
          return new Container(
              margin: const EdgeInsets.all(20.0),
              child: new Form(
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      key: new Key('name'),
                      decoration:
                          new InputDecoration.collapsed(hintText: "name"),
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
                ),
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
