import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

import 'package:spotitem/ui/spot_strings.dart';

/// Add Group screen class
class AddConvScreen extends StatefulWidget {
  /// Add Group screen initalizer
  const AddConvScreen();

  @override
  _AddConvScreenState createState() => new _AddConvScreenState();
}

class _AddConvScreenState extends State<AddConvScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String message;
  String group;

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _addConv(BuildContext context) async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return showSnackBar(context, SpotL.of(context).correctError());
    }
    if (group == null) {
      return showSnackBar(context, 'Please select group');
    }
    final response = await Services.social.addConversation({
      'message': message,
      'group': group,
    });
    if (resValid(context, response)) {
      showSnackBar(context, response.msg);
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Future<Null> _selectGroup(BuildContext context) async {
    await showDialog<Null>(
      context: context,
      child: new SimpleDialog(
          title: new Text(SpotL.of(Services.loc).confirm()),
          children: new List<Widget>.generate(
              Services.groups.groups.length,
              (i) => new ListTile(
                    title: new Text(Services.groups.groups[i].name),
                    onTap: () {
                      group = Services.groups.groups[i].id;
                      Navigator.of(context).pop();
                    },
                  ))),
    );
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
                                              key: const Key('message'),
                                              decoration: new InputDecoration(
                                                  hintText: SpotL
                                                      .of(context)
                                                      .namePh(),
                                                  labelText: SpotL
                                                      .of(Services.loc)
                                                      .name()),
                                              validator: validateString,
                                              onSaved: (value) {
                                                message = value.trim();
                                              }),
                                        ])),
                                    new RaisedButton(
                                      child: const Text('Select group'),
                                      onPressed: () {
                                        _selectGroup(context);
                                      },
                                    )
                                  ])))),
                  new Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                        constraints: new BoxConstraints.tightFor(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width),
                        child: new RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _addConv(context);
                          },
                          child: new Text(
                            SpotL.of(context).addGroup().toUpperCase(),
                            style: new TextStyle(
                                color: Theme.of(context).canvasColor),
                          ),
                        )),
                  ),
                ])),
      );
}
