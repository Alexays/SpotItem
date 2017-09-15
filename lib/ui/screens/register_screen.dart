import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';

/// Register screen class
class RegisterScreen extends StatefulWidget {
  /// Register screen initializer
  const RegisterScreen();

  @override
  State createState() => new _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _name;
  TextEditingController _lastname;
  TextEditingController _email;
  TextEditingController _password;

  dynamic user;
  String password;
  String repeat;

  @override
  void initState() {
    super.initState();
    _name = new TextEditingController(text: user['firstname']);
    _lastname = new TextEditingController(text: user['name']);
    _email = new TextEditingController(text: user['email']);
  }

  Future<bool> doRegister(BuildContext context) async {
    final FormState form = _formKey.currentState..save();
    if (password != repeat) {
      showSnackBar(context, 'Password don\'t match !');
      return false;
    }
    if (form.validate()) {
      user['password'] = password;
      final dynamic data = await Services.auth.register(user);
      if (data['success']) {
        Navigator.pushReplacementNamed(context, '/login');
        return true;
      }
      showSnackBar(context, data['msg']);
      return false;
    }
    showSnackBar(context, 'Form must be valid !');
    return false;
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
          body: new SingleChildScrollView(
        child: new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Card(
                child: new Container(
              margin: const EdgeInsets.all(15.0),
              child: new Form(
                  key: _formKey,
                  autovalidate: true,
                  child: new Column(
                    children: <Widget>[
                      new TextFormField(
                        key: const Key('name'),
                        decoration: const InputDecoration(
                            labelText: 'Firstname',
                            hintText: 'Enter your firstname'),
                        onSaved: (value) {
                          user['firstname'] = value;
                        },
                        controller: _name,
                        validator: validateName,
                      ),
                      new TextFormField(
                        key: const Key('lastname'),
                        decoration: const InputDecoration(
                            labelText: 'Lastname',
                            hintText: 'Enter your lastname'),
                        onSaved: (value) {
                          user['name'] = value;
                        },
                        controller: _lastname,
                        validator: validateName,
                      ),
                      new TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                        onSaved: (value) {
                          user['email'] = value;
                        },
                        validator: validateEmail,
                      ),
                      new TextFormField(
                        key: const Key('password'),
                        decoration: const InputDecoration(
                            labelText: 'Password', hintText: '***********'),
                        onSaved: (value) {
                          password = value;
                        },
                        obscureText: true,
                        validator: validatePassword,
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
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new RaisedButton(
                              child: const Text('Have an account ?'),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                            ),
                            const Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                            ),
                            new RaisedButton(
                                child: const Text('Register'),
                                onPressed: () {
                                  doRegister(context);
                                })
                          ]),
                    ],
                  )),
            ))),
      ));
}
