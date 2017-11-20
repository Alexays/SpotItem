import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Register screen class
class RegisterScreen extends StatelessWidget {
  /// It's constructor
  RegisterScreen();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _name = new TextEditingController();
  final TextEditingController _lastname = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final TextEditingController _repeat = new TextEditingController();

  Future<Null> _doRegister(BuildContext context) async {
    final form = _formKey.currentState;
    if (_password.text != _repeat.text) {
      showSnackBar(context, SpotL.of(context).passwordError);
      return;
    }
    if (!form.validate()) {
      showSnackBar(context, SpotL.of(context).correctError);
      return;
    }
    final res = await Services.auth.register({
      'firstname': _name.text,
      'name': _lastname.text,
      'email': _email.text,
      'password': _password.text,
    });
    if (!resValid(context, res)) {
      return;
    }
    await Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Builder(builder: (context) {
          Services.context = context;
          return new SingleChildScrollView(
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
                              labelText: SpotL.of(context).firstname,
                              hintText: SpotL.of(context).firstnamePh),
                          controller: _name,
                          validator: validateName,
                        ),
                        new TextFormField(
                          key: const Key('lastname'),
                          decoration: new InputDecoration(
                              labelText: SpotL.of(context).lastname,
                              hintText: SpotL.of(context).lastnamePh),
                          controller: _lastname,
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: new InputDecoration(
                            labelText: SpotL.of(context).email,
                            hintText: SpotL.of(context).emailPh,
                          ),
                          controller: _email,
                          validator: validateEmail,
                        ),
                        new TextFormField(
                          key: const Key('password'),
                          decoration: new InputDecoration(
                            labelText: SpotL.of(context).password,
                            hintText: SpotL.of(context).passwordPh,
                          ),
                          obscureText: true,
                          controller: _password,
                          validator: validatePassword,
                        ),
                        new TextFormField(
                          key: const Key('repeat'),
                          decoration: new InputDecoration(
                            labelText: SpotL.of(context).passwordRepeat,
                            hintText: SpotL.of(context).passwordRepeatPh,
                          ),
                          controller: _repeat,
                          obscureText: true,
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new RaisedButton(
                              child: new Text(SpotL.of(context).haveAccount),
                              onPressed: () =>
                                  Navigator.pushReplacementNamed(context, '/'),
                            ),
                            const Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                            ),
                            new RaisedButton(
                              child: new Text(SpotL.of(context).register),
                              onPressed: () => _doRegister(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
}
