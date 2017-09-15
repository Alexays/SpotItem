import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

import 'package:spotitem/ui/spot_strings.dart';

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
    final Group group = new Group(
        {'name': name, 'about': about, 'owner': Services.auth.user.id});
    final dynamic response = await Services.groups.addGroup(group, email);
    showSnackBar(context, response['msg']);
    if (response['success']) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<Null> _addPeople(BuildContext context) async {
    final String _email = await Navigator.pushNamed(context, '/contacts');
    if (_email == null) {
      return;
    }
    if (!email.contains(_email)) {
      setState(() {
        email.add(_email);
      });
    } else {
      showSnackBar(context, SpotL.of(context).alreadyAdded());
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).addGroup())),
        body: new Builder(
            builder: (context) => new Column(children: <Widget>[
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
                                              decoration: new InputDecoration(
                                                  hintText: SpotL
                                                      .of(context)
                                                      .namePh(),
                                                  labelText:
                                                      SpotL.of(context).name()),
                                              onSaved: (value) {
                                                name = value.trim();
                                              }),
                                          new TextFormField(
                                              key: const Key('about'),
                                              decoration: new InputDecoration(
                                                  hintText: SpotL
                                                      .of(context)
                                                      .aboutPh(),
                                                  labelText: SpotL
                                                      .of(context)
                                                      .about()),
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
                                                    label:
                                                        new Text(email[index]),
                                                    onDeleted: () {
                                                      setState(() {
                                                        email.removeAt(index);
                                                      });
                                                    })),
                                          ),
                                          const Divider(),
                                          new RaisedButton(
                                              child: new Text(SpotL
                                                  .of(context)
                                                  .addSomeone()),
                                              onPressed: () {
                                                _addPeople(context);
                                              })
                                        ]))
                                  ])))),
                  new Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 48.0),
                      child: new Center(
                          child: new RaisedButton(
                        onPressed: () {
                          addGroup(context);
                        },
                        child: new Text(
                            SpotL.of(context).addGroup().toUpperCase()),
                      )),
                    ),
                  )
                ])),
      );
}
