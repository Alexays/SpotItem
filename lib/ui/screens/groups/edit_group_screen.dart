import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Edit group screen class
class EditGroupScreen extends StatefulWidget {
  /// Edit group screen initalizer
  const EditGroupScreen({Key key, this.groupId, this.group})
      : assert(groupId != null || group != null),
        super(key: key);

  /// Group id
  final String groupId;

  /// Group data
  final Group group;

  @override
  _EditGroupScreenState createState() =>
      new _EditGroupScreenState(groupId, group);
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  _EditGroupScreenState(this._groupId, this._group);

  String _groupId;
  Group _group;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController nameCtrl;
  TextEditingController aboutCtrl;

  @override
  void initState() {
    if (_group == null) {
      Services.groups.getGroup(_groupId).then((res) {
        if (!mounted) {
          return;
        }
        setState(() {
          _group = new Group(res.data);
          _initForm();
        });
      });
    } else {
      _initForm();
    }
    super.initState();
  }

  void _initForm() {
    setState(() {
      nameCtrl = new TextEditingController.fromValue(
          new TextEditingValue(text: _group.name));
      aboutCtrl = new TextEditingController.fromValue(
          new TextEditingValue(text: _group.about));
    });
  }

  Future<Null> editGroup(BuildContext context) async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return showSnackBar(context, SpotL.of(context).correctError());
    }
    final response = await Services.groups.editGroup(_group);
    if (resValid(context, response)) {
      showSnackBar(context, response.msg);
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).editGroup())),
      body: new Builder(
          builder: (context) => _group == null
              ? const Center(child: const CircularProgressIndicator())
              : new Column(
                  children: <Widget>[
                    new Expanded(
                        child: new SingleChildScrollView(
                            child: new Container(
                                margin: const EdgeInsets.all(20.0),
                                child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    labelText: SpotL
                                                        .of(context)
                                                        .name()),
                                                controller: nameCtrl,
                                                validator: validateName,
                                                onSaved: (value) {
                                                  _group.name = value.trim();
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
                                                controller: aboutCtrl,
                                                onSaved: (value) {
                                                  _group.about = value.trim();
                                                }),
                                          ]))
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
                            onPressed: () async {
                              await editGroup(context);
                            },
                            child: new Text(
                              SpotL.of(context).save().toUpperCase(),
                              style: new TextStyle(
                                  color: Theme.of(context).canvasColor),
                            ),
                          )),
                    ),
                  ],
                )));
}