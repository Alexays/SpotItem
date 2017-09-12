import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

/// Add Group screen class
class AddGroupScreen extends StatefulWidget {
  /// Add Group screen initalizer
  const AddGroupScreen();

  @override
  _AddGroupScreenState createState() => new _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String name;
  String about;
  String location;
  List<String> email = <String>[];

  @override
  void initState() {
    super.initState();
  }

  Future<Null> addGroup() async {
    _formKey.currentState.save();
    final Group group = new Group(<String, String>{
      'name': name,
      'about': about,
      'owner': Services.auth.user.id
    });
    final dynamic response = await Services.groups.addGroup(group, email);
    showSnackBar(Services.context, response['msg']);
    if (response['success']) {
      await Navigator
          .of(Services.context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<Null> _addPeople() async {
    final String _email = await Navigator.pushNamed(context, '/contacts');
    if (!email.contains(_email)) {
      setState(() {
        email.add(_email);
      });
    } else {
      showSnackBar(Services.context, 'Already added !');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text('Add Group')),
      body: new Builder(builder: (context) {
        Services.context = context;
        return new Column(children: <Widget>[
          new Expanded(
              child: new SingleChildScrollView(
                  child: new Container(
                      margin: const EdgeInsets.all(20.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Form(
                                key: _formKey,
                                child: new Column(children: <Widget>[
                                  new TextFormField(
                                      key: const Key('name'),
                                      decoration: const InputDecoration(
                                          hintText: 'Enter name',
                                          labelText: 'Name'),
                                      onSaved: (value) {
                                        name = value.trim();
                                      }),
                                  new TextFormField(
                                      key: const Key('about'),
                                      decoration: const InputDecoration(
                                          hintText: 'Enter description',
                                          labelText: 'Description'),
                                      onSaved: (value) {
                                        about = value.trim();
                                      }),
                                  const Divider(),
                                  new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: new List<Widget>.generate(
                                        email.length,
                                        (index) => new Chip(
                                            label: new Text(email[index]),
                                            onDeleted: () {
                                              setState(() {
                                                email.removeAt(index);
                                              });
                                            })),
                                  ),
                                  const Divider(),
                                  new RaisedButton(
                                      child: const Text('Add someone'),
                                      onPressed: () {
                                        _addPeople();
                                      })
                                ]))
                          ])))),
          new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: new ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: 48.0),
              child: new Builder(
                builder: (context) => new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          textTheme: ButtonTextTheme.normal,
                          child: const Text('CANCEL'),
                        ),
                        new RaisedButton(
                          onPressed: () {
                            addGroup();
                          },
                          child: const Text('ADD GROUP'),
                        )
                      ],
                    ),
              ),
            ),
          )
        ]);
      }),
    );
  }
}
