import 'dart:async';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/model/user.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  final AuthManager _authManager;
  const EditUserScreen(this._authManager);

  @override
  _EditUserScreenState createState() => new _EditUserScreenState(_authManager);
}

class _EditUserScreenState extends State<EditUserScreen> {
  _EditUserScreenState(this._authManager);

  final AuthManager _authManager;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _name;
  TextEditingController _lastname;
  TextEditingController _email;
  TextEditingController _password;

  User user;
  String password;
  String repeat;

  @override
  void initState() {
    super.initState();
    final User tmp = _authManager.user;
    user = new User(
        tmp.id, tmp.name, tmp.email, tmp.firstname, tmp.avatar, tmp.groups);
    _name = new TextEditingController(text: user.firstname);
    _lastname = new TextEditingController(text: user.name);
    _email = new TextEditingController(text: user.email);
  }

  Future<bool> editUser(BuildContext context) async {
    _formKey.currentState.save();
    if (password != repeat) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: const Text('Password don\t match !')));
      return false;
    }
    final dynamic response = await _authManager.updateUser(user, password);
    Scaffold
        .of(context)
        .showSnackBar(new SnackBar(content: new Text(response['msg'])));
    if (response['success']) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(title: const Text('Edit Profile'), actions: <Widget>[
        new Builder(
            builder: (BuildContext context) => new IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    editUser(context);
                  },
                ))
      ]),
      body: new SingleChildScrollView(
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
                            key: const Key('name'),
                            decoration: const InputDecoration(
                                labelText: 'Firstname',
                                hintText: 'Enter your firstname'),
                            onSaved: (String value) {
                              user.firstname = value;
                            },
                            controller: _name,
                          ),
                          new TextFormField(
                            key: const Key('lastname'),
                            decoration: const InputDecoration(
                                labelText: 'Lastname',
                                hintText: 'Enter your lastname'),
                            onSaved: (String value) {
                              user.name = value;
                            },
                            controller: _lastname,
                          ),
                          new FocusScope(
                            node: new FocusScopeNode(),
                            child: new TextFormField(
                              controller: _email,
                              style: theme.textTheme.subhead.copyWith(
                                color: theme.disabledColor,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                              ),
                            ),
                          ),
                          new TextFormField(
                            key: const Key('password'),
                            decoration: const InputDecoration(
                                labelText: 'Password', hintText: '***********'),
                            onSaved: (String value) {
                              password = value;
                            },
                            obscureText: true,
                          ),
                          new TextFormField(
                            key: const Key('repeat'),
                            decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                hintText: '***********'),
                            onSaved: (String value) {
                              repeat = value;
                            },
                            controller: _password,
                            obscureText: true,
                          ),
                        ],
                      )),
                ],
              ))),
    );
  }
}
