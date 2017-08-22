import 'dart:async';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/model/group.dart';
import 'package:spotitems/interactor/utils.dart';
import 'package:flutter/material.dart';

class AddGroupScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  AddGroupScreen(this._authManager, this._itemsManager);

  @override
  _AddGroupScreenState createState() =>
      new _AddGroupScreenState(_authManager, _itemsManager);
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  _AddGroupScreenState(this._authManager, this._itemsManager);
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEmail = new GlobalKey<FormState>();

  String name;
  String about;
  String location;
  List<String> email = <String>[];

  @override
  void initState() {
    super.initState();
  }

  Future<bool> addGroup(BuildContext context) async {
    final FormState form = _formKey.currentState;
    form.save();
    Group group = new Group(null, name, about, null, _authManager.user.id);
    final dynamic response = await _authManager.addGroup(group, email);
    Scaffold
        .of(context)
        .showSnackBar(new SnackBar(content: new Text(response['msg'])));
    if (response['success']) {
      Navigator.pushReplacementNamed(context, '/home');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Add Group'),
        actions: <Widget>[
          new Builder(builder: (BuildContext context) {
            return new IconButton(
              icon: new Column(
                children: <Widget>[const Icon(Icons.add_box), new Text("Add")],
              ),
              onPressed: () {
                addGroup(context);
              },
            );
          })
        ],
      ),
      body: new Builder(builder: (BuildContext context) {
        return new SingleChildScrollView(
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
                      new Divider(),
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: new List<Widget>.generate(email.length,
                            (int index) {
                          return new Flexible(
                              child: new Chip(
                            label: new Text(email[index]),
                            onDeleted: () {
                              setState(() {
                                email.removeAt(index);
                              });
                            },
                          ));
                        }),
                      ),
                      new Divider(),
                      new RaisedButton(
                        child: const Text("Add someone"),
                        onPressed: () {
                          String _email;
                          showDialog<Null>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            child: new AlertDialog(
                              title: new Text('Add someone'),
                              content: new SingleChildScrollView(
                                  child: new Form(
                                autovalidate: true,
                                key: _formKeyEmail,
                                child: new ListBody(
                                  children: <Widget>[
                                    new Text('Enter email of user.'),
                                    new TextFormField(
                                      key: new Key('email'),
                                      decoration: new InputDecoration.collapsed(
                                          hintText: 'ex: john.do@exemple.com'),
                                      onSaved: (String value) {
                                        _email = value;
                                      },
                                      validator: validateEmail,
                                    ),
                                  ],
                                ),
                              )),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text('Add'),
                                  onPressed: () {
                                    final FormState form =
                                        _formKeyEmail.currentState;
                                    form.save();
                                    if (_email != null &&
                                        emailExp.hasMatch(_email)) {
                                      email.add(_email);
                                      Navigator.of(context).pop();
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          new SnackBar(
                                              content: new Text(
                                                  "Enter valid email")));
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  )),
            ],
          ),
        ));
      }),
    );
  }
}
