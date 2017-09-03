import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen();

  @override
  _AddGroupScreenState createState() => new _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
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

  Future<Null> addGroup(BuildContext context) async {
    _formKey.currentState.save();
    final Group group =
        new Group(null, name, about, null, Services.auth.user.id);
    final dynamic response = await Services.groups.addGroup(group, email);
    showSnackBar(context, response['msg']);
    if (response['success']) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _addPeople() {
    String _email;
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        child: new AlertDialog(
            title: const Text('Add someone'),
            content: new SingleChildScrollView(
                child: new Form(
                    autovalidate: true,
                    key: _formKeyEmail,
                    child: new ListBody(children: <Widget>[
                      const Text('Enter email of user.'),
                      new TextFormField(
                        key: const Key('email'),
                        decoration: const InputDecoration.collapsed(
                            hintText: 'ex: john.do@exemple.com'),
                        onSaved: (value) {
                          _email = value.trim();
                        },
                        validator: validateEmail,
                      )
                    ]))),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              new FlatButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _formKeyEmail.currentState.save();
                    if (_email != null && emailExp.hasMatch(_email)) {
                      email.add(_email);
                      Navigator.of(context).pop();
                    } else {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                          content: const Text('Enter valid email')));
                    }
                  }),
            ]));
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
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
