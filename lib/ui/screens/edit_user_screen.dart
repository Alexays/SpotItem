import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/user.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen();

  @override
  _EditUserScreenState createState() => new _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
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
    final User tmp = Services.authManager.user;
    user = new User(
        tmp.id, tmp.name, tmp.email, tmp.firstname, tmp.avatar, tmp.groups);
    _name = new TextEditingController(text: user.firstname);
    _lastname = new TextEditingController(text: user.name);
    _email = new TextEditingController(text: user.email);
    super.initState();
  }

  Future<bool> editUser(BuildContext context) async {
    _formKey.currentState.save();
    if (password != repeat) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: const Text('Password don\t match !')));
      return false;
    }
    final dynamic response =
        await Services.authManager.updateUser(user, password);
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
            builder: (context) => new IconButton(
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
                            onSaved: (value) {
                              user.firstname = value.trim();
                            },
                            controller: _name,
                          ),
                          new TextFormField(
                            key: const Key('lastname'),
                            decoration: const InputDecoration(
                                labelText: 'Lastname',
                                hintText: 'Enter your lastname'),
                            onSaved: (value) {
                              user.name = value.trim();
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
                            onSaved: (value) {
                              password = value;
                            },
                            obscureText: true,
                          ),
                          new TextFormField(
                            key: const Key('repeat'),
                            decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                hintText: '***********'),
                            onSaved: (value) {
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
