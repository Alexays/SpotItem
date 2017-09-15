import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/user.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';

/// Edit user screen class
class EditUserScreen extends StatefulWidget {
  /// Edit user screen initializer
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
    final User tmp = Services.auth.user;
    user = new User.from(tmp);
    _name = new TextEditingController(text: user.firstname);
    _lastname = new TextEditingController(text: user.name);
    _email = new TextEditingController(text: user.email);
    super.initState();
  }

  Future<bool> editUser() async {
    _formKey.currentState.save();
    if (password != repeat) {
      showSnackBar(Services.context, 'Password don\t match !');
      return false;
    }
    final dynamic res = await Services.users.updateUser(user, password);
    showSnackBar(Services.context, res['msg']);
    if (res['success']) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: const Text('Edit Profile')),
        body: new Builder(builder: (context) {
          Services.context = context;
          final ThemeData theme = Theme.of(context);
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
                                      validator: validateString,
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
                                      validator: validateString,
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
                                        validator: validateEmail,
                                      ),
                                    ),
                                    new TextFormField(
                                      key: const Key('password'),
                                      decoration: const InputDecoration(
                                          labelText: 'Password',
                                          hintText: '***********'),
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
                        )))),
            new Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: new ConstrainedBox(
                constraints: const BoxConstraints.tightFor(height: 48.0),
                child: new Center(
                    child: new RaisedButton(
                  onPressed: () {
                    editUser();
                  },
                  child: const Text('SAVE'),
                )),
              ),
            )
          ]);
        }),
      );
}
