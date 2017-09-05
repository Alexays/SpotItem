import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen(this._groupId);

  final String _groupId;

  @override
  _EditGroupScreenState createState() => new _EditGroupScreenState(_groupId);
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  _EditGroupScreenState(this._groupId);

  String _groupId;
  Group _group;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController nameCtrl;
  TextEditingController aboutCtrl;

  @override
  void initState() {
    Services.groups.getGroup(_groupId).then((data) {
      setState(() {
        _group = new Group(data);
        nameCtrl = new TextEditingController.fromValue(
            new TextEditingValue(text: _group.name));
        aboutCtrl = new TextEditingController.fromValue(
            new TextEditingValue(text: _group.about));
      });
    });
    super.initState();
  }

  Future<Null> editGroup(BuildContext context) async {
    _formKey.currentState.save();
    final dynamic response = await Services.groups.editGroup(_group);
    showSnackBar(context, response['msg']);
    if (response['success']) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: const Text('Edit Group'), actions: <Widget>[
          new Builder(
              builder: (context) => new IconButton(
                  icon: new Column(children: <Widget>[
                    const Icon(Icons.add_box),
                    const Text('Edit')
                  ]),
                  onPressed: () {
                    editGroup(context);
                  }))
        ]),
        body: new Builder(
            builder: (context) => _group == null
                ? const Center(child: const CircularProgressIndicator())
                : new SingleChildScrollView(
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
                                        controller: nameCtrl,
                                        onSaved: (value) {
                                          _group.name = value.trim();
                                        }),
                                    new TextFormField(
                                        key: const Key('about'),
                                        decoration: const InputDecoration(
                                            hintText: 'Enter description',
                                            labelText: 'Description'),
                                        controller: aboutCtrl,
                                        onSaved: (value) {
                                          _group.about = value.trim();
                                        }),
                                  ]))
                            ])))),
      );
}
