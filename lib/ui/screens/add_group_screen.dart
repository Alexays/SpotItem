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

  Future<Null> addGroup(BuildContext context) async {
    _formKey.currentState.save();
    final Group group = new Group(<String, String>{
      'name': name,
      'about': about,
      'owner': Services.auth.user.id
    });
    final dynamic response = await Services.groups.addGroup(group, email);
    showSnackBar(context, response['msg']);
    if (response['success']) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<Null> _addPeople() async {
    Navigator.pushNamed(context, '/contacts').then((data) {
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    Services.context = context;
    return new Scaffold(
      appBar: new AppBar(title: const Text('Add Group'), actions: <Widget>[
        new Builder(
            builder: (context) => new IconButton(
                icon: new Column(children: <Widget>[
                  const Icon(Icons.add_box),
                  const Text('Add')
                ]),
                onPressed: () {
                  addGroup(context);
                }))
      ]),
      body: new Builder(
          builder: (context) => new SingleChildScrollView(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
