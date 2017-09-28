import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

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

  dynamic user = {};
  String password;
  String repeat;

  @override
  void initState() {
    super.initState();
    _name = new TextEditingController(text: user['firstname']);
    _lastname = new TextEditingController(text: user['name']);
    _email = new TextEditingController(text: user['email']);
  }

  Future<Null> doRegister(BuildContext context) async {
    final form = _formKey.currentState..save();
    if (password != repeat) {
      return showSnackBar(context, SpotL.of(context).passwordError());
    }
    if (form.validate()) {
      user['password'] = password;
      final dynamic data = await Services.auth.register(user);
      if (data['success']) {
        return Navigator.pushReplacementNamed(context, '/');
      }
      return showSnackBar(context, data['msg']);
    }
    showSnackBar(context, SpotL.of(context).correctError());
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      body: new Builder(
          builder: (context) => new SingleChildScrollView(
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
                                decoration: new InputDecoration(
                                    labelText: SpotL.of(context).firstname(),
                                    hintText: SpotL.of(context).firstnamePh()),
                                onSaved: (value) {
                                  user['firstname'] = value;
                                },
                                controller: _name,
                                validator: validateName,
                              ),
                              new TextFormField(
                                key: const Key('lastname'),
                                decoration: new InputDecoration(
                                    labelText: SpotL.of(context).lastname(), hintText: SpotL.of(context).lastnamePh()),
                                onSaved: (value) {
                                  user['name'] = value;
                                },
                                controller: _lastname,
                                validator: validateName,
                              ),
                              new TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: new InputDecoration(
                                  labelText: SpotL.of(context).email(),
                                  hintText: SpotL.of(context).emailPh(),
                                ),
                                onSaved: (value) {
                                  user['email'] = value;
                                },
                                validator: validateEmail,
                              ),
                              new TextFormField(
                                key: const Key('password'),
                                decoration: new InputDecoration(
                                  labelText: SpotL.of(context).password(),
                                  hintText: SpotL.of(context).passwordPh(),
                                ),
                                onSaved: (value) {
                                  password = value;
                                },
                                obscureText: true,
                                validator: validatePassword,
                              ),
                              new TextFormField(
                                key: const Key('repeat'),
                                decoration: new InputDecoration(
                                  labelText: SpotL.of(context).passwordRepeat(),
                                  hintText: SpotL.of(context).passwordRepeatPh(),
                                ),
                                onSaved: (value) {
                                  repeat = value;
                                },
                                controller: _password,
                                obscureText: true,
                              ),
                              new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                new RaisedButton(
                                  child: new Text(SpotL.of(context).haveAccount()),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/');
                                  },
                                ),
                                const Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                ),
                                new RaisedButton(
                                    child: new Text(SpotL.of(context).register()),
                                    onPressed: () {
                                      doRegister(context);
                                    })
                              ]),
                            ],
                          )),
                    ))),
              )));
}
