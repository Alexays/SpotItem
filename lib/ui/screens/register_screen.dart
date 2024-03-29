import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Register screen class
class RegisterScreen extends StatefulWidget {
  /// Contact screen initalizer
  const RegisterScreen();

  @override
  State createState() => new _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  _RegisterScreenState();

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
      'email': _email.text.toLowerCase(),
      'password': _password.text,
    });
    if (!resValid(context, res)) {
      return;
    }
    await showDialog<Null>(
      context: context,
      child: new SimpleDialog(children: [
        new Container(
          padding: const EdgeInsets.all(20.0),
          child: new Text(SpotL.of(context).emailConfirmation),
        ),
      ]),
    );
    await Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Builder(builder: (context) {
          Services.context = context;
          return new ListView(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: new Image.asset(
                  'assets/logo.png',
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: new Form(
                  key: _formKey,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new TextFormField(
                        key: const Key('name'),
                        decoration: new InputDecoration(
                          labelText: SpotL.of(context).firstname,
                          hintText: SpotL.of(context).firstnamePh,
                        ),
                        controller: _name,
                        validator: validateName,
                      ),
                      new TextFormField(
                        key: const Key('lastname'),
                        decoration: new InputDecoration(
                          labelText: SpotL.of(context).lastname,
                          hintText: SpotL.of(context).lastnamePh,
                        ),
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
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        persistentFooterButtons: [
          new FlatButton(
            child: new Text(SpotL.of(context).haveAccount),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
        bottomNavigationBar: new ConstrainedBox(
          constraints: new BoxConstraints.tightFor(
            height: 48.0,
            width: MediaQuery.of(context).size.width,
          ),
          child: new Builder(
            builder: (context) => new RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed: () => _doRegister(context),
                  child: new Text(
                    SpotL.of(context).register.toUpperCase(),
                    style: new TextStyle(
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ),
          ),
        ),
      );
}
